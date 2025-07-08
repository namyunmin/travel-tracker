#!/bin/bash
# EC2 인스턴스에서 앱 설치 및 설정 스크립트

echo "🚀 여행 추적기 설치 스크립트"
echo "============================"

# 필수 패키지 설치
echo "📦 시스템 업데이트 및 필수 패키지 설치..."
sudo apt-get update -y
sudo apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    git \
    curl \
    wget \
    htop \
    nginx \
    certbot \
    python3-certbot-nginx

# 프로젝트 디렉토리 생성
PROJECT_DIR="$HOME/travel-tracker"
if [ ! -d "$PROJECT_DIR" ]; then
    echo "📁 프로젝트 디렉토리 생성..."
    mkdir -p "$PROJECT_DIR"
fi

cd "$PROJECT_DIR"

# Python 가상환경 설정
echo "🐍 Python 가상환경 설정..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

source venv/bin/activate

# 기본 requirements.txt 생성 (GitHub에서 가져오기 전)
if [ ! -f "requirements.txt" ]; then
    echo "📄 기본 requirements.txt 생성..."
    cat > requirements.txt << 'EOF'
Flask==2.3.3
Flask-CORS==4.0.0
Werkzeug==2.3.7
gunicorn==21.2.0
python-dotenv==1.0.0
EOF
fi

# 패키지 설치
echo "📦 Python 패키지 설치..."
pip install --upgrade pip
pip install -r requirements.txt

# 방화벽 설정
echo "🔥 방화벽 설정..."
sudo ufw allow 22
sudo ufw allow 5000
sudo ufw allow 80
sudo ufw allow 443
sudo ufw --force enable

# 스크립트 실행 권한 설정
echo "🔧 스크립트 권한 설정..."
chmod +x *.sh 2>/dev/null || true

# 서비스 파일 생성 (systemd)
echo "⚙️ 시스템 서비스 설정..."
sudo tee /etc/systemd/system/travel-tracker.service > /dev/null << EOF
[Unit]
Description=Travel Tracker Flask App
After=network.target

[Service]
Type=forking
User=$USER
Group=$USER
WorkingDirectory=$PROJECT_DIR
Environment=PATH=$PROJECT_DIR/venv/bin
ExecStart=$PROJECT_DIR/venv/bin/gunicorn --bind 0.0.0.0:5000 --workers 2 --daemon --pid $PROJECT_DIR/gunicorn.pid backend.app:app
ExecReload=/bin/kill -s HUP \$MAINPID
ExecStop=/bin/kill -s TERM \$MAINPID
PIDFile=$PROJECT_DIR/gunicorn.pid
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# 서비스 등록
sudo systemctl daemon-reload
sudo systemctl enable travel-tracker.service

# 로그 디렉토리 생성
mkdir -p logs

# 환경 정보 출력
echo ""
echo "✅ 설치 완료!"
echo "==============="
echo "📁 프로젝트 경로: $PROJECT_DIR"
echo "🐍 Python 버전: $(python3 --version)"
echo "📦 가상환경: $PROJECT_DIR/venv"
echo "🌐 외부 IP: $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo '확인 불가')"
echo ""
echo "🚀 다음 단계:"
echo "1. GitHub에서 코드 클론 또는 업데이트"
echo "2. ./start_production.sh 실행"
echo "3. http://YOUR-EC2-IP:5000 으로 접속"
echo ""
echo "📱 관리 명령어:"
echo "• 서버 시작: ./start_production.sh"
echo "• 서버 중지: ./stop_production.sh"
echo "• 상태 확인: ./status.sh"
echo "• 시스템 서비스 시작: sudo systemctl start travel-tracker"
echo "• 시스템 서비스 중지: sudo systemctl stop travel-tracker"
echo "• 서비스 상태 확인: sudo systemctl status travel-tracker"
