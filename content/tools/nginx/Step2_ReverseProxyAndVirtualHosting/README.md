# Step2: Nginx 리버스 프록시 및 가상 호스팅

이 디렉토리는 Nginx를 리버스 프록시로 설정하고, 이름 기반 가상 호스팅을 구현하는 방법을 학습하기 위한 예제 코드입니다.

## 학습 목표

-   Nginx의 리버스 프록시 역할 이해 및 설정
-   `proxy_set_header`를 이용한 요청 헤더 설정
-   이름 기반 가상 호스팅을 이용한 여러 도메인 서비스
-   `default_server`를 이용한 catch-all 서버 설정

## 프로젝트 구조

```
nginx/Step2_ReverseProxyAndVirtualHosting/
├── docker-compose.yaml       # Docker Compose 설정 파일
├── nginx.conf                # Nginx 메인 설정 파일 (리버스 프록시 및 가상 호스팅)
├── backend1/                 # 첫 번째 백엔드 서비스의 정적 콘텐츠
│   └── index.html
├── backend2/                 # 두 번째 백엔드 서비스의 정적 콘텐츠
│   └── index.html
└── README.md
```

## 파일 설명

-   **`docker-compose.yaml`**:
    -   `nginx` 서비스: Nginx 컨테이너를 실행하고, 호스트의 80번 포트를 컨테이너의 80번 포트에 매핑합니다. `nginx.conf` 파일을 마운트하고, `backend1`, `backend2` 서비스가 시작된 후에 Nginx가 시작되도록 `depends_on`을 설정합니다.
    -   `backend1`, `backend2` 서비스: 각각 `node:14-alpine` 이미지를 사용하여 간단한 웹 서버를 시뮬레이션합니다. 컨테이너 내부의 3001번(backend1)과 3002번(backend2) 포트를 노출하고, `volumes`를 통해 호스트의 `backend1`/`backend2` 디렉토리의 `index.html` 파일을 제공합니다.

-   **`nginx.conf`**:
    -   **`proxy_set_header`**: Nginx가 백엔드 서버로 요청을 전달할 때 `Host`, `X-Real-IP`, `X-Forwarded-For`, `X-Forwarded-Proto` 헤더를 설정하여 클라이언트의 실제 정보가 백엔드에 전달되도록 합니다.
    -   **가상 호스팅 (`server` 블록)**:
        -   `server_name app1.example.com`: `app1.example.com` 도메인으로 들어오는 요청을 처리합니다.
        -   `proxy_pass http://backend1:3001;`: 클라이언트의 요청을 `backend1` 컨테이너의 3001번 포트로 리버스 프록시합니다.
        -   `server_name app2.example.com`: `app2.example.com` 도메인으로 들어오는 요청을 처리하고 `backend2` 컨테이너로 리버스 프록시합니다.
        -   `server { listen 80 default_server; server_name _; ... }`: `default_server`로 설정된 서버 블록은 `server_name`이 일치하지 않는 모든 요청을 처리합니다. 여기서는 444 상태 코드를 반환하여 연결을 끊습니다.

-   **`backend1/index.html`, `backend2/index.html`**:
    -   각 백엔드 서비스가 제공할 간단한 HTML 파일입니다.

## 설정 및 실행 방법

`nginx/Step2_ReverseProxyAndVirtualHosting` 디렉토리에서 터미널을 열고 다음 명령어를 실행합니다.

1.  **프로젝트 준비**:
    -   `backend1` 및 `backend2` 디렉토리를 생성하고 각각 `index.html` 파일을 위 `nginx.conf` 주석 예시 내용으로 생성합니다.

2.  **`hosts` 파일 수정**:
    -   로컬 환경에서 가상 호스트를 테스트하기 위해 `hosts` 파일을 수정해야 합니다.
    -   **macOS/Linux**: `/etc/hosts`
    -   **Windows**: `C:\Windows\System32\drivers\etc\hosts`
    -   파일 끝에 다음 두 줄을 추가하고 저장합니다.
        ```
        127.0.0.1 app1.example.com
        127.0.0.1 app2.example.com
        ```

3.  **컨테이너 시작**:
    ```bash
    docker-compose up -d
    ```
    -   Nginx 및 두 백엔드 서비스 컨테이너가 시작됩니다.

4.  **웹 페이지 접근**:
    -   웹 브라우저를 열고 다음 URL로 접근합니다.
        -   `http://app1.example.com`: "Hello from Backend 1!" 메시지가 표시됩니다.
        -   `http://app2.example.com`: "Hello from Backend 2!" 메시지가 표시됩니다.
        -   `http://localhost` (또는 `http://any.other.domain`): Nginx 설정에 따라 444 에러 또는 응답 없음이 발생합니다.

    -   `curl` 명령어로도 테스트할 수 있습니다.
        ```bash
        curl http://app1.example.com
        curl http://app2.example.com
        ```

5.  **컨테이너 중지 및 삭제**:
    ```bash
    docker-compose down
    ```

## 나쁜 예시와 좋은 예시 (개념)

`nginx.conf` 파일 내의 주석을 참조하여, Nginx 리버스 프록시 및 가상 호스팅 설정 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 특히 `proxy_set_header`를 통한 정보 전달과 `default_server`를 이용한 정의되지 않은 요청 처리는 중요한 보안 및 관리 관점입니다.
