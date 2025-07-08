# GitHub Actions 배포 설정 가이드

## 🔐 GitHub Secrets 설정

GitHub Actions 자동 배포를 위해 다음 Secrets를 설정해야 합니다:

### 1. GitHub Repository 설정
1. GitHub 저장소로 이동
2. `Settings` → `Secrets and variables` → `Actions`
3. `New repository secret` 클릭

### 2. 필수 Secrets 추가

#### EC2_HOST
- **이름**: `EC2_HOST`
- **값**: EC2 인스턴스의 퍼블릭 IP 주소
- **예시**: `54.123.45.67`

#### EC2_USERNAME
- **이름**: `EC2_USERNAME`
- **값**: EC2 인스턴스 사용자명
- **예시**: `ubuntu` (Ubuntu 인스턴스의 경우)

#### EC2_SSH_KEY
- **이름**: `EC2_SSH_KEY`
- **값**: EC2 인스턴스 접속용 SSH 개인키 전체 내용
- **예시**:
```
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA...
(전체 키 내용)
...
-----END RSA PRIVATE KEY-----
```

## 🚀 배포 프로세스

### 자동 배포 (GitHub Actions)
1. `main` 브랜치에 푸시
2. 자동으로 EC2에 배포
3. 서버 재시작

### 수동 배포 (GitHub Actions)
1. GitHub 저장소 → `Actions` 탭
2. `Deploy to EC2` 워크플로우 선택
3. `Run workflow` 클릭

### 테스트 배포
1. `Test Deployment` 워크플로우 실행
2. 연결 및 기본 설정 확인

## 🔧 EC2 인스턴스 초기 설정

### 1. SSH 키 설정
```bash
# 로컬에서 SSH 키 생성 (없는 경우)
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# 공개키를 EC2에 등록
ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@YOUR_EC2_IP
```

### 2. EC2 보안 그룹 설정
- **SSH (22)**: 0.0.0.0/0 또는 특정 IP
- **HTTP (5000)**: 0.0.0.0/0
- **HTTPS (443)**: 0.0.0.0/0 (선택사항)

### 3. 초기 설정 스크립트 실행
```bash
# EC2에 접속
ssh -i your-key.pem ubuntu@YOUR_EC2_IP

# 설치 스크립트 실행
curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/install.sh | bash
```

## 📊 배포 상태 확인

### 성공한 배포
```bash
# EC2에서 상태 확인
./status.sh

# 로그 확인
tail -f logs/access.log
tail -f logs/error.log
```

### 실패한 배포 디버깅
```bash
# 디버깅 스크립트 실행
./debug_deployment.sh

# 수동 서버 시작
./start_production.sh
```

## 🐛 일반적인 문제 해결

### 1. SSH 연결 실패
- EC2 보안 그룹 확인
- SSH 키 권한 확인: `chmod 600 ~/.ssh/id_rsa`
- EC2 인스턴스 상태 확인

### 2. 패키지 설치 실패
```bash
# 시스템 업데이트
sudo apt-get update -y
sudo apt-get upgrade -y

# Python 재설치
sudo apt-get install python3 python3-pip python3-venv
```

### 3. 포트 충돌
```bash
# 포트 사용 확인
sudo lsof -i :5000

# 프로세스 종료
sudo pkill -f gunicorn
```

### 4. 권한 문제
```bash
# 스크립트 권한 설정
chmod +x *.sh

# 디렉토리 권한 확인
ls -la
```

## 🚨 응급 대응

### 서버 다운시
```bash
# 빠른 재시작
./start_production.sh

# 또는 시스템 서비스 사용
sudo systemctl restart travel-tracker
```

### 롤백 필요시
```bash
# 백업 디렉토리 확인
ls -la ~/travel-tracker-backup-*

# 백업으로 복원
mv travel-tracker travel-tracker-failed
mv travel-tracker-backup-YYYYMMDD-HHMMSS travel-tracker
cd travel-tracker
./start_production.sh
```

## 📱 모니터링

### 로그 모니터링
```bash
# 실시간 로그 확인
tail -f logs/access.log

# 에러 로그 확인
tail -f logs/error.log

# 시스템 로그 확인
sudo journalctl -u travel-tracker -f
```

### 성능 모니터링
```bash
# 시스템 리소스 확인
htop

# 서버 상태 확인
./status.sh
```

## 🔄 업데이트 프로세스

### 안전한 업데이트
1. 테스트 브랜치에서 먼저 테스트
2. `Test Deployment` 워크플로우 실행
3. 문제 없으면 `main` 브랜치로 머지
4. 자동 배포 실행
5. 배포 후 상태 확인

### 긴급 업데이트
1. 직접 서버에 접속
2. 수동으로 코드 업데이트
3. 서버 재시작
4. 나중에 GitHub에 반영
