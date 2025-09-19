#!/usr/bin/env python3
"""
간단한 Slack 봇 테스트 스크립트 (Flask 없이)
GitHub Actions 트리거만 테스트
"""

import json
import urllib.request
import urllib.parse
import os
import sys

def trigger_github_actions(command, channel="#optimization", user="test-user"):
    """GitHub Actions를 트리거하는 함수"""
    
    # GitHub 설정
    github_token = os.getenv('GITHUB_TOKEN', 'your_github_token_here')
    github_repo = os.getenv('GITHUB_REPO', 'jongminoh-bsp/KDT-Project')
    
    if github_token == 'your_github_token_here':
        print("❌ GITHUB_TOKEN 환경변수를 설정해주세요")
        print("export GITHUB_TOKEN=ghp_your_token_here")
        return False
    
    # GitHub API URL
    url = f"https://api.github.com/repos/{github_repo}/dispatches"
    
    # 페이로드 생성
    payload = {
        "event_type": "slack-command",
        "client_payload": {
            "command": command,
            "channel": channel,
            "user": user
        }
    }
    
    # 헤더 설정
    headers = {
        "Authorization": f"token {github_token}",
        "Accept": "application/vnd.github.v3+json",
        "Content-Type": "application/json",
        "User-Agent": "Slack-Bot-Test"
    }
    
    try:
        # HTTP 요청 생성
        data = json.dumps(payload).encode('utf-8')
        req = urllib.request.Request(url, data=data, headers=headers, method='POST')
        
        # 요청 전송
        print(f"🚀 GitHub Actions 트리거 중...")
        print(f"📝 명령: {command}")
        print(f"📱 채널: {channel}")
        print(f"👤 사용자: {user}")
        
        with urllib.request.urlopen(req) as response:
            if response.status == 204:
                print("✅ GitHub Actions 트리거 성공!")
                print("🔍 GitHub Actions 탭에서 워크플로우 실행 확인하세요")
                return True
            else:
                print(f"❌ 오류: HTTP {response.status}")
                return False
                
    except Exception as e:
        print(f"❌ 오류 발생: {e}")
        return False

def main():
    """메인 함수"""
    print("🤖 Slack 봇 GitHub Actions 트리거 테스트")
    print("=" * 50)
    
    if len(sys.argv) < 2:
        print("사용법: python3 simple-slack-test.py '명령어'")
        print("예시:")
        print("  python3 simple-slack-test.py '리소스 현황'")
        print("  python3 simple-slack-test.py '비용 분석'")
        print("  python3 simple-slack-test.py '보안 점검'")
        print("  python3 simple-slack-test.py '도움말'")
        return
    
    command = sys.argv[1]
    channel = sys.argv[2] if len(sys.argv) > 2 else "#optimization"
    user = sys.argv[3] if len(sys.argv) > 3 else "test-user"
    
    # GitHub Actions 트리거
    success = trigger_github_actions(command, channel, user)
    
    if success:
        print("\n🎉 테스트 완료!")
        print("📱 Slack 채널에서 응답을 확인하세요")
        print("🔗 GitHub: https://github.com/jongminoh-bsp/KDT-Project/actions")
    else:
        print("\n❌ 테스트 실패")
        print("🔧 GitHub Token과 권한을 확인해주세요")

if __name__ == "__main__":
    main()
