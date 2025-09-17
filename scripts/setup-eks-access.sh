#!/bin/bash

# EKS Cluster Access Setup Script
# Usage: ./setup-eks-access.sh <cluster-name> [region]

set -e

CLUSTER_NAME=${1:-""}
REGION=${2:-${AWS_DEFAULT_REGION:-"ap-northeast-2"}}

if [ -z "$CLUSTER_NAME" ]; then
    echo "Usage: $0 <cluster-name> [region]"
    echo "Example: $0 kdt-dev-eks-cluster ap-northeast-2"
    exit 1
fi

echo "🔧 Setting up EKS cluster access..."
echo "📍 Cluster: $CLUSTER_NAME"
echo "📍 Region: $REGION"
echo "----------------------------------------"

# Function to check if AWS CLI is available
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        echo "❌ AWS CLI not found. Please install AWS CLI first."
        exit 1
    fi
}

# Function to check if kubectl is available
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        echo "❌ kubectl not found. Please install kubectl first."
        echo "💡 Install guide: https://kubernetes.io/docs/tasks/tools/"
        exit 1
    fi
}

# Function to update kubeconfig
update_kubeconfig() {
    echo "🔄 Updating kubeconfig..."
    
    aws eks update-kubeconfig \
        --region "$REGION" \
        --name "$CLUSTER_NAME" \
        --alias "$CLUSTER_NAME"
    
    if [ $? -eq 0 ]; then
        echo "✅ Kubeconfig updated successfully"
    else
        echo "❌ Failed to update kubeconfig"
        exit 1
    fi
}

# Function to test cluster access
test_cluster_access() {
    echo "🧪 Testing cluster access..."
    
    # Test basic connectivity
    if kubectl cluster-info --context="$CLUSTER_NAME" &> /dev/null; then
        echo "✅ Cluster connectivity: OK"
    else
        echo "⚠️  Cluster connectivity: Failed"
        echo "💡 This might be due to network or permission issues"
    fi
    
    # Test node access
    if kubectl get nodes --context="$CLUSTER_NAME" &> /dev/null; then
        echo "✅ Node access: OK"
        kubectl get nodes --context="$CLUSTER_NAME"
    else
        echo "⚠️  Node access: Failed"
        echo "💡 Check IAM permissions and access entries"
    fi
    
    # Test namespace access
    if kubectl get namespaces --context="$CLUSTER_NAME" &> /dev/null; then
        echo "✅ Namespace access: OK"
    else
        echo "⚠️  Namespace access: Failed"
    fi
}

# Function to show current AWS identity
show_aws_identity() {
    echo "👤 Current AWS Identity:"
    aws sts get-caller-identity --output table
    echo ""
}

# Function to check EKS access entries
check_access_entries() {
    echo "🔐 Checking EKS Access Entries..."
    
    local access_entries=$(aws eks list-access-entries \
        --cluster-name "$CLUSTER_NAME" \
        --region "$REGION" \
        --output table 2>/dev/null)
    
    if [ -n "$access_entries" ]; then
        echo "$access_entries"
    else
        echo "⚠️  No access entries found or permission denied"
    fi
    echo ""
}

# Function to provide troubleshooting tips
show_troubleshooting_tips() {
    echo "🔧 Troubleshooting Tips:"
    echo "----------------------------------------"
    echo "1. Verify IAM permissions:"
    echo "   - eks:DescribeCluster"
    echo "   - eks:ListAccessEntries"
    echo "   - eks:DescribeAccessEntry"
    echo ""
    echo "2. Check if you're the cluster creator:"
    echo "   aws eks describe-cluster --name $CLUSTER_NAME --region $REGION"
    echo ""
    echo "3. Add access entry manually if needed:"
    echo "   aws eks create-access-entry \\"
    echo "     --cluster-name $CLUSTER_NAME \\"
    echo "     --principal-arn <your-iam-arn> \\"
    echo "     --region $REGION"
    echo ""
    echo "4. Associate admin policy:"
    echo "   aws eks associate-access-policy \\"
    echo "     --cluster-name $CLUSTER_NAME \\"
    echo "     --principal-arn <your-iam-arn> \\"
    echo "     --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy \\"
    echo "     --access-scope type=cluster \\"
    echo "     --region $REGION"
}

# Main execution
main() {
    check_aws_cli
    check_kubectl
    
    show_aws_identity
    check_access_entries
    update_kubeconfig
    echo ""
    test_cluster_access
    echo ""
    show_troubleshooting_tips
}

# Run main function
main
