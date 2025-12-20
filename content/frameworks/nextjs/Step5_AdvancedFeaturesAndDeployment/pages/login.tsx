// pages/login.tsx
// Next.js 미들웨어 리다이렉트 테스트를 위한 로그인 페이지입니다.

import Layout from '../components/Layout';

export default function LoginPage() {
  return (
    <Layout title="로그인">
      <h1>로그인 페이지</h1>
      <p>미들웨어가 인증되지 않은 사용자를 이 페이지로 리다이렉트합니다.</p>
      {/* 나쁜 예시: 실제 로그인 처리 없이 클라이언트 측에서만 쿠키를 설정하는 것.
        - 실제 로그인 프로세스는 서버 측 인증을 거쳐 JWT 토큰이나 세션 쿠키를 발행해야 합니다.
        - 이 버튼은 미들웨어 테스트를 위한 임시 방편입니다. */}
      <button onClick={() => document.cookie = 'token=my-secret-token; path=/'}>토큰 설정 (로그인 시뮬레이션)</button>
      <p style={{ marginTop: '20px' }}>
        버튼을 누른 후 <a href="/admin">관리자 페이지</a>로 다시 접근해보세요.
      </p>
    </Layout>
  );
}
