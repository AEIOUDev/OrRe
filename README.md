# 🏪 오리 가오리 - 원격 웨이팅 및 주문 관리 시스템
## 🙋 MyKnow: PM, FE, DevOps, QA
- 본 프로젝트에서 Flutter 기반 사용자/점주용 앱 개발, CI/CD 구축, 그리고 QA 프로세스 설계 및 테스트 자동화 전반을 담당했습니다.
- 실시간 연결 안정성을 위한 WebSocket 재연결 알고리즘, 다양한 디바이스 대응을 위한 플랫폼 대응 로직, 그리고 운영 편의를 위한 DevOps 설계에 중점을 두었습니다.

## 📌 프로젝트 소개
- **오리 가오리**는 가게의 웨이팅과 주문을 원격으로 관리할 수 있도록 도와주는 서비스입니다.  
- 사용자는 매장 방문 전 **웨이팅 인원을 확인하고 예약**할 수 있으며, **QR/NFC를 활용하여 비회원도 웨이팅**이 가능합니다.  
- 매장 점주는 **앱을 통해 웨이팅과 주문을 실시간으로 관리**할 수 있어 운영 효율을 극대화할 수 있습니다.  

## 🎯 주요 기능  
![Functions](https://github.com/user-attachments/assets/61309f4f-a3f5-4036-84a2-e9ffb6d6581b)

### 🔹 1. 원격 웨이팅 확인 및 예약  
- ✅ 사용자는 앱에서 대기 인원을 확인하고 사전 웨이팅을 등록할 수 있습니다.  

### 🔹 2. NFC/QR을 통한 비회원 웨이팅  
- ✅ 회원이 아니더라도 매장 앞에서 **QR 코드 또는 NFC 태그**를 이용해 웨이팅을 등록할 수 있습니다.  

### 🔹 3. NFC/QR을 통한 비대면 주문  
- ✅ 테이블마다 부착된 **QR 코드/NFC 태그를 스캔하여 비대면 주문**을 진행할 수 있습니다.  
- ✅ 인력 부담을 줄이고 운영 효율을 높일 수 있습니다.  

### 🔹 4. 점주를 위한 관리 앱 제공  
- ✅ 점주는 **웨이팅 및 주문을 한 곳에서 통합 관리**할 수 있습니다.  
- ✅ 실시간으로 변동되는 데이터를 반영하여 손쉽게 매장을 운영할 수 있습니다.  

## 🏗 시스템 아키텍처  
![System Architecture - BACKEND](https://github.com/user-attachments/assets/5a79d2ee-45c4-415b-8dfb-4d23ad1c0980)
![System Architecture - ORRE](https://github.com/user-attachments/assets/19611b2d-a95b-40f4-9fd9-4f4a263facd6)
![System Architecture - GAORRE](https://github.com/user-attachments/assets/25fc2975-23a8-4b5a-8040-ff7302c7093d)

## 📺 소개 영상  
🔗 [원격 웨이팅 앱 오리, 가오리 시연 영상](https://www.youtube.com/watch?v=tMEdkNkiJkg)  

## 🚀 기술 스택  

### **Frontend**  
- ✅ Flutter (사용자 및 점주용 앱) 및 WASM 기반 Web page
- ✅ Custom Animation, Responsive UI/UX

### **Backend**    
- ✅ Spring boot  
- ✅ MySQL  

### **Infrastructure**  
- ✅ AWS (EC2, S3, CloudWatch)  
- ✅ Nginx (Reverse Proxy & Load Balancer)
- ✅ GitHub Actions 기반 CI/CD 구성
- ✅ Xcode Cloud를 통한 배포 자동화 

## 🧪 QA 및 운영 안정화

### ✅ QA 프로세스 정립 및 적용
- 크로스 플랫폼 QA 시나리오 수립 및 테스트
- Android/iOS 디바이스별 이슈 추적 및 해결
- 웨이팅/주문 흐름 관련한 edge case 수동 테스트 주도

### ✅ 운영 이슈 모니터링 및 대응
- 실시간 로그 모니터링
- 앱 크래시 및 비정상 요청 모니터링 자동화
- 앱 업데이트 자동 알림 및 Remote Config를 통한 hotfix 구조 설계

## 🛠 기술적 과제 및 해결

### 🔥 1. 실시간 상태 동기화 이슈
- 사용자와 점주 앱 간 상태 동기화 문제를 개선하기 위해 백엔드의 데이터 반영 주기를 고려한 UI 상태 관리 구조 설계
- Riverpod 기반 상태관리로 실시간 상태 반영과 성능 균형 확보

### 🔥 2. 플랫폼 이슈 및 대응
- iOS에서의 NFC 미지원 기기 고려한 graceful fallback 처리
- Android에서 특정 제조사 기기의 QR 스캔 버그 대응

### 🔥 3. 연결 안정성 확보
- WebSocket 연결이 불안정하거나 끊어진 경우를 대비하여 연결 상태를 주기적으로 점검하는 헬스 체크 로직 구현
- 연결이 끊긴 경우 HTTPS fallback 요청을 통해 서버 상태를 점검한 후 자동으로 WebSocket 재연결

## 📸 실제 매장 도입 예시

![sundobu](https://github.com/user-attachments/assets/7044bfa4-729e-427e-a58c-1ac33fbaa013)
![gompocha](https://github.com/user-attachments/assets/20409b38-2d07-483e-bc31-2a792ed335c7)
