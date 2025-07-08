#!/bin/bash
# 배포 문제 진단 및 해결 스크립트

echo "🔍 배포 문제 진단 스크립트"
echo "========================="

# 1. 시스템 정보 확인
echo "📊 시스템 정보:"
echo "OS: $(lsb_release -d 2>/dev/null | cut -f2- || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "Python: $(python3 --version 2>/dev/null || echo '설치되지 않음')"
echo "Git: $(git --version 2>/dev/null || echo '설치되지 않음')"
echo "Curl: $(curl --version 2>/dev/null | head -1 || echo '설치되지 않음')"
echo ""

# 2. 네트워크 연결 확인
echo "🌐 네트워크 연결 테스트:"
if ping -c 1 google.com &> /dev/null; then
    echo "✅ 인터넷 연결 정상"
else
    echo "❌ 인터넷 연결 실패"
fi

if ping -c 1 github.com &> /dev/null; then
    echo "✅ GitHub 연결 정상"
else
    echo "❌ GitHub 연결 실패"
fi
echo ""

# 3. 권한 및 디렉토리 확인
echo "📁 파일 시스템 권한:"
pwd
ls -la
echo ""

# 4. Python 패키지 확인
echo "🐍 Python 환경:"
if [ -d "venv" ]; then
    echo "✅ 가상환경 존재"
    source venv/bin/activate
    echo "가상환경 활성화됨"
    pip list | grep -E "(Flask|gunicorn)" || echo "주요 패키지 설치 확인 필요"
else
    echo "❌ 가상환경 없음"
fi
echo ""

# 5. 포트 사용 현황
echo "🌐 포트 사용 현황:"
netstat -tlnp 2>/dev/null | grep ":5000" || echo "포트 5000 사용 중이 아님"
echo ""

# 6. 프로세스 확인
echo "🔄 관련 프로세스:"
ps aux | grep -E "(python|gunicorn)" | grep -v grep || echo "관련 프로세스 없음"
echo ""

# 7. 로그 파일 확인
echo "📄 로그 파일 확인:"
if [ -d "logs" ]; then
    echo "✅ 로그 디렉토리 존재"
    ls -la logs/
    if [ -f "logs/error.log" ]; then
        echo "최근 에러 로그:"
        tail -10 logs/error.log
    fi
else
    echo "❌ 로그 디렉토리 없음"
fi
echo ""

# 8. 메모리 및 디스크 확인
echo "💾 시스템 리소스:"
echo "메모리: $(free -h | awk '/^Mem:/ {print $3"/"$2}')"
echo "디스크: $(df -h . | awk 'NR==2 {print $3"/"$2" ("$5" 사용)"}')"
echo ""

# 9. 일반적인 문제 해결 제안
echo "🔧 문제 해결 제안:"
echo "1. 시스템 패키지 업데이트: sudo apt-get update && sudo apt-get upgrade"
echo "2. Python 재설치: sudo apt-get install python3 python3-pip python3-venv"
echo "3. 가상환경 재생성: rm -rf venv && python3 -m venv venv"
echo "4. 권한 문제 해결: chmod +x *.sh"
echo "5. 포트 충돌 해결: sudo lsof -i :5000"
echo "6. 방화벽 설정: sudo ufw allow 5000"
echo ""

# 10. 자동 수정 옵션
read -p "🛠️ 자동으로 일반적인 문제를 수정하시겠습니까? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔄 자동 수정 시작..."
    
    # 패키지 업데이트
    echo "📦 시스템 업데이트..."
    sudo apt-get update -y
    sudo apt-get install -y python3 python3-pip python3-venv git curl
    
    # 가상환경 재생성
    echo "🐍 가상환경 재생성..."
    rm -rf venv
    python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    
    # 요구사항 설치
    if [ -f "requirements.txt" ]; then
        echo "📦 패키지 설치..."
        pip install -r requirements.txt
    fi
    
    # 권한 설정
    echo "🔧 권한 설정..."
    chmod +x *.sh
    
    # 로그 디렉토리 생성
    mkdir -p logs
    
    # 방화벽 설정
    echo "🔥 방화벽 설정..."
    sudo ufw allow 5000
    
    echo "✅ 자동 수정 완료!"
    echo "이제 ./start_production.sh 를 실행해보세요."
fi
