# Step5: Node.js 배포 및 마이크로서비스

이 디렉토리는 Node.js 애플리케이션의 Docker 컨테이너화 및 클라우드 배포, CI/CD 파이프라인 연동, 그리고 마이크로서비스 아키텍처 개념을 학습하기 위한 예제 코드입니다.

## 학습 목표

-   Docker를 이용한 Node.js 애플리케이션 컨테이너화
-   다단계 빌드(`Multi-stage Builds`)를 이용한 Docker 이미지 최적화
-   클라우드 플랫폼 배포 및 CI/CD 파이프라인 연동 개념
-   마이크로서비스 아키텍처의 개념 이해

## 프로젝트 구조

```
nodejs/Step5_DeploymentAndMicroservices/
├── Dockerfile                # Docker 이미지 빌드 정의
├── package.json              # 프로젝트 메타데이터 및 의존성 정의
├── server.js                 # 컨테이너화될 간단한 Express.js 앱
└── README.md
```

## 파일 설명

-   **`Dockerfile`**:
    -   `FROM node:18-alpine AS builder`: `node:18-alpine` 이미지를 사용하여 의존성을 설치하고 애플리케이션을 빌드하는 첫 번째(`builder`) 단계를 정의합니다. `alpine` 기반 이미지는 크기가 작아 프로덕션 이미지에 적합합니다.
    -   `COPY package*.json ./`: `package.json`과 `package-lock.json`만 먼저 복사하여 의존성 레이어를 캐싱합니다.
    -   `RUN npm install --omit=dev`: 개발 의존성을 제외하고 프로덕션 의존성만 설치합니다.
    -   `COPY . .`: 애플리케이션 소스 코드를 복사합니다.
    -   `FROM node:18-alpine`: 두 번째 (`runner`) 단계에서는 다시 경량 Node.js 이미지를 사용합니다.
    -   `COPY --from=builder /app /app`: `builder` 단계에서 설치된 의존성과 애플리케이션 코드를 복사합니다.
    -   `EXPOSE 3000`: 컨테이너가 3000번 포트를 통해 외부와 통신할 것임을 문서화합니다.
    -   `CMD ["node", "server.js"]`: 컨테이너가 시작될 때 `node server.js` 명령을 실행하여 애플리케이션을 시작합니다.

-   **`package.json`**:
    -   `main: "server.js"`: 애플리케이션의 메인 스크립트 파일을 `server.js`로 지정합니다.
    -   `dependencies`: `express`를 포함합니다.

-   **`server.js`**:
    -   Express.js를 사용하여 루트 경로(`/`)로 들어오는 요청에 "Hello from Dockerized Node.js App!" 메시지를 반환하는 간단한 웹 서버입니다.

## 설정 및 실행 방법

`nodejs/Step5_DeploymentAndMicroservices` 디렉토리에서 터미널을 열고 다음 명령어를 실행합니다.

1.  **프로젝트 준비**:
    -   `package.json` 및 `server.js` 파일을 위 내용으로 생성합니다.
    -   `Dockerfile` 파일을 위 내용으로 생성합니다.

2.  **Docker 이미지 빌드**:
    ```bash
    docker build -t my-nodejs-app:1.0 .
    ```
    -   `my-nodejs-app`이라는 이름으로 `1.0` 버전의 Docker 이미지를 빌드합니다. `.`은 현재 디렉토리에서 `Dockerfile`을 찾도록 지시합니다.

3.  **Docker 컨테이너 실행**:
    ```bash
    docker run -p 3000:3000 my-nodejs-app:1.0
    ```
    -   빌드된 Docker 이미지를 사용하여 컨테이너를 실행합니다. `-p 3000:3000`은 호스트의 3000번 포트를 컨테이너의 3000번 포트에 매핑합니다.

4.  **애플리케이션 테스트**:
    -   웹 브라우저를 열고 `http://localhost:3000`으로 접근합니다.
    -   컨테이너에서 실행 중인 Node.js 애플리케이션의 "Hello from Dockerized Node.js App!" 메시지가 표시됩니다.

5.  **컨테이너 중지 및 삭제**:
    ```bash
    docker ps  # 실행 중인 컨테이너 ID 확인
    docker stop <컨테이너 ID>
    docker rm <컨테이너 ID>
    docker rmi my-nodejs-app:1.0 # 생성된 Docker 이미지 삭제
    ```

## CI/CD 파이프라인 연동 (개념)

-   **GitHub Actions / GitLab CI / Jenkins**: CI/CD 도구에서 `docker build`, `docker push` 명령을 사용하여 Node.js 애플리케이션 이미지를 자동으로 빌드하고 Docker Registry (Docker Hub, AWS ECR, Google Container Registry, Nexus Docker Registry)에 푸시할 수 있습니다.
-   **Kubernetes / Docker Swarm**: 빌드된 이미지를 Kubernetes 클러스터 또는 Docker Swarm에 배포하여 서비스를 확장하고 관리합니다.
-   **Cloud Platforms (AWS Lambda, Google Cloud Run, Azure App Service)**: 컨테이너화된 애플리케이션을 클라우드 제공업체의 관리형 서비스에 배포하여 서버 관리 부담을 줄입니다.

## 마이크로서비스 아키텍처 (개념)

-   Docker와 같은 컨테이너 기술은 마이크로서비스 아키텍처 구현의 핵심입니다. 각 마이크로서비스는 독립적인 Docker 컨테이너로 패키징되고 배포될 수 있습니다.
-   Node.js는 경량하고 빠른 특성으로 마이크로서비스 개발에 매우 적합합니다.
-   서비스 간 통신: HTTP/REST, gRPC, 메시지 큐(RabbitMQ, Kafka) 등을 사용합니다.

## 나쁜 예시와 좋은 예시 (개념)

`Dockerfile` 내의 주석을 참조하여, Docker를 이용한 Node.js 애플리케이션 배포 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 다단계 빌드를 통한 이미지 최적화, `.dockerignore` 파일 활용, 보안을 위한 최소 권한 이미지 사용 등은 프로덕션 환경에서 안전하고 효율적인 컨테이너 이미지를 만드는 데 중요합니다.
