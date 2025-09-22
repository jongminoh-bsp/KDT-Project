#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CLUSTER_NAME="skyline-dev-cluster"
REGION="ap-northeast-2"
ECR_REPO="646558765106.dkr.ecr.ap-northeast-2.amazonaws.com/skyline-dev"
NAMESPACE="skyline"

echo -e "${BLUE}🚀 Starting Skyline Application Deployment${NC}"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo -e "${YELLOW}📋 Checking prerequisites...${NC}"
for cmd in kubectl aws docker; do
    if ! command_exists $cmd; then
        echo -e "${RED}❌ $cmd is not installed${NC}"
        exit 1
    fi
done
echo -e "${GREEN}✅ All prerequisites met${NC}"

# Update kubeconfig
echo -e "${YELLOW}🔧 Updating kubeconfig...${NC}"
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME
echo -e "${GREEN}✅ Kubeconfig updated${NC}"

# Verify cluster connection
echo -e "${YELLOW}🔍 Verifying cluster connection...${NC}"
kubectl cluster-info
kubectl get nodes
echo -e "${GREEN}✅ Cluster connection verified${NC}"

# Install AWS Load Balancer Controller (if not exists)
echo -e "${YELLOW}🔧 Checking AWS Load Balancer Controller...${NC}"
if ! kubectl get deployment -n kube-system aws-load-balancer-controller >/dev/null 2>&1; then
    echo -e "${YELLOW}📦 Installing AWS Load Balancer Controller...${NC}"
    
    # Create IAM role for AWS Load Balancer Controller
    curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json
    
    aws iam create-policy \
        --policy-name AWSLoadBalancerControllerIAMPolicy \
        --policy-document file://iam_policy.json || true
    
    # Create service account
    eksctl create iamserviceaccount \
        --cluster=$CLUSTER_NAME \
        --namespace=kube-system \
        --name=aws-load-balancer-controller \
        --role-name AmazonEKSLoadBalancerControllerRole \
        --attach-policy-arn=arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/AWSLoadBalancerControllerIAMPolicy \
        --approve || true
    
    # Install controller using Helm
    helm repo add eks https://aws.github.io/eks-charts
    helm repo update
    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
        -n kube-system \
        --set clusterName=$CLUSTER_NAME \
        --set serviceAccount.create=false \
        --set serviceAccount.name=aws-load-balancer-controller || true
    
    rm -f iam_policy.json
    echo -e "${GREEN}✅ AWS Load Balancer Controller installed${NC}"
else
    echo -e "${GREEN}✅ AWS Load Balancer Controller already exists${NC}"
fi

# Get RDS password from Secrets Manager
echo -e "${YELLOW}🔐 Retrieving database credentials...${NC}"
DB_PASSWORD=$(aws secretsmanager get-secret-value \
    --secret-id skyline-dev-db-credentials \
    --region $REGION \
    --query SecretString --output text | jq -r .password)

if [ -z "$DB_PASSWORD" ]; then
    echo -e "${RED}❌ Failed to retrieve database password${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Database credentials retrieved${NC}"

# Update secret with actual password
echo -e "${YELLOW}🔧 Updating Kubernetes secret with database password...${NC}"
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic skyline-db-secret \
    --namespace=$NAMESPACE \
    --from-literal=DB_HOST=skyline-dev-db.c5d2wfqufspp.ap-northeast-2.rds.amazonaws.com \
    --from-literal=DB_PORT=3306 \
    --from-literal=DB_NAME=skyline \
    --from-literal=DB_USER=skyline_user \
    --from-literal=DB_PASSWORD="$DB_PASSWORD" \
    --dry-run=client -o yaml | kubectl apply -f -

echo -e "${GREEN}✅ Database secret updated${NC}"

# Deploy application using Kustomize
echo -e "${YELLOW}🚀 Deploying Skyline application...${NC}"
kubectl apply -k overlays/dev/

# Wait for deployment to be ready
echo -e "${YELLOW}⏳ Waiting for deployment to be ready...${NC}"
kubectl wait --for=condition=available --timeout=300s deployment/skyline-app -n $NAMESPACE

# Get deployment status
echo -e "${YELLOW}📊 Checking deployment status...${NC}"
kubectl get pods -n $NAMESPACE
kubectl get services -n $NAMESPACE
kubectl get ingress -n $NAMESPACE

# Get Load Balancer URL
echo -e "${YELLOW}🌐 Getting application URL...${NC}"
sleep 30  # Wait for ALB to be provisioned
ALB_URL=$(kubectl get ingress skyline-ingress -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

if [ -n "$ALB_URL" ]; then
    echo -e "${GREEN}✅ Application deployed successfully!${NC}"
    echo -e "${BLUE}🌐 Application URL: http://$ALB_URL${NC}"
    echo -e "${BLUE}📊 Health Check: http://$ALB_URL/health${NC}"
    echo -e "${BLUE}📈 Metrics: http://$ALB_URL/metrics${NC}"
else
    echo -e "${YELLOW}⏳ Load Balancer is still being provisioned. Check again in a few minutes:${NC}"
    echo -e "${BLUE}kubectl get ingress skyline-ingress -n $NAMESPACE${NC}"
fi

echo -e "${GREEN}🎉 Deployment completed!${NC}"
