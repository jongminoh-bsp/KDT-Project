# 🔧 Slack 알림 설정 가이드

## 1. Slack Webhook URL 생성

### Slack App 생성
1. [Slack API](https://api.slack.com/apps) 접속
2. "Create New App" 클릭
3. "From scratch" 선택
4. App 이름: `KDT-GitHub-Bot`
5. Workspace 선택

### Incoming Webhooks 활성화
1. 생성된 앱에서 "Incoming Webhooks" 클릭
2. "Activate Incoming Webhooks" 토글 ON
3. "Add New Webhook to Workspace" 클릭
4. 알림을 받을 채널 선택 (예: #infrastructure)
5. "Allow" 클릭
6. 생성된 Webhook URL 복사

## 2. GitHub Secrets 설정

### Repository Secrets 추가
1. GitHub 저장소 → Settings → Secrets and variables → Actions
2. "New repository secret" 클릭
3. Name: `SLACK_WEBHOOK_URL`
4. Secret: 복사한 Webhook URL 붙여넣기
5. "Add secret" 클릭

## 3. 테스트 실행

### 수동 테스트
```bash
# GitHub Actions에서 수동 실행
1. Actions 탭 → "🧪 Test Slack Notification" 선택
2. "Run workflow" 클릭
3. 메시지와 채널 입력 (선택사항)
4. "Run workflow" 실행
```

### 자동 트리거 테스트
```bash
# develop 브랜치에 푸시하여 테스트
git checkout develop
echo "# 테스트" >> test.md
git add test.md
git commit -m "Slack 알림 테스트"
git push origin develop
```

## 4. 알림 채널 설정

### 권장 채널 구조
- `#infrastructure`: 인프라 배포 관련
- `#optimization`: 비용 최적화 관련  
- `#alerts`: 긴급 알림
- `#general`: 일반 알림

### 채널별 알림 설정
```yaml
# 워크플로우에서 채널 지정
"channel": "#infrastructure"  # 인프라 배포
"channel": "#optimization"    # 비용 최적화
"channel": "#alerts"          # 실패/오류 알림
```

## 5. 커스터마이징

### 메시지 형식 변경
```json
{
  "channel": "#infrastructure",
  "username": "Custom Bot Name",
  "icon_emoji": ":robot_face:",
  "text": "커스텀 메시지",
  "attachments": [...]
}
```

### 조건부 알림
```yaml
# 특정 브랜치에서만 알림
if: github.ref == 'refs/heads/main'

# 실패시에만 알림  
if: failure()

# 성공시에만 알림
if: success()
```

## 6. 문제 해결

### 일반적인 오류
1. **Webhook URL 오류**: Secrets 설정 확인
2. **채널 권한 오류**: Bot을 채널에 초대
3. **메시지 형식 오류**: JSON 문법 확인

### 디버깅 방법
```bash
# 로컬에서 테스트
curl -X POST -H 'Content-type: application/json' \
--data '{"text":"테스트 메시지"}' \
YOUR_WEBHOOK_URL
```

## 7. 보안 고려사항

- Webhook URL은 절대 코드에 하드코딩하지 말 것
- GitHub Secrets 사용 필수
- 필요시 IP 제한 설정
- 정기적인 Webhook URL 갱신 권장
