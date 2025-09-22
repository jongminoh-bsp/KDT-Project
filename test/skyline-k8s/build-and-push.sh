#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ECR_REPO="646558765106.dkr.ecr.ap-northeast-2.amazonaws.com/skyline-dev"
REGION="ap-northeast-2"
SOURCE_DIR="/home/ojm/skyline_system_demo"
TAG="latest"

echo -e "${BLUE}🐳 Building and pushing Skyline Docker image${NC}"

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}❌ Source directory not found: $SOURCE_DIR${NC}"
    exit 1
fi

# Login to ECR
echo -e "${YELLOW}🔐 Logging in to ECR...${NC}"
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_REPO
echo -e "${GREEN}✅ ECR login successful${NC}"

# Build Docker image
echo -e "${YELLOW}🔨 Building Docker image...${NC}"
cd $SOURCE_DIR
docker build -t skyline:$TAG .
echo -e "${GREEN}✅ Docker image built successfully${NC}"

# Tag image for ECR
echo -e "${YELLOW}🏷️ Tagging image for ECR...${NC}"
docker tag skyline:$TAG $ECR_REPO:$TAG
docker tag skyline:$TAG $ECR_REPO:dev-latest
echo -e "${GREEN}✅ Image tagged successfully${NC}"

# Push image to ECR
echo -e "${YELLOW}📤 Pushing image to ECR...${NC}"
docker push $ECR_REPO:$TAG
docker push $ECR_REPO:dev-latest
echo -e "${GREEN}✅ Image pushed successfully${NC}"

# Clean up local images
echo -e "${YELLOW}🧹 Cleaning up local images...${NC}"
docker rmi skyline:$TAG || true
echo -e "${GREEN}✅ Cleanup completed${NC}"

echo -e "${GREEN}🎉 Build and push completed successfully!${NC}"
echo -e "${BLUE}📦 Image: $ECR_REPO:$TAG${NC}"
