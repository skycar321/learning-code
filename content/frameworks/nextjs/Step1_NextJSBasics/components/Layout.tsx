// nextjs/Step1_NextJSBasics/components/Layout.tsx
// Next.js 학습 계획 - 1단계: Next.js 기본 개념 및 시작
// 이 파일은 Next.js 애플리케이션의 `Layout` 컴포넌트입니다.
// `Layout` 컴포넌트는 여러 페이지에 걸쳐 재사용되는 공통적인 UI 구조를 정의합니다.
// (예: 헤더, 내비게이션 바, 푸터 등)
//
// 이를 통해 각 페이지 컴포넌트는 페이지별 고유한 내용에만 집중할 수 있어
// 코드의 재사용성과 유지보수성이 향상됩니다.

import Head from 'next/head'; // Next.js의 Head 컴포넌트 임포트
import React, { ReactNode } from 'react'; // ReactNode 타입 임포트

// -----------------------------------------------------------------------------
// 학습 포인트 1: `Head` 컴포넌트를 이용한 문서 헤더 관리
// - `next/head`에서 제공하는 `Head` 컴포넌트를 사용하여 페이지의 `<head>` 섹션을 수정합니다.
// - `<title>`, `<meta>`, `<link>` 태그 등을 포함하여 페이지 제목, SEO 메타 정보 등을 설정합니다.
// - 각 페이지에서 `Head` 컴포넌트 내의 내용은 병합되어 최종적으로 하나의 `<head>` 섹션이 됩니다.
// -----------------------------------------------------------------------------

// Layout 컴포넌트의 props 인터페이스 정의
interface LayoutProps {
  children: ReactNode; // 자식 컴포넌트 (페이지 내용)
  title?: string;      // 페이지 제목 (선택 사항)
}

export default function Layout({ children, title = 'Next.js 기본 앱' }: LayoutProps) {
  return (
    <div>
      <Head>
        <title>{title}</title>
        <meta charSet="utf-8" />
        <meta name="viewport" content="initial-scale=1.0, width=device-width" />
        {/* 나쁜 예시: 모든 페이지의 `<head>` 태그에 동일한 SEO 메타 정보를 반복해서 작성하는 것.
          - 코드 중복을 유발하고, 메타 정보 변경 시 여러 파일을 수정해야 합니다.
          - `Layout` 컴포넌트나 `_app.tsx`를 통해 공통 메타 정보를 관리하고,
          - 필요한 경우에만 개별 페이지에서 `Head`를 사용하여 재정의하는 것이 좋습니다. */}
      </Head>
      <header>
        <nav>
          {/* 내비게이션 바 등 공통 헤더 요소 */}
          <a href="/">홈</a> | <a href="/about">About</a> | <a href="/ssr">SSR 예시</a>
        </nav>
      </header>
      <main style={{ padding: '20px' }}>
        {children} {/* 페이지별 내용이 여기에 렌더링됩니다 */}
      </main>
      <footer style={{ marginTop: '20px', textAlign: 'center', borderTop: '1px solid #eaeaea', paddingTop: '10px' }}>
        {/* 공통 푸터 요소 */}
        <hr />
        <span>&copy; 2023 Next.js Learning App</span>
      </footer>
      <style jsx>{`
        nav {
          padding: 10px 20px;
          background: #333;
          color: white;
        }
        nav a {
          color: white;
          margin-right: 15px;
          text-decoration: none;
        }
        nav a:hover {
          text-decoration: underline;
        }
      `}</style>
    </div>
  );
}

/*
이 코드를 실행하려면:

1. `nextjs-basics-app/components` 디렉토리를 생성하고 이 파일을 `Layout.tsx`로 저장합니다.
2. `pages/index.tsx`, `pages/about.tsx` 등 다른 페이지 컴포넌트에서 이 `Layout` 컴포넌트를 임포트하여 사용합니다.
*/
