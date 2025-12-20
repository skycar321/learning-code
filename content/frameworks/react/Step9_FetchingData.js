// React 데이터 가져오기 (Fetch, Axios, React Query)
// 서버에서 데이터 가져오기 및 상태 관리 라이브러리 활용

// 나쁜 예시: `useEffect` 내부에서 비동기 로직을 직접 관리하여 로딩, 에러, 캐싱 처리 등을 수동으로 구현하여 복잡도가 높고 버그 발생 가능성 높음.
// 좋은 예시: `Fetch API`나 `Axios`로 데이터 요청을 수행하고, `React Query` 같은 데이터 페칭 라이브러리를 사용하여 로딩, 에러, 캐싱, 재시도, 동기화 등을 효율적으로 관리.

import React, { useState, useEffect } from 'react';
// import axios from 'axios'; // npm install axios 필요
// import { QueryClient, QueryClientProvider, useQuery } from 'react-query'; // npm install react-query 필요

const API_URL = "https://jsonplaceholder.typicode.com/posts/1"; // 공개 테스트 API
const TODOS_API_URL = "https://jsonplaceholder.typicode.com/todos";

// --- 1. Fetch API (기본 제공) ---
// JavaScript의 기본 API로, Promise 기반으로 동작합니다.

function FetchExample() {
    const [post, setPost] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        const fetchPost = async () => {
            try {
                const response = await fetch(API_URL);
                if (!response.ok) {
                    throw new Error(`HTTP 오류! 상태: ${response.status}`);
                }
                const data = await response.json();
                setPost(data);
            } catch (err) {
                setError(err);
            } finally {
                setLoading(false);
            }
        };
        fetchPost();
    }, []); // 컴포넌트 마운트 시 한 번만 실행

    if (loading) return <p>데이터를 불러오는 중...</p>;
    if (error) return <p>오류 발생: {error.message}</p>;

    return (
        <div style={{ border: '1px solid lightgray', padding: '10px', margin: '10px' }}>
            <h3>Fetch API 예시</h3>
            {post && (
                <div>
                    <h4>{post.title}</h4>
                    <p>{post.body}</p>
                </div>
            )}
        </div>
    );
}

// --- 2. Axios (인기 있는 HTTP 클라이언트 라이브러리) ---
// Fetch API보다 더 많은 기능을 제공합니다. (자동 JSON 파싱, 인터셉터, 요청 취소 등)
// (`npm install axios` 필요)

/*
function AxiosExample() {
    const [todo, setTodo] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        const fetchTodo = async () => {
            try {
                const response = await axios.get(`${TODOS_API_URL}/1`); // GET 요청
                setTodo(response.data); // Axios는 응답 데이터를 data 속성으로 제공
            } catch (err) {
                setError(err);
            } finally {
                setLoading(false);
            }
        };
        fetchTodo();
    }, []);

    if (loading) return <p>데이터를 불러오는 중 (Axios)...</p>;
    if (error) return <p>오류 발생 (Axios): {error.message}</p>;

    return (
        <div style={{ border: '1px solid lightgray', padding: '10px', margin: '10px' }}>
            <h3>Axios 예시</h3>
            {todo && (
                <div>
                    <h4>할 일: {todo.title}</h4>
                    <p>완료 여부: {todo.completed ? '예' : '아니오'}</p>
                </div>
            )}
        </div>
    );
}
*/

// --- 3. React Query (데이터 페칭 라이브러리) ---
// 서버 상태를 관리하기 위한 강력한 라이브러리. 캐싱, 백그라운드 업데이트, 에러 처리, 재시도 등을 자동화합니다.
// (`npm install react-query` 필요)
// QueryClientProvider로 앱을 감싸야 합니다.

/*
const queryClient = new QueryClient(); // QueryClient 인스턴스 생성

function ReactQueryExample() {
    // `useQuery` 훅을 사용하여 데이터 페칭 및 관리
    const { data, isLoading, isError, error } = useQuery('todoData', async () => {
        const response = await axios.get(`${TODOS_API_URL}/2`);
        return response.data;
    });

    if (isLoading) return <p>데이터를 불러오는 중 (React Query)...</p>;
    if (isError) return <p>오류 발생 (React Query): {error.message}</p>;

    return (
        <div style={{ border: '1px solid lightgray', padding: '10px', margin: '10px' }}>
            <h3>React Query 예시</h3>
            {data && (
                <div>
                    <h4>할 일: {data.title}</h4>
                    <p>완료 여부: {data.completed ? '예' : '아니오'}</p>
                </div>
            )}
        </div>
    );
}
*/


function App() {
    return (
        // React Query를 사용하려면 전체 앱을 QueryClientProvider로 감싸야 합니다.
        // <QueryClientProvider client={queryClient}>
            <div style={{ padding: '20px', border: '1px solid #eee' }}>
                <h1>React 데이터 가져오기 학습</h1>

                <FetchExample />
                {/* <AxiosExample /> */}
                {/* <ReactQueryExample /> */}

                <p>간단한 요청에는 Fetch API나 Axios가 적합하지만, 복잡한 서버 상태 관리에는 React Query와 같은 라이브러리가 매우 유용합니다.</p>
                <p>주석 처리된 Axios와 React Query 예제를 실행하려면 해당 라이브러리를 설치해야 합니다.</p>
            </div>
        // </QueryClientProvider>
    );
}

// ReactDOM.render(<App />, document.getElementById('root'));
