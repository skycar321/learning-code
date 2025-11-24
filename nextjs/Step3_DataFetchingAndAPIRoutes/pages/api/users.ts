// nextjs/Step3_DataFetchingAndAPIRoutes/pages/api/users.ts
// Next.js 학습 계획 - 3단계: 데이터 페칭 및 API 라우팅
// 이 파일은 Next.js의 API 라우트(`pages/api/users.ts`)를 보여주는 예시입니다.
// `pages/api` 디렉토리 내의 파일들은 서버리스 함수(Serverless Function) 형태로 동작하며,
// 클라이언트 측 요청에 응답하는 백엔드 API 엔드포인트를 구축할 수 있습니다.
//
// API 라우트는 데이터베이스 연동, 외부 API 호출, 인증 로직 등
// 서버 측에서만 가능한 작업을 수행하는 데 사용됩니다.

import { NextApiRequest, NextApiResponse } from 'next';

// 임시 사용자 데이터 (실제 프로젝트에서는 데이터베이스에서 가져옵니다)
const users = [
  { id: 1, name: 'Alice', email: 'alice@example.com' },
  { id: 2, name: 'Bob', email: 'bob@example.com' },
  { id: 3, name: 'Charlie', email: 'charlie@example.com' },
];

// -----------------------------------------------------------------------------
// 학습 포인트 1: API 라우트 핸들러 함수
// - `NextApiRequest`: 들어오는 HTTP 요청 객체입니다. 쿼리 파라미터, 요청 본문, 헤더 등을 포함합니다.
// - `NextApiResponse`: HTTP 응답 객체입니다. 상태 코드, 헤더, 응답 본문 등을 설정합니다.
// -----------------------------------------------------------------------------
export default function handler(req: NextApiRequest, res: NextApiResponse) {
  // -----------------------------------------------------------------------------
  // 학습 포인트 2: HTTP 메서드 처리
  // - `req.method`를 사용하여 요청의 HTTP 메서드(GET, POST, PUT, DELETE 등)를 확인하고
  //   각 메서드에 맞는 로직을 수행합니다.
  // - 일반적으로 `switch` 문을 사용하여 메서드를 분기합니다.
  // -----------------------------------------------------------------------------
  if (req.method === 'GET') {
    // 나쁜 예시: API 라우트에서 인증 없이 민감한 모든 사용자 정보를 반환하는 것.
    // - API 라우트도 백엔드이므로 인증, 인가, 데이터 유효성 검사 등
    // - 보안 및 비즈니스 로직을 반드시 구현해야 합니다.
    res.status(200).json(users); // GET 요청 시 모든 사용자 목록 반환
  } else if (req.method === 'POST') {
    // POST 요청 시 새 사용자 생성 (예시)
    const { name, email } = req.body;
    if (!name || !email) {
      return res.status(400).json({ message: 'Name and email are required' });
    }
    const newUser = { id: users.length + 1, name, email };
    users.push(newUser); // 임시 데이터에 추가 (재시작 시 사라짐)
    res.status(201).json(newUser);
  } else {
    // 지원하지 않는 HTTP 메서드
    res.setHeader('Allow', ['GET', 'POST']);
    res.status(405).end(`Method ${req.method} Not Allowed`);
  }
}

/*
이 코드를 실행하려면:

1. `nextjs-basics-app/pages/api/users.ts` 파일 내용을 이 파일의 내용으로 교체.
2. `npm run dev` (또는 `yarn dev`) 명령어로 애플리케이션 실행.
3. `/users` 페이지(`pages/users.tsx`)에서 이 API 라우트를 호출합니다.
4. `curl` 또는 Postman을 사용하여 직접 API 엔드포인트에 요청을 보낼 수 있습니다.
   - GET 요청: `curl http://localhost:3000/api/users`
   - POST 요청: `curl -X POST -H "Content-Type: application/json" -d '{"name": "David", "email": "david@example.com"}' http://localhost:3000/api/users`
*/
