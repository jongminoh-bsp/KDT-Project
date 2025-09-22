# Git 워크플로우 및 PR 가이드

## 🎯 개요

KDT-Project의 브랜치 전략과 Pull Request 워크플로우를 설명합니다.

## 🌿 브랜치 전략

### 브랜치 구조
```
main (프로덕션)
  ↑
staging (스테이징)
  ↑
develop (개발 통합)
  ↑
feature/* (기능 개발)
```

### 브랜치별 역할

- **`main`**: 프로덕션 환경 배포용
  - 안정적이고 테스트된 코드만 포함
  - 태그를 통한 릴리즈 관리
  - 직접 커밋 금지

- **`staging`**: 스테이징 환경 테스트용
  - 프로덕션 배포 전 최종 검증
  - QA 및 통합 테스트 수행
  - develop에서만 머지 허용

- **`develop`**: 개발 통합 환경
  - 기능 브랜치들의 통합 지점
  - CI/CD 파이프라인 실행
  - 개발팀 공유 브랜치

- **`feature/*`**: 기능 개발 브랜치
  - 개별 기능 또는 버그 수정
  - develop에서 분기
  - 작업 완료 후 develop으로 PR

## 🔄 작업 플로우

### 1. 기능 개발 시작

```bash
# develop 브랜치에서 최신 코드 가져오기
git checkout develop
git pull origin develop

# 새 기능 브랜치 생성
git checkout -b feature/infrastructure-automation
```

### 2. 개발 작업 수행

```bash
# 파일 수정 및 커밋
git add .
git commit -m "feat: Add Terraform infrastructure automation

- Add VPC module with multi-AZ configuration
- Add EKS cluster module with managed node groups
- Add RDS module with MySQL 8.0
- Add EC2 instances for management and development"

# 원격 브랜치에 푸시
git push origin feature/infrastructure-automation
```

### 3. Pull Request 생성

#### PR 템플릿 예시

```markdown
## 📋 변경 사항 요약

Terraform을 사용한 AWS 인프라 자동화 구현

## 🎯 작업 내용

### 추가된 기능
- [x] VPC 모듈 (Multi-AZ 구성)
- [x] EKS 클러스터 모듈
- [x] RDS MySQL 모듈
- [x] EC2 관리 인스턴스 모듈

### 변경된 파일
- `terraform/modules/vpc/` - VPC 리소스 정의
- `terraform/modules/eks/` - EKS 클러스터 설정
- `terraform/modules/rds/` - RDS 데이터베이스 설정
- `terraform/environments/dev/` - 개발 환경 설정

## 🧪 테스트 결과

- [x] Terraform plan 검증 완료
- [x] 리소스 생성 테스트 완료
- [x] EKS 클러스터 연결 확인
- [x] RDS 연결 테스트 완료

## 📊 배포 영향도

- **인프라**: 새로운 AWS 리소스 생성
- **비용**: 월 예상 $150-200 (개발 환경)
- **보안**: IAM 역할 및 보안 그룹 적용
- **가용성**: Multi-AZ 구성으로 고가용성 확보

## 🔍 리뷰 포인트

1. Terraform 모듈 구조의 적절성
2. 보안 그룹 규칙의 최소 권한 원칙 준수
3. 리소스 태깅 일관성
4. 비용 최적화 방안

## 📝 추가 정보

- 관련 이슈: #123
- 문서 업데이트: `docs/infrastructure/README.md`
- 배포 가이드: `docs/deployment/README.md`
```

### 4. 코드 리뷰 과정

#### 리뷰어 체크리스트

```markdown
## 🔍 코드 리뷰 체크리스트

### 기능성
- [ ] 요구사항 충족 여부
- [ ] 에러 처리 적절성
- [ ] 테스트 커버리지

### 코드 품질
- [ ] 코딩 컨벤션 준수
- [ ] 주석 및 문서화
- [ ] 코드 중복 제거

### 보안
- [ ] 민감 정보 하드코딩 없음
- [ ] 권한 최소화 원칙
- [ ] 입력값 검증

### 성능
- [ ] 리소스 사용량 최적화
- [ ] 확장성 고려
- [ ] 병목 지점 없음

### 인프라 (Terraform)
- [ ] 모듈 구조 적절성
- [ ] 변수 및 출력값 정의
- [ ] 상태 파일 관리
- [ ] 리소스 태깅
```

### 5. 머지 및 배포

```bash
# PR 승인 후 develop 브랜치로 머지
# GitHub UI에서 "Squash and merge" 사용

# develop → staging 머지 (릴리즈 준비)
git checkout staging
git pull origin staging
git merge develop
git push origin staging

# staging → main 머지 (프로덕션 배포)
git checkout main
git pull origin main
git merge staging
git tag v1.0.0
git push origin main --tags
```

## 📋 커밋 메시지 컨벤션

### 커밋 타입

- **feat**: 새로운 기능 추가
- **fix**: 버그 수정
- **docs**: 문서 수정
- **style**: 코드 포맷팅, 세미콜론 누락 등
- **refactor**: 코드 리팩토링
- **test**: 테스트 코드 추가/수정
- **chore**: 빌드 프로세스, 도구 설정 등

### 커밋 메시지 형식

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 예시

```
feat(infrastructure): Add EKS cluster with managed node groups

- Configure EKS cluster with version 1.27
- Add managed node group with t3.medium instances
- Set up auto-scaling from 2 to 4 nodes
- Configure proper IAM roles and policies

Closes #123
```

## 🚀 CI/CD 파이프라인

### GitHub Actions 워크플로우

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [develop, staging, main]
  pull_request:
    branches: [develop]

jobs:
  terraform-validate:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
    - name: Terraform Validate
      run: terraform validate

  application-test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Setup Java
      uses: actions/setup-java@v3
      with:
        java-version: '17'
    - name: Run Tests
      run: mvn test

  deploy-staging:
    if: github.ref == 'refs/heads/staging'
    needs: [terraform-validate, application-test]
    runs-on: ubuntu-latest
    steps:
    - name: Deploy to Staging
      run: |
        # 스테이징 환경 배포 스크립트
        kubectl set image deployment/skyline-app skyline=${{ github.sha }}

  deploy-production:
    if: github.ref == 'refs/heads/main'
    needs: [terraform-validate, application-test]
    runs-on: ubuntu-latest
    steps:
    - name: Deploy to Production
      run: |
        # 프로덕션 환경 배포 스크립트
        kubectl set image deployment/skyline-app skyline=${{ github.sha }}
```

## 🔧 브랜치 보호 규칙

### main 브랜치 보호

- ✅ Require pull request reviews before merging
- ✅ Require status checks to pass before merging
- ✅ Require branches to be up to date before merging
- ✅ Restrict pushes that create files larger than 100MB
- ✅ Require signed commits

### develop 브랜치 보호

- ✅ Require pull request reviews before merging
- ✅ Require status checks to pass before merging
- ✅ Allow force pushes (개발 중 히스토리 정리용)

## 📊 릴리즈 관리

### 버전 관리 (Semantic Versioning)

- **MAJOR**: 호환되지 않는 API 변경
- **MINOR**: 하위 호환되는 기능 추가
- **PATCH**: 하위 호환되는 버그 수정

### 릴리즈 노트 예시

```markdown
# Release v1.0.0

## 🎉 새로운 기능

- AWS EKS 기반 인프라 자동화
- Skyline 항공예약시스템 배포
- 도메인 기반 HTTPS 접근
- SPA 라우팅 완전 지원

## 🐛 버그 수정

- 데이터베이스 연결 안정성 개선
- 메모리 누수 문제 해결

## 🔧 개선사항

- Docker 이미지 크기 30% 감소
- 애플리케이션 시작 시간 50% 단축

## 📋 Breaking Changes

- 환경변수 `DB_URL` → `DB_HOST`, `DB_PORT`로 분리
- API 엔드포인트 `/v1/` 접두사 추가

## 🚀 배포 가이드

1. 새로운 환경변수 설정
2. 데이터베이스 마이그레이션 실행
3. 애플리케이션 이미지 업데이트
```

이 워크플로우를 통해 체계적이고 안전한 코드 관리가 가능합니다! 🎯
