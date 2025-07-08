#!/bin/bash
# 프로덕션 서버 중지 스크립트

echo "🛑 프로덕션 서버 중지 중..."

# PID 파일로 프로세스 종료
if [ -f "gunicorn.pid" ]; then
    PID=$(cat gunicorn.pid)
    if kill -0 "$PID" 2>/dev/null; then
        echo "🔄 Gunicorn 프로세스 중지 중... (PID: $PID)"
        kill "$PID"
        
        # 10초 대기 후 강제 종료
        sleep 10
        if kill -0 "$PID" 2>/dev/null; then
            echo "⚠️ 강제 종료 중..."
            kill -9 "$PID"
        fi
    fi
    rm -f gunicorn.pid
fi

# 혹시 남은 프로세스들 정리
pkill -f "gunicorn.*app:app" 2>/dev/null || true
pkill -f "python.*main.py" 2>/dev/null || true

echo "✅ 서버 중지 완료"

# 현재 실행 중인 관련 프로세스 확인
RUNNING=$(ps aux | grep -E "(gunicorn|python.*main)" | grep -v grep)
if [ -n "$RUNNING" ]; then
    echo "⚠️ 아직 실행 중인 프로세스가 있습니다:"
    echo "$RUNNING"
else
    echo "✅ 모든 서버 프로세스가 종료되었습니다."
fi
