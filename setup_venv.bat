@echo off
echo 🔧 가상환경을 생성하고 패키지를 설치합니다...

REM 가상환경 생성
python -m venv venv

REM 가상환경 활성화
call venv\Scripts\activate.bat

REM pip 업그레이드
python -m pip install --upgrade pip

REM 필요한 패키지 설치
pip install -r requirements.txt

echo ✅ 설정이 완료되었습니다!
echo 📍 PyCharm에서 프로젝트를 열고 인터프리터를 venv\Scripts\python.exe로 설정하세요
echo 🚀 main.py를 실행하여 서버를 시작할 수 있습니다

pause
