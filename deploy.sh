#!/bin/bash
# EC2 자동 배포 스크립트

echo "🚀 GitHub에서 최신 코드 가져오기..."

# 기존 코드 백업
if [ -d "my_web_app" ]; then
    mv my_web_app my_web_app_backup_$(date +%Y%m%d_%H%M%S)
fi

# GitHub에서 클론
git clone https://github.com/YOUR_USERNAME/travel-tracker.git my_web_app
cd my_web_app

echo "📦 Python 환경 설정..."

# 가상환경 생성
python3 -m venv venv
source venv/bin/activate

# 패키지 설치
pip install -r requirements.txt

echo "✅ 배포 완료!"
echo "🌐 서버 시작: python main.py"
