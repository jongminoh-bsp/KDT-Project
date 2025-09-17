# 작업 리포트 #003: 네이밍 컨벤션 통일

## 📋 작업 정보
- **작업일**: 2025-09-17
- **브랜치**: `feature/naming-convention-standardization`
- **담당자**: Q Developer + 사용자
- **우선순위**: Medium

## 🎯 작업 목표
인프라 리소스 네이밍 컨벤션 표준화 및 일관성 확보

## 🔍 발견된 문제점

### 1. 혼재된 네이밍 패턴
```hcl
# 기존 문제점들
Name = "ojm-vpc"                    # 개인명 포함
Name = "public-snt-a"               # 약어 사용
Name = "mgmt-sg"                    # 일관성 없음
Name = "private-qdev-snt"           # 환경 구분 없음
```

### 2. 태깅 전략 부재
- 공통 태그 없음
- 리소스 목적 불분명
- 환경별 구분 어려움

## ✅ 구현된 해결책

### 1. 표준 네이밍 컨벤션 정의
**패턴**: `{project}-{environment}-{resource-type}-{identifier}`

```hcl
# 예시
kdt-dev-vpc
kdt-dev-public-subnet-1
kdt-dev-management-sg
kdt-dev-nodegroup-sg
```

### 2. 공통 변수 및 로컬 값 추가
```hcl
# variables.tf
variable "project" {
  default = "kdt"
}
variable "environment" {
  default = "dev"
}

# locals.tf
locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "kdt-team"
  }
}
```

### 3. 향상된 태깅 전략
```hcl
tags = merge(var.common_tags, {
  Name    = "${var.name_prefix}-vpc"
  Type    = "network"
  Purpose = "infrastructure"
})
```

## 📊 변경 사항 요약
```
9 files changed, 186 insertions(+), 80 deletions(-)
```

### 주요 변경 파일
- **variables.tf**: project, environment 변수 추가
- **locals.tf**: name_prefix, common_tags 로직 추가
- **terraform.tfvars**: 프로젝트 정보 업데이트
- **modules/network/**: 모든 네트워크 리소스 네이밍 표준화
- **modules/sg/**: 보안 그룹 네이밍 및 설명 개선
- **modules/ec2/**: EC2 인스턴스 네이밍 표준화

### Before vs After 비교

| 리소스 타입 | Before | After |
|------------|--------|-------|
| VPC | `ojm-vpc` | `kdt-dev-vpc` |
| Subnet | `public-snt-a` | `kdt-dev-public-subnet-1` |
| Security Group | `mgmt-sg` | `kdt-dev-management-sg` |
| EC2 Instance | `ojm-mgmt` | `kdt-dev-management-instance` |

## 🚀 개선 효과

### 1. 운영 효율성
- **리소스 식별**: 환경과 목적이 명확한 네이밍
- **비용 추적**: 프로젝트/환경별 태그 기반 분석
- **자동화**: 일관된 패턴으로 스크립트 작성 용이

### 2. 확장성
- **다중 환경**: dev, stag, prod 환경 구분 가능
- **다중 프로젝트**: 프로젝트별 리소스 분리
- **팀 협업**: 표준화된 네이밍으로 혼선 방지

### 3. 보안 및 거버넌스
- **권한 관리**: 태그 기반 IAM 정책 적용 가능
- **규정 준수**: 기업 네이밍 표준 준수
- **감사**: 리소스 추적 및 관리 용이

## 📝 후속 작업
1. **다른 환경 적용**: staging, production 환경에 동일한 패턴 적용
2. **RDS 모듈 완성**: 데이터베이스 네이밍 표준화 완료
3. **EKS 모듈 검토**: 클러스터 및 노드 그룹 네이밍 확인
4. **출력값 추가**: 표준화된 리소스 정보 출력

## 💡 학습 포인트
- Terraform 변수 및 로컬 값 활용
- 모듈 간 일관된 네이밍 전략 구현
- 태그 기반 리소스 관리 베스트 프랙티스
- 확장 가능한 인프라 코드 설계 원칙

## 🔄 네이밍 컨벤션 가이드
```
리소스 네이밍 패턴:
{project}-{environment}-{resource-type}-{identifier}

태그 전략:
- Name: 리소스 식별명
- Project: 프로젝트명
- Environment: 환경명 (dev/stag/prod)
- Purpose: 리소스 목적
- Type: 리소스 유형
- ManagedBy: terraform
```
