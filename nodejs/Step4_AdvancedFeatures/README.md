# Step4: Node.js 고급 기능 및 모범 사례

이 디렉토리는 Node.js의 클러스터링(`cluster`) 모듈, 환경 변수(`dotenv`),
그리고 로깅(`winston`)과 같은 고급 기능 및 모범 사례를 학습하기 위한 예제 코드입니다.

## 학습 목표

-   `cluster` 모듈을 이용한 Node.js 애플리케이션 클러스터링
-   `dotenv`를 이용한 환경 변수 관리
-   `winston`을 이용한 체계적인 로깅 설정
-   Node.js 애플리케이션 프로세스 관리자(`PM2`)의 개념 이해

## 프로젝트 구조

```
nodejs/Step4_AdvancedFeatures/
├── package.json              # 프로젝트 메타데이터 및 의존성 정의
├── index.js                  # 클러스터링, 환경 변수, 로깅 예제
├── .env                      # 환경 변수 정의 파일
├── error.log                 # (생성 후) 에러 로그 파일
├── combined.log              # (생성 후) 모든 로그 파일
└── README.md
```

## 파일 설명

-   **`package.json`**:
    -   `main: "index.js"`: 메인 스크립트 파일을 지정합니다.
    -   `dependencies`: `dotenv` (환경 변수 로드), `express` (간단한 웹 서버), `winston` (로깅)을 포함합니다.

-   **`index.js`**:
    -   **환경 변수 관리 (`dotenv`)**: `dotenv.config()`를 호출하여 `.env` 파일에 정의된 `PORT`, `NODE_ENV`, `API_KEY`와 같은 환경 변수를 `process.env` 객체에 로드합니다.
    -   **로깅 (`winston`)**: `winston.createLogger`를 사용하여 개발/운영 환경에 따라 다른 로그 레벨을 설정하고, 콘솔, 에러 파일(`error.log`), 통합 로그 파일(`combined.log`)에 로그를 출력하도록 구성합니다.
    -   **클러스터링 (`cluster`)**:
        -   `cluster.isMaster`를 통해 현재 프로세스가 마스터 프로세스인지 확인합니다.
        -   마스터 프로세스는 `os.cpus().length`를 통해 CPU 코어 수를 확인하고, `cluster.fork()`를 호출하여 코어 수만큼 워커 프로세스를 생성합니다.
        -   `cluster.on('exit', ...)` 이벤트 핸들러를 사용하여 워커 프로세스가 종료될 경우 자동으로 새로운 워커를 다시 시작하여 서비스의 안정성을 유지합니다.
        -   워커 프로세스는 Express.js 서버를 시작하고 요청을 처리합니다.

-   **`.env`**:
    -   `PORT`, `NODE_ENV`, `API_KEY`와 같은 환경 변수를 key-value 쌍 형태로 정의합니다. 이 파일은 `.gitignore`에 추가하여 Git 추적에서 제외해야 합니다.

## 설정 및 실행 방법

`nodejs/Step4_AdvancedFeatures` 디렉토리에서 터미널을 열고 다음 명령어를 실행합니다.

1.  **프로젝트 준비**:
    -   `index.js` 파일을 위 내용으로 생성합니다.
    -   `.env` 파일을 위 내용으로 생성합니다.

2.  **의존성 설치**:
    ```bash
    npm install
    ```
    -   `package.json`에 정의된 `dotenv`, `express`, `winston` 의존성을 설치합니다.

3.  **애플리케이션 실행**:
    ```bash
    npm start
    # 또는 npm run dev (파일 변경 시 자동 재시작)
    ```
    -   콘솔에 마스터 프로세스가 시작되고 여러 워커 프로세스를 생성하는 로그가 출력됩니다.
    -   워커 프로세스들이 각자 `http://localhost:3000`에서 서버를 실행한다는 메시지가 출력됩니다.

4.  **API 테스트**:
    -   웹 브라우저를 열고 `http://localhost:3000`으로 접근합니다.
    -   페이지를 새로고침하거나 여러 번 접근하면, 콘솔 로그에서 다른 `워커 ${process.pid}`가 요청을 번갈아 처리하는 것을 확인할 수 있습니다.
    -   `error.log` 및 `combined.log` 파일이 생성되어 로깅이 올바르게 작동하는지 확인합니다.

5.  **워커 프로세스 종료 테스트**:
    -   `docker ps`와 유사한 명령으로 `ps aux | grep node`를 실행하여 워커 프로세스의 PID를 확인한 후, `kill <PID>` 명령으로 워커 프로세스 중 하나를 수동으로 종료해봅니다.
    -   콘솔에서 마스터 프로세스가 종료된 워커를 감지하고 새로운 워커를 다시 시작하는 로그를 확인할 수 있습니다.

## 나쁜 예시와 좋은 예시 (개념)

`index.js` 파일 내의 주석을 참조하여, Node.js 고급 기능 및 모범 사례 사용 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 특히 `cluster` 모듈을 통한 멀티 코어 활용, `dotenv`를 통한 환경 변수 관리, `winston`을 통한 체계적인 로깅은 고성능의 안정적인 Node.js 애플리케이션을 구축하고 운영하는 데 필수적입니다.
