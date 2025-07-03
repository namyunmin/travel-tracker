#!/usr/bin/env python3
"""
HTTPS용 메인 실행 파일
"""

import os
import sys
import ssl

# 현재 스크립트의 디렉토리를 Python 경로에 추가
current_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, current_dir)

# 백엔드 디렉토리를 Python 경로에 추가
backend_dir = os.path.join(current_dir, 'backend')
sys.path.insert(0, backend_dir)

def create_ssl_context():
    """SSL 컨텍스트 생성 (자체 서명 인증서 사용)"""
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    
    # 인증서 파일 경로
    cert_path = '/etc/ssl/travel-tracker/travel-tracker.crt'
    key_path = '/etc/ssl/travel-tracker/travel-tracker.key'
    
    # 인증서 파일이 없으면 생성 안내
    if not os.path.exists(cert_path) or not os.path.exists(key_path):
        print("❌ SSL 인증서가 없습니다.")
        print("🔧 먼저 setup_https_ip.sh를 실행하세요:")
        print("sudo chmod +x setup_https_ip.sh && sudo ./setup_https_ip.sh")
        return None
    
    try:
        context.load_cert_chain(cert_path, key_path)
        return context
    except Exception as e:
        print(f"❌ SSL 설정 오류: {e}")
        return None

if __name__ == '__main__':
    from backend.app import app
    
    # SSL 컨텍스트 생성
    ssl_context = create_ssl_context()
    
    if ssl_context:
        print("🔒 HTTPS 모드로 실행 중...")
        print("🌐 접속 주소: https://YOUR_EC2_IP:5000")
        print("⚠️  브라우저 보안 경고시 '고급' → '계속 진행' 클릭")
        
        app.run(
            debug=False, 
            host='0.0.0.0', 
            port=5000,
            ssl_context=ssl_context
        )
    else:
        print("🚀 HTTP 모드로 실행 중...")
        print("📍 브라우저에서 http://localhost:5000 으로 접속하세요")
        
        app.run(debug=True, host='0.0.0.0', port=5000)
