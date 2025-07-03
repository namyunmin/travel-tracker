#!/usr/bin/env python3
import os
import sys

current_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, current_dir)
sys.path.insert(0, os.path.join(current_dir, 'backend'))

if __name__ == '__main__':
    from backend.app import app, init_db
    
    init_db()
    print("🌐 HTTP 서버 시작 (포트 80)")
    print("📍 접속: http://16.171.133.35")
    
    app.run(debug=False, host='0.0.0.0', port=80)
