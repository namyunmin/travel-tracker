#!/bin/bash
# ngrok으로 빠른 HTTPS 테스트

echo "🚀 ngrok으로 HTTPS 터널 생성..."

# ngrok 설치 (Ubuntu/Debian)
if ! command -v ngrok &> /dev/null; then
    echo "📦 ngrok 설치 중..."
    wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
    tar xvzf ngrok-v3-stable-linux-amd64.tgz
    sudo mv ngrok /usr/local/bin
fi

echo "⚠️  ngrok 계정 설정이 필요합니다:"
echo "1. https://ngrok.com 에서 무료 계정 생성"
echo "2. 토큰 복사 후 아래 명령어 실행:"
echo "   ngrok config add-authtoken YOUR_TOKEN"
echo ""
echo "설정 완료 후 Flask 앱 실행:"
echo "cd ~/my_web_app && source venv/bin/activate && python main.py &"
echo ""
echo "그 다음 새 터미널에서:"
echo "ngrok http 5000"
echo ""
echo "✅ ngrok이 제공하는 https://xxx.ngrok.io 주소로 모바일 테스트 가능!"
