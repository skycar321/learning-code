# Step4: Nginx SSL/TLS 설정 및 보안

이 디렉토리는 Nginx에 SSL/TLS를 설정하여 HTTPS를 적용하고, 기본적인 보안 설정을 강화하는 방법을 학습하기 위한 예제 코드입니다.

## 학습 목표

-   SSL/TLS 인증서 개요 및 HTTPS의 중요성 이해
-   Nginx에서 SSL/TLS를 설정하여 HTTPS를 적용하는 방법 (`ssl_certificate`, `ssl_certificate_key`)
-   HTTP/2 활성화 및 강력한 암호화 프로토콜/스위트 설정
-   HSTS(HTTP Strict Transport Security) 등 보안 헤더 적용
-   `limit_req`를 이용한 요청 속도 제한

## 프로젝트 구조

```
nginx/Step4_SSLTLSAndSecurity/
├── docker-compose.yaml       # Docker Compose 설정 파일
├── nginx.conf                # Nginx SSL/TLS 및 보안 설정 파일
├── generate-certs.sh         # 자체 서명 인증서 생성 스크립트
├── certs/                    # SSL/TLS 인증서 및 키 파일 저장 디렉토리 (생성 후)
│   ├── nginx.crt
│   └── nginx.key
├── html/                     # Nginx가 제공할 정적 웹 콘텐츠 (HTTP 리다이렉션 테스트용)
│   └── index.html
├── backend-app/              # 백엔드 애플리케이션의 정적 콘텐츠
│   └── index.html
└── README.md
```

## 파일 설명

-   **`docker-compose.yaml`**:
    -   `nginx` 서비스: Nginx 컨테이너를 실행하고, 호스트의 80번(HTTP)과 443번(HTTPS) 포트를 컨테이너에 매핑합니다. `nginx.conf`, `certs`, `html` 디렉토리를 마운트합니다.
    -   `backend-app` 서비스: 간단한 백엔드 웹 애플리케이션을 시뮬레이션합니다. Nginx가 이 백엔드로 HTTPS 트래픽을 프록시합니다.

-   **`nginx.conf`**:
    -   **HTTP to HTTPS 리다이렉션**: 80번 포트로 들어오는 HTTP 요청을 443번 포트의 HTTPS로 자동 리다이렉션하도록 설정합니다.
    -   **HTTPS 설정**: 443번 포트에서 `ssl`과 `http2`를 활성화하고, `ssl_certificate`, `ssl_certificate_key`로 인증서와 개인 키 파일 경로를 지정합니다.
    -   **보안 프로토콜 및 암호화 스위트**: `ssl_protocols`와 `ssl_ciphers`를 사용하여 강력하고 안전한 프로토콜(TLSv1.2, TLSv1.3) 및 암호화 스위트만 허용하도록 설정합니다.
    -   **보안 헤더**: `Strict-Transport-Security` (HSTS), `X-Frame-Options`, `X-Content-Type-Options`, `X-XSS-Protection`, `Referrer-Policy` 등의 보안 헤더를 추가하여 다양한 웹 공격을 방어합니다.
    -   **요청 속도 제한**: `limit_req_zone`과 `limit_req` 지시어를 사용하여 `/api/rate-limited` 경로에 대한 요청 속도를 제한하여 DDoS 공격 및 API 남용을 방어합니다.

-   **`generate-certs.sh`**:
    -   `openssl` 명령어를 사용하여 `localhost` 도메인에 대한 자체 서명 SSL/TLS 인증서(`nginx.crt`)와 개인 키(`nginx.key`)를 `certs` 디렉토리에 생성하는 쉘 스크립트입니다.

-   **`html/index.html`**:
    -   Nginx의 기본 웹 루트(`root /usr/share/nginx/html;`)에 제공될 간단한 정적 HTML 파일입니다.

-   **`backend-app/index.html`**:
    -   Nginx의 리버스 프록시를 통해 접근될 백엔드 애플리케이션의 콘텐츠입니다.

## 설정 및 실행 방법

`nginx/Step4_SSLTLSAndSecurity` 디렉토리에서 터미널을 열고 다음 명령어를 실행합니다.

1.  **프로젝트 준비**:
    -   `html`, `certs`, `backend-app` 디렉토리를 생성하고 `html/index.html`, `backend-app/index.html` 파일을 위 `nginx.conf` 주석 예시 내용으로 생성합니다.

2.  **SSL/TLS 인증서 생성**:
    ```bash
    ./generate-certs.sh
    ```
    -   `certs` 디렉토리에 `nginx.crt` (인증서)와 `nginx.key` (개인 키) 파일이 생성됩니다.

3.  **컨테이너 시작**:
    ```bash
    docker-compose up -d
    ```
    -   Nginx 및 백엔드 애플리케이션 컨테이너가 시작됩니다.

4.  **웹 페이지 접근**:
    -   웹 브라우저를 열고 `https://localhost`로 접근합니다.
        -   자체 서명 인증서이므로 브라우저에서 "안전하지 않은 연결" 경고가 나타날 수 있습니다. "고급" 또는 "예외 추가"를 통해 접속을 허용합니다.
        -   `backend-app/index.html`의 내용이 웹 페이지에 표시되면 성공입니다.
    -   `http://localhost`로 접근 시 자동으로 `https://localhost`로 리다이렉션되는 것을 확인합니다.
    -   `curl -I https://localhost` 명령어로 HTTP 응답 헤더에 `Strict-Transport-Security` 등의 보안 헤더가 포함되어 있는지 확인합니다.

5.  **요청 속도 제한 테스트**:
    -   새 터미널을 열고 다음 명령어를 여러 번 빠르게 실행합니다.
        ```bash
        for i in {1..15}; do curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8080/api/rate-limited; done
        ```
    -   초당 5개 요청(`rate=5r/s`)을 초과하면 503 `Service Temporarily Unavailable` 응답 코드가 반환되는 것을 확인합니다.

6.  **컨테이너 중지 및 삭제**:
    ```bash
    docker-compose down
    ```

## 나쁜 예시와 좋은 예시 (개념)

`nginx.conf` 파일 내의 주석을 참조하여, Nginx SSL/TLS 설정 및 보안 강화 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 웹 통신 보안은 사용자 데이터 보호와 서비스 신뢰도에 직접적인 영향을 미치므로, 강력한 SSL/TLS 설정과 다양한 보안 헤더를 적용하는 것이 중요합니다.
