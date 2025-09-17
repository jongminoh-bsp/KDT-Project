# 작업 리포트 #004: 인프라 리소스 정리

## 📋 작업 정보
- **작업일**: 2025-09-17
- **브랜치**: `feature/infrastructure-cleanup`
- **담당자**: Q Developer + 사용자
- **우선순위**: High

## 🎯 작업 목표
기존 Terraform 관리 리소스 전체 정리 및 깨끗한 상태 구축

## 🔍 정리 전 상황

### Terraform 관리 리소스 (57개)
```bash
# 주요 리소스들
- EKS 클러스터 (ojm-cluster)
- EKS 노드 그룹 (ojm-node)
- EC2 인스턴스 2개 (mgmt, q-dev)
- RDS 인스턴스 (MySQL)
- VPC 및 네트워킹 리소스
- 보안 그룹 5개
- IAM 역할 및 정책
- KMS 키
- CloudWatch 로그 그룹
- Secrets Manager
```

### 예상 월 비용
- **EKS 클러스터**: ~$73/월
- **EC2 인스턴스**: ~$30/월
- **RDS**: ~$15/월
- **기타**: ~$10/월
- **총 예상**: ~$128/월

## ✅ 수행된 작업

### 1. 리소스 삭제 과정
```bash
# 1단계: 전체 리소스 삭제 시도
terraform destroy -auto-approve

# 2단계: EKS 노드 그룹 의존성 문제 해결
# - 노드 그룹이 연결된 클러스터 삭제 실패
# - 수동으로 EKS 모듈 타겟 삭제

# 3단계: 남은 리소스 정리
terraform destroy -auto-approve -target=module.eks
terraform destroy -auto-approve
```

### 2. 삭제된 리소스 목록

#### 네트워크 리소스
- VPC (vpc-0b7007e48d2aea8f8)
- 서브넷 6개 (public, private-mgmt, private-ng, private-rds, private-qdev)
- 인터넷 게이트웨이
- NAT 게이트웨이 및 EIP
- 라우팅 테이블 5개

#### 컴퓨팅 리소스
- EKS 클러스터 (ojm-cluster)
- EKS 노드 그룹 (ojm-node)
- EC2 인스턴스 2개 (i-07b4157b33b895577, i-09c6b75119638efac)
- Launch Template

#### 보안 리소스
- 보안 그룹 5개 (mgmt, ng, cluster, rds, qdev)
- IAM 역할 및 정책 6개
- KMS 키 및 별칭

#### 데이터베이스 리소스
- RDS 인스턴스 (MySQL)
- DB 서브넷 그룹
- Secrets Manager 시크릿

#### 기타 리소스
- CloudWatch 로그 그룹
- OIDC Provider
- Random Password

### 3. 문제 해결 과정

#### EKS 클러스터 삭제 오류
```
Error: deleting EKS Cluster (ojm-cluster): ResourceInUseException: 
Cluster has nodegroups attached
```

**해결 방법**: 
- EKS 모듈을 타겟으로 지정하여 단계별 삭제
- 노드 그룹 → 클러스터 순서로 정리

#### 보안 그룹 삭제 지연
- 일부 보안 그룹이 14분 이상 삭제 대기
- 의존성 해결 후 자동 삭제 완료

## 📊 정리 결과

### 삭제 완료 상태
```bash
terraform state list
# (출력 없음 - 모든 리소스 삭제 완료)
```

### 비용 절감 효과
- **월 예상 절약**: ~$128/월
- **연 예상 절약**: ~$1,536/년

### 정리 시간
- **총 소요 시간**: 약 20분
- **주요 대기 시간**: RDS 삭제 (4분), 보안 그룹 삭제 (14분)

## 🚀 정리 후 상태

### 깨끗한 환경 구축
- ✅ Terraform 상태 파일 정리 완료
- ✅ 모든 AWS 리소스 삭제 완료
- ✅ 비용 발생 요소 제거
- ✅ 새로운 인프라 구축 준비 완료

### 보존된 항목
- ✅ Terraform 코드 (개선된 버전)
- ✅ 모듈 구조
- ✅ 네이밍 컨벤션
- ✅ 보안 설정
- ✅ 작업 리포트

## 📝 후속 작업

### 1. 새로운 인프라 구축 준비
- 표준화된 네이밍 컨벤션 적용
- 보안 강화된 설정 사용
- 환경별 구조 분리 (dev/stag/prod)

### 2. 비용 최적화
- 필요한 리소스만 선별적 배포
- 개발 환경용 소형 인스턴스 사용
- 자동 스케일링 및 스케줄링 적용

### 3. 모니터링 및 알림
- 비용 알림 설정
- 리소스 사용량 모니터링
- 자동 정리 스크립트 구축

## 💡 학습 포인트

### Terraform 리소스 관리
- 의존성 순서의 중요성
- 타겟 삭제 활용법
- 상태 파일 관리 방법

### AWS 리소스 특성
- EKS 클러스터 삭제 시 노드 그룹 의존성
- 보안 그룹 삭제 시간 지연 현상
- RDS 삭제 시 스냅샷 정책

### 비용 관리
- 사용하지 않는 리소스의 비용 영향
- 정기적인 리소스 정리의 중요성
- 개발 환경 리소스 최적화 방법

## 🔄 정리 체크리스트

- [x] Terraform 상태 확인
- [x] 모든 리소스 삭제 실행
- [x] 의존성 문제 해결
- [x] 최종 상태 검증
- [x] 비용 절감 효과 확인
- [x] 작업 문서화 완료

이제 깨끗한 환경에서 새로운 인프라를 구축할 준비가 완료되었습니다!
