# 🤖 Slack 봇 상세 설정 가이드

## 1️⃣ Slack 앱 생성 (5분)

### Step 1: Slack API 사이트 접속
1. https://api.slack.com/apps 접속
2. **"Create New App"** 클릭
3. **"From scratch"** 선택
4. App Name: `AWS-Q-Bot` 입력
5. Workspace 선택 후 **"Create App"** 클릭

### Step 2: Slash Commands 설정
1. 왼쪽 메뉴에서 **"Slash Commands"** 클릭
2. **"Create New Command"** 클릭
3. 다음 정보 입력:
   ```
   Command: /aws
   Request URL: https://your-domain.com/slack (나중에 변경)
   Short Description: AWS 리소스 실시간 조회
   Usage Hint: 리소스 현황 | 비용 분석 | 보안 점검 | 도움말
   ```
4. **"Save"** 클릭

### Step 3: 권한 설정
1. 왼쪽 메뉴에서 **"OAuth & Permissions"** 클릭
2. **"Scopes"** 섹션에서 **"Add an OAuth Scope"** 클릭
3. 다음 권한들 추가:
   - `chat:write` (메시지 전송)
   - `commands` (슬래시 명령)
   - `incoming-webhook` (웹훅)

### Step 4: 앱 설치
1. 같은 페이지에서 **"Install to Workspace"** 클릭
2. **"Allow"** 클릭
3. **Bot User OAuth Token** 복사해두기 (xoxb-로 시작)

## 2️⃣ GitHub Secrets 설정 (2분)

### GitHub Repository 설정
1. https://github.com/jongminoh-bsp/KDT-Project 접속
2. **Settings** → **Secrets and variables** → **Actions** 클릭
3. **"New repository secret"** 클릭하여 다음 추가:

```bash
# 1. GitHub Personal Access Token
Name: GITHUB_TOKEN
Secret: ghp_your_personal_access_token_here

# 2. Slack Bot Token (위에서 복사한 것)
Name: SLACK_BOT_TOKEN  
Secret: xoxb-your-bot-token-here

# 3. Slack Webhook URL (기존 것 사용)
Name: SLACK_WEBHOOK_URL
Secret: https://hooks.slack.com/services/...
```

## 3️⃣ Flask 서버 실행 (3가지 방법)

### 방법 1: 로컬에서 실행 (가장 간단)

```bash
# 1. 의존성 설치
pip install flask requests

# 2. 환경변수 설정
export GITHUB_TOKEN=ghp_your_token_here
export GITHUB_REPO=jongminoh-bsp/KDT-Project

# 3. 서버 실행
cd /home/ojm/KDT-Project
python scripts/slack-bot-trigger.py

# 4. 터널링 (외부 접속 가능하게)
# ngrok 설치 후
ngrok http 5000
```

### 방법 2: AWS EC2에서 실행 (권장)

```bash
# EC2 인스턴스 생성 후
sudo yum update -y
sudo yum install -y python3 python3-pip git

# 코드 다운로드
git clone https://github.com/jongminoh-bsp/KDT-Project.git
cd KDT-Project

# 의존성 설치
pip3 install flask requests

# 환경변수 설정
export GITHUB_TOKEN=ghp_your_token_here
export GITHUB_REPO=jongminoh-bsp/KDT-Project

# 백그라운드 실행
nohup python3 scripts/slack-bot-trigger.py &

# 보안 그룹에서 5000 포트 열기
```

### 방법 3: AWS Lambda (서버리스)

```python
# lambda_function.py
import json
import requests
import os

def lambda_handler(event, context):
    # HTTP 요청 파싱
    body = json.loads(event['body'])
    
    command = body.get('text', '')
    channel = body.get('channel_name', 'optimization')
    user = body.get('user_name', 'unknown')
    
    # GitHub Actions 트리거
    github_url = f"https://api.github.com/repos/{os.environ['GITHUB_REPO']}/dispatches"
    
    payload = {
        "event_type": "slack-command",
        "client_payload": {
            "command": command,
            "channel": f"#{channel}",
            "user": user
        }
    }
    
    headers = {
        "Authorization": f"token {os.environ['GITHUB_TOKEN']}",
        "Accept": "application/vnd.github.v3+json"
    }
    
    requests.post(github_url, json=payload, headers=headers)
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'response_type': 'in_channel',
            'text': f'🤖 "{command}" 명령을 처리 중입니다...'
        })
    }
```

## 4️⃣ Slack 앱 URL 업데이트

### 서버 실행 후 URL 변경
1. Slack API 사이트에서 앱 선택
2. **"Slash Commands"** → `/aws` 명령 클릭
3. **Request URL** 변경:
   ```
   로컬: http://your-ngrok-url.ngrok.io/slack
   EC2: http://your-ec2-ip:5000/slack  
   Lambda: https://your-api-gateway-url/slack
   ```
4. **"Save"** 클릭

## 5️⃣ 테스트 실행

### 1. 서버 상태 확인
```bash
# 헬스체크
curl http://localhost:5000/health

# 응답 예시
{"status": "healthy", "service": "slack-bot-trigger"}
```

### 2. 로컬 테스트
```bash
# 테스트 스크립트 실행
./scripts/test-slack-bot.sh

# 또는 직접 테스트
curl -X POST http://localhost:5000/slack \
  -H "Content-Type: application/json" \
  -d '{"text":"리소스 현황", "channel":"#optimization", "user_name":"test"}'
```

### 3. Slack에서 테스트
```
/aws 도움말
/aws 리소스 현황
/aws 비용 분석
/aws 보안 점검
```

## 6️⃣ 문제 해결

### 자주 발생하는 오류들

#### 1. "url_verification failed"
```bash
# Slack 앱 설정에서 Event Subscriptions 비활성화
# Slash Commands만 사용하므로 불필요
```

#### 2. "GitHub API 403 Forbidden"
```bash
# GitHub Token 권한 확인
# repo, workflow 권한 필요
```

#### 3. "Connection refused"
```bash
# 서버가 실행 중인지 확인
ps aux | grep python
netstat -tlnp | grep 5000
```

#### 4. "Slack command timeout"
```bash
# 3초 내에 응답해야 함
# GitHub Actions는 비동기로 실행되므로 즉시 응답 전송
```

## 7️⃣ 운영 팁

### 1. 로그 모니터링
```bash
# Flask 서버 로그 확인
tail -f nohup.out

# GitHub Actions 로그 확인
# https://github.com/your-repo/actions
```

### 2. 자동 재시작 설정
```bash
# systemd 서비스 생성
sudo nano /etc/systemd/system/slack-bot.service

[Unit]
Description=Slack AWS Bot
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user/KDT-Project
Environment=GITHUB_TOKEN=your_token
Environment=GITHUB_REPO=jongminoh-bsp/KDT-Project
ExecStart=/usr/bin/python3 scripts/slack-bot-trigger.py
Restart=always

[Install]
WantedBy=multi-user.target

# 서비스 시작
sudo systemctl enable slack-bot
sudo systemctl start slack-bot
```

### 3. 보안 강화
```bash
# HTTPS 사용 (Let's Encrypt)
sudo yum install -y certbot
sudo certbot certonly --standalone -d your-domain.com

# Nginx 리버스 프록시 설정
sudo yum install -y nginx
```

## 8️⃣ 완료 체크리스트

- [ ] Slack 앱 생성 완료
- [ ] Slash Command `/aws` 설정 완료  
- [ ] GitHub Secrets 3개 추가 완료
- [ ] Flask 서버 실행 완료
- [ ] ngrok/EC2/Lambda URL 설정 완료
- [ ] Slack에서 `/aws 도움말` 테스트 성공
- [ ] GitHub Actions 워크플로우 실행 확인
- [ ] Slack 채널에 응답 수신 확인

모든 체크리스트 완료하면 실시간 Slack AWS 봇 사용 가능! 🎉
