@echo off
echo 🗑️ 불필요한 파일들을 삭제합니다...

REM 테스트 및 디버그 파일들
if exist "add_test_data.py" del "add_test_data.py"
if exist "debug_routes.py" del "debug_routes.py"
if exist "simulate_route.py" del "simulate_route.py"
if exist "reset_database.py" del "reset_database.py"

REM 중복 실행 스크립트들
if exist "main_https.py" del "main_https.py"
if exist "run_https.py" del "run_https.py"

REM 설정 및 배치 파일들
if exist "setup_https_ec2.sh" del "setup_https_ec2.sh"
if exist "setup_letsencrypt.sh" del "setup_letsencrypt.sh"
if exist "add_https_port.sh" del "add_https_port.sh"
if exist "fix_pem_permissions.bat" del "fix_pem_permissions.bat"
if exist "run_chrome_dev.bat" del "run_chrome_dev.bat"
if exist "get_mobile_https_url.bat" del "get_mobile_https_url.bat"
if exist "upload_to_ec2.bat" del "upload_to_ec2.bat"

REM 가상환경 설정 스크립트들 (하나만 남기고 삭제)
if exist "setup_venv.ps1" del "setup_venv.ps1"
if exist "setup_venv.sh" del "setup_venv.sh"

REM 중복 가이드 문서들
if exist "AWS_STEP_BY_STEP_GUIDE.md" del "AWS_STEP_BY_STEP_GUIDE.md"
if exist "PYCHARM_SETUP.md" del "PYCHARM_SETUP.md"
if exist "ANDROID_STUDIO_GUIDE.md" del "ANDROID_STUDIO_GUIDE.md"
if exist "CORDOVA_GUIDE.md" del "CORDOVA_GUIDE.md"
if exist "PEM_PERMISSION_FIX_GUIDE.md" del "PEM_PERMISSION_FIX_GUIDE.md"
if exist "PYCHARM_GITHUB_GUIDE.md" del "PYCHARM_GITHUB_GUIDE.md"

REM 데이터베이스 파일 (개발용)
if exist "location_data.db" del "location_data.db"

echo ✅ 파일 정리 완료!
echo 📁 남은 핵심 파일들:
dir /b *.py *.md *.txt *.bat *.sh 2>nul

pause
