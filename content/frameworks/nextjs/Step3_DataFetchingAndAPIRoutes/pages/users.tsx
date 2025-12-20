// nextjs/Step3_DataFetchingAndAPIRoutes/pages/users.tsx
// Next.js 학습 계획 - 3단계: 데이터 페칭 및 API 라우팅
// 이 파일은 클라이언트 측 데이터 페칭(`useEffect`와 `fetch`)을 보여주는 `users.tsx` 페이지입니다.
// Next.js의 API 라우트(`pages/api/users.ts`)를 호출하여 사용자 목록을 가져옵니다.
//
// 클라이언트 측 데이터 페칭은 초기 로드 속도보다는 상호작용성이나
// 사용자 인증이 필요한 데이터에 주로 사용됩니다.

import { useEffect, useState } from 'react';
import Layout from '../../components/Layout'; // Layout 컴포넌트 임포트

// 사용자 데이터 인터페이스 정의
interface User {
  id: number;
  name: string;
  email: string;
}

export default function UsersPage() {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // -----------------------------------------------------------------------------
  // 학습 포인트 1: 클라이언트 측 데이터 페칭 (`useEffect`)
  // - `useEffect` 훅을 사용하여 컴포넌트가 마운트될 때 API를 호출하고 데이터를 가져옵니다.
  // - `fetch` API를 사용하여 Next.js API 라우트(`api/users`)를 호출합니다.
  // - 로딩 상태(`loading`)와 에러 상태(`error`)를 관리하여 사용자 경험을 향상시킵니다.
  // -----------------------------------------------------------------------------
  useEffect(() => {
    const fetchUsers = async () => {
      try {
        setLoading(true); // 데이터 가져오기 시작 시 로딩 상태 true
        const response = await fetch('/api/users'); // Next.js API 라우트 호출
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        const data: User[] = await response.json();
        setUsers(data);
      } catch (err) {
        // 나쁜 예시: API 호출 실패 시 에러를 UI에 표시하지 않고,
        // - 사용자에게 아무런 피드백도 주지 않아 왜 데이터가 보이지 않는지 알 수 없게 하는 것.
        // - 항상 에러 상태를 관리하고 사용자에게 적절한 메시지를 보여줘야 합니다.
        setError((err as Error).message);
      } finally {
        setLoading(false); // 데이터 가져오기 완료 시 로딩 상태 false
      }
    };

    fetchUsers();
  }, []); // 빈 배열은 컴포넌트가 처음 마운트될 때 한 번만 실행됨을 의미합니다.

  if (loading) {
    return (
      <Layout title="사용자 목록">
        <h1>사용자 목록 (클라이언트 측 페칭)</h1>
        <p>데이터 로딩 중...</p>
      </Layout>
    );
  }

  if (error) {
    return (
      <Layout title="사용자 목록">
        <h1>사용자 목록 (클라이언트 측 페칭)</h1>
        <p style={{ color: 'red' }}>에러 발생: {error}</p>
      </Layout>
    );
  }

  return (
    <Layout title="사용자 목록">
      <h1>사용자 목록 (클라이언트 측 페칭)</h1>
      <p>이 페이지는 클라이언트 측에서 `api/users` 엔드포인트를 호출하여 데이터를 가져옵니다.</p>
      <ul>
        {users.map(user => (
          <li key={user.id}>
            <strong>{user.name}</strong> ({user.email})
          </li>
        ))}
      </ul>
      {/* 나쁜 예시: 클라이언트 측에서 페칭한 데이터를 SEO에 중요한 페이지에 사용하는 것.
        - 검색 엔진 크롤러는 JavaScript를 실행하지 못할 수 있으므로,
        - 초기 로드 시 데이터가 없는 페이지는 SEO에 불리할 수 있습니다.
        - SEO가 중요한 페이지에는 SSR 또는 SSG를 고려해야 합니다. */}
    </Layout>
  );
}

/*
이 코드를 실행하려면:

1. `nextjs-basics-app/pages/users.tsx` 파일 내용을 이 파일의 내용으로 교체.
2. `nextjs-basics-app/pages/api/users.ts` 파일을 생성하여 이 페이지가 호출할 API 라우트를 구현해야 합니다.
3. `nextjs-basics-app/components` 디렉토리에 `Layout.tsx` 파일이 있어야 합니다.
4. `npm run dev` (또는 `yarn dev`) 명령어로 애플리케이션 실행 후 `/users` 경로로 접근.
*/
