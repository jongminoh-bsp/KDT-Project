# 작업 리포트 #006: EKS 접근 권한 문제 해결

## 📋 작업 정보
- **작업일**: 2025-09-17
- **브랜치**: `feature/eks-access-permission-fix`
- **담당자**: Q Developer + 사용자
- **우선순위**: High
- **카테고리**: Security

## 🎯 작업 목표
EKS 클러스터 생성 후 AWS 콘솔에서 접근 권한 오류 문제 해결

## 🔍 발견된 문제점

### 오류 메시지
```
Your current IAM principal doesn't have access to Kubernetes objects on this cluster.
This might be due to the current principal not having an IAM access entry with permissions to access the cluster.
```

### 문제 원인 분석
1. **EKS Access Entry 누락**: Terraform으로 생성 시 명시적 접근 권한 미설정
2. **IAM 권한 불충분**: 클러스터 생성자 권한이 자동으로 부여되지 않음
3. **kubeconfig 미설정**: kubectl 접근을 위한 설정 누락

## ✅ 구현된 해결책

### 1. EKS 모듈에 명시적 접근 권한 추가
```hcl
# EKS Access Entries for additional users/roles
access_entries = {
  cluster_creator = {
    kubernetes_groups = []
    principal_arn     = data.aws_caller_identity.current.arn
    policy_associations = {
      admin = {
        policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
        access_scope = {
          type = "cluster"
        }
      }
    }
  }
}
```

### 2. 클러스터 로깅 활성화
```hcl
# Enable EKS Cluster access logging
cluster_enabled_log_types = ["api", "audit", "authenticator"]
```

### 3. 노드 그룹 보안 강화
```hcl
eks_managed_node_groups = {
  "${var.cluster_name}-node" = {
    # ... 기존 설정 ...
    
    # Enable IMDSv2 for better security
    metadata_options = {
      http_endpoint = "enabled"
      http_tokens   = "required"
      http_put_response_hop_limit = 2
    }
  }
}
```

### 4. EKS 접근 설정 자동화 스크립트
```bash
# scripts/setup-eks-access.sh
./setup-eks-access.sh kdt-dev-eks-cluster ap-northeast-2

# 기능:
- kubeconfig 자동 업데이트
- 클러스터 접근 테스트
- 접근 권한 진단
- 문제 해결 가이드 제공
```

## 📊 변경 사항 요약

### 수정된 파일
```
infra/dev/terraform/modules/eks/main.tf: 접근 권한 및 보안 설정 강화
scripts/setup-eks-access.sh: EKS 접근 설정 자동화 스크립트 신규 생성
```

### 추가된 보안 기능
- **명시적 접근 권한**: cluster creator에게 admin 권한 자동 부여
- **접근 로깅**: API, audit, authenticator 로그 활성화
- **IMDSv2 강제**: 노드 그룹에서 메타데이터 보안 강화
- **자동화 스크립트**: 접근 설정 및 문제 진단 자동화

## 🚀 사용법

### 1. Terraform 적용 후 접근 설정
```bash
# 1. 인프라 배포
terraform apply

# 2. EKS 접근 설정
./scripts/setup-eks-access.sh kdt-dev-eks-cluster

# 3. 클러스터 접근 테스트
kubectl get nodes
kubectl get namespaces
```

### 2. 수동 접근 권한 추가 (필요시)
```bash
# 현재 IAM 사용자 ARN 확인
aws sts get-caller-identity

# 접근 엔트리 생성
aws eks create-access-entry \
  --cluster-name kdt-dev-eks-cluster \
  --principal-arn arn:aws:iam::123456789012:user/username

# 관리자 정책 연결
aws eks associate-access-policy \
  --cluster-name kdt-dev-eks-cluster \
  --principal-arn arn:aws:iam::123456789012:user/username \
  --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy \
  --access-scope type=cluster
```

## 🔒 보안 개선 효과

### 접근 제어 강화
- **명시적 권한 관리**: 클러스터 접근 권한 명확화
- **최소 권한 원칙**: 필요한 권한만 부여
- **감사 로깅**: 모든 접근 시도 기록

### 운영 효율성
- **자동화된 설정**: 스크립트를 통한 일관된 설정
- **문제 진단**: 접근 문제 자동 진단 및 해결 가이드
- **표준화**: 팀 내 일관된 EKS 접근 방법

## 📝 후속 작업

### 단기 계획
1. **RBAC 설정**: Kubernetes 내부 권한 관리 세분화
2. **다중 사용자 지원**: 팀원별 접근 권한 설정
3. **네임스페이스 권한**: 환경별 접근 권한 분리

### 장기 계획
1. **OIDC 통합**: 외부 인증 시스템 연동
2. **접근 모니터링**: 클러스터 접근 패턴 분석
3. **자동 권한 관리**: GitOps 기반 권한 관리

## 💡 학습 포인트

### EKS 접근 제어
- EKS Access Entry vs ConfigMap 방식 차이점
- IAM과 Kubernetes RBAC 연동 방법
- 클러스터 생성자 권한의 특수성

### 보안 베스트 프랙티스
- 최소 권한 원칙 적용
- 접근 로깅 및 모니터링 중요성
- IMDSv2 강제 사용의 보안 이점

### 운영 자동화
- 스크립트를 통한 일관된 설정 관리
- 문제 진단 자동화의 효율성
- 문서화된 문제 해결 프로세스

## 🔧 기술적 세부사항

### EKS Access Entry 방식
- **신규 방식**: EKS v1.23+ 권장 접근 제어 방법
- **기존 ConfigMap 방식 대체**: 더 안전하고 관리하기 쉬움
- **IAM 통합**: AWS IAM과 직접 연동

### 스크립트 안정성
- **에러 핸들링**: 각 단계별 오류 검증
- **의존성 체크**: AWS CLI, kubectl 존재 여부 확인
- **상세 진단**: 문제 발생 시 구체적인 해결 방법 제시

이제 EKS 클러스터에 안전하고 편리하게 접근할 수 있습니다!
