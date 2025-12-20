// nextjs/Step2_RenderingStrategies/pages/ssr.tsx
// Next.js 학습 계획 - 2단계: 렌더링 전략
// 이 파일은 Next.js의 서버 사이드 렌더링(SSR: Server-Side Rendering)을 보여주는 `ssr.tsx` 페이지입니다.
// `getServerSideProps` 함수를 사용하여 페이지 요청 시마다 서버에서 데이터를 가져와 렌더링합니다.
//
// SSR은 동적인 데이터가 자주 변경되거나, 사용자별로 다른 콘텐츠를 보여주어야 할 때 유용합니다.
// SEO(검색 엔진 최적화)에도 유리합니다.

import { GetServerSideProps } from 'next';
import Layout from '../components/Layout'; // Layout 컴포넌트 임포트

// 페이지 컴포넌트의 props 인터페이스 정의
interface SsrPageProps {
  data: string;
  timestamp: string;
}

// -----------------------------------------------------------------------------
// 학습 포인트 1: `getServerSideProps` 함수
// - 이 함수는 페이지 컴포넌트(`SsrPage`)가 렌더링되기 전에 서버에서 실행됩니다.
// - 페이지 요청 시마다 실행되며, 서버에서 데이터를 가져와 `props`로 페이지에 전달합니다.
// - 클라이언트 사이드 번들에는 포함되지 않습니다 (브라우저에서 실행되지 않음).
// -----------------------------------------------------------------------------
export const getServerSideProps: GetServerSideProps<SsrPageProps> = async (context) => {
  // 나쁜 예시: `getServerSideProps` 내에서 클라이언트 측에만 존재하는 API (예: `window` 객체)를 사용하는 것.
  // - 이 함수는 서버에서 실행되므로 클라이언트 측 API에 접근할 수 없습니다.
  // - 런타임 에러가 발생합니다.

  // API 호출 또는 데이터베이스 쿼리 등 서버에서만 가능한 작업을 수행
  const response = await new Promise<string>(resolve => {
    setTimeout(() => resolve('SSR에서 가져온 데이터입니다!'), 1000); // 1초 지연 시뮬레이션
  });

  const timestamp = new Date().toLocaleString();

  // `props` 객체에 데이터를 담아 페이지 컴포넌트로 전달합니다.
  return {
    props: {
      data: response,
      timestamp,
    },
  };
};

// 페이지 컴포넌트
export default function SsrPage({ data, timestamp }: SsrPageProps) {
  return (
    <Layout title="SSR 페이지">
      <h1>서버 사이드 렌더링 (SSR)</h1>
      <p>이 페이지는 요청 시마다 서버에서 데이터를 가져와 렌더링됩니다.</p>
      <p>가져온 데이터: <strong>{data}</strong></p>
      <p>서버에서 데이터 가져온 시간: <strong>{timestamp}</strong></p>
      {/* 나쁜 예시: `getServerSideProps`에서 가져온 데이터를 다시 클라이언트에서 SWR 등으로 가져오는 것.
        - 불필요한 중복 데이터 페칭을 발생시킵니다.
        - SSR로 데이터를 가져왔다면, 그 데이터를 사용하여 페이지를 렌더링해야 합니다. */}
    </Layout>
  );
}

/*
이 코드를 실행하려면:

1. `nextjs-basics-app/pages/ssr.tsx` 파일 내용을 이 파일의 내용으로 교체.
2. `nextjs-basics-app/components` 디렉토리에 `Layout.tsx` 파일이 있어야 합니다.
3. `npm run dev` (또는 `yarn dev`) 명령어로 애플리케이션 실행 후 `/ssr` 경로로 접근.
4. 페이지를 새로고침할 때마다 `서버에서 데이터 가져온 시간`이 현재 시간으로 업데이트되는 것을 확인합니다.
*/
