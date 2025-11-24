// nextjs/Step4_StylingAndOptimization/pages/_app.tsx
// Next.js 학습 계획 - 4단계: 스타일링 및 최적화
// 이 파일은 Next.js 애플리케이션의 커스텀 `App` 컴포넌트인 `_app.tsx`입니다.
// 모든 페이지에 공통된 레이아웃을 적용하거나, 전역 CSS를 임포트하는 데 사용됩니다.

import type { AppProps } from 'next/app';
import '../styles/globals.css'; // 전역 CSS 임포트

function MyApp({ Component, pageProps }: AppProps) {
  // `_app.tsx`는 모든 페이지에 공통된 전역 스타일을 적용하는 데 적합합니다.
  // CSS Modules는 `_app.tsx`에서 임포트할 수 없으며, 개별 컴포넌트나 페이지에서 임포트해야 합니다.
  return <Component {...pageProps} />;
}

export default MyApp;

/*
이 코드를 실행하려면:

1. `nextjs-basics-app/pages/_app.tsx` 파일 내용을 이 파일의 내용으로 교체.
2. `nextjs-basics-app/styles` 디렉토리에 `globals.css` 파일이 있어야 합니다.
*/
