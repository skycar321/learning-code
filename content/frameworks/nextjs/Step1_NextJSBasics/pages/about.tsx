// nextjs/Step1_NextJSBasics/pages/about.tsx
// Next.js 학습 계획 - 1단계: Next.js 기본 개념 및 시작
// 이 파일은 Next.js 애플리케이션의 `About` 페이지인 `about.tsx`입니다.
// `pages/about.tsx` 파일은 `/about` 경로에 매핑됩니다 (파일 시스템 기반 라우팅).
//
// `next/link` 컴포넌트를 사용하여 홈 페이지로 돌아가는 링크를 제공하고,
// `Layout` 컴포넌트를 사용하여 공통 레이아웃을 적용합니다.

import Link from 'next/link';
import Layout from '../components/Layout'; // Layout 컴포넌트 임포트

export default function About() {
  return (
    <Layout title="About 페이지">
      <h1>About 페이지입니다.</h1>
      <p>이 페이지는 Next.js의 파일 시스템 기반 라우팅을 보여주기 위한 예시입니다.</p>
      <p>
        `<Link href="/">` 컴포넌트를 사용하여
        <Link href="/">
          <a> 홈 페이지로 돌아갈 수 있습니다.</a>
        </Link>
      </p>

      <style jsx>{`
        h1 {
          color: #333;
        }
        p {
          color: #555;
          line-height: 1.6;
        }
        a {
          color: #0070f3;
          text-decoration: underline;
        }
      `}</style>
    </Layout>
  );
}

/*
이 코드를 실행하려면:

1. `main.ts` 및 `app.module.ts`가 설정된 NestJS 프로젝트에 이 파일을 생성합니다.
2. `nextjs-basics-app/pages/about.tsx` 파일 내용을 이 파일의 내용으로 교체.
3. `nextjs-basics-app/components` 디렉토리에 `Layout.tsx` 파일을 생성해야 합니다.
4. `npm run dev` (또는 `yarn dev`) 명령어로 애플리케이션 실행 후 `/about` 경로로 접근.
*/
