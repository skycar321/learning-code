# Step3: Node.js 웹 서버 구축 및 REST API

이 디렉토리는 Express.js 프레임워크를 사용하여 RESTful API 서버를 구축하는 방법을 학습하기 위한 예제 코드입니다.

## 학습 목표

-   Express.js를 이용한 웹 서버 초기화 및 라우팅 설정
-   미들웨어(`body-parser`, 커스텀 로거)의 역할 및 활용
-   RESTful API 설계 원칙 및 CRUD(Create, Read, Update, Delete) 엔드포인트 구현
-   요청 (`req`) 및 응답 (`res`) 객체 활용

## 프로젝트 구조

```
nodejs/Step3_WebServerAndRESTAPI/
├── package.json              # 프로젝트 메타데이터 및 의존성 정의
├── server.js                 # Express.js 애플리케이션의 메인 파일
├── routes/
│   └── user.js               # 사용자 관련 API 라우트 정의
├── middleware/
│   └── logger.js             # 커스텀 로깅 미들웨어
└── README.md
```

## 파일 설명

-   **`package.json`**:
    -   `main: "server.js"`: 애플리케이션의 메인 스크립트 파일을 `server.js`로 지정합니다.
    -   `scripts`: `npm start` 명령 시 `node server.js`를 실행하고, `npm run dev` 명령 시 `node --watch server.js`를 실행합니다.
    -   `dependencies`: `express` (웹 프레임워크)와 `body-parser` (요청 본문 파싱 미들웨어)를 포함합니다.

-   **`server.js`**:
    -   `express`를 임포트하여 Express 애플리케이션 `app`을 생성합니다.
    -   `app.use(loggerMiddleware)`: 모든 요청에 대해 `loggerMiddleware`를 적용합니다.
    -   `app.use(bodyParser.json())`: JSON 형식의 요청 본문을 파싱하여 `req.body`에 추가합니다.
    -   `app.use('/api/users', userRoutes)`: `/api/users` 경로로 들어오는 모든 요청을 `userRoutes` 모듈로 전달합니다.
    -   `app.use((err, req, res, next) => { ... })`: 4개의 인자를 받는 함수는 Express.js에서 에러 핸들링 미들웨어로 인식되어 모든 에러를 처리합니다.
    -   `app.listen(port, () => { ... })`: 서버를 시작하고 지정된 포트에서 요청을 수신 대기합니다.

-   **`routes/user.js`**:
    -   `express.Router()`를 사용하여 사용자 관련 API 엔드포인트를 정의하는 라우터 인스턴스를 생성합니다.
    -   `router.get('/', ...)`, `router.get('/:id', ...)`, `router.post('/', ...)`, `router.put('/:id', ...)`, `router.delete('/:id', ...)` 등의 메서드를 사용하여 RESTful API의 CRUD 작업을 구현합니다.
    -   `req.params.id`로 경로 파라미터를, `req.body`로 요청 본문을 가져옵니다.

-   **`middleware/logger.js`**:
    -   `function loggerMiddleware(req, res, next) { ... }` 형태로 Express.js 미들웨어 함수를 정의합니다.
    -   요청 메서드와 URL을 콘솔에 로깅하고, `next()`를 호출하여 다음 미들웨어 또는 라우트 핸들러로 요청을 전달합니다.

## 설정 및 실행 방법

`nodejs/Step3_WebServerAndRESTAPI` 디렉토리에서 터미널을 열고 다음 명령어를 실행합니다.

1.  **프로젝트 준비**:
    -   `server.js`, `routes/user.js`, `middleware/logger.js` 파일을 위 내용으로 생성합니다. (`routes` 및 `middleware` 디렉토리 생성 필요)

2.  **의존성 설치**:
    ```bash
    npm install
    ```
    -   `package.json`에 정의된 `express`와 `body-parser` 의존성을 설치합니다.

3.  **애플리케이션 실행**:
    ```bash
    npm start
    # 또는 npm run dev (파일 변경 시 자동 재시작)
    ```
    -   콘솔에 "서버가 http://localhost:3000 에서 실행 중입니다." 메시지가 출력됩니다.

4.  **API 테스트 (예시)**:
    -   웹 브라우저 또는 `curl` 명령어를 사용하여 API를 테스트합니다.
    -   `middleware/logger.js`에 의해 터미널에 요청 로그가 출력되는 것을 확인할 수 있습니다.

    -   **루트 경로 (GET)**:
        ```bash
        curl http://localhost:3000/
        ```
        -   "Node.js Express.js REST API Server!" 메시지가 반환됩니다.

    -   **모든 사용자 조회 (GET)**:
        ```bash
        curl http://localhost:3000/api/users
        ```
        -   임시 사용자 목록이 JSON 형태로 반환됩니다.

    -   **특정 ID의 사용자 조회 (GET)**:
        ```bash
        curl http://localhost:3000/api/users/1
        ```
        -   ID가 1인 사용자 정보가 반환됩니다.

    -   **새 사용자 생성 (POST)**:
        ```bash
        curl -X POST -H "Content-Type: application/json" -d '{"name": "Charlie", "email": "charlie@example.com"}' http://localhost:3000/api/users
        ```
        -   새로 생성된 사용자 정보와 함께 HTTP 201 Created 응답이 반환됩니다.

    -   **사용자 업데이트 (PUT)**:
        ```bash
        curl -X PUT -H "Content-Type: application/json" -d '{"name": "Updated Alice"}' http://localhost:3000/api/users/1
        ```
        -   업데이트된 사용자 정보가 반환됩니다.

    -   **사용자 삭제 (DELETE)**:
        ```bash
        curl -X DELETE http://localhost:3000/api/users/2
        ```
        -   HTTP 204 No Content 응답이 반환됩니다.

## 나쁜 예시와 좋은 예시 (개념)

`server.js`, `routes/user.js`, `middleware/logger.js` 파일 내의 주석을 참조하여, Express.js 웹 서버 구축 및 REST API 개발 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 특히 미들웨어의 역할, 라우팅의 모듈화, RESTful API 원칙 준수, 그리고 에러 처리 전략은 안정적이고 유지보수하기 쉬운 백엔드 서버를 만드는 데 중요합니다.
