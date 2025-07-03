# 🔥 빠른 시작 가이드 (5분 만에 배포!)

## 전체 과정 요약
1. **AWS EC2 인스턴스 생성** (5분)
2. **파일 업로드** (2분)  
3. **서버 실행** (3분)
4. **모바일 테스트** (즉시!)

---

## 🚀 초고속 배포 (경험자용)

### 1. EC2 인스턴스 생성
- Ubuntu 22.04 LTS, t2.micro
- 보안 그룹: SSH(22), HTTP(80), TCP(5000) 모두 0.0.0.0/0
- 키 페어 다운로드

### 2. 자동 업로드 (Windows)
```cmd
# my_web_app 폴더에서 실행
upload_to_ec2.bat
```

### 3. 서버에서 실행
```bash
# EC2 접속 후
cd ~/my_web_app
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
python main.py
```

### 4. 접속 테스트
- PC: `http://EC2-IP:5000`
- 모바일: 크롬에서 접속 → 홈화면에 추가

---

## 🆘 자주 묻는 질문 (FAQ)

### Q: 비용이 얼마나 나올까요?
**A:** 프리티어로 12개월 무료! 단, 다음 조건:
- t2.micro 인스턴스 (다른 타입 선택 시 과금)
- 월 750시간 이내 사용
- 30GB 스토리지 이내

### Q: 인스턴스를 꺼도 되나요?
**A:** 네! 테스트 후 중지하면 비용 거의 안 나옴
- 중지: 컴퓨팅 요금 없음 (스토리지만 소액)
- 시작: 다시 켜면 IP 주소 바뀔 수 있음

### Q: IP 주소가 바뀌는게 싫어요
**A:** Elastic IP 할당 (무료)
- EC2 → Elastic IP → 할당 → 인스턴스에 연결

### Q: HTTPS로 만들고 싶어요
**A:** 도메인 필요
1. 도메인 구매 (가비아, Route53 등)
2. Route53에서 DNS 설정
3. Let's Encrypt SSL 인증서 설치

### Q: 파일 업로드가 안되요
**A:** 다음 순서로 확인:
1. EC2 인스턴스가 "실행 중" 상태인지
2. 보안 그룹에서 SSH 포트가 열려있는지
3. 키 파일 경로가 정확한지
4. 네트워크 연결 상태

### Q: 서버 접속이 안되요
**A:** 
```bash
# Windows에서 텔넷으로 포트 확인
telnet EC2-IP 5000

# 안되면 보안 그룹에서 5000 포트 열기
```

### Q: 앱이 느려요
**A:** 
- 서버 위치: 아시아 태평양(서울) 리전 선택
- 이미지 최적화: 아이콘 크기 줄이기
- CDN 사용: CloudFront 적용

### Q: 데이터베이스가 날아갔어요
**A:** 정기 백업 설정:
```bash
# crontab 설정
crontab -e

# 매일 새벽 2시 백업
0 2 * * * cp ~/my_web_app/backend/location_data.db ~/backup_$(date +\%Y\%m\%d).db
```

---

## 🎯 실제 운영 시 고려사항

### 보안 강화
```bash
# SSH 포트 변경
sudo nano /etc/ssh/sshd_config
# Port 22 → Port 2222 변경

# 불필요한 포트 닫기
sudo ufw delete allow 5000  # 테스트 후 닫기
```

### 모니터링
```bash
# 시스템 리소스 확인
htop

# 디스크 사용량
df -h

# 로그 확인
tail -f ~/my_web_app/app.log
```

### 자동 재시작 설정
```bash
# systemd 서비스 등록
sudo nano /etc/systemd/system/travel-tracker.service

# 서비스 활성화
sudo systemctl enable travel-tracker
sudo systemctl start travel-tracker
```

---

## 🎉 성공 체크리스트

- [ ] EC2 인스턴스 생성 완료
- [ ] SSH 접속 성공  
- [ ] 파일 업로드 완료
- [ ] Python 서버 실행 성공
- [ ] PC에서 웹 접속 성공
- [ ] 모바일에서 앱 접속 성공
- [ ] PWA 홈화면 추가 성공
- [ ] 위치 권한 허용 완료
- [ ] 경로 추적 테스트 성공

**모든 항목이 체크되면 배포 완료! 🚀**

---

## 📞 지원

막히는 부분이 있으면:
1. 에러 메시지 스크린샷
2. 어느 단계에서 멈췄는지
3. EC2 인스턴스 상태

이 정보와 함께 질문하시면 빠르게 도와드릴게요! 😊
