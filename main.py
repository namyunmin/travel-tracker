#!/usr/bin/env python3
"""
지도 기반 실시간 위치 추적 앱
PyCharm 실행을 위한 메인 엔트리 포인트
"""

import os
import sys

# 현재 스크립트의 디렉토리를 Python 경로에 추가
current_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, current_dir)

# 백엔드 디렉토리를 Python 경로에 추가
backend_dir = os.path.join(current_dir, 'backend')
sys.path.insert(0, backend_dir)

if __name__ == '__main__':
    # 백엔드 앱 실행
    from backend.app import app
    print("🚀 지도 기반 위치 추적 앱을 시작합니다...")
    print("📍 브라우저에서 http://localhost:5000 으로 접속하세요")
    print("⚠️  위치 권한을 허용해주세요")
    print("🔧 개발 모드로 실행 중...")
    
    app.run(debug=True, host='0.0.0.0', port=5000)
