# Skyline Infrastructure

Skyline 항공예약시스템을 위한 AWS 인프라 Terraform 코드입니다.

## 📋 인프라 구성

### 주요 리소스
- **VPC**: 10.0.0.0/16 CIDR, 2개 AZ에 걸친 Public/Private 서브넷
- **EKS**: Kubernetes 1.28 클러스터 + 관리형 노드그룹
- **RDS**: MySQL 8.0 (Multi-AZ 지원)
- **ECR**: Docker 이미지 저장소
- **Security Groups**: 최소 권한 원칙 적용

### 모듈 구조
```
modules/
├── vpc/     # VPC, 서브넷, NAT Gateway, Route Table
├── eks/     # EKS 클러스터, 노드그룹, IAM 역할
├── rds/     # RDS MySQL, 보안그룹, Secrets Manager
└── ecr/     # ECR 리포지토리, 라이프사이클 정책
```

## 🚀 배포 방법

### 1. 사전 준비
```bash
# AWS CLI 설정
aws configure

# Terraform 초기화
terraform init
```

### 2. 개발 환경 배포
```bash
# 계획 확인
terraform plan -var-file="environments/dev/terraform.tfvars"

# 배포 실행
terraform apply -var-file="environments/dev/terraform.tfvars"
```

### 3. 배포 후 설정
```bash
# EKS 클러스터 접근 설정
aws eks update-kubeconfig --region ap-northeast-2 --name skyline-dev-cluster

# 클러스터 상태 확인
kubectl get nodes
```

## 📊 출력 정보

배포 완료 후 다음 정보들이 출력됩니다:
- `vpc_id`: VPC ID
- `eks_cluster_name`: EKS 클러스터 이름
- `eks_cluster_endpoint`: EKS API 서버 엔드포인트
- `rds_endpoint`: RDS MySQL 엔드포인트
- `ecr_repository_url`: ECR 리포지토리 URL

## 🔧 환경별 설정

### 개발 환경 (dev)
- EKS 노드: t3.medium × 2개
- RDS: db.t3.micro (단일 AZ)
- 비용 최적화 우선

### 운영 환경 (prod) - 추후 추가 예정
- EKS 노드: t3.large × 3개 이상
- RDS: db.r5.large (Multi-AZ)
- 고가용성 및 성능 우선

## 🔒 보안 고려사항

- RDS 비밀번호는 Secrets Manager에서 자동 생성/관리
- EKS 노드는 Private 서브넷에 배치
- 보안그룹은 최소 권한 원칙 적용
- 모든 리소스에 암호화 적용

## 💰 비용 예상 (월간, 서울 리전 기준)

### 개발 환경
- EKS 클러스터: $73
- EC2 (t3.medium × 2): $60
- RDS (db.t3.micro): $15
- NAT Gateway: $45
- **총 예상 비용: ~$193/월**

## 🚨 주의사항

1. **State 파일 관리**: S3 백엔드 설정 필요
2. **리소스 정리**: 불필요한 비용 방지를 위해 `terraform destroy` 실행
3. **권한 관리**: 적절한 IAM 권한 설정 필요

## 📝 다음 단계

1. Kubernetes 매니페스트 작성
2. CI/CD 파이프라인 구성
3. 모니터링 및 로깅 설정
4. 운영 환경 구성 추가
