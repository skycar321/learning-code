# Step3: Next.js 데이터 페칭 및 API 라우팅

이 디렉토리는 Next.js 애플리케이션에서 클라이언트 측 데이터 페칭과 API 라우팅 기능을 학습하기 위한 예제 코드입니다.

## 학습 목표

-   `useEffect`와 `fetch`를 이용한 클라이언트 측 데이터 페칭 구현
-   Next.js API 라우트를 이용한 백엔드 API 엔드포인트 구축
-   클라이언트/서버 데이터 페칭 전략의 차이점 및 사용 시나리오 이해
-   HTTP 메서드(`GET`, `POST`)에 따른 API 라우트 핸들러 분기 처리

## 프로젝트 구조

```
nextjs/Step3_DataFetchingAndAPIRoutes/
├── pages/
│   ├── users.tsx             # 클라이언트 측 데이터 페칭 예제 페이지
│   └── api/
│       └── users.ts          # Next.js API 라우트 예제
└── README.md
```

## 파일 설명

-   **`pages/users.tsx`**:
    -   `useEffect` 훅을 사용하여 컴포넌트가 마운트될 때 Next.js API 라우트(`/api/users`)를 호출하여 사용자 목록을 가져옵니다.
    -   `useState` 훅을 사용하여 `users` 데이터, `loading` 상태, `error` 상태를 관리하여 로딩 중 및 에러 발생 시 사용자에게 적절한 피드백을 제공합니다.
    -   클라이언트 측 데이터 페칭은 초기 로드 속도보다는 상호작용성이나 사용자 인증이 필요한 데이터에 주로 사용됩니다.

-   **`pages/api/users.ts`**:
    -   `pages/api` 디렉토리 내의 파일은 서버리스 함수 형태로 동작하며, 클라이언트 측 요청에 응답하는 백엔드 API 엔드포인트를 구축할 수 있습니다.
    -   `NextApiRequest`, `NextApiResponse` 타입을 사용하여 요청 및 응답 객체를 다룹니다.
    -   `req.method`를 사용하여 요청의 HTTP 메서드(`GET`, `POST`)를 확인하고 각 메서드에 맞는 로직을 수행합니다.
    -   `GET` 요청 시 임시 사용자 목록을 반환하고, `POST` 요청 시 새 사용자를 생성하는 (임시) 로직을 포함합니다.

## 설정 및 실행 방법

이 예제를 실행하려면 기존 Next.js 프로젝트(`Step1`에서 생성한 프로젝트)를 기반으로 합니다. `Layout` 컴포넌트와 `globals.css` 파일은 `Step1`에서 미리 준비되어 있어야 합니다.

1.  **Next.js 프로젝트 생성 및 Step1 파일 설정**:
    -   `npx create-next-app nextjs-data-fetching-app --typescript`
    -   `cd nestjs-data-fetching-app`
    -   `Step1`의 `pages/index.tsx`, `pages/about.tsx`, `components/Layout.tsx`, `pages/_app.tsx`, `styles/globals.css` 파일을 적절한 경로에 복사합니다.

2.  **파일 복사**:
    -   `users.tsx` 파일을 `pages/` 디렉토리로 복사합니다.
    -   `api/users.ts` 파일을 `pages/api/` 디렉토리로 복사합니다. (pages 아래에 `api` 디렉토리 생성)

3.  **애플리케이션 실행**:
    ```bash
    npm run dev
    # 또는 yarn dev
    ```

4.  **API 테스트 (예시)**:
    -   웹 브라우저로 `http://localhost:3000/users` 경로에 접근하여 클라이언트 측 데이터 페칭 동작을 확인합니다. 사용자 목록이 로딩된 후 표시됩니다.

    -   `curl` 또는 Postman을 사용하여 직접 API 엔드포인트에 요청을 보낼 수 있습니다.
        -   **GET 요청**:
            ```bash
            curl http://localhost:3000/api/users
            ```
            -   임시 사용자 목록이 JSON 형태로 반환됩니다.

        -   **POST 요청**:
            ```bash
            curl -X POST -H "Content-Type: application/json" -d '{"name": "David", "email": "david@example.com"}' http://localhost:3000/api/users
            ```
            -   새로운 사용자 정보와 함께 HTTP 201 Created 응답이 반환됩니다. (서버 재시작 시 임시 데이터는 사라집니다.)

## 나쁜 예시와 좋은 예시 (개념)

`users.tsx` 및 `pages/api/users.ts` 파일 내의 주석을 참조하여, Next.js 데이터 페칭 및 API 라우팅 사용 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 특히 SEO가 중요한 페이지에는 SSR/SSG를 고려하고, API 라우트에서도 백엔드 보안 및 유효성 검사를 철저히 하는 것이 중요합니다.
