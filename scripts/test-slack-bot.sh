#!/bin/bash
# Slack 봇 테스트 스크립트

SERVER_URL=${1:-"http://localhost:5000"}

echo "🧪 Slack 봇 테스트 시작..."
echo "🌐 서버: $SERVER_URL"

# 헬스체크
echo ""
echo "1️⃣ 헬스체크 테스트"
curl -s "$SERVER_URL/health" | jq .

# 리소스 현황 테스트
echo ""
echo "2️⃣ 리소스 현황 테스트"
curl -X POST "$SERVER_URL/slack" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "리소스 현황",
    "channel": "#optimization",
    "user_name": "test-user"
  }' | jq .

# 비용 분석 테스트
echo ""
echo "3️⃣ 비용 분석 테스트"
curl -X POST "$SERVER_URL/slack" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "비용 분석",
    "channel": "#optimization", 
    "user_name": "test-user"
  }' | jq .

# 보안 점검 테스트
echo ""
echo "4️⃣ 보안 점검 테스트"
curl -X POST "$SERVER_URL/slack" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "보안 점검",
    "channel": "#optimization",
    "user_name": "test-user"
  }' | jq .

# 도움말 테스트
echo ""
echo "5️⃣ 도움말 테스트"
curl -X POST "$SERVER_URL/slack" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "도움말",
    "channel": "#optimization",
    "user_name": "test-user"
  }' | jq .

# 잘못된 명령 테스트
echo ""
echo "6️⃣ 잘못된 명령 테스트"
curl -X POST "$SERVER_URL/slack" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "알 수 없는 명령",
    "channel": "#optimization",
    "user_name": "test-user"
  }' | jq .

echo ""
echo "✅ 테스트 완료!"
