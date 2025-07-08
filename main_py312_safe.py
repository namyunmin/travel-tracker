#!/usr/bin/env python3
"""
지도 기반 실시간 위치 추적 앱 (Python 3.12 호환)
PyCharm 실행을 위한 메인 엔트리 포인트
"""

import os
import sys
import warnings

# Python 3.12 호환성을 위한 경고 무시
warnings.filterwarnings("ignore", category=DeprecationWarning)
warnings.filterwarnings("ignore", category=SyntaxWarning)

# 현재 스크립트의 디렉토리를 Python 경로에 추가
current_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, current_dir)

# 백엔드 디렉토리를 Python 경로에 추가
backend_dir = os.path.join(current_dir, 'backend')
sys.path.insert(0, backend_dir)

def check_environment():
    """환경 확인"""
    print(f"Python 버전: {sys.version}")
    
    try:
        import flask
        print(f"Flask 버전: {flask.__version__}")
    except ImportError as e:
        print(f"❌ Flask 가져오기 실패: {e}")
        print("다음 명령으로 설치하세요: pip install flask flask-cors")
        return False
    
    return True

if __name__ == '__main__':
    print("🚀 지도 기반 위치 추적 앱을 시작합니다...")
    
    if not check_environment():
        print("❌ 환경 설정에 문제가 있습니다.")
        sys.exit(1)
    
    try:
        # 백엔드 앱 실행
        from backend.app import app
        print("📍 브라우저에서 http://localhost:5000 으로 접속하세요")
        print("⚠️  위치 권한을 허용해주세요")
        print("🔧 개발 모드로 실행 중...")
        
        # Python 3.12에서 안전한 설정으로 실행
        app.run(
            debug=True, 
            host='0.0.0.0', 
            port=5000,
            use_reloader=False  # Python 3.12 호환성을 위해 reloader 비활성화
        )
        
    except ImportError as e:
        print(f"❌ 모듈 가져오기 실패: {e}")
        print("check_env.py를 실행하여 환경을 확인하세요.")
    except Exception as e:
        print(f"❌ 서버 시작 실패: {e}")
        print("fix_python312.bat를 실행하여 환경을 재설정하세요.")
