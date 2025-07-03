#!/bin/bash
# EC2에서 HTTPS 설정 자동화 스크립트

echo "🔒 HTTPS 설정 시작..."

# 도메인 입력 받기
read -p "도메인을 입력하세요 (예: yourdomain.com): " DOMAIN

if [ -z "$DOMAIN" ]; then
    echo "❌ 도메인을 입력해야 합니다."
    exit 1
fi

echo "🔧 Nginx 및 Certbot 설치..."
sudo apt update
sudo apt install nginx certbot python3-certbot-nginx -y

echo "📝 Nginx 설정 파일 생성..."
sudo tee /etc/nginx/sites-available/travel-tracker << EOF > /dev/null
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

echo "🔗 Nginx 사이트 활성화..."
sudo ln -sf /etc/nginx/sites-available/travel-tracker /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

echo "🔄 Nginx 재시작..."
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx

echo "📜 SSL 인증서 발급..."
sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN

echo "🔒 방화벽 설정..."
sudo ufw allow 'Nginx Full'
sudo ufw allow ssh
sudo ufw --force enable

echo "✅ HTTPS 설정 완료!"
echo "🌐 이제 https://$DOMAIN 으로 접속 가능합니다."
echo ""
echo "📋 Flask 앱 실행 명령어:"
echo "cd ~/my_web_app"
echo "source venv/bin/activate"
echo "python main.py"
