// nodejs/Step3_WebServerAndRESTAPI/server.js
// Node.js 학습 계획 - 3단계: 웹 서버 구축 및 REST API
// 이 파일은 Express.js 프레임워크를 사용하여 RESTful API 서버를 구축하는 예시입니다.
// 라우팅, 미들웨어, 요청 및 응답 객체를 다루며, 간단한 CRUD(Create, Read, Update, Delete) 작업을 수행합니다.

const express = require('express'); // Express.js 프레임워크 임포트
const bodyParser = require('body-parser'); // 요청 본문 파싱 미들웨어
const userRoutes = require('./routes/user'); // 사용자 라우트 임포트
const loggerMiddleware = require('./middleware/logger'); // 커스텀 미들웨어 임포트

const app = express(); // Express 애플리케이션 생성
const port = 3000; // 서버가 수신 대기할 포트

// -----------------------------------------------------------------------------
// 학습 포인트 1: 미들웨어 (Middleware)
// - 요청-응답 주기(cycle) 동안 특정 작업을 수행하는 함수.
// - `app.use()`를 사용하여 미들웨어를 등록합니다. 등록 순서가 중요합니다.
// -----------------------------------------------------------------------------

// 1.1. 로깅 미들웨어 (커스텀 미들웨어 예시)
app.use(loggerMiddleware); // 모든 요청에 대해 로깅 미들웨어 적용

// 1.2. 요청 본문(body) 파싱 미들웨어
// `body-parser` 미들웨어를 사용하여 JSON 형식의 요청 본문을 파싱합니다.
app.use(bodyParser.json()); // JSON 형태의 요청 본문을 파싱하여 `req.body`에 추가

// 1.3. URL 인코딩된 본문 파싱 미들웨어
app.use(bodyParser.urlencoded({ extended: true })); // URL-encoded 형태의 요청 본문을 파싱

// -----------------------------------------------------------------------------
// 학습 포인트 2: 라우팅 (Routing)
// - 클라이언트의 요청 URL(경로)에 따라 적절한 핸들러 함수를 연결합니다.
// - `app.get()`, `app.post()`, `app.put()`, `app.delete()` 등 HTTP 메서드에 따라 정의합니다.
// - `app.use('/api/users', userRoutes)`와 같이 라우터 모듈을 등록할 수 있습니다.
// -----------------------------------------------------------------------------

// 루트 경로 ('/')에 대한 GET 요청 핸들러
app.get('/', (req, res) => {
    // 나쁜 예시: 응답으로 HTML 전체를 템플릿 엔진 없이 직접 텍스트로 보내는 것.
    // - UI가 복잡해지면 관리하기 어렵고, 코드 재사용성이 떨어집니다.
    // - `res.render()`와 같은 템플릿 엔진을 사용하거나, 정적 파일을 제공해야 합니다.
    res.send('<h1>Node.js Express.js REST API Server!</h1><p>Check /api/users for user data.</p>');
});

// 사용자 관련 라우트 등록
app.use('/api/users', userRoutes); // '/api/users' 경로로 시작하는 모든 요청은 userRoutes에서 처리

// -----------------------------------------------------------------------------
// 학습 포인트 3: 에러 핸들링 미들웨어
// - `app.use((err, req, res, next) => { ... })` 형식으로 정의하여 모든 에러를 처리합니다.
// - 미들웨어 체인의 가장 마지막에 등록해야 합니다.
// -----------------------------------------------------------------------------
app.use((err, req, res, next) => {
    // 나쁜 예시: 에러 발생 시 사용자에게 상세한 스택 트레이스를 그대로 노출하는 것.
    // - 보안에 매우 취약하며, 서버 내부 구조를 공격자에게 알려줄 수 있습니다.
    // - 운영 환경에서는 일반적인 에러 메시지만 보여주고, 상세한 로그는 서버에 기록해야 합니다.
    console.error(err.stack);
    res.status(500).send('서버 내부 오류 발생!');
});

// -----------------------------------------------------------------------------
// 학습 포인트 4: 서버 시작
// - `app.listen()` 메서드를 사용하여 서버를 시작하고 지정된 포트에서 요청을 수신 대기합니다.
// -----------------------------------------------------------------------------
app.listen(port, () => {
    console.log(`서버가 http://localhost:${port} 에서 실행 중입니다.`);
    console.log(`사용자 API 엔드포인트: http://localhost:${port}/api/users`);
});

/*
이 코드를 실행하려면:

1. `package.json` 파일과 함께 `nodejs/Step3_WebServerAndRESTAPI` 디렉토리에 이 파일을 `server.js`로 저장.
2. `nodejs/Step3_WebServerAndRESTAPI` 디렉토리에 `routes` 디렉토리를 생성하고 `user.js` 파일을 생성.
3. `nodejs/Step3_WebServerAndRESTAPI` 디렉토리에 `middleware` 디렉토리를 생성하고 `logger.js` 파일을 생성.
4. `npm install express body-parser` 명령으로 의존성 설치.
5. `npm start` (또는 `npm run dev`) 명령으로 애플리케이션 실행.
*/
