// nextjs/Step4_StylingAndOptimization/pages/index.tsx
// Next.js 학습 계획 - 4단계: 스타일링 및 최적화
// 이 파일은 Next.js 애플리케이션에서 CSS Modules를 사용하여 컴포넌트 스코프 스타일을 적용하고,
// `next/image` 컴포넌트를 사용하여 이미지를 최적화하는 방법을 보여주는 `index.tsx` 페이지입니다.
//
// Next.js는 웹 애플리케이션의 성능과 사용자 경험을 향상시키기 위한 다양한 내장 최적화 기능을 제공합니다.

import Link from 'next/link';
import Layout from '../components/Layout'; // Layout 컴포넌트 임포트
import OptimizedImage from '../components/OptimizedImage'; // OptimizedImage 컴포넌트 임포트
import styles from '../styles/Home.module.css'; // CSS Modules 임포트

export default function Home() {
  return (
    <Layout title="홈 페이지 (스타일링 & 최적화)">
      {/* -----------------------------------------------------------------------------
        학습 포인트 1: CSS Modules를 이용한 컴포넌트 스코프 스타일링
        - `[name].module.css` 파일명 규칙을 사용하여 CSS Modules를 생성합니다.
        - CSS 클래스 이름이 자동으로 고유하게 해싱되어 다른 컴포넌트의 스타일과 충돌하지 않습니다.
        - `styles.title`과 같이 임포트한 객체의 속성으로 클래스에 접근합니다.
        ----------------------------------------------------------------------------- */}
      <h1 className={styles.title}>
        Next.js 스타일링 및 최적화
      </h1>
      <p className={styles.description}>
        CSS Modules와 `next/image`를 사용해봅시다.
      </p>

      {/* -----------------------------------------------------------------------------
        학습 포인트 2: `next/image` 컴포넌트를 이용한 이미지 최적화
        - `next/image`는 이미지를 자동으로 최적화하여 웹 성능을 향상시킵니다.
        - 이미지 크기 최적화, 지연 로딩(Lazy Loading), WebP와 같은 최신 이미지 포맷 지원,
          뷰포트 기반 이미지 로딩 등을 자동으로 처리합니다.
        - `width`와 `height`를 명시하여 CLS(Cumulative Layout Shift)를 방지합니다.
        ----------------------------------------------------------------------------- */}
      <div className={styles.imageContainer}>
        <OptimizedImage
          src="/nextjs-logo.png" // `public` 디렉토리 내 이미지
          alt="Next.js Logo"
          width={300}
          height={180}
        />
        {/* 나쁜 예시: 일반 `<img>` 태그를 사용하여 이미지를 로드하는 것.
          - 이미지 크기 최적화나 지연 로딩을 수동으로 구현해야 하므로 번거롭고 오류 발생 가능성이 높습니다.
          - `next/image`를 사용하지 않으면 Core Web Vitals 점수에 부정적인 영향을 미칠 수 있습니다. */}
      </div>

      <div className={styles.grid}>
        <Link href="/about" className={styles.card}>
          <h2>About 페이지 &rarr;</h2>
          <p>공통 레이아웃과 전역 CSS를 확인하세요.</p>
        </Link>
      </div>
    </Layout>
  );
}

/*
이 코드를 실행하려면:

1. `nextjs-basics-app/pages/index.tsx` 파일 내용을 이 파일의 내용으로 교체.
2. `nextjs-basics-app/styles/Home.module.css` 파일을 생성합니다.
3. `nextjs-basics-app/components/OptimizedImage.tsx` 파일을 생성합니다.
4. `nextjs-basics-app/public` 디렉토리에 `nextjs-logo.png` 파일을 추가합니다. (예시 이미지)
5. `nextjs-basics-app/components` 디렉토리에 `Layout.tsx` 파일이 있어야 합니다.
6. `nextjs-basics-app/pages/_app.tsx` 파일과 `nextjs-basics-app/styles/globals.css` 파일이 있어야 합니다.
7. `npm run dev` (또는 `yarn dev`) 명령어로 애플리케이션 실행 후 `/` 경로로 접근.
*/
