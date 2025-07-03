@echo off
echo 🌐 현재 PC의 IP 주소 확인
echo =====================================

for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /c:"IPv4"') do (
    set ip=%%i
    set ip=!ip: =!
    echo 📱 모바일에서 접속할 주소: http://!ip!:5000
)

echo.
echo 📋 사용 방법:
echo 1. 위 주소를 모바일 크롬 브라우저에서 열기
echo 2. 메뉴(⋮) → '홈 화면에 추가' 선택
echo 3. 앱처럼 사용 가능!
echo.
pause
