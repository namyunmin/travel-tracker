#!/bin/bash
# Flask 앱을 백그라운드에서 실행하는 스크립트

echo "🚀 Flask 앱 백그라운드 실행..."

# 기존 프로세스 종료
pkill -f "python.*main.py"

cd ~/my_web_app
source venv/bin/activate

# 백그라운드에서 실행
nohup python main.py > app.log 2>&1 &

echo "✅ Flask 앱이 백그라운드에서 실행 중입니다."
echo "📋 상태 확인: ps aux | grep main.py"
echo "📄 로그 확인: tail -f ~/my_web_app/app.log"
echo "⏹️  앱 종료: pkill -f 'python.*main.py'"
