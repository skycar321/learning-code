# Step 10: Next.js 트러블슈팅 가이드 (Troubleshooting Guide)

Next.js 개발 중(App Router/Pages Router) 자주 마주치는 오류 Top 50을 정리했습니다. 오류 메시지의 핵심 키워드로 검색(`Ctrl+F`)하여 해결책을 찾으세요.

## 1. Rendering & Hydration (렌더링 및 하이드레이션)

### 1-1. `Hydration failed because the initial UI does not match what was rendered on the server`
- **원인**: 서버(SSR)에서 만든 HTML과 클라이언트(CSR) 초기 렌더링 결과가 다름. (예: `new Date()`, `Math.random()`, `window` 접근).
- **해결**:
  - `useEffect`로 마운트 후 값 업데이트.
  - `suppressHydrationWarning` 속성 사용 (타임스탬프 등).
  - 동적 import (`ssr: false`).

### 1-2. `window is not defined` / `document is not defined`
- **원인**: 서버 사이드 렌더링 중 브라우저 전용 객체 접근.
- **해결**: `useEffect` 내부에서 접근하거나 `if (typeof window !== 'undefined')` 체크.

### 1-3. `Text content does not match server-rendered HTML`
- **원인**: 1-1과 동일. HTML 태그 중첩 규칙 위반(예: `<p>` 안에 `<div>`)일 수도 있음.
- **해결**: HTML 구조 수정 (`div` 대신 `span` 사용 등).

### 1-4. `useEffect` running twice
- **원인**: React 18+ `Strict Mode` (개발 환경 전용).
- **해결**: 정상 동작임. 클린업(Cleanup) 함수 잘 작성하면 문제 없음. 신경 쓰이면 `reactStrictMode: false` (비권장).

### 1-5. FOUC (Flash of Unstyled Content)
- **원인**: CSS-in-JS 라이브러리(Styled-components 등)의 서버 설정 누락.
- **해결**: `registry.tsx` (App Router) 또는 `_document.tsx` (Pages Router)에 스타일 수집 로직 추가.

### 1-6. `NextRouter was not mounted`
- **원인**: `useRouter`를 Next.js 앱 외부(테스트, Storybook)에서 호출.
- **해결**: Mock Router 사용 또는 앱 래퍼 확인.

### 1-7. `Error: Objects are not valid as a React child`
- **원인**: 객체나 배열을 그대로 렌더링하려 함 (`<div>{obj}</div>`).
- **해결**: `JSON.stringify(obj)` 하거나 특정 필드(`obj.name`) 렌더링.

### 1-8. `Cannot update a component while rendering a different component`
- **원인**: 렌더링 도중 다른 컴포넌트의 상태를 변경(`setState`).
- **해결**: `useEffect` 또는 이벤트 핸들러 내부로 상태 변경 이동.

### 1-9. `Too many re-renders`
- **원인**: `onClick={handler()}` 처럼 함수를 바로 실행해버려 무한 루프 발생.
- **해결**: `onClick={() => handler()}` 로 래핑.

### 1-10. Server Component에서 Context/Hook 사용 에러
- **원인**: Server Component는 `useState`, `useContext` 사용 불가.
- **해결**: 파일 최상단에 `'use client'` 선언하여 Client Component로 변환.

---

## 2. Routing & Navigation (라우팅)

### 2-1. `404 This page could not be found`
- **원인**: `pages/` 또는 `app/` 디렉토리 경로 불일치. 동적 라우트 파일명(`[id].tsx`) 확인.
- **해결**: 파일 트리 확인. `export default` 컴포넌트 존재 확인.

### 2-2. `useRouter` returns null/undefined properties
- **원인**: 초기 렌더링 시 쿼리 파라미터가 아직 준비 안 됨 (Pages Router).
- **해결**: `router.isReady` 체크 후 로직 실행.

### 2-3. Link `href` interpolation failed
- **원인**: `href`에 undefined/null 전달.
- **해결**: 값 유무 체크 후 렌더링.

### 2-4. `Hard navigation` (Full page reload) occurs
- **원인**: `<Link>` 대신 `<a>` 태그 사용 또는 `window.location.href` 사용.
- **해결**: Next.js `<Link>` 컴포넌트 사용.

### 2-5. Middleware Infinite Redirect loop
- **원인**: 미들웨어 리다이렉트 조건이 계속 참(True)임.
- **해결**: 리다이렉트 대상 경로를 조건에서 제외(`matcher` 설정).

### 2-6. `Error: Multiple children were passed to <Link>`
- **원인**: `<Link>`는 하나의 자식만 가져야 함 (Legacy behavior, 최신 버전은 완화됨).
- **해결**: `<a>` 태그 하나로 감싸기.

### 2-7. Dynamic Route Parameter is Array
- **원인**: `[...slug]` (Catch-all) 사용 시 쿼리 값이 배열로 옴.
- **해결**: `Array.isArray()` 체크 로직 추가.

### 2-8. App Router `NotFound` UI not showing
- **원인**: `not-found.tsx` 파일이 해당 세그먼트에 없음.
- **해결**: 루트 또는 해당 폴더에 `not-found.tsx` 생성.

### 2-9. Intercepting Routes not working
- **원인**: 폴더 명명 규칙 `(..)` 오타 또는 매칭 실패.
- **해결**: 폴더 구조 재확인.

### 2-10. Parallel Routes (`@folder`) 404
- **원인**: `default.tsx` 누락. Soft Navigation 시엔 괜찮지만 Hard Refresh 시 404.
- **해결**: 각 슬롯에 `default.tsx` 파일 추가.

---

## 3. Data Fetching & API (데이터)

### 3-1. `API resolved without sending a response`
- **원인**: API Route에서 `res.send()` 등을 안 하고 함수가 종료됨 (비동기 처리 미흡).
- **해결**: `await` 사용 또는 `return` 문 확인.

### 3-2. `Fetch failed` (Build time)
- **원인**: `getStaticProps` 또는 `generateStaticParams`에서 로컬 API(`localhost:3000`) 호출. 빌드 시엔 서버가 안 떠있음.
- **해결**: 내부 로직 함수 직접 호출 또는 외부 API만 호출.

### 3-3. CORS Error on API Route
- **원인**: 다른 도메인에서 Next.js API 호출.
- **해결**: API 핸들러에 CORS 헤더 설정 또는 미들웨어 사용.

### 3-4. `getStaticPaths` fallback issue
- **원인**: `fallback: false`인데 빌드되지 않은 경로로 접근.
- **해결**: `fallback: blocking` 또는 `true` 사용.

### 3-5. Serialization Error (Data Fetching)
- **원인**: `getStaticProps` 리턴값에 `Date` 객체나 `Undefined` 포함. (JSON 직렬화 불가).
- **해결**: `.toString()` 변환 또는 `JSON.parse(JSON.stringify(data))` 트릭 사용.

### 3-6. Caching issues (App Router)
- **원인**: `fetch`가 기본적으로 캐싱됨.
- **해결**: `fetch(url, { cache: 'no-store' })` 또는 `revalidate` 설정.

### 3-7. Database connection limit exceeded (Hot Reload)
- **원인**: 개발 환경에서 파일 변경 시마다 DB 연결 재생성.
- **해결**: 전역 변수(`globalForPrisma`)에 DB 인스턴스 저장하여 재사용.

### 3-8. `NEXT_PUBLIC_` variable missing
- **원인**: 클라이언트에서 환경변수 접근 시 접두사 누락.
- **해결**: 브라우저 노출 변수는 `NEXT_PUBLIC_` 붙이기.

### 3-9. `API handler should export a default function`
- **원인**: Pages Router API 파일에서 `export default` 누락.
- **해결**: 핸들러 함수 export.

### 3-10. Large Payload Error (API)
- **원인**: 4MB 넘는 Body 요청 (Vercel 등 제한).
- **해결**: `export const config = { api: { bodyParser: { sizeLimit: '10mb' } } }`.

---

## 4. Build & Deployment (빌드 및 배포)

### 4-1. `Build failed` (Type Error)
- **원인**: TypeScript 에러 존재.
- **해결**: 에러 수정 또는 `next.config.js`에서 `ignoreBuildErrors: true` (비권장).

### 4-2. `Build failed` (ESLint)
- **원인**: Lint 규칙 위반.
- **해결**: `npm run lint`로 확인 및 수정.

### 4-3. `Image Optimization failed`
- **원인**: 외부 이미지 도메인이 `next.config.js`의 `images.domains`에 없음.
- **해결**: 도메인 추가.

### 4-4. `Module not found: Can't resolve 'fs'`
- **원인**: 클라이언트 컴포넌트에서 Node.js 모듈(`fs`, `path`) import.
- **해결**: 해당 로직을 `getServerSideProps`나 API Route로 이동. `next.config.js`에서 webpack 설정 (`fs: false`) 추가.

### 4-5. `swcMinify` error
- **원인**: SWC 컴파일러 버그 또는 호환성.
- **해결**: `swcMinify: false` (Babel 사용) 시도 후 이슈 리포트.

### 4-6. Environment Variables undefined in Production
- **원인**: 배포 대시보드(Vercel/Netlify)에 환경변수 미등록.
- **해결**: 배포 설정에서 변수 추가.

### 4-7. `Export failed` (Image Component)
- **원인**: `next export`는 기본 Image Optimization 지원 안 함.
- **해결**: `images: { unoptimized: true }` 설정.

### 4-8. CSS/Sass Module not found
- **원인**: 파일명 규칙(`*.module.css`) 위반 또는 설치 누락.
- **해결**: 파일명 확인. `sass` 패키지 설치.

### 4-9. Duplicate Atom Key (Recoil)
- **원인**: Hot Reload 시 아톰 키 충돌.
- **해결**: 아톰 키에 난수 추가 또는 키 관리 전략 수정.

### 4-10. Invalid `next.config.js`
- **원인**: 설정 파일 문법 오류.
- **해결**: 문서 참조하여 올바른 옵션 사용.

---

## 🔍 Good vs Bad Troubleshooting Habits

### ❌ Bad Practice
- **`suppressHydrationWarning` 남발**: 근본 원인(불일치) 해결 대신 경고만 끔.
- **`any` 타입 사용**: TS 에러 귀찮다고 `any` 도배 -> 런타임 터짐.
- **`use client` 남용**: 모든 컴포넌트를 클라이언트로 만들면 Next.js 장점(SSR/RSC) 사라짐.

### ✅ Good Practice
- **콘솔 로그 확인**: 브라우저 콘솔(Client 에러)과 터미널(Server 에러)을 모두 확인하는 습관.
- **Canary 테스트**: 버그 의심 시 Next.js 최신 카나리 버전으로 테스트.
- **공식 문서 검색**: 에러 메시지를 그대로 복사해서 Next.js 공식 문서/Github Discussion 검색.
