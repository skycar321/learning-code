// React 조건부 렌더링과 리스트 렌더링
// `if/else`, 삼항 연산자, `map`을 이용한 조건부/리스트 렌더링

// 나쁜 예시: 조건에 따라 여러 컴포넌트를 하드코딩하거나, 배열 데이터를 수동으로 DOM에 추가하여 코드의 유연성 저해.
// 좋은 예시: JavaScript의 조건문과 배열 메서드 `map`을 활용하여 선언적이고 재사용 가능한 방식으로 UI를 렌더링.

import React, { useState } from 'react';

// --- 1. 조건부 렌더링 (Conditional Rendering) ---
// 조건에 따라 다른 UI 요소를 보여주거나 숨깁니다.

function UserGreeting(props) {
    return <h1>환영합니다!</h1>;
}

function GuestGreeting(props) {
    return <h1>로그인해주세요.</h1>;
}

function Greeting(props) {
    const isLoggedIn = props.isLoggedIn;
    if (isLoggedIn) { // 1. `if` 문 사용 (컴포넌트 함수 내부)
        return <UserGreeting />;
    }
    return <GuestGreeting />;
}

function LoginControl() {
    const [isLoggedIn, setIsLoggedIn] = useState(false);

    const handleLoginClick = () => {
        setIsLoggedIn(true);
    };

    const handleLogoutClick = () => {
        setIsLoggedIn(false);
    };

    let button;
    if (isLoggedIn) {
        button = <button onClick={handleLogoutClick}>로그아웃</button>;
    } else {
        button = <button onClick={handleLoginClick}>로그인</button>;
    }

    return (
        <div style={{ border: '1px solid lightgray', padding: '10px', margin: '10px' }}>
            <h3>조건부 렌더링 (if/else)</h3>
            <Greeting isLoggedIn={isLoggedIn} />
            {button}
        </div>
    );
}

function ConditionalDisplay() {
    const [showMessage, setShowMessage] = useState(false);
    const [userStatus, setUserStatus] = useState('pending'); // 'pending', 'active', 'inactive'

    return (
        <div style={{ border: '1px solid lightgray', padding: '10px', margin: '10px' }}>
            <h3>조건부 렌더링 (논리 &&, 삼항 연산자)</h3>
            <button onClick={() => setShowMessage(!showMessage)}>메시지 토글</button>
            {/* 2. 논리 && 연산자 (조건이 true일 때만 렌더링) */}
            {showMessage && <p>이 메시지는 showMessage가 true일 때만 보입니다.</p>}

            <br />
            <p>현재 사용자 상태: {userStatus}</p>
            <button onClick={() => setUserStatus('active')}>활성화</button>
            <button onClick={() => setUserStatus('inactive')}>비활성화</button>
            <button onClick={() => setUserStatus('pending')}>대기 중</button>

            {/* 3. 삼항 연산자 (조건에 따라 두 가지 중 하나 렌더링) */}
            {userStatus === 'active' ? (
                <p style={{ color: 'green' }}>사용자가 활성화되었습니다.</p>
            ) : userStatus === 'inactive' ? (
                <p style={{ color: 'red' }}>사용자가 비활성화되었습니다.</p>
            ) : (
                <p style={{ color: 'orange' }}>사용자 상태 대기 중...</p>
            )}
        </div>
    );
}

// --- 2. 리스트 렌더링 (List Rendering) ---
// 배열 데이터를 사용하여 여러 개의 컴포넌트를 렌더링합니다.

function NumberList(props) {
    const numbers = props.numbers;
    const listItems = numbers.map((number) =>
        // 각 리스트 아이템에는 고유한 `key` prop을 제공해야 합니다.
        // `key`는 React가 리스트의 어떤 항목이 변경, 추가 또는 제거되었는지 식별하는 데 도움을 줍니다.
        // `key`로 `index`를 사용하는 것은 리스트 항목이 재정렬되거나 추가/삭제될 때 문제가 발생할 수 있으므로,
        // 데이터에 고유한 ID가 있다면 그것을 `key`로 사용하는 것이 좋습니다.
        <li key={number.toString()}>
            {number}
        </li>
    );
    return (
        <ul style={{ border: '1px solid lightgray', padding: '10px', margin: '10px' }}>
            <h3>리스트 렌더링 (숫자)</h3>
            {listItems}
        </ul>
    );
}

function TodoList() {
    const todos = [
        { id: 1, text: 'React 학습하기', isCompleted: false },
        { id: 2, text: '프로젝트 개발하기', isCompleted: false },
        { id: 3, text: '점심 식사하기', isCompleted: true },
    ];

    return (
        <div style={{ border: '1px solid lightgray', padding: '10px', margin: '10px' }}>
            <h3>리스트 렌더링 (Todo 목록)</h3>
            <ul>
                {todos.map((todo) =>
                    <li key={todo.id} style={{ textDecoration: todo.isCompleted ? 'line-through' : 'none' }}>
                        {todo.text}
                    </li>
                )}
            </ul>
        </div>
    );
}


function App() {
    const numbers = [1, 2, 3, 4, 5];

    return (
        <div style={{ padding: '20px', border: '1px solid #eee' }}>
            <h1>React 조건부 렌더링과 리스트 렌더링 학습</h1>

            <LoginControl />
            <ConditionalDisplay />

            <NumberList numbers={numbers} />
            <TodoList />

            <p>React에서는 JavaScript의 강력한 기능을 활용하여 조건과 배열을 기반으로 유연하게 UI를 구성합니다.</p>
            <p>리스트 렌더링 시에는 항상 `key` prop을 사용하여 React의 효율적인 업데이트를 돕는 것이 중요합니다.</p>
        </div>
    );
}

// ReactDOM.render(<App />, document.getElementById('root'));
