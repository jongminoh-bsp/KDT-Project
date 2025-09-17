# KDT-Project

## 브랜치 전략

### 브랜치 구조
- `main`: 프로덕션 환경 배포용
- `staging`: 스테이징 환경 테스트용  
- `develop`: 개발 통합 환경

### 작업 플로우
1. `develop`에서 기능 브랜치 생성
2. 기능 완료 후 `develop`으로 PR
3. 코드 리뷰 완료 후 머지
4. `develop` → `staging` → `main` 순서로 배포

## 인프라 구조

현재 Terraform으로 다음 리소스들을 관리:
- VPC 및 네트워킹
- EKS 클러스터
- RDS 데이터베이스
- EC2 인스턴스 (Management, Q-Dev)
- 보안 그룹
