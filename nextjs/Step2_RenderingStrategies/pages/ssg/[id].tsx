// nextjs/Step2_RenderingStrategies/pages/ssg/[id].tsx
// Next.js 학습 계획 - 2단계: 렌더링 전략
// 이 파일은 Next.js의 정적 사이트 생성(SSG: Static Site Generation)을 보여주는 `ssg/[id].tsx` 페이지입니다.
// `getStaticProps`와 `getStaticPaths` 함수를 사용하여 빌드 시점에 데이터를 가져와 정적인 HTML 파일을 생성합니다.
//
// SSG는 데이터가 빌드 시점에 결정되고 자주 변경되지 않는 페이지(블로그 게시물, 제품 상세 페이지 등)에 적합합니다.
// 매우 빠른 응답 속도와 우수한 SEO 성능을 제공합니다.

import { GetStaticProps, GetStaticPaths } from 'next';
import Layout from '../../components/Layout'; // Layout 컴포넌트 임포트
import { useRouter } from 'next/router'; // Next.js 라우터 훅 임포트

// 게시물 데이터 인터페이스 정의
interface Post {
  id: string;
  title: string;
  content: string;
}

// 페이지 컴포넌트의 props 인터페이스 정의
interface SsgPageProps {
  post: Post;
  timestamp: string;
}

// -----------------------------------------------------------------------------
// 학습 포인트 1: `getStaticPaths` 함수
// - 이 함수는 SSG를 위해 필요한 동적 경로(Dynamic Routes)의 모든 가능한 경로를 정의합니다.
// - 빌드 시점에 실행되며, 어떤 `id` 값으로 페이지를 미리 생성할지 Next.js에 알려줍니다.
// - `fallback`:
//   - `false`: `paths`에 정의되지 않은 경로로 접근 시 404 페이지를 반환.
//   - `true`: `paths`에 정의되지 않은 경로로 접근 시, Next.js는 해당 페이지를 서버에서 렌더링하고 HTML을 캐시합니다 (ISR과 유사).
//   - `blocking`: `true`와 유사하지만, 서버에서 페이지가 준비될 때까지 사용자에게는 빈 페이지가 아닌 로딩 상태를 보여줍니다.
// -----------------------------------------------------------------------------
export const getStaticPaths: GetStaticPaths = async () => {
  // 나쁜 예시: `getStaticPaths` 내에서 `context.params`를 사용하여 경로를 동적으로 생성하는 것.
  // - `getStaticPaths`는 빌드 시점에 실행되므로 `context` 객체는 파라미터를 포함하지 않습니다.
  // - 경로 데이터는 외부 API 호출 등으로 가져와야 합니다.
  const posts: Post[] = [ // 실제 API 호출을 시뮬레이션
    { id: '1', title: '첫 번째 SSG 게시물', content: 'SSG는 빌드 시점에 페이지를 생성합니다.' },
    { id: '2', title: '두 번째 SSG 게시물', content: '정적 파일로 제공되어 매우 빠릅니다.' },
  ];

  const paths = posts.map((post) => ({
    params: { id: post.id }, // 각 게시물의 id를 경로 파라미터로 정의
  }));

  return {
    paths,
    fallback: false, // `paths`에 없는 ID로 접근 시 404 페이지 반환
  };
};

// -----------------------------------------------------------------------------
// 학습 포인트 2: `getStaticProps` 함수
// - 이 함수는 각 페이지 컴포넌트(`SsgPage`)가 렌더링되기 전에 빌드 시점에 실행됩니다.
// - `context.params`를 통해 `getStaticPaths`에서 정의된 경로 파라미터에 접근할 수 있습니다.
// - 데이터를 가져와 `props`로 페이지에 전달합니다.
// - `revalidate` 옵션을 사용하여 ISR(증분 정적 재생성)을 설정할 수 있습니다.
// -----------------------------------------------------------------------------
export const getStaticProps: GetStaticProps<SsgPageProps> = async (context) => {
  const { id } = context.params as { id: string }; // 경로 파라미터 id 가져오기

  // API 호출 또는 데이터베이스 쿼리 등 빌드 시점에 가능한 작업을 수행
  const response: Post = await new Promise(resolve => {
    setTimeout(() => resolve(
      id === '1' ? { id: '1', title: 'SSG 게시물 1', content: '빌드 시점에 생성된 페이지입니다.' } :
      id === '2' ? { id: '2', title: 'SSG 게시물 2', content: '데이터 변경이 적은 경우에 유용합니다.' } :
      { id: 'default', title: '기본 SSG 게시물', content: '기본 콘텐츠입니다.' }
    ), 500); // 0.5초 지연 시뮬레이션
  });

  const timestamp = new Date().toLocaleString(); // 빌드된 시간

  return {
    props: {
      post: response,
      timestamp,
    },
    // revalidate: 60, // 60초마다 ISR (증분 정적 재생성)을 통해 페이지를 다시 생성
  };
};

// 페이지 컴포넌트
export default function SsgPage({ post, timestamp }: SsgPageProps) {
  const router = useRouter();

  // `router.isFallback`은 `fallback: true`일 때 사용됩니다.
  if (router.isFallback) {
    return <Layout title="로딩 중..."><div>페이지 로딩 중...</div></Layout>;
  }

  return (
    <Layout title={`SSG 게시물: ${post.title}`}>
      <h1>정적 사이트 생성 (SSG)</h1>
      <p>이 페이지는 <strong>빌드 시점</strong>에 생성되었습니다.</p>
      <h2>{post.title} (ID: {post.id})</h2>
      <p>{post.content}</p>
      <p>빌드된 시간: <strong>{timestamp}</strong></p>
      {/* 나쁜 예시: `getStaticProps`에서 가져온 데이터를 다시 `useEffect`에서 불러오는 것.
        - 불필요한 클라이언트 측 데이터 페칭을 발생시킵니다.
        - SSG로 데이터를 가져왔다면, 그 데이터를 사용하여 페이지를 렌더링해야 합니다. */}
    </Layout>
  );
}

/*
이 코드를 실행하려면:

1. `nextjs-basics-app/pages/ssg/[id].tsx` 파일 내용을 이 파일의 내용으로 교체.
2. `nextjs-basics-app/components` 디렉토리에 `Layout.tsx` 파일이 있어야 합니다.
3. `npm run dev` (또는 `yarn dev`) 명령어로 개발 서버를 시작하거나,
   `npm run build` 후 `npm run start` (또는 `yarn build` 후 `yarn start`) 명령어로 빌드 후 실행합니다.
4. `/ssg/1` 또는 `/ssg/2` 경로로 접근하여 페이지를 확인합니다.
5. `/ssg/3`과 같이 `getStaticPaths`에 없는 ID로 접근 시 404 페이지가 나타나는 것을 확인합니다 (`fallback: false`이기 때문).
*/
