#!/bin/bash
# 서버 상태 확인 스크립트

echo "📊 여행 추적기 서버 상태 확인"
echo "=================================="

# 프로세스 상태 확인
echo "🔍 프로세스 상태:"
GUNICORN_PROCS=$(ps aux | grep -E "gunicorn.*app:app" | grep -v grep)
PYTHON_PROCS=$(ps aux | grep -E "python.*main.py" | grep -v grep)

if [ -n "$GUNICORN_PROCS" ]; then
    echo "✅ Gunicorn 프로세스 실행 중:"
    echo "$GUNICORN_PROCS"
elif [ -n "$PYTHON_PROCS" ]; then
    echo "✅ Python 개발 서버 실행 중:"
    echo "$PYTHON_PROCS"
else
    echo "❌ 서버 프로세스가 실행되지 않음"
fi

# PID 파일 확인
if [ -f "gunicorn.pid" ]; then
    PID=$(cat gunicorn.pid)
    if kill -0 "$PID" 2>/dev/null; then
        echo "📄 PID 파일: $PID (실행 중)"
    else
        echo "⚠️ PID 파일: $PID (프로세스 없음)"
    fi
else
    echo "📄 PID 파일 없음"
fi

# 포트 확인
echo ""
echo "🌐 포트 상태:"
PORT_5000=$(netstat -tlnp 2>/dev/null | grep ":5000 " || ss -tlnp | grep ":5000 " 2>/dev/null)
if [ -n "$PORT_5000" ]; then
    echo "✅ 포트 5000 사용 중:"
    echo "$PORT_5000"
else
    echo "❌ 포트 5000 사용 중이 아님"
fi

# 로그 파일 확인
echo ""
echo "📄 로그 파일 상태:"
if [ -f "logs/access.log" ]; then
    ACCESS_SIZE=$(wc -l < logs/access.log)
    echo "✅ 액세스 로그: $ACCESS_SIZE 줄"
else
    echo "❌ 액세스 로그 파일 없음"
fi

if [ -f "logs/error.log" ]; then
    ERROR_SIZE=$(wc -l < logs/error.log)
    echo "📄 에러 로그: $ERROR_SIZE 줄"
    if [ "$ERROR_SIZE" -gt 0 ]; then
        echo "⚠️ 최근 에러 로그 (마지막 5줄):"
        tail -5 logs/error.log
    fi
else
    echo "📄 에러 로그 파일 없음"
fi

# 서버 연결 테스트
echo ""
echo "🔗 서버 연결 테스트:"
if command -v curl >/dev/null 2>&1; then
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000 2>/dev/null)
    if [ "$HTTP_STATUS" = "200" ]; then
        echo "✅ 서버 응답 정상 (HTTP $HTTP_STATUS)"
    else
        echo "❌ 서버 응답 실패 (HTTP $HTTP_STATUS)"
    fi
else
    echo "⚠️ curl이 설치되지 않음"
fi

# 외부 IP 확인
echo ""
echo "🌍 외부 접속 정보:"
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "IP 확인 실패")
echo "🌐 외부 접속 주소: http://$PUBLIC_IP:5000"

# 시스템 리소스 확인
echo ""
echo "💻 시스템 리소스:"
echo "CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)% 사용"
echo "메모리: $(free -h | awk '/^Mem:/ {print $3"/"$2}')"
echo "디스크: $(df -h . | awk 'NR==2 {print $3"/"$2" ("$5" 사용)"}')"

echo ""
echo "📱 관리 명령어:"
echo "• 서버 시작: ./start_production.sh"
echo "• 서버 중지: ./stop_production.sh"
echo "• 실시간 로그: tail -f logs/access.log"
echo "• 에러 로그: tail -f logs/error.log"
