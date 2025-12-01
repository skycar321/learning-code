// React React Router
// SPA 구현을 위한 React Router 설정 및 동적 라우팅

// 나쁜 예시: SPA에서 브라우저의 기본 페이지 이동을 사용하거나, 라우팅 로직을 직접 구현하여 복잡하고 오류 발생 가능성 높음.
// 좋은 예시: React Router를 사용하여 SPA를 구현하고, 선언적인 라우팅, 동적 라우팅, 중첩 라우팅 등으로 사용자 친화적인 내비게이션 제공.

// (설치: `npm install react-router-dom`)
// 이 예시는 React Router v6를 기반으로 작성되었습니다.

import React from 'react';
import { BrowserRouter as Router, Routes, Route, Link, useParams, useNavigate } from 'react-router-dom';

// --- 1. 라우팅을 위한 컴포넌트 정의 ---
function Home() {
    return (
        <div>
            <h2>홈 페이지</h2>
            <p>React Router를 이용한 SPA 예제입니다.</p>
        </div>
    );
}

function About() {
    return (
        <div>
            <h2>회사 소개</h2>
            <p>저희 회사에 대해 알아보세요.</p>
        </div>
    );
}

function UserProfile() {
    // useParams 훅을 사용하여 URL 파라미터를 가져옵니다.
    const { userId } = useParams();
    const navigate = useNavigate(); // useNavigate 훅을 사용하여 프로그래밍 방식 탐색

    const goToDashboard = () => {
        navigate('/dashboard'); // /dashboard 경로로 이동
    };

    return (
        <div>
            <h2>사용자 프로필: {userId}</h2>
            <p>여기는 {userId}의 상세 프로필 페이지입니다.</p>
            <ul>
                <li><Link to="posts">게시물 보기</Link></li>
                <li><Link to="settings">설정</Link></li>
            </ul>
            <button onClick={goToDashboard}>대시보드로 이동</button>
        </div>
    );
}

function UserPosts() {
    const { userId } = useParams();
    return (
        <div style={{ border: '1px dashed gray', padding: '10px', marginTop: '10px' }}>
            <h3>{userId}의 게시물 목록</h3>
            <ul>
                <li>첫 번째 게시물</li>
                <li>두 번째 게시물</li>
            </ul>
        </div>
    );
}

function UserSettings() {
    const { userId } = useParams();
    return (
        <div style={{ border: '1px dashed gray', padding: '10px', marginTop: '10px' }}>
            <h3>{userId}의 설정</h3>
            <p>이메일 변경, 비밀번호 변경 등의 설정이 가능합니다.</p>
        </div>
    );
}

function Dashboard() {
    const navigate = useNavigate();
    return (
        <div>
            <h2>대시보드</h2>
            <p>로그인 후 접근 가능한 페이지입니다.</p>
            <button onClick={() => navigate(-1)}>뒤로 가기</button> {/* 이전 페이지로 */}
        </div>
    );
}

function NotFound() {
    return (
        <div>
            <h2>404 - 페이지를 찾을 수 없습니다.</h2>
            <p>요청하신 페이지가 존재하지 않습니다.</p>
            <Link to="/">홈으로 돌아가기</Link>
        </div>
    );
}


// --- 메인 App 컴포넌트 ---
function App() {
    return (
        // BrowserRouter로 전체 앱을 감싸 라우팅 기능 활성화
        <Router>
            <div style={{ padding: '20px', border: '1px solid #eee' }}>
                <h1>React Router v6 학습</h1>

                <nav style={{ marginBottom: '20px' }}>
                    <Link to="/" style={{ marginRight: '10px' }}>홈</Link>
                    <Link to="/about" style={{ marginRight: '10px' }}>소개</Link>
                    <Link to="/users/1" style={{ marginRight: '10px' }}>사용자 1</Link>
                    <Link to="/users/2" style={{ marginRight: '10px' }}>사용자 2</Link>
                    <Link to="/dashboard" style={{ marginRight: '10px' }}>대시보드</Link>
                </nav>

                <hr />

                {/* Routes는 여러 Route 컴포넌트를 감싸고, 가장 먼저 매칭되는 Route를 렌더링합니다. */}
                <Routes>
                    <Route path="/" element={<Home />} />
                    <Route path="/about" element={<About />} />
                    
                    {/* 동적 라우팅 및 중첩 라우팅 */}
                    <Route path="/users/:userId" element={<UserProfile />}>
                        {/* 자식 라우트들은 UserProfile 컴포넌트 내부의 <Outlet />에 렌더링됩니다. */}
                        <Route path="posts" element={<UserPosts />} />
                        <Route path="settings" element={<UserSettings />} />
                    </Route>

                    {/* 중첩 라우트의 인덱스 라우트 (부모 라우트 경로로 접속 시 기본으로 렌더링될 내용) */}
                    <Route path="/dashboard" element={<Dashboard />} />
                    
                    {/* 매칭되는 라우트가 없을 때 (404 페이지) */}
                    <Route path="*" element={<NotFound />} />
                </Routes>
            </div>
        </Router>
    );
}

// ReactDOM.render(<App />, document.getElementById('root'));
