@echo off
echo Python 3.12 호환 환경 설정...

REM 기존 venv 삭제
if exist venv (
    echo 기존 가상환경 삭제 중...
    rmdir /s /q venv
)

REM 새 가상환경 생성
python -m venv venv
if errorlevel 1 (
    echo Python 가상환경 생성 실패
    pause
    exit /b 1
)

REM 가상환경 활성화
call venv\Scripts\activate

REM pip 업그레이드
python -m pip install --upgrade pip

REM Python 3.12 호환 패키지 설치
echo Python 3.12 호환 패키지 설치 중...
pip install Flask==3.0.0
pip install Flask-CORS==4.0.0
pip install Werkzeug==3.0.1
pip install gunicorn==21.2.0
pip install python-dotenv==1.0.0
pip install requests==2.31.0
pip install typing-extensions==4.8.0

REM 설치된 패키지 확인
echo.
echo 설치된 패키지:
pip list

echo.
echo 설정 완료! 다음 명령으로 서버를 시작하세요:
echo call venv\Scripts\activate
echo python main.py
pause
