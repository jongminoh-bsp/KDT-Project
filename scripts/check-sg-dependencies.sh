#!/bin/bash

# Security Group Dependencies Checker
# Usage: ./check-sg-dependencies.sh [security-group-id]

set -e

SG_ID=${1:-""}
REGION=${AWS_DEFAULT_REGION:-"ap-northeast-2"}

if [ -z "$SG_ID" ]; then
    echo "Usage: $0 <security-group-id>"
    echo "Example: $0 sg-0123456789abcdef0"
    exit 1
fi

echo "🔍 Checking dependencies for Security Group: $SG_ID"
echo "📍 Region: $REGION"
echo "----------------------------------------"

# Function to check if AWS CLI is available
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        echo "❌ AWS CLI not found. Please install AWS CLI first."
        exit 1
    fi
}

# Function to check network interfaces
check_network_interfaces() {
    echo "🔌 Checking Network Interfaces..."
    
    local enis=$(aws ec2 describe-network-interfaces \
        --region "$REGION" \
        --filters "Name=group-id,Values=$SG_ID" \
        --query 'NetworkInterfaces[*].{ID:NetworkInterfaceId,Status:Status,Type:InterfaceType,Description:Description}' \
        --output table 2>/dev/null)
    
    if [ -n "$enis" ] && [ "$enis" != "[]" ]; then
        echo "⚠️  Found attached Network Interfaces:"
        echo "$enis"
        return 1
    else
        echo "✅ No Network Interfaces found"
        return 0
    fi
}

# Function to check EC2 instances
check_ec2_instances() {
    echo "🖥️  Checking EC2 Instances..."
    
    local instances=$(aws ec2 describe-instances \
        --region "$REGION" \
        --filters "Name=instance.group-id,Values=$SG_ID" \
        --query 'Reservations[*].Instances[*].{ID:InstanceId,State:State.Name,Type:InstanceType,Name:Tags[?Key==`Name`].Value|[0]}' \
        --output table 2>/dev/null)
    
    if [ -n "$instances" ] && [ "$instances" != "[]" ]; then
        echo "⚠️  Found EC2 Instances using this Security Group:"
        echo "$instances"
        return 1
    else
        echo "✅ No EC2 Instances found"
        return 0
    fi
}

# Function to check RDS instances
check_rds_instances() {
    echo "🗄️  Checking RDS Instances..."
    
    local rds_instances=$(aws rds describe-db-instances \
        --region "$REGION" \
        --query "DBInstances[?VpcSecurityGroups[?VpcSecurityGroupId=='$SG_ID']].{ID:DBInstanceIdentifier,Status:DBInstanceStatus,Engine:Engine}" \
        --output table 2>/dev/null)
    
    if [ -n "$rds_instances" ] && [ "$rds_instances" != "[]" ]; then
        echo "⚠️  Found RDS Instances using this Security Group:"
        echo "$rds_instances"
        return 1
    else
        echo "✅ No RDS Instances found"
        return 0
    fi
}

# Function to check Lambda functions
check_lambda_functions() {
    echo "⚡ Checking Lambda Functions..."
    
    # Lambda functions don't directly reference security groups in describe-functions
    # They're associated through VPC configuration
    local lambda_functions=$(aws lambda list-functions \
        --region "$REGION" \
        --query 'Functions[?VpcConfig.SecurityGroupIds && contains(VpcConfig.SecurityGroupIds, `'$SG_ID'`)].{Name:FunctionName,Runtime:Runtime}' \
        --output table 2>/dev/null)
    
    if [ -n "$lambda_functions" ] && [ "$lambda_functions" != "[]" ]; then
        echo "⚠️  Found Lambda Functions using this Security Group:"
        echo "$lambda_functions"
        return 1
    else
        echo "✅ No Lambda Functions found"
        return 0
    fi
}

# Function to check EKS clusters
check_eks_clusters() {
    echo "☸️  Checking EKS Clusters..."
    
    local clusters=$(aws eks list-clusters \
        --region "$REGION" \
        --query 'clusters' \
        --output text 2>/dev/null)
    
    local found_clusters=""
    for cluster in $clusters; do
        local cluster_sg=$(aws eks describe-cluster \
            --region "$REGION" \
            --name "$cluster" \
            --query "cluster.resourcesVpcConfig.securityGroupIds[?@ == '$SG_ID']" \
            --output text 2>/dev/null)
        
        if [ -n "$cluster_sg" ]; then
            found_clusters="$found_clusters $cluster"
        fi
    done
    
    if [ -n "$found_clusters" ]; then
        echo "⚠️  Found EKS Clusters using this Security Group:"
        echo "$found_clusters"
        return 1
    else
        echo "✅ No EKS Clusters found"
        return 0
    fi
}

# Main execution
main() {
    check_aws_cli
    
    local has_dependencies=0
    
    check_network_interfaces || has_dependencies=1
    echo ""
    
    check_ec2_instances || has_dependencies=1
    echo ""
    
    check_rds_instances || has_dependencies=1
    echo ""
    
    check_lambda_functions || has_dependencies=1
    echo ""
    
    check_eks_clusters || has_dependencies=1
    echo ""
    
    echo "----------------------------------------"
    if [ $has_dependencies -eq 0 ]; then
        echo "✅ Security Group $SG_ID is safe to delete"
        echo "🚀 No dependencies found"
        exit 0
    else
        echo "❌ Security Group $SG_ID has dependencies"
        echo "⚠️  Please remove dependencies before deletion"
        exit 1
    fi
}

# Run main function
main
