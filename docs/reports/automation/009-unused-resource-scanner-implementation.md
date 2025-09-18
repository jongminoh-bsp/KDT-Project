# 009. 미사용 리소스 스캐너 구축 및 자동화

## 📋 작업 개요

**작업 일시**: 2025-09-18  
**작업자**: 개발팀  
**작업 유형**: 자동화 시스템 구축  
**우선순위**: 중간  

## 🎯 목표

AWS 인프라의 미사용 리소스를 자동으로 감지하고 비용 최적화 제안을 제공하는 시스템 구축

## 🔧 구현 내용

### 1. 워크플로우 구축
- **파일**: `.github/workflows/unused-resource-scanner.yml`
- **트리거**: 
  - 주간 자동 실행 (매주 월요일 오전 9시)
  - 수동 실행 (`workflow_dispatch`)
  - 자연어 명령을 통한 자동 트리거

### 2. 스캔 대상 리소스
- **EBS 볼륨**: 미연결 상태의 볼륨 감지
- **Elastic IP**: 미할당 상태의 EIP 감지  
- **스냅샷**: 30일 이상 오래된 스냅샷 감지
- **보안 그룹**: 미사용 보안 그룹 감지

### 3. 자연어 명령 통합
- **명령어**: "미사용 리소스 스캐너 실행해줘"
- **처리**: `infrastructure-change-detection.yml`에서 자동 감지
- **트리거**: GitHub Actions API를 통한 워크플로우 실행

### 4. Slack 알림 시스템
- **채널**: `#optimization` (신규 생성)
- **사용자**: AWS Cost Optimizer
- **아이콘**: 💰 (`:moneybag:`)
- **내용**: 스캔 결과, 비용 절약 제안, 상세 분석

## 🛠️ 기술적 구현

### AWS 자격증명 설정
```yaml
- name: 🔐 Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: ${{ env.AWS_REGION }}
```

### Slack 알림 구성
```yaml
- name: 📢 Send Slack Notification
  uses: 8398a7/action-slack@v3
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
  with:
    status: custom
    custom_payload: |
      {
        "channel": "#optimization",
        "username": "AWS Cost Optimizer",
        "icon_emoji": ":moneybag:",
        "attachments": [...]
      }
```

### 자동 트리거 시스템
```yaml
- name: 🔍 Trigger Resource Scanner
  uses: actions/github-script@v7
  with:
    script: |
      const result = await github.rest.actions.createWorkflowDispatch({
        owner: context.repo.owner,
        repo: context.repo.repo,
        workflow_id: 'unused-resource-scanner.yml',
        ref: 'main',
        inputs: { scan_type: 'full' }
      });
```

## 🐛 해결한 문제들

### 1. 워크플로우 404 에러
- **문제**: main 브랜치에 워크플로우 파일 부재
- **해결**: PR을 통한 main 브랜치 동기화

### 2. AWS 자격증명 오류
- **문제**: Role 기반 인증 설정 오류
- **해결**: Access Key 방식으로 변경

### 3. Slack 액션 설정 오류
- **문제**: `webhook_url` 파라미터 호환성 문제
- **해결**: `env` 섹션으로 이동

### 4. JSON 파싱 에러
- **문제**: Shell 명령어 사용으로 인한 JSON 문법 오류
- **해결**: GitHub Actions 변수로 대체

## 📊 테스트 결과

### 첫 번째 스캔 결과 (2025-09-18 10:57)
```
📅 스캔 일시: Run #4 (ID: 17815643047)
🌍 리전: ap-northeast-2
📊 총 미사용 리소스: 0개
💰 예상 월간 절약: $0
📋 상세 내역:
• EBS 볼륨: 0개
• Elastic IP: 0개  
• 오래된 스냅샷: 0개
```

**결과 분석**: 현재 인프라가 잘 최적화되어 있어 미사용 리소스가 없음을 확인

## 🎯 달성 효과

### 1. 자동화 구현
- ✅ 주간 자동 스캔 시스템 구축
- ✅ 자연어 명령을 통한 즉시 실행
- ✅ 실시간 Slack 알림

### 2. 비용 최적화
- ✅ 미사용 리소스 자동 감지
- ✅ 월간 절약 가능 비용 계산
- ✅ 상세한 분석 리포트 제공

### 3. 운영 효율성
- ✅ 수동 확인 작업 자동화
- ✅ 전용 채널을 통한 알림 분리
- ✅ 히스토리 추적 가능

## 🔄 향후 개선 계획

### 1. 스캔 범위 확장
- [ ] RDS 인스턴스 미사용 감지
- [ ] Lambda 함수 사용량 분석
- [ ] CloudWatch 로그 그룹 정리

### 2. 알림 개선
- [ ] 임계값 기반 알림 설정
- [ ] 트렌드 분석 추가
- [ ] 자동 정리 제안

### 3. 대시보드 구축
- [ ] 비용 절약 히스토리
- [ ] 리소스 사용률 시각화
- [ ] 월간/연간 리포트

## 📁 관련 파일

- `.github/workflows/unused-resource-scanner.yml`: 메인 워크플로우
- `.github/workflows/infrastructure-change-detection.yml`: 자연어 명령 처리
- `scripts/unused-resource-scanner.py`: 스캔 로직 (향후 구현)
- `infra/requirements/infrastructure-spec.yml`: 설정 파일

## 🏷️ 태그

`#automation` `#cost-optimization` `#aws` `#github-actions` `#slack-integration` `#resource-management`

---

**작업 완료**: 2025-09-18 11:05  
**상태**: ✅ 완료  
**다음 작업**: 스캔 범위 확장 및 대시보드 구축
