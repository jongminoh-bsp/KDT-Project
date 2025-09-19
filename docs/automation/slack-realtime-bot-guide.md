# 🤖 Slack 실시간 AWS 봇 설정 가이드

## 🚀 개요
Slack에서 실시간으로 AWS 리소스 현황을 조회하고 분석할 수 있는 봇 시스템

## 📋 사용 가능한 명령어

### 1. 리소스 현황 조회
```
리소스 현황
AWS 리소스 현황 자세히 분석
resource status
```
→ EC2, EBS, VPC, RDS, EKS 실시간 현황

### 2. 비용 분석
```
비용 분석
cost analysis
```
→ 미사용 리소스 기반 비용 절약 분석

### 3. 보안 점검
```
보안 점검
security check
```
→ 보안 그룹, IAM 사용자 보안 상태 점검

### 4. 도움말
```
도움말
help
```
→ 사용 가능한 명령어 목록

## 🔧 설정 방법

### 1. Slack 앱 생성
1. [Slack API](https://api.slack.com/apps) → "Create New App"
2. "From scratch" 선택
3. App 이름: `AWS-Q-Bot`
4. Workspace 선택

### 2. Slash Commands 설정
1. 앱 설정 → "Slash Commands"
2. "Create New Command" 클릭
3. 설정:
   - Command: `/aws`
   - Request URL: `https://your-server.com/slack`
   - Short Description: `AWS 리소스 실시간 조회`
   - Usage Hint: `리소스 현황 | 비용 분석 | 보안 점검`

### 3. GitHub Secrets 추가
```bash
# Repository Settings → Secrets → Actions
GITHUB_TOKEN=ghp_your_personal_access_token
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...
```

### 4. 서버 배포 (옵션 1: 로컬)
```bash
# 의존성 설치
pip install flask requests

# 환경변수 설정
export GITHUB_TOKEN=ghp_your_token
export GITHUB_REPO=jongminoh-bsp/KDT-Project

# 서버 실행
python scripts/slack-bot-trigger.py
```

### 5. 서버 배포 (옵션 2: AWS Lambda)
```python
# AWS Lambda 함수로 배포하여 서버리스 운영 가능
# API Gateway + Lambda로 /slack 엔드포인트 생성
```

## 💬 사용 예시

### Slack에서 사용
```
/aws 리소스 현황
→ 🤖 '리소스 현황' 명령을 처리 중입니다...
→ 📊 실시간 AWS 리소스 현황
   🖥️ EC2 실행중: 3개
   ⏹️ EC2 중지됨: 1개
   💾 미사용 EBS: 2개
   🌐 VPC: 1개
   🗄️ RDS: 1개
   ☸️ EKS: 1개
```

```
/aws 비용 분석
→ 💰 실시간 비용 최적화 분석
   ⏹️ 중지된 EC2: 1개 → 월 $20 절약 가능
   💾 미사용 EBS: 2개 → 월 $16 절약 가능
   💵 총 절약 가능: 월 $36
```

## 🔄 작동 원리

1. **Slack 명령** → Slash Command (`/aws 리소스 현황`)
2. **웹훅 서버** → Python Flask 서버가 명령 수신
3. **GitHub API** → Repository Dispatch로 Actions 트리거
4. **AWS 조회** → GitHub Actions에서 AWS CLI 실행
5. **Slack 응답** → 결과를 Slack 채널로 실시간 전송

## 🛠️ 고급 기능

### 1. 예약된 리포트
```yaml
# .github/workflows/scheduled-reports.yml
on:
  schedule:
    - cron: '0 9 * * MON'  # 매주 월요일 오전 9시
```

### 2. 알림 조건 설정
```bash
# 특정 임계값 초과시 자동 알림
if [ $EC2_STOPPED -gt 5 ]; then
  # 긴급 알림 전송
fi
```

### 3. 대화형 버튼
```json
{
  "actions": [{
    "type": "button",
    "text": "🔄 리소스 정리 실행",
    "value": "cleanup_resources"
  }]
}
```

## 🔒 보안 고려사항

- GitHub Token은 최소 권한으로 설정
- Slack 앱은 필요한 채널에만 설치
- 웹훅 서버는 HTTPS 필수
- 민감한 정보는 GitHub Secrets 사용

## 🚨 문제 해결

### 일반적인 오류
1. **GitHub API 403**: Token 권한 확인
2. **Slack 응답 없음**: Webhook URL 확인
3. **AWS 권한 오류**: IAM 정책 확인

### 디버깅
```bash
# 로컬 테스트
curl -X POST http://localhost:5000/slack \
  -H "Content-Type: application/json" \
  -d '{"text":"리소스 현황", "channel":"#test", "user":"test"}'
```
