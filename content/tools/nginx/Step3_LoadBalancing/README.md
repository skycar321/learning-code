# Step3: Nginx 로드 밸런싱

이 디렉토리는 Nginx를 로드 밸런서로 설정하고, 다양한 로드 밸런싱 방식을 적용하는 방법을 학습하기 위한 예제 코드입니다.

## 학습 목표

-   로드 밸런싱의 개념 및 필요성 이해
-   `upstream` 블록을 이용한 백엔드 서버 그룹 정의
-   라운드 로빈(기본값), `least_conn`, `ip_hash` 등 다양한 로드 밸런싱 방식 설정
-   서버 가중치 (`weight`) 및 서버 상태 (`down`, `backup`) 설정
-   세션 지속성 및 헬스 체크의 중요성 파악

## 프로젝트 구조

```
nginx/Step3_LoadBalancing/
├── docker-compose.yaml       # Docker Compose 설정 파일
├── nginx.conf                # Nginx 로드 밸런싱 설정 파일
├── backend-app/              # 백엔드 애플리케이션의 정적 콘텐츠 (두 인스턴스에서 공유)
│   └── index.html
└── README.md
```

## 파일 설명

-   **`docker-compose.yaml`**:
    -   `nginx` 서비스: Nginx 컨테이너를 로드 밸런서로 실행하고, 호스트의 80번 포트를 컨테이너의 80번 포트에 매핑합니다. `nginx.conf` 파일을 마운트하고, `backend-app1`, `backend-app2` 서비스가 시작된 후에 Nginx가 시작되도록 `depends_on`을 설정합니다.
    -   `backend-app1`, `backend-app2` 서비스: 각각 `node:14-alpine` 이미지를 사용하여 간단한 백엔드 웹 애플리케이션 인스턴스를 시뮬레이션합니다. 컨테이너 내부의 3000번 포트를 노출하고 (`expose`), `backend-app/index.html` 파일을 제공합니다.

-   **`nginx.conf`**:
    -   **`upstream backend_servers { ... }`**: `backend-app1:3000`과 `backend-app2:3000` 두 개의 서버로 구성된 백엔드 서버 그룹을 정의합니다.
        -   **로드 밸런싱 방식**: `round robin` (기본값) 외에 `least_conn` (최소 연결), `ip_hash` (IP 해시) 등의 방식을 주석 처리된 예시로 제공합니다.
        -   **서버 옵션**: `weight` (가중치), `down` (비활성화), `backup` (백업 서버) 등의 옵션을 통해 각 서버의 동작을 제어할 수 있습니다.
    -   **`server { listen 80; server_name localhost; ... }`**:
        -   `proxy_pass http://backend_servers;`: 클라이언트의 요청을 `backend_servers` `upstream` 그룹으로 전달하여 로드 밸런싱이 이루어지도록 합니다.

-   **`backend-app/index.html`**:
    -   두 백엔드 애플리케이션 인스턴스가 제공할 동일한 HTML 파일입니다. 이 HTML 파일의 내용(`Hello from Backend App 1!`, `Hello from Backend App 2!`)은 컨테이너가 시작될 때 `command` 옵션으로 주입됩니다.

## 설정 및 실행 방법

`nginx/Step3_LoadBalancing` 디렉토리에서 터미널을 열고 다음 명령어를 실행합니다.

1.  **프로젝트 준비**:
    -   `backend-app` 디렉토리를 생성하고 `index.html` 파일을 위 `nginx.conf` 주석 예시 내용으로 생성합니다.

2.  **컨테이너 시작**:
    ```bash
    docker-compose up -d
    ```
    -   Nginx 및 두 백엔드 애플리케이션 컨테이너가 시작됩니다.

3.  **로드 밸런싱 테스트**:
    -   웹 브라우저를 열고 `http://localhost`로 여러 번 접근합니다.
    -   콘솔 로그(`docker-compose logs -f`) 또는 웹 페이지에 "Hello from Backend App 1!"과 "Hello from Backend App 2!" 메시지가 번갈아 나타나는 것을 확인합니다 (기본 라운드 로빈 방식).

    -   **다른 로드 밸런싱 방식 테스트**:
        -   `nginx.conf` 파일에서 `least_conn;` 또는 `ip_hash;` 주석을 해제하고 `docker-compose restart nginx` 명령으로 Nginx 컨테이너를 재시작합니다.
        -   `ip_hash`의 경우, 동일한 클라이언트 IP에서 항상 동일한 백엔드 앱의 응답을 받는지 확인합니다.

4.  **컨테이너 중지 및 삭제**:
    ```bash
    docker-compose down
    ```

## 나쁜 예시와 좋은 예시 (개념)

`nginx.conf` 파일 내의 주석을 참조하여, Nginx 로드 밸런싱 설정 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 특히 트래픽 패턴, 서버 성능, 세션 지속성 요구 사항 등을 고려하여 적절한 로드 밸런싱 전략을 선택하고, 백엔드 서버의 헬스 체크를 통해 장애에 대비하는 것이 중요합니다.
