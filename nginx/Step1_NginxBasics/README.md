# Step1: Nginx 기본 개념 및 설치

이 디렉토리는 Nginx의 기본 개념과 Docker Compose를 이용한 설치 및 정적 웹 서버 설정 방법을 학습하기 위한 예제 코드입니다.

## 학습 목표

-   Nginx의 아키텍처 및 주요 설정 파일(`nginx.conf`) 구조 이해
-   `main`, `events`, `http`, `server`, `location` 컨텍스트의 역할 파악
-   Docker Compose를 이용한 Nginx 웹 서버 컨테이너 실행
-   Nginx를 통해 정적 HTML 파일을 제공하는 기본 웹 서버 설정

## 프로젝트 구조

```
nginx/Step1_NginxBasics/
├── docker-compose.yaml       # Docker Compose 설정 파일
├── nginx.conf                # Nginx 메인 설정 파일
├── html/                     # Nginx가 제공할 정적 웹 콘텐츠 디렉토리
│   └── index.html            # 예제 HTML 파일
└── README.md
```

## 파일 설명

-   **`docker-compose.yaml`**:
    -   `image: nginx:latest`: 최신 Nginx Docker 이미지를 사용합니다.
    -   `ports: - "80:80"`: 호스트의 80번 포트를 컨테이너의 80번 포트에 매핑하여 외부에서 HTTP로 Nginx에 접근할 수 있도록 합니다.
    -   `volumes`:
        -   `./nginx.conf:/etc/nginx/nginx.conf:ro`: 호스트의 `nginx.conf` 파일을 Nginx 컨테이너의 기본 설정 파일 경로에 읽기 전용(`ro`)으로 마운트합니다.
        -   `./html:/usr/share/nginx/html:ro`: 호스트의 `html` 디렉토리를 컨테이너의 웹 루트 디렉토리(`usr/share/nginx/html`)에 읽기 전용으로 마운트합니다. Nginx는 이 디렉토리에서 정적 파일을 찾습니다.

-   **`nginx.conf`**:
    -   **`worker_processes auto;`**: Nginx 워커 프로세스 수를 CPU 코어 수에 맞게 자동으로 설정합니다.
    -   **`events { worker_connections 1024; }`**: 각 워커 프로세스가 처리할 최대 동시 연결 수를 정의합니다.
    -   **`http { ... }`**: HTTP 서버의 전역 설정을 포함합니다. `mime.types` 포함, 접근 로그 설정(`access_log`), `sendfile on`, `keepalive_timeout` 등이 정의됩니다.
    -   **`server { listen 80; server_name localhost; ... }`**: 80번 포트에서 `localhost` 도메인으로 들어오는 요청을 처리하는 서버 블록을 정의합니다.
    -   **`location / { root /usr/share/nginx/html; index index.html; }`**: 루트 경로(`/`)에 대한 요청을 처리하며, `/usr/share/nginx/html` 디렉토리에서 `index.html` 파일을 찾아 제공하도록 설정합니다.

-   **`html/index.html`**:
    -   Nginx가 웹 브라우저에 제공할 간단한 정적 HTML 파일입니다.

## 설정 및 실행 방법

`nginx/Step1_NginxBasics` 디렉토리에서 터미널을 열고 다음 명령어를 실행합니다.

1.  **컨테이너 시작**:
    ```bash
    docker-compose up -d
    ```
    -   `nginx:latest` 이미지를 다운로드하고, `my-nginx-webserver`라는 이름의 컨테이너를 백그라운드(`-d`)에서 시작합니다.
    -   호스트의 `nginx.conf`와 `html` 디렉토리가 컨테이너 내부에 마운트됩니다.

2.  **Nginx 상태 확인**:
    ```bash
    docker-compose ps
    docker-compose logs -f nginx
    ```
    -   컨테이너가 `Up` 상태인지 확인합니다. `logs -f nginx` 명령으로 Nginx의 로그를 실시간으로 확인할 수 있습니다.

3.  **웹 페이지 접근**:
    -   웹 브라우저를 열고 `http://localhost`로 접근합니다.
    -   `html/index.html` 파일의 내용이 웹 페이지에 표시되는 것을 확인합니다.

4.  **컨테이너 중지 및 삭제**:
    ```bash
    docker-compose down
    ```
    -   `my-nginx-webserver` 컨테이너를 중지하고 삭제합니다. 이 명령은 볼륨 데이터를 삭제하지 않습니다.
    -   볼륨 데이터까지 삭제하려면 `docker-compose down -v` 명령을 사용합니다.

## 나쁜 예시와 좋은 예시 (개념)

`nginx.conf` 파일 내의 주석을 참조하여, Nginx 기본 설정 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 특히 Nginx 설정 파일과 웹 콘텐츠를 Docker Volume으로 마운트하여 영구적으로 관리하고, 보안을 위해 `root` 경로를 적절히 설정하는 것이 중요합니다.
