#!/usr/bin/env python3
"""
Slack Bot GitHub Actions 트리거 스크립트
사용법: curl -X POST http://localhost:5000/slack -d '{"text":"리소스 현황", "channel":"#optimization", "user":"user1"}'
"""

import json
import requests
import os
from flask import Flask, request, jsonify

app = Flask(__name__)

# GitHub Personal Access Token과 Repository 정보
GITHUB_TOKEN = os.getenv('GITHUB_TOKEN', 'your_github_token_here')
GITHUB_REPO = os.getenv('GITHUB_REPO', 'jongminoh-bsp/KDT-Project')

@app.route('/slack', methods=['POST'])
def handle_slack_command():
    try:
        data = request.get_json()
        
        # Slack에서 받은 데이터
        command = data.get('text', '')
        channel = data.get('channel', '#optimization')
        user = data.get('user_name', 'unknown')
        
        print(f"📝 받은 명령: {command}")
        print(f"📱 채널: {channel}")
        print(f"👤 사용자: {user}")
        
        # GitHub Actions 트리거
        github_url = f"https://api.github.com/repos/{GITHUB_REPO}/dispatches"
        
        payload = {
            "event_type": "slack-command",
            "client_payload": {
                "command": command,
                "channel": channel,
                "user": user
            }
        }
        
        headers = {
            "Authorization": f"token {GITHUB_TOKEN}",
            "Accept": "application/vnd.github.v3+json",
            "Content-Type": "application/json"
        }
        
        response = requests.post(github_url, json=payload, headers=headers)
        
        if response.status_code == 204:
            return jsonify({
                "response_type": "in_channel",
                "text": f"🤖 '{command}' 명령을 처리 중입니다..."
            })
        else:
            return jsonify({
                "response_type": "ephemeral", 
                "text": f"❌ 오류 발생: {response.status_code}"
            })
            
    except Exception as e:
        print(f"❌ 오류: {e}")
        return jsonify({
            "response_type": "ephemeral",
            "text": f"❌ 처리 중 오류가 발생했습니다: {str(e)}"
        })

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "healthy", "service": "slack-bot-trigger"})

if __name__ == '__main__':
    print("🚀 Slack Bot 트리거 서버 시작...")
    print("📱 엔드포인트: POST /slack")
    print("🔍 헬스체크: GET /health")
    app.run(host='0.0.0.0', port=5000, debug=True)
