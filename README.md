# 여행 경로 추적 앱

## 🌟 프로젝트 소개
실시간 위치 추적과 경로 기록이 가능한 모바일 웹 앱입니다.

## 🚀 빠른 시작

### 로컬 개발 환경
```bash
# 저장소 클론
git clone https://github.com/YOUR_USERNAME/travel-tracker.git
cd travel-tracker

# 가상환경 생성 및 활성화
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 패키지 설치
pip install -r requirements.txt

# 서버 실행
python main.py
```

### AWS EC2 배포
```bash
# EC2 인스턴스에서 실행
curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/travel-tracker/main/deploy.sh | bash
cd my_web_app
source venv/bin/activate
python main.py
```

## ✨ 주요 기능
- 📍 실시간 위치 추적
- 🗺️ 경로 시각화 (컬러 경로)
- 💾 경로 저장 및 관리
- 📱 PWA 지원 (앱처럼 설치 가능)
- 🎨 다양한 경로 색상

## 🛠️ 기술 스택
- **Backend**: Python Flask, SQLite
- **Frontend**: HTML5, CSS3, JavaScript
- **Map**: Leaflet.js + OpenStreetMap
- **Location**: HTML5 Geolocation API

## 📱 PWA 설치
1. 모바일 브라우저에서 접속
2. 크롬 메뉴 → "홈 화면에 추가"
3. 앱처럼 사용 가능!

## 🌐 배포 URL
- **개발**: http://localhost:5000
- **배포**: https://your-domain.com

## 📋 환경 요구사항
- Python 3.8+
- Flask 2.3+
- 모던 브라우저 (Chrome, Firefox, Safari)

## 🤝 기여하기
1. Fork the Project
2. Create your Feature Branch
3. Commit your Changes
4. Push to the Branch
5. Open a Pull Request

## 📄 라이센스
MIT License - 자세한 내용은 LICENSE 파일을 참조하세요.
