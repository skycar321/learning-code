# Nginx 학습 계획

## 개요 (Overview)
Nginx(엔진엑스)는 고성능 웹 서버, 리버스 프록시, 로드 밸런서 및 HTTP 캐시로 널리 사용되는 오픈소스 소프트웨어입니다. 대규모 웹 서비스와 마이크로서비스 아키텍처에서 핵심적인 역할을 하며, 높은 동시 처리 능력과 낮은 메모리 사용량을 자랑합니다. 이 학습 계획은 Nginx의 기본 설정부터 고급 기능, 그리고 실무에 필요한 성능 최적화 및 보안 강화 전략까지 다루어, 웹 서비스 인프라를 효과적으로 구축하고 운영하는 역량을 키우는 것을 목표로 합니다.

## 학습 목표 (Learning Objectives)
*   Nginx의 역할 및 핵심 기능 이해
*   기본 웹 서버 및 리버스 프록시 설정
*   로드 밸런싱을 통한 서비스 가용성 및 확장성 확보
*   SSL/TLS 설정 및 보안 강화
*   성능 최적화 및 문제 해결 능력 향상

## 학습 내용 (Learning Content)

### 1단계: Nginx 기본 개념 및 설치 (Nginx Basics & Installation)
*   Nginx 소개 (Introduction to Nginx) - 역사, 특징, 사용 사례
*   Nginx vs Apache (Nginx vs Apache) - 아키텍처 비교
*   설치 및 초기 설정 (Installation & Initial Setup) - Linux, Docker
*   Nginx 설정 파일 구조 (Nginx Configuration File Structure) - `nginx.conf`, `server`, `location` 블록
*   기본 웹 서버 설정 (Basic Web Server Setup) - 정적 파일 제공

### 2단계: 리버스 프록시 및 가상 호스팅 (Reverse Proxy & Virtual Hosting)
*   리버스 프록시 이해 및 설정 (Understanding & Configuring Reverse Proxy)
    *   `proxy_pass` 지시어
*   가상 호스팅 (Virtual Hosting) - 여러 도메인을 하나의 Nginx로 서비스
    *   이름 기반(Name-based) 및 IP 기반(IP-based) 가상 호스팅
*   HTTP/HTTPS 리다이렉션 (HTTP/HTTPS Redirection)
*   웹소켓 프록시 설정 (WebSocket Proxy Configuration)

### 3단계: 로드 밸런싱 (Load Balancing)
*   로드 밸런싱 개념 및 필요성 (Concepts & Necessity of Load Balancing)
*   Nginx 로드 밸런싱 설정 (Configuring Nginx Load Balancing)
    *   `upstream` 블록 정의
    *   라운드 로빈(Round Robin), IP 해시(IP Hash), 최소 연결(Least Connected) 방식
*   세션 지속성 (Session Persistence)
*   헬스 체크 (Health Checks) - `health_check` 지시어 (Nginx Plus) 또는 커스텀 방식

### 4단계: SSL/TLS 설정 및 보안 (SSL/TLS Setup & Security)
*   SSL/TLS 인증서 개요 (Overview of SSL/TLS Certificates)
*   SSL/TLS 설정 (Configuring SSL/TLS) - `ssl_certificate`, `ssl_certificate_key`
*   HTTPS 적용 및 HTTP/2 활성화 (Applying HTTPS & Enabling HTTP/2)
*   Ciphers 및 Protocols 설정 (Configuring Ciphers & Protocols) - 보안 강화
*   Nginx 방화벽(WAF) 기본 (Basic Nginx WAF) - `limit_req`, `limit_conn`
*   봇 및 스크래퍼 차단 (Blocking Bots & Scrapers)

### 5단계: 성능 최적화 및 모니터링 (Performance Optimization & Monitoring)
*   캐싱 설정 (Configuring Caching) - `proxy_cache`
*   Gzip 압축 (Gzip Compression)
*   버퍼 및 타임아웃 설정 (Buffer & Timeout Settings)
*   Keepalive Connection (Keepalive 연결)
*   접근 로그 및 에러 로그 관리 (Access & Error Log Management)
*   Nginx 상태 모니터링 (Monitoring Nginx Status) - `stub_status` 모듈, Prometheus/Grafana 연동

## 예상 학습 시간 (Estimated Learning Time)
*   각 단계별 3-6시간 (총 15-30시간)

## 실습 과제 (Practical Exercises)
*   Nginx를 웹 서버로 설치하고 정적 웹사이트 호스팅 (Install Nginx & host a static website)
*   두 개의 백엔드 애플리케이션에 대한 리버스 프록시 및 로드 밸런싱 설정 (Set up reverse proxy & load balancing for two backend apps)
*   Let's Encrypt를 이용하여 SSL/TLS 인증서 발급 및 HTTPS 적용 (Apply HTTPS with Let's Encrypt)
*   Nginx 설정 파일을 최적화하여 성능 개선 (Optimize Nginx config for better performance)
*   간단한 Docker Compose 환경에서 Nginx를 리버스 프록시로 사용 (Use Nginx as a reverse proxy in a Docker Compose setup)

## 참고 자료 (References)
*   Nginx 공식 문서 (Nginx Official Documentation)
*   Mastering Nginx by Dimitri Aivaliotis
*   The Nginx HTTP Server by Martin F. N. Slawski
*   각종 Nginx 튜토리얼 및 블로그 (Various Nginx tutorials & blogs)
