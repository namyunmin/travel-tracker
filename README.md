# 🗺️ 여행 경로 추적 앱

실시간 위치 추적과 경로 기록이 가능한 모바일 웹 앱입니다.

## 🚀 EC2 원클릭 배포

### 빠른 설치
```bash
curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/travel-tracker/main/install.sh | bash
```

### 수동 배포
```bash
# 1. 저장소 클론
git clone https://github.com/YOUR_USERNAME/travel-tracker.git
cd travel-tracker

# 2. 배포 스크립트 실행
chmod +x deploy.sh
./deploy.sh

# 3. 서버 시작
source venv/bin/activate
python main.py
```

## 🔒 HTTPS 설정 (모바일 테스트용)

```bash
# IP 주소용 SSL 인증서 생성
sudo ./setup_https_ip.sh

# HTTPS 서버 실행
python main_https.py
```

## 🌐 접속 방법

- **HTTP**: `http://YOUR_EC2_IP:5000`
- **HTTPS**: `https://YOUR_EC2_IP:5000` (자체 서명 인증서)

## 📱 모바일 테스트

1. 모바일 브라우저에서 HTTPS 주소 접속
2. 보안 경고시 "고급" → "계속 진행" 클릭
3. 위치 권한 허용
4. 여행 경로 추적 시작!

## 🛠️ 서버 관리

```bash
# 프로덕션 서버 시작
./start_production.sh

# 서버 상태 확인
./status.sh

# 서버 중지
pkill -f gunicorn

# 로그 확인
tail -f logs/access.log
```

## ✨ 주요 기능

- 📍 실시간 위치 추적
- 🗺️ 경로 시각화 (컬러 경로)
- 💾 경로 저장 및 관리
- 📱 PWA 지원
- 🔒 HTTPS 지원

## 🔧 기술 스택

- **Backend**: Python Flask + SQLite
- **Frontend**: HTML5 + Leaflet.js
- **Server**: Gunicorn (프로덕션)
- **SSL**: OpenSSL (자체 서명)

## 📋 요구사항

- Ubuntu 18.04+ (EC2 추천)
- Python 3.8+
- 5000번 포트 개방
- 모던 브라우저

## 🤝 GitHub Actions 자동 배포

1. GitHub Secrets 설정:
   - `EC2_HOST`: EC2 IP 주소
   - `EC2_USERNAME`: ubuntu
   - `EC2_SSH_KEY`: SSH 개인키

2. main 브랜치에 push하면 자동 배포

## 📄 라이센스

MIT License
