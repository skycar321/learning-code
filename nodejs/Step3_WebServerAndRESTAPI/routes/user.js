// nodejs/Step3_WebServerAndRESTAPI/routes/user.js
// Node.js 학습 계획 - 3단계: 웹 서버 구축 및 REST API
// 이 파일은 Express.js 라우터(Router)를 사용하여 사용자 관련 REST API 엔드포인트를 정의합니다.
//
// 라우터는 특정 경로에 대한 요청을 처리하는 핸들러 함수들을 모아놓은 미들웨어입니다.
// 이를 통해 코드를 모듈화하고 유지보수성을 높일 수 있습니다.

const express = require('express'); // Express.js 임포트
const router = express.Router(); // Express.js 라우터 인스턴스 생성

// 임시 사용자 데이터 (실제 프로젝트에서는 데이터베이스에서 가져옵니다)
let users = [
    { id: 1, name: 'Alice', email: 'alice@example.com' },
    { id: 2, name: 'Bob', email: 'bob@example.com' },
];

// -----------------------------------------------------------------------------
// 학습 포인트 1: `router` 객체 및 RESTful API 구현
// - `router.get()`, `router.post()`, `router.put()`, `router.delete()` 메서드를 사용하여
//   HTTP 메서드에 따른 엔드포인트를 정의하고 핸들러 함수를 연결합니다.
// - `:id`와 같이 콜론(`:`)을 사용하여 경로 파라미터를 정의합니다.
// -----------------------------------------------------------------------------

// 모든 사용자 조회 (GET /api/users)
router.get('/', (req, res) => {
    // 나쁜 예시: `GET` 요청으로 민감한 사용자 비밀번호까지 반환하는 것.
    // - 항상 클라이언트에 필요한 최소한의 정보만 반환해야 합니다.
    // - `users.map(user => ({ id: user.id, name: user.name, email: user.email }))` 와 같이
    // - 필요한 필드만 선택하여 반환해야 합니다.
    res.json(users);
});

// 특정 ID의 사용자 조회 (GET /api/users/:id)
router.get('/:id', (req, res) => {
    const id = parseInt(req.params.id); // 경로 파라미터는 문자열이므로 숫자로 변환
    const user = users.find(u => u.id === id);

    if (user) {
        res.json(user);
    } else {
        // 나쁜 예시: 존재하지 않는 리소스 요청 시 200 OK 응답을 보내거나,
        // - 상세한 내부 에러 메시지를 노출하는 것.
        // - RESTful API 원칙에 따라 404 Not Found 응답을 보내야 합니다.
        res.status(404).send('사용자를 찾을 수 없습니다.');
    }
});

// 새 사용자 생성 (POST /api/users)
router.post('/', (req, res) => {
    const { name, email } = req.body; // `body-parser` 미들웨어를 통해 파싱된 요청 본문
    if (!name || !email) {
        return res.status(400).send('이름과 이메일은 필수입니다.');
    }
    const newUser = { id: users.length + 1, name, email };
    users.push(newUser);
    res.status(201).json(newUser); // HTTP 201 Created 응답
});

// 특정 ID의 사용자 업데이트 (PUT /api/users/:id)
router.put('/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const { name, email } = req.body;
    const userIndex = users.findIndex(u => u.id === id);

    if (userIndex !== -1) {
        users[userIndex] = { ...users[userIndex], name, email }; // 기존 사용자 정보 업데이트
        res.json(users[userIndex]);
    } else {
        res.status(404).send('사용자를 찾을 수 없습니다.');
    }
});

// 특정 ID의 사용자 삭제 (DELETE /api/users/:id)
router.delete('/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const initialLength = users.length;
    users = users.filter(u => u.id !== id); // 해당 ID의 사용자 제외

    if (users.length < initialLength) {
        res.status(204).send(); // HTTP 204 No Content (삭제 성공)
    } else {
        res.status(404).send('사용자를 찾을 수 없습니다.');
    }
});

// -----------------------------------------------------------------------------
// 학습 포인트 2: 데이터베이스 연동 (개념)
// - 실제 프로젝트에서는 위 `users` 배열 대신 MongoDB (Mongoose), PostgreSQL (Sequelize) 등
//   데이터베이스와 연동하여 데이터를 영구적으로 저장하고 관리합니다.
// - 데이터베이스 드라이버 또는 ORM(Object-Relational Mapping) 라이브러리를 사용합니다.
// -----------------------------------------------------------------------------
// 나쁜 예시: 모든 데이터베이스 쿼리 로직을 라우트 핸들러 내에 직접 작성하는 것.
// - 코드가 복잡해지고, 테스트하기 어려워지며, 데이터베이스 로직과 API 로직이 강하게 결합됩니다.
// - 데이터베이스 로직은 별도의 서비스(Service) 또는 리포지토리(Repository) 레이어로 분리해야 합니다.

// 라우터 모듈 내보내기
module.exports = router;

/*
이 코드를 실행하려면:

1. `server.js` 파일과 함께 `nodejs/Step3_WebServerAndRESTAPI/routes` 디렉토리에 이 파일을 `user.js`로 저장.
*/
