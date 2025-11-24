# Step5: Nginx 성능 최적화 및 모니터링

이 디렉토리는 Nginx의 성능 최적화 기능(캐싱, Gzip 압축, Keepalive)과
모니터링(접근 로그, 에러 로그, Nginx 상태) 설정을 학습하기 위한 예제 코드입니다.

## 학습 목표

-   Nginx 캐싱 (`proxy_cache`)을 이용한 응답 속도 향상 및 백엔드 부하 감소
-   Gzip 압축 (`gzip on`)을 이용한 네트워크 트래픽 절감
-   Keepalive 연결 (`keepalive_timeout`)을 이용한 효율적인 연결 관리
-   접근 로그 (`access_log`) 및 에러 로그 (`error_log`) 설정
-   Nginx 상태 모니터링 (`stub_status`) 활용

## 프로젝트 구조

```
nginx/Step5_PerformanceAndMonitoring/
├── docker-compose.yaml       # Docker Compose 설정 파일
├── nginx.conf                # Nginx 성능 최적화 및 모니터링 설정 파일
├── html/                     # Nginx가 제공할 정적 웹 콘텐츠
│   └── index.html
├── backend-app/              # 백엔드 애플리케이션의 콘텐츠
│   └── index.html
├── nginx-cache/              # Nginx 캐시 저장 디렉토리 (Docker Volume)
├── logs/                     # Nginx 로그 저장 디렉토리 (Docker Volume)
└── README.md
```

## 파일 설명

-   **`docker-compose.yaml`**:
    -   `nginx` 서비스: Nginx 컨테이너를 실행하고, 호스트의 80번 포트를 컨테이너에 매핑합니다. `nginx.conf`, `html` (정적 콘텐츠), `backend-app` (백엔드 콘텐츠) 디렉토리를 마운트합니다.
    -   `./nginx-cache:/var/cache/nginx:rw`: 호스트의 `nginx-cache` 디렉토리를 컨테이너의 캐시 디렉토리에 마운트하여 캐시 데이터를 영구적으로 저장하고 관리합니다.
    -   `./logs:/var/log/nginx:rw`: 호스트의 `logs` 디렉토리를 컨테이너의 로그 디렉토리에 마운트하여 로그 파일을 영구적으로 저장하고 외부에서 접근할 수 있도록 합니다.
    -   `backend-app` 서비스: 간단한 백엔드 웹 애플리케이션을 시뮬레이션합니다. Nginx가 이 백엔드로 요청을 프록시합니다.

-   **`nginx.conf`**:
    -   **접근 로그 및 에러 로그**: `access_log`와 `error_log` 지시어를 사용하여 로그 파일 경로와 형식을 설정합니다. `log_format`을 통해 요청 처리 시간 및 백엔드 응답 시간과 같은 추가 정보를 로그에 기록하도록 구성합니다.
    -   **Keepalive Connection**: `keepalive_timeout`을 설정하여 클라이언트와의 연결을 재사용하고 HTTP 요청 처리 효율을 높입니다.
    -   **캐싱 (`proxy_cache`)**: `proxy_cache_path` 지시어로 캐시 파일을 저장할 디렉토리와 캐시 영역(`my_cache`)의 설정(크기, 만료 시간 등)을 정의합니다. `location /` 블록 내에서 `proxy_cache my_cache`와 같이 이 캐시 영역을 적용하고, `proxy_cache_valid`로 캐시 유효성을 설정합니다.
    -   **Gzip 압축 (`gzip on`)**: `gzip on`을 설정하여 클라이언트에게 응답을 전송하기 전에 데이터를 압축합니다. `gzip_comp_level`, `gzip_types` 등을 통해 압축 레벨과 압축할 파일 타입을 지정합니다.
    -   **Nginx 상태 모니터링 (`stub_status`)**: `/nginx_status` 경로에 `stub_status on`을 설정하여 Nginx의 활성 연결 수, 처리된 요청 수 등의 상태 정보를 제공합니다. 보안을 위해 `allow`, `deny` 지시어를 사용하여 접근을 제한합니다.

-   **`html/index.html`**:
    -   Nginx의 웹 루트에 제공될 정적 HTML 파일입니다.
-   **`backend-app/index.html`**:
    -   Nginx의 리버스 프록시를 통해 접근될 백엔드 애플리케이션의 콘텐츠입니다. 스크립트를 통해 현재 시간을 표시하여 캐싱 동작을 시각적으로 확인할 수 있습니다.

## 설정 및 실행 방법

`nginx/Step5_PerformanceAndMonitoring` 디렉토리에서 터미널을 열고 다음 명령어를 실행합니다.

1.  **프로젝트 준비**:
    -   `html`, `backend-app`, `nginx-cache`, `logs` 디렉토리를 생성하고 `html/index.html`, `backend-app/index.html` 파일을 위 `nginx.conf` 주석 예시 내용으로 생성합니다. `nginx-cache`와 `logs` 디렉토리는 비어있어도 됩니다.

2.  **컨테이너 시작**:
    ```bash
    docker-compose up -d
    ```
    -   Nginx 및 백엔드 애플리케이션 컨테이너가 시작됩니다.

3.  **성능 최적화 및 모니터링 테스트**:
    -   **캐싱 테스트**:
        -   웹 브라우저로 `http://localhost`에 접근합니다. 첫 접근 시에는 백엔드에서 데이터를 가져오므로 응답에 약간의 지연이 있을 수 있습니다.
        -   개발자 도구(F12)의 네트워크 탭에서 응답 헤더(`X-Cache: MISS`)를 확인합니다.
        -   페이지를 새로고침합니다. 두 번째 접근부터는 Nginx 캐시에서 데이터를 가져와 응답 속도가 빨라지는 것을 확인합니다. (`X-Cache: HIT`)
        -   `backend-app/index.html`에 표시되는 시간이 새로고침해도 변경되지 않음을 통해 캐시된 콘텐츠가 제공됨을 확인할 수 있습니다.
    -   **Gzip 압축 테스트**:
        -   개발자 도구의 네트워크 탭에서 응답 헤더에 `Content-Encoding: gzip`이 포함되어 있는지 확인합니다.
        -   `Content-Length`가 압축 전보다 줄어들었는지 확인합니다.
    -   **Nginx 상태 모니터링**:
        -   웹 브라우저로 `http://localhost/nginx_status`에 접근합니다. (컨테이너 내에서 `curl http://localhost/nginx_status`로 확인)
        -   Nginx의 활성 연결 수, 처리된 요청 수 등의 상태 정보를 확인할 수 있습니다.
    -   **로그 확인**:
        -   `docker-compose logs nginx` 명령으로 Nginx 컨테이너의 접근 로그와 에러 로그를 확인합니다. `logs/access.log`와 `logs/error.log` 파일에도 기록됩니다.

4.  **컨테이너 중지 및 삭제**:
    ```bash
    docker-compose down
    ```

## 나쁜 예시와 좋은 예시 (개념)

`nginx.conf` 파일 내의 주석을 참조하여, Nginx 성능 최적화 및 모니터링 설정 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. Nginx의 캐싱, 압축, 연결 관리 기능을 적절히 활용하여 웹 서비스의 성능을 극대화하고, 체계적인 로깅 및 모니터링을 통해 시스템의 안정적인 운영을 보장하는 것이 중요합니다.
