# 인프라 구축 가이드

## 🎯 개요

AWS EKS 기반 인프라를 Terraform으로 자동 구축하는 과정을 설명합니다.

## 📋 사전 요구사항

- AWS CLI 설정 완료
- Terraform 설치
- kubectl 설치
- eksctl 설치

## 🏗️ 인프라 아키텍처

```
┌─────────────────────────────────────────────────────────┐
│                        VPC                              │
│  ┌─────────────────┐    ┌─────────────────────────────┐ │
│  │   Public Subnet │    │      Private Subnet         │ │
│  │                 │    │                             │ │
│  │  ┌─────────────┐│    │  ┌─────────────────────────┐│ │
│  │  │     NAT     ││    │  │      EKS Cluster        ││ │
│  │  │   Gateway   ││    │  │                         ││ │
│  │  └─────────────┘│    │  │  ┌─────────────────────┐││ │
│  │                 │    │  │  │    Worker Nodes     │││ │
│  │  ┌─────────────┐│    │  │  └─────────────────────┘││ │
│  │  │ Internet    ││    │  └─────────────────────────┘│ │
│  │  │ Gateway     ││    │                             │ │
│  │  └─────────────┘│    │  ┌─────────────────────────┐│ │
│  └─────────────────┘    │  │         RDS             ││ │
│                         │  │      (MySQL)            ││ │
│                         │  └─────────────────────────┘│ │
│                         └─────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

## 🚀 1단계: Terraform 코드 자동 생성

### 1.1 프로젝트 구조 생성

```bash
mkdir -p terraform/{modules,environments/dev}
cd terraform
```

### 1.2 자동 생성된 주요 모듈

#### VPC 모듈 (`modules/vpc/`)
- **파일**: `main.tf`, `variables.tf`, `outputs.tf`
- **리소스**: VPC, Subnets, IGW, NAT Gateway, Route Tables
- **특징**: Multi-AZ 구성, Public/Private 서브넷 분리

#### EKS 모듈 (`modules/eks/`)
- **파일**: `main.tf`, `variables.tf`, `outputs.tf`
- **리소스**: EKS Cluster, Node Groups, IAM Roles
- **특징**: Managed Node Groups, Auto Scaling 지원

#### RDS 모듈 (`modules/rds/`)
- **파일**: `main.tf`, `variables.tf`, `outputs.tf`
- **리소스**: RDS Instance, Subnet Group, Parameter Group
- **특징**: MySQL 8.0, Multi-AZ 배포

#### EC2 모듈 (`modules/ec2/`)
- **파일**: `main.tf`, `variables.tf`, `outputs.tf`
- **리소스**: Management Instance, Q-Dev Instance
- **특징**: 개발 및 관리용 인스턴스

## 🔧 2단계: 인프라 배포

### 2.1 환경 설정

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

### 2.2 배포 결과 확인

```bash
# EKS 클러스터 연결
aws eks update-kubeconfig --region ap-northeast-2 --name skyline-dev-cluster

# 노드 상태 확인
kubectl get nodes

# RDS 엔드포인트 확인
terraform output rds_endpoint
```

## 📊 생성된 리소스 목록

### 네트워킹
- ✅ VPC: `10.0.0.0/16`
- ✅ Public Subnets: `10.0.1.0/24`, `10.0.2.0/24`
- ✅ Private Subnets: `10.0.10.0/24`, `10.0.11.0/24`
- ✅ Internet Gateway
- ✅ NAT Gateway (Multi-AZ)

### 컴퓨팅
- ✅ EKS Cluster: `skyline-dev-cluster`
- ✅ Worker Nodes: `t3.medium` (2-4 nodes)
- ✅ Management EC2: `t3.micro`
- ✅ Q-Dev EC2: `t3.micro`

### 데이터베이스
- ✅ RDS MySQL 8.0
- ✅ Multi-AZ 배포
- ✅ 자동 백업 설정

### 보안
- ✅ Security Groups (EKS, RDS, EC2)
- ✅ IAM Roles (EKS Service, Node Group)
- ✅ VPC Endpoints (ECR, S3)

## 🔍 트러블슈팅

### 일반적인 문제들

1. **EKS 노드 그룹 생성 실패**
   - IAM 역할 권한 확인
   - 서브넷 가용성 확인

2. **RDS 연결 실패**
   - 보안 그룹 규칙 확인
   - 서브넷 그룹 설정 확인

3. **Terraform 상태 충돌**
   - 상태 파일 잠금 해제
   - 리소스 import 필요시 수행

## 📝 다음 단계

인프라 구축 완료 후 [애플리케이션 배포](../application/) 단계로 진행합니다.
