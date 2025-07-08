#!/bin/bash
# 프로덕션 환경에서 앱 실행

set -e  # 에러 시 스크립트 중단

cd "$(dirname "$0")"

echo "🚀 프로덕션 서버 시작 스크립트"
echo "📅 시작 시간: $(date)"

# 가상환경 확인 및 활성화
if [ ! -d "venv" ]; then
    echo "❌ 가상환경이 없습니다. 먼저 설치 스크립트를 실행하세요."
    exit 1
fi

source venv/bin/activate

# 환경변수 설정
export FLASK_ENV=production
export FLASK_DEBUG=False

# 기존 프로세스 종료
echo "🔄 기존 프로세스 확인 및 종료..."
pkill -f "python.*main.py" 2>/dev/null || true
pkill -f "gunicorn.*app:app" 2>/dev/null || true

# PID 파일이 있으면 해당 프로세스 종료
if [ -f "gunicorn.pid" ]; then
    if kill -0 "$(cat gunicorn.pid)" 2>/dev/null; then
        echo "🔄 기존 Gunicorn 프로세스 종료 중..."
        kill "$(cat gunicorn.pid)"
        sleep 3
    fi
    rm -f gunicorn.pid
fi

sleep 2

# 로그 디렉토리 생성
mkdir -p logs

# 데이터베이스 초기화 (필요시)
echo "🗄️ 데이터베이스 초기화 확인..."
python3 -c "
import sys
sys.path.insert(0, '.')
from backend.app import init_db
init_db()
print('✅ 데이터베이스 초기화 완료')
"

# 프로덕션 서버로 실행 (Gunicorn 사용)
echo "🚀 Gunicorn 서버 시작 중..."

# Gunicorn 설정
gunicorn \
    --bind 0.0.0.0:5000 \
    --workers 2 \
    --worker-class sync \
    --timeout 120 \
    --keep-alive 60 \
    --max-requests 1000 \
    --max-requests-jitter 100 \
    --access-logfile logs/access.log \
    --error-logfile logs/error.log \
    --log-level info \
    --daemon \
    --pid gunicorn.pid \
    --user $(whoami) \
    backend.app:app

# 서버 시작 확인
sleep 3
if [ -f "gunicorn.pid" ] && kill -0 "$(cat gunicorn.pid)" 2>/dev/null; then
    echo "✅ 서버가 성공적으로 시작되었습니다!"
    echo "📊 프로세스 ID: $(cat gunicorn.pid)"
    echo "📄 액세스 로그: tail -f logs/access.log"
    echo "📄 에러 로그: tail -f logs/error.log"
    echo "⏹️  서버 중지: ./stop_production.sh"
    
    # 외부 IP 확인 시도
    PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "YOUR-EC2-IP")
    echo "🌐 접속 주소: http://$PUBLIC_IP:5000"
    
    # 상태 확인
    echo "📊 서버 상태:"
    ps aux | grep gunicorn | grep -v grep
    
else
    echo "❌ 서버 시작 실패!"
    if [ -f "logs/error.log" ]; then
        echo "📄 에러 로그:"
        tail -20 logs/error.log
    fi
    exit 1
fi

echo "🎉 프로덕션 서버 시작 완료!"
