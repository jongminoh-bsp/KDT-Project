# 🚀 Slack 봇 빠른 설정 가이드

## 📋 필요한 것들
- Slack 워크스페이스 관리자 권한
- GitHub Personal Access Token
- 서버 (로컬 PC, EC2, 또는 Lambda)

## 1️⃣ Slack 앱 생성 (5분)

### 🔗 https://api.slack.com/apps
1. **"Create New App"** → **"From scratch"**
2. **App Name**: `AWS-Q-Bot`
3. **Workspace** 선택 → **"Create App"**

### Slash Commands 설정
1. 왼쪽 메뉴 **"Slash Commands"** 클릭
2. **"Create New Command"** 클릭
3. 입력:
   ```
   Command: /aws
   Request URL: https://임시주소.com/slack (나중에 변경)
   Short Description: AWS 리소스 실시간 조회
   Usage Hint: 리소스 현황 | 비용 분석 | 보안 점검
   ```

### 권한 설정
1. **"OAuth & Permissions"** 클릭
2. **"Bot Token Scopes"**에 추가:
   - `chat:write`
   - `commands`

### 앱 설치
1. **"Install to Workspace"** → **"Allow"**
2. **Bot User OAuth Token** 복사 (xoxb-로 시작)

## 2️⃣ GitHub Token 생성

### 🔗 https://github.com/settings/tokens
1. **"Generate new token"** → **"Classic"**
2. **Scopes** 선택:
   - `repo` (전체)
   - `workflow`
3. **"Generate token"** → 토큰 복사 (ghp-로 시작)

## 3️⃣ GitHub Secrets 설정

### 🔗 https://github.com/jongminoh-bsp/KDT-Project/settings/secrets/actions
**"New repository secret"** 클릭하여 추가:

```
Name: GITHUB_TOKEN
Secret: ghp_your_personal_access_token

Name: SLACK_BOT_TOKEN  
Secret: xoxb_your_bot_token

Name: SLACK_WEBHOOK_URL
Secret: https://hooks.slack.com/services/... (기존 것)
```

## 4️⃣ 서버 실행 (3가지 방법 중 선택)

### 방법 A: 로컬 PC (가장 간단)
```bash
# 1. Python 패키지 설치
pip install flask requests

# 2. 환경변수 설정
export GITHUB_TOKEN=ghp_your_token_here
export GITHUB_REPO=jongminoh-bsp/KDT-Project

# 3. 서버 실행
cd KDT-Project
python scripts/slack-bot-trigger.py

# 4. 외부 접속 가능하게 (새 터미널)
# ngrok 다운로드: https://ngrok.com/download
./ngrok http 5000
# → https://abc123.ngrok.io 주소 복사
```

### 방법 B: AWS EC2 (권장)
```bash
# EC2 t2.micro 인스턴스 생성 후
sudo yum update -y
sudo yum install -y python3 python3-pip git

git clone https://github.com/jongminoh-bsp/KDT-Project.git
cd KDT-Project

pip3 install flask requests

export GITHUB_TOKEN=ghp_your_token_here
export GITHUB_REPO=jongminoh-bsp/KDT-Project

# 백그라운드 실행
nohup python3 scripts/slack-bot-trigger.py &

# 보안 그룹에서 5000 포트 열기
# → http://your-ec2-ip:5000 주소 사용
```

### 방법 C: 간단 테스트 (Flask 서버 없이)
```bash
# GitHub Token 설정
export GITHUB_TOKEN=ghp_your_token_here

# 직접 테스트
python3 scripts/simple-slack-test.py "리소스 현황"
python3 scripts/simple-slack-test.py "비용 분석"
python3 scripts/simple-slack-test.py "도움말"
```

## 5️⃣ Slack 앱 URL 업데이트

### 서버 주소를 Slack에 등록
1. **https://api.slack.com/apps** → 앱 선택
2. **"Slash Commands"** → `/aws` 클릭
3. **Request URL** 변경:
   ```
   로컬+ngrok: https://abc123.ngrok.io/slack
   EC2: http://your-ec2-ip:5000/slack
   ```
4. **"Save"** 클릭

## 6️⃣ 테스트

### Slack에서 테스트
```
/aws 도움말
/aws 리소스 현황  
/aws 비용 분석
/aws 보안 점검
```

### 예상 결과
```
🤖 '리소스 현황' 명령을 처리 중입니다...
📊 실시간 AWS 리소스 현황
🖥️ EC2 실행중: 3개
⏹️ EC2 중지됨: 1개
💾 미사용 EBS: 2개
🌐 VPC: 1개
🗄️ RDS: 1개
☸️ EKS: 1개
```

## 🚨 문제 해결

### "Command failed"
- GitHub Token 권한 확인 (repo, workflow)
- Secrets 이름 정확히 입력했는지 확인

### "No response"  
- 서버가 실행 중인지 확인: `curl http://localhost:5000/health`
- Slack Request URL이 정확한지 확인

### "Timeout"
- 서버 응답이 3초 내에 와야 함
- GitHub Actions는 비동기로 실행됨

## ✅ 완료 체크리스트

- [ ] Slack 앱 생성 ✓
- [ ] GitHub Token 생성 ✓  
- [ ] GitHub Secrets 3개 추가 ✓
- [ ] 서버 실행 (로컬/EC2/테스트) ✓
- [ ] Slack Request URL 업데이트 ✓
- [ ] `/aws 도움말` 테스트 성공 ✓

**모든 단계 완료하면 실시간 Slack AWS 봇 사용 가능! 🎉**
