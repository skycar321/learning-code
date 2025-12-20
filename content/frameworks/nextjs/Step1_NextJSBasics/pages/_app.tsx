// nextjs/Step1_NextJSBasics/pages/_app.tsx
// Next.js 학습 계획 - 1단계: Next.js 기본 개념 및 시작
// 이 파일은 Next.js 애플리케이션의 커스텀 `App` 컴포넌트인 `_app.tsx`입니다.
// `_app.tsx`는 모든 페이지를 감싸는 최상위 React 컴포넌트입니다.
//
// 이 파일은 모든 페이지에 공통된 레이아웃을 적용하거나, 전역 CSS를 임포트하거나,
// 상태 관리(Redux, Context API 등)를 초기화하는 데 사용됩니다.

import type { AppProps } from 'next/app';
import '../styles/globals.css'; // 전역 CSS 임포트 (아직 생성되지 않음)

// -----------------------------------------------------------------------------
// 학습 포인트 1: `_app.tsx`의 역할
// - `Component`: 현재 요청된 페이지 컴포넌트입니다 (예: `pages/index.tsx`).
// - `pageProps`: `getServerSideProps` 또는 `getStaticProps`를 통해 페이지 컴포넌트로 전달되는 prop들입니다.
// - `_app.tsx`는 서버 사이드 렌더링(SSR) 또는 정적 사이트 생성(SSG) 프로세스에서도 실행됩니다.
// -----------------------------------------------------------------------------
function MyApp({ Component, pageProps }: AppProps) {
  // 나쁜 예시: `_app.tsx`에서 모든 페이지의 데이터를 가져오려 하는 것.
  // - `_app.tsx`는 모든 페이지가 공통으로 필요한 데이터(예: 사용자 인증 상태)를 가져오는 데 적합하지만,
  // - 개별 페이지별로 필요한 데이터는 해당 페이지의 `getServerSideProps` 또는 `getStaticProps`에서 가져와야 합니다.
  // - 그렇지 않으면 불필요한 데이터 페칭으로 성능 저하가 발생할 수 있습니다.

  // -----------------------------------------------------------------------------
  // 학습 포인트 2: 전역 CSS 임포트
  // - Next.js에서는 `_app.tsx`에서만 전역 CSS 파일을 임포트할 수 있습니다.
  // - `styles/globals.css`와 같이 CSS Modules가 아닌 일반 CSS 파일을 임포트할 때 사용됩니다.
  // -----------------------------------------------------------------------------
  return <Component {...pageProps} />;
}

export default MyApp;

/*
이 코드를 실행하려면:

1. `nextjs-basics-app/pages/_app.tsx` 파일 내용을 이 파일의 내용으로 교체.
2. `nextjs-basics-app/styles` 디렉토리를 생성하고 `globals.css` 파일을 생성해야 합니다.
   ```css
   /* nextjs-basics-app/styles/globals.css * /
   html,
   body {
     padding: 0;
     margin: 0;
     font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Oxygen,
       Ubuntu, Cantarell, Fira Sans, Droid Sans, Helvetica Neue, sans-serif;
   }

   a {
     color: inherit;
     text-decoration: none;
   }

   * {
     box-sizing: border-box;
   }

   .container {
     min-height: 100vh;
     padding: 0 0.5rem;
     display: flex;
     flex-direction: column;
     justify-content: center;
     align-items: center;
   }
   ```
3. `npm run dev` (또는 `yarn dev`) 명령어로 애플리케이션 실행.
*/
