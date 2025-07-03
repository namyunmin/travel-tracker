#!/bin/bash
# EC2 서버에서 실행할 자동 설정 스크립트

echo "🚀 여행 추적 앱 자동 설치 시작..."

# 시스템 업데이트
echo "📦 시스템 업데이트 중..."
sudo apt update && sudo apt upgrade -y

# 필수 패키지 설치
echo "🔧 필수 패키지 설치 중..."
sudo apt install python3 python3-pip python3-venv git wget curl nano -y

# 방화벽 설정
echo "🔒 방화벽 설정 중..."
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 5000
sudo ufw --force enable

# 프로젝트 폴더 생성
echo "📁 프로젝트 폴더 생성 중..."
mkdir -p ~/my_web_app/backend
mkdir -p ~/my_web_app/frontend/css
mkdir -p ~/my_web_app/frontend/js

# requirements.txt 생성
echo "📝 requirements.txt 생성 중..."
cat > ~/my_web_app/requirements.txt << 'EOF'
Flask==2.3.3
Flask-CORS==4.0.0
Werkzeug==2.3.7
EOF

echo "✅ 자동 설정 완료!"
echo "📋 다음 단계:"
echo "1. 각 파일 내용을 복사해서 붙여넣기"
echo "2. python3 -m venv venv && source venv/bin/activate"
echo "3. pip install -r requirements.txt"
echo "4. python main.py"
