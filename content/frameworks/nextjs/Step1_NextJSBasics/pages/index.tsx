// nextjs/Step1_NextJSBasics/pages/index.tsx
// Next.js 학습 계획 - 1단계: Next.js 기본 개념 및 시작
// 이 파일은 Next.js 애플리케이션의 메인 페이지(홈 페이지)인 `index.tsx`입니다.
// Next.js는 파일 시스템 기반 라우팅을 사용하여 `pages/index.tsx`를 루트 경로('/')에 매핑합니다.
//
// React 컴포넌트와 `next/link` 컴포넌트를 사용하여 페이지 간 이동을 구현합니다.

import Link from 'next/link';
import Layout from '../components/Layout'; // Layout 컴포넌트 임포트 (아직 생성되지 않음)

// -----------------------------------------------------------------------------
// 학습 포인트 1: `Link` 컴포넌트를 이용한 페이지 이동
// - `next/link`에서 제공하는 `Link` 컴포넌트는 클라이언트 측 라우팅을 제공합니다.
// - `<Link href="/about">`와 같이 `href` 속성으로 이동할 페이지 경로를 지정합니다.
// - `Link` 컴포넌트 내부에 HTML 태그(예: `<a>`)를 포함해야 합니다.
// - SEO 및 접근성을 위해 `Link` 내부의 `<a>` 태그는 `href`를 생략합니다.
// -----------------------------------------------------------------------------
export default function Home() {
  return (
    // -----------------------------------------------------------------------------
    // 학습 포인트 2: 컴포넌트 구조 이해
    // - `Layout` 컴포넌트를 사용하여 모든 페이지에 공통된 레이아웃(헤더, 푸터 등)을 적용합니다.
    // - `children` prop을 통해 페이지별 내용을 `Layout` 내부에 렌더링합니다.
    // -----------------------------------------------------------------------------
    <Layout title="홈 페이지">
      <h1 className="title">환영합니다! Next.js 학습 페이지입니다.</h1>
      <p className="description">
        `pages/index.tsx`에서 시작하여 Next.js의 기본 개념을 탐색해봅시다.
      </p>

      <div className="grid">
        <Link href="/about" className="card">
          <h2>About 페이지 &rarr;</h2>
          <p>Next.js의 라우팅과 `Link` 컴포넌트 사용법을 배웁니다.</p>
        </Link>

        <Link href="/ssr" className="card">
          <h2>SSR 페이지 &rarr;</h2>
          <p>서버 사이드 렌더링(SSR)을 통해 데이터를 가져오는 방법을 알아봅니다.</p>
        </Link>

        <Link href="/ssg/1" className="card">
          <h2>SSG 페이지 (ID: 1) &rarr;</h2>
          <p>정적 사이트 생성(SSG)으로 빌드 시점에 데이터를 가져오는 방법을 알아봅니다.</p>
        </Link>

        <Link href="/users" className="card">
          <h2>데이터 페칭 페이지 &rarr;</h2>
          <p>클라이언트 측 데이터 페칭과 API 라우트 사용법을 배웁니다.</p>
        </Link>
      </div>

      <style jsx>{`
        .title {
          margin: 0;
          line-height: 1.15;
          font-size: 4rem;
          text-align: center;
        }
        .description {
          text-align: center;
          line-height: 1.5;
          font-size: 1.5rem;
        }
        .grid {
          display: flex;
          align-items: center;
          justify-content: center;
          flex-wrap: wrap;
          max-width: 800px;
          margin-top: 3rem;
        }
        .card {
          margin: 1rem;
          padding: 1.5rem;
          text-align: left;
          color: inherit;
          text-decoration: none;
          border: 1px solid #eaeaea;
          border-radius: 10px;
          transition: color 0.15s ease, border-color 0.15s ease;
          width: 45%;
        }
        .card:hover,
        .card:focus,
        .card:active {
          color: #0070f3;
          border-color: #0070f3;
        }
        .card h2 {
          margin: 0 0 1rem 0;
          font-size: 1.5rem;
        }
        .card p {
          margin: 0;
          font-size: 1.25rem;
          line-height: 1.5;
        }
        .logo {
          height: 1em;
          margin-left: 0.5rem;
        }
        @media (max-width: 600px) {
          .grid {
            width: 100%;
            flex-direction: column;
          }
          .card {
            width: 90%;
          }
        }
      `}</style>

      {/* 나쁜 예시: 페이지를 새로고침하는 `<a href="/about">` 태그를 사용하는 것.
        - 클라이언트 측 라우팅을 제공하지 않아 페이지 전환 시 모든 리소스를 다시 로드합니다.
        - 이는 사용자 경험을 저하시키고, SPA(Single Page Application)의 장점을 활용하지 못하게 합니다.
        - 항상 `next/link` 컴포넌트를 사용하여 페이지 간 이동을 구현해야 합니다. */}
    </Layout>
  );
}

/*
이 코드를 실행하려면:

1. Node.js 및 npm (또는 yarn) 설치.
2. Next.js 프로젝트 생성: `npx create-next-app nextjs-basics-app --typescript`
   (TypeScript를 사용하지 않으려면 `--typescript` 제거)
3. `nextjs-basics-app/pages/index.tsx` 파일 내용을 이 파일의 내용으로 교체.
4. `nextjs-basics-app/components` 디렉토리를 생성하고 `Layout.tsx` 파일을 생성.
5. `npm run dev` (또는 `yarn dev`) 명령어로 애플리케이션 실행.
*/
