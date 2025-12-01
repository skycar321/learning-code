// React 기본 개념
// JSX, 컴포넌트, Props, State 등 React 핵심 개념 이해

// 나쁜 예시: JSX 내에서 직접 DOM 조작 코드를 작성하거나, 컴포넌트 간에 props 없이 전역 변수를 공유합니다.
// 좋은 예시: JSX 문법을 사용하여 선언적으로 UI를 구성하고, props를 통해 데이터를 단방향으로 전달하여 컴포넌트의 재사용성을 높입니다.

import React, { useState } from 'react'; // React와 useState Hook 임포트

// --- 1. JSX (JavaScript XML) ---
// JavaScript 안에 HTML과 유사한 마크업을 작성할 수 있게 해주는 React 확장 문법.
// Babel을 통해 일반 JavaScript로 변환됩니다.

function JsxExample() {
    const name = 'React World';
    const element = <h1>Hello, {name}!</h1>; // JSX 사용

    // 조건부 렌더링 예시 (JSX 내부에서 JavaScript 표현식 사용)
    const isLoggedIn = true;
    const greeting = (
        <div>
            {isLoggedIn ? <p>환영합니다!</p> : <p>로그인해주세요.</p>}
        </div>
    );

    // JSX는 반드시 하나의 부모 요소로 감싸져야 합니다. (Fragment 사용 가능)
    return (
        <div>
            {element}
            {greeting}
            <p>JSX는 JavaScript 표현식을 중괄호 {{}} 안에 넣어 사용할 수 있습니다.</p>
        </div>
    );
}

// --- 2. 컴포넌트 (Component) ---
// UI를 독립적이고 재사용 가능한 조각으로 나눈 것입니다.
// 함수형 컴포넌트 (Functional Component)와 클래스형 컴포넌트 (Class Component)가 있습니다.
// React 16.8+ 버전부터는 Hooks의 도입으로 함수형 컴포넌트가 주로 사용됩니다.

// 함수형 컴포넌트 예시 (선언적 UI)
function WelcomeMessage(props) { // props를 인자로 받습니다.
    return (
        <div className="welcome-card">
            <h2>안녕하세요, {props.name}!</h2>
            <p>{props.message}</p>
        </div>
    );
}

// --- 3. Props (속성) ---
// 컴포넌트 간에 데이터를 전달하는 방법입니다. (부모 -> 자식 단방향 흐름)
// Props는 읽기 전용(read-only)이며, 자식 컴포넌트가 직접 변경해서는 안 됩니다.

function UserProfile(props) {
    return (
        <div>
            <h3>사용자 프로필</h3>
            <p>이름: {props.user.name}</p>
            <p>나이: {props.user.age}</p>
            <p>직업: {props.user.job}</p>
            {/* props.children: 컴포넌트 태그 사이에 있는 내용을 렌더링 */}
            {props.children}
        </div>
    );
}

// --- 4. State (상태) ---
// 컴포넌트 내부에서 변경될 수 있는 데이터를 관리하는 객체입니다.
// State가 변경되면 컴포넌트가 다시 렌더링(re-render)됩니다.
// 함수형 컴포넌트에서는 `useState` Hook을 사용하여 상태를 관리합니다.

function Counter() {
    // `count`는 현재 상태 값, `setCount`는 상태를 업데이트하는 함수
    const [count, setCount] = useState(0); // 초기값 0

    const increment = () => {
        setCount(count + 1); // 상태 업데이트 함수 사용
    };

    const decrement = () => {
        setCount(count - 1);
    };

    return (
        <div>
            <h3>카운터</h3>
            <p>현재 카운트: {count}</p>
            <button onClick={increment}>증가</button>
            <button onClick={decrement}>감소</button>
        </div>
    );
}


// --- 메인 앱 컴포넌트 (모든 예시를 포함) ---
function App() {
    const userInfo = {
        name: "김리액트",
        age: 28,
        job: "프론트엔드 개발자"
    };

    return (
        <div style={{ padding: '20px', border: '1px solid #eee' }}>
            <h1>React 기본 개념 학습</h1>
            
            <JsxExample />
            <hr />
            
            <WelcomeMessage name="Jane Doe" message="React 세계에 오신 것을 환영합니다!" />
            <WelcomeMessage name="John Smith" message="Props를 통해 데이터를 전달하는 예시입니다." />
            <hr />

            <UserProfile user={userInfo}>
                <p>추가 정보: 이 프로필은 {userInfo.name} 님의 것입니다.</p>
            </UserProfile>
            <hr />

            <Counter />
            <hr />

            <p>React는 단방향 데이터 흐름을 가지며, 상태가 변경될 때마다 효율적으로 UI를 업데이트합니다.</p>
            <p>JSX, 컴포넌트, Props, State는 React 개발의 핵심 기둥입니다.</p>
        </div>
    );
}

// React 애플리케이션을 DOM에 렌더링합니다. (HTML에 <div id="root"></div> 필요)
// ReactDOM.render(<App />, document.getElementById('root'));

// 위 코드는 React 애플리케이션의 핵심 개념을 설명하는 JavaScript 파일입니다.
// 실제 React 프로젝트는 보통 JSX를 직접 지원하는 빌드 도구(예: Create React App, Vite)를 사용합니다.
// 이 코드를 실행하려면 HTML 파일과 React 라이브러리가 필요합니다.
// (예: <script src="https://unpkg.com/react/umd/react.development.js"></script>,
// <script src="https://unpkg.com/react-dom/umd/react-dom.development.js"></script>,
// <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
// <script type="text/babel" src="Step1_ReactBasicConcepts.js"></script>)
