#!/usr/bin/env python3
import os
import sys

# 경로 설정
current_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, current_dir)
backend_dir = os.path.join(current_dir, 'backend')
sys.path.insert(0, backend_dir)

print(f"현재 디렉토리: {current_dir}")
print(f"백엔드 디렉토리: {backend_dir}")

if __name__ == '__main__':
    try:
        print("📦 백엔드 모듈 로드 중...")
        from backend.app import app, init_db
        
        print("📊 데이터베이스 초기화...")
        init_db()
        
        print("🔐 HTTPS 서버 시작...")
        print("📍 접속 주소: https://16.171.133.35:5000")
        print("⚠️ 브라우저 보안 경고 시 '고급' → '계속 진행' 클릭")
        
        # HTTPS 서버 실행
        app.run(debug=False, host='0.0.0.0', port=5000, ssl_context='adhoc')
        
    except ImportError as e:
        print(f"❌ 모듈 임포트 오류: {e}")
        print("📁 현재 경로의 파일들:")
        import glob
        print("Python 파일들:", glob.glob("**/*.py", recursive=True))
    except Exception as e:
        print(f"❌ 서버 시작 오류: {e}")
        import traceback
        traceback.print_exc()
