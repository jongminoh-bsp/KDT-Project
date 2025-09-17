# 📢 Slack 알림 연동 가이드

## Slack Webhook URL 설정

### 1. Slack App 생성
1. https://api.slack.com/apps 접속
2. "Create New App" → "From scratch"
3. App 이름: `Terraform Bot`
4. Workspace 선택

### 2. Incoming Webhooks 활성화
1. 좌측 메뉴 "Incoming Webhooks" 클릭
2. "Activate Incoming Webhooks" 토글 ON
3. "Add New Webhook to Workspace" 클릭
4. 알림받을 채널 선택 (예: `#infrastructure`)
5. Webhook URL 복사

### 3. GitHub Secrets 설정
```
Name: SLACK_WEBHOOK_URL
Value: https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX
```

## 알림 내용

### ✅ 성공 알림
- 🚀 Infrastructure Deployment Success
- 환경, 액션, 실행자 정보
- 브랜치, 커밋 정보

### ❌ 실패 알림  
- ❌ Infrastructure Deployment Failed
- 에러 상세 정보
- GitHub Actions 로그 링크

## 채널 설정

기본 채널: `#infrastructure`

다른 채널로 변경하려면 워크플로우 파일에서 수정:
```yaml
channel: '#your-channel'
```

## 알림 비활성화

Slack 알림을 받지 않으려면 `SLACK_WEBHOOK_URL` Secret을 삭제하면 됩니다.
