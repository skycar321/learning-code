// nextjs/Step4_StylingAndOptimization/components/Layout.tsx
// Next.js 학습 계획 - 4단계: 스타일링 및 최적화
// 이 파일은 Next.js 애플리케이션의 `Layout` 컴포넌트입니다.
// 여러 페이지에 걸쳐 재사용되는 공통적인 UI 구조를 정의합니다.
//
// `Head` 컴포넌트를 사용하여 페이지의 `<head>` 섹션을 관리하고,
// 공통 헤더 및 푸터를 포함합니다.

import Head from 'next/head';
import React, { ReactNode } from 'react';

interface LayoutProps {
  children: ReactNode;
  title?: string;
}

export default function Layout({ children, title = 'Next.js 최적화 앱' }: LayoutProps) {
  return (
    <div>
      <Head>
        <title>{title}</title>
        <meta charSet="utf-8" />
        <meta name="viewport" content="initial-scale=1.0, width=device-width" />
      </Head>
      <header>
        <nav>
          <a href="/">홈</a> | <a href="/about">About</a> | <a href="/ssr">SSR 예시</a>
        </nav>
      </header>
      <main style={{ padding: '20px' }}>
        {children}
      </main>
      <footer style={{ marginTop: '20px', textAlign: 'center', borderTop: '1px solid #eaeaea', paddingTop: '10px' }}>
        <hr />
        <span>&copy; 2023 Next.js Learning App - Optimized</span>
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
