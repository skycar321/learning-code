// nextjs/Step5_AdvancedFeaturesAndDeployment/middleware.ts
// Next.js 학습 계획 - 5단계: 고급 기능 및 배포
// 이 파일은 Next.js 12부터 도입된 미들웨어(Middleware)를 사용하여
// 요청 처리 전/후에 로직을 추가하는 방법을 보여줍니다.
//
// 미들웨어는 클라이언트 요청이 페이지 핸들러에 도달하기 전에 코드를 실행할 수 있게 하여,
// 인증, 리다이렉션, 헤더 수정 등 다양한 기능을 서버 사이드에서 구현할 수 있도록 합니다.

import { NextRequest, NextResponse } from 'next/server';

// -----------------------------------------------------------------------------
// 학습 포인트 1: `middleware` 함수
// - `NextRequest` 객체를 받아 `NextResponse` 객체를 반환하는 함수입니다.
// - 미들웨어는 `_middleware.ts` 또는 `middleware.ts` 파일로 정의됩니다.
// - `matcher` 설정을 통해 미들웨어가 적용될 경로를 지정할 수 있습니다.
// -----------------------------------------------------------------------------
export function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl;

  // 1.1. 특정 경로에 대한 인증 로직 (예시)
  if (pathname.startsWith('/admin')) {
    const isAuthenticated = req.cookies.get('token'); // 쿠키에서 인증 토큰 확인 (예시)
    if (!isAuthenticated) {
      // 나쁜 예시: 인증되지 않은 사용자에게 무조건 401 Unauthorized 응답만 보내는 것.
      // - 사용자 경험을 고려하여 로그인 페이지로 리다이렉트하거나,
      // - 에러 페이지를 보여주는 것이 좋습니다.
      const url = req.nextUrl.clone();
      url.pathname = '/login'; // 로그인 페이지로 리다이렉트
      return NextResponse.redirect(url);
    }
  }

  // 1.2. 특정 경로에 대한 리다이렉션 (예시)
  if (pathname === '/old-page') {
    return NextResponse.redirect(new URL('/new-page', req.url));
  }

  // 1.3. 헤더 수정 (예시)
  const response = NextResponse.next();
  response.headers.set('x-custom-header', 'Hello from Next.js Middleware!');
  return response;

  // 나쁜 예시: 미들웨어 내에서 너무 많은 비즈니스 로직을 처리하여 성능 저하를 유발하는 것.
  // - 미들웨어는 가볍게 요청을 가로채고, 페이지 로드 전에 필요한 최소한의 처리를 수행해야 합니다.
  // - 복잡한 로직은 API 라우트나 서버리스 함수로 분리하는 것이 좋습니다.
}

// -----------------------------------------------------------------------------
// 학습 포인트 2: `config` 객체의 `matcher`
// - 미들웨어가 적용될 경로를 정의합니다.
// - 정규식 또는 문자열 배열을 사용할 수 있습니다.
// - `['/about/:path*', '/dashboard/:path*']`: `/about` 또는 `/dashboard`로 시작하는 모든 경로.
// -----------------------------------------------------------------------------
export const config = {
  matcher: ['/admin/:path*', '/old-page'], // `/admin`으로 시작하는 모든 경로와 `/old-page` 경로에 미들웨어 적용
};

/*
이 코드를 실행하려면:

1. `nextjs-basics-app` 프로젝트의 루트 디렉토리에 이 파일을 `middleware.ts`로 생성합니다.
2. Next.js 12 이상 버전에서만 미들웨어 기능이 작동합니다.
3. `pages/admin.tsx`와 같은 페이지를 생성하여 미들웨어의 리다이렉션/인증 로직을 테스트해볼 수 있습니다.
   ```typescript
   // pages/admin.tsx
   import Layout from '../components/Layout';

   export default function AdminPage() {
     return (
       <Layout title="관리자 페이지">
         <h1>관리자 페이지입니다.</h1>
         <p>인증된 사용자만 접근할 수 있습니다.</p>
       </Layout>
     );
   }
   ```
4. `npm run dev` (또는 `yarn dev`) 명령어로 애플리케이션 실행 후 `/admin` 경로로 접근.
   - 쿠키에 'token'이 없으면 `/login` 페이지로 리다이렉트됩니다. (실제 `/login` 페이지는 구현해야 함)
   - 개발자 도구의 네트워크 탭에서 `x-custom-header`가 추가되었는지 확인합니다.
*/
