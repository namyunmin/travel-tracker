#!/bin/bash
# IP 주소용 자체 서명 SSL 인증서 생성

echo "🔒 자체 서명 SSL 인증서 생성..."

# EC2의 퍼블릭 IP 가져오기
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "🌐 감지된 퍼블릭 IP: $PUBLIC_IP"

# SSL 인증서 디렉토리 생성
sudo mkdir -p /etc/ssl/travel-tracker
cd /etc/ssl/travel-tracker

# OpenSSL 설정 파일 생성
sudo tee openssl.cnf << EOF > /dev/null
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = v3_req

[dn]
C=KR
ST=Seoul
L=Seoul
O=Travel Tracker
OU=IT Department
CN=$PUBLIC_IP

[v3_req]
subjectAltName = @alt_names

[alt_names]
IP.1 = $PUBLIC_IP
IP.2 = 127.0.0.1
EOF

# 개인키와 인증서 생성
echo "🔑 개인키 및 인증서 생성 중..."
sudo openssl req -new -x509 -nodes -days 365 \
    -keyout travel-tracker.key \
    -out travel-tracker.crt \
    -config openssl.cnf \
    -extensions v3_req

# 권한 설정
sudo chmod 600 travel-tracker.key
sudo chmod 644 travel-tracker.crt

echo "📝 Nginx 설정..."
sudo tee /etc/nginx/sites-available/travel-tracker << EOF > /dev/null
server {
    listen 80;
    server_name $PUBLIC_IP;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl;
    server_name $PUBLIC_IP;

    ssl_certificate /etc/ssl/travel-tracker/travel-tracker.crt;
    ssl_certificate_key /etc/ssl/travel-tracker/travel-tracker.key;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Nginx 설정 활성화
sudo ln -sf /etc/nginx/sites-available/travel-tracker /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Nginx 재시작
sudo nginx -t
sudo systemctl restart nginx

echo "✅ HTTPS 설정 완료!"
echo "🌐 접속 주소: https://$PUBLIC_IP"
echo "⚠️  브라우저에서 보안 경고가 나타나면 '고급' → '계속 진행' 클릭"
echo ""
echo "📱 모바일에서 테스트:"
echo "1. https://$PUBLIC_IP 접속"
echo "2. '이 사이트는 안전하지 않음' 경고 → '세부정보' → '안전하지 않은 사이트로 이동'"
echo "3. 위치 권한 허용"
