#!/bin/bash
# EC2 자동 배포 스크립트 (개선 버전)

set -e  # 오류시 스크립트 중단

echo "🚀 여행 추적기 EC2 배포 시작..."

# 변수 설정
REPO_URL="https://github.com/YOUR_USERNAME/travel-tracker.git"
APP_DIR="travel-tracker"
BACKUP_DIR="${APP_DIR}_backup_$(date +%Y%m%d_%H%M%S)"

echo "📋 배포 정보:"
echo "   Repository: $REPO_URL"
echo "   App Directory: $APP_DIR"
echo "   Backup Directory: $BACKUP_DIR"
echo ""

# 시스템 업데이트 및 필수 패키지 설치
echo "📦 시스템 패키지 업데이트..."
sudo apt update
sudo apt install -y python3 python3-pip python3-venv git curl wget

# 기존 앱 백업
if [ -d "$APP_DIR" ]; then
    echo "💾 기존 앱 백업 중..."
    mv "$APP_DIR" "$BACKUP_DIR"
fi

# GitHub에서 최신 코드 클론
echo "📥 GitHub에서 코드 다운로드..."
git clone "$REPO_URL" "$APP_DIR"
cd "$APP_DIR"

# Python 가상환경 설정
echo "🐍 Python 가상환경 설정..."
python3 -m venv venv
source venv/bin/activate

# 패키지 설치
echo "📦 Python 패키지 설치..."
pip install --upgrade pip
pip install -r requirements.txt

# 실행 권한 설정
echo "🔐 실행 권한 설정..."
chmod +x *.sh 2>/dev/null || true

# 데이터베이스 초기화
echo "🗄️ 데이터베이스 초기화..."
python3 -c "
from backend.app import init_db
init_db()
print('데이터베이스 초기화 완료!')
" 2>/dev/null || echo "데이터베이스 초기화는 앱 실행시 자동으로 됩니다."

echo ""
echo "✅ 배포 완료!"
echo "🌐 서버 시작 방법:"
echo "   cd $APP_DIR"
echo "   source venv/bin/activate"
echo "   python main.py"
echo ""
echo "🔒 HTTPS 설정:"
echo "   sudo ./setup_https_ip.sh"
echo ""
echo "🚀 백그라운드 실행:"
echo "   ./run_background.sh"
