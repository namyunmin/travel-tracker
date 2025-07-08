@echo off
echo Python 3.11로 가상환경 재설정...

REM 기존 venv 삭제
if exist venv (
    echo 기존 가상환경 삭제 중...
    rmdir /s /q venv
)

REM Python 3.11로 가상환경 생성
python3.11 -m venv venv
if errorlevel 1 (
    echo Python 3.11이 설치되어 있지 않습니다.
    echo Python 3.11을 설치하거나 python311 명령을 사용하세요.
    pause
    exit /b 1
)

REM 가상환경 활성화
call venv\Scripts\activate

REM pip 업그레이드
python -m pip install --upgrade pip

REM 의존성 설치
pip install -r requirements.txt

echo.
echo 설정 완료! 다음 명령으로 서버를 시작하세요:
echo venv\Scripts\activate
echo python main.py
pause
