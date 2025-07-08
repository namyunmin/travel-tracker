# EC2 배포용 빠른 설정 스크립트

echo "🚀 여행 추적기 EC2 배포 시작..."

# 시스템 업데이트
sudo apt update

# Python과 필수 도구 설치
sudo apt install python3 python3-pip python3-venv git -y

# 프로젝트 디렉토리로 이동
cd ~/travel-tracker

# 가상환경 생성 및 활성화
python3 -m venv venv
source venv/bin/activate

# 패키지 설치
pip install flask flask-cors

# SSL 설정을 위한 추가 패키지
sudo apt install nginx openssl -y

echo "✅ 기본 설정 완료!"
echo "📋 다음 단계:"
echo "1. 파일들을 업로드하거나 수동으로 생성"
echo "2. python main.py 실행"
echo "3. HTTPS 설정 (선택사항)"
