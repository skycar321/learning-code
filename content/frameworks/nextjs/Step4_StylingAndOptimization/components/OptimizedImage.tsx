// nextjs/Step4_StylingAndOptimization/components/OptimizedImage.tsx
// Next.js 학습 계획 - 4단계: 스타일링 및 최적화
// 이 파일은 `next/image` 컴포넌트를 사용하여 이미지를 최적화하는 예시입니다.
// `next/image`는 이미지를 자동으로 최적화하여 웹 애플리케이션의 성능을 향상시킵니다.
//
// 이미지 최적화는 웹 페이지 로딩 속도와 사용자 경험(Core Web Vitals)에 큰 영향을 미칩니다.

import Image from 'next/image'; // `next/image` 컴포넌트 임포트

// OptimizedImage 컴포넌트의 props 인터페이스 정의
interface OptimizedImageProps {
  src: string;
  alt: string;
  width: number;
  height: number;
}

export default function OptimizedImage({ src, alt, width, height }: OptimizedImageProps) {
  return (
    // -----------------------------------------------------------------------------
    // 학습 포인트 1: `next/image` 컴포넌트
    // - 이미지 크기 최적화: 이미지 요청 시 뷰포트에 맞는 크기로 이미지를 자동으로 조정.
    // - 지연 로딩 (Lazy Loading): 뷰포트 내에 들어올 때까지 이미지 로딩을 지연.
    // - WebP와 같은 최신 이미지 포맷 지원: 브라우저가 지원하는 경우 자동으로 변환.
    // - 뷰포트 기반 이미지 로딩: 디바이스 해상도에 따라 가장 적합한 이미지를 제공.
    // - CLS (Cumulative Layout Shift) 방지: `width`와 `height`를 명시하여 이미지 로드 시 레이아웃 흔들림 방지.
    // -----------------------------------------------------------------------------
    <Image
      src={src} // 이미지 소스 경로 (public 디렉토리 기준)
      alt={alt} // 이미지 대체 텍스트 (접근성 및 SEO에 중요)
      width={width} // 이미지의 고유 가로 크기
      height={height} // 이미지의 고유 세로 크기
      layout="responsive" // 반응형 레이아웃 (뷰포트에 따라 크기 조정)
      // layout="fill" // 부모 요소에 꽉 채움 (CSS `object-fit`과 함께 사용)
      // objectFit="contain" // `layout="fill"` 사용 시 이미지 비율 유지
      priority={true} // 이 이미지를 먼저 로드 (LCP 이미지에 사용, Lighthouse 점수 개선)
      // 나쁜 예시: `priority={true}`를 모든 이미지에 사용하는 것.
      // - 모든 이미지를 즉시 로드하려 시도하여 초기 로딩 성능에 악영향을 줍니다.
      // - 초기 뷰포트 내에 보이는 가장 중요한 이미지(LCP)에만 사용해야 합니다.
    />
  );
}

/*
이 코드를 실행하려면:

1. `nextjs-basics-app/components` 디렉토리에 이 파일을 `OptimizedImage.tsx`로 저장합니다.
2. `pages/index.tsx`에서 이 컴포넌트를 임포트하여 사용합니다.
*/
