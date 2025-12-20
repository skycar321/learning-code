// pages/admin.tsx
// Next.js 미들웨어 테스트를 위한 관리자 페이지입니다.
// `middleware.ts` 파일에 의해 인증되지 않은 사용자의 접근이 제한됩니다.

import Layout from '../components/Layout';

export default function AdminPage() {
  return (
    <Layout title="관리자 페이지">
      <h1>관리자 페이지입니다.</h1>
      <p>미들웨어에 의해 보호됩니다.</p>
    </Layout>
  );
}
