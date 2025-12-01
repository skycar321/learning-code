// React 상태 관리 (Context API, Redux/Zustand)
// Context API 또는 Redux/Zustand를 이용한 전역 상태 관리

// 나쁜 예시: `props` 드릴링(컴포넌트 트리를 따라 props를 깊게 전달)을 사용하여 코드를 복잡하게 만들거나,
// 전역 상태를 전역 변수로 관리하여 예측 불가능한 버그 발생.
// 좋은 예시: `Context API`로 간단한 전역 상태를 관리하고,
// `Redux`나 `Zustand` 같은 전문 상태 관리 라이브러리로 복잡한 전역 상태를 예측 가능하고 효율적으로 관리.

import React, { useState, useEffect, useContext, createContext, useReducer } from 'react';

// --- 1. Context API ---
// 간단한 전역 상태 관리나 테마, 언어 설정 등 자주 변경되지 않는 값들을 컴포넌트 트리에 제공할 때 사용합니다.
// `props` 드릴링을 피할 수 있지만, Provider의 re-render 문제가 있을 수 있습니다 (optimizing Provider re-renders).

// 1-1. Context 생성
const ThemeContext = createContext(null); // 초기값은 null로 설정하거나 기본값을 줄 수 있습니다.

// 1-2. Context Provider 컴포넌트
function ThemeProvider({ children }) {
    const [theme, setTheme] = useState('light');

    const toggleTheme = () => {
        setTheme(prevTheme => (prevTheme === 'light' ? 'dark' : 'light'));
    };

    return (
        // Context.Provider로 하위 컴포넌트에 `theme`과 `toggleTheme`을 제공
        <ThemeContext.Provider value={{ theme, toggleTheme }}>
            {children}
        </ThemeContext.Provider>
    );
}

// 1-3. Context Consumer 컴포넌트
function ThemeDisplay() {
    const { theme, toggleTheme } = useContext(ThemeContext); // useContext Hook으로 Context 값 접근

    return (
        <div style={{ background: theme === 'dark' ? '#333' : '#fff', color: theme === 'dark' ? '#fff' : '#333', padding: '15px' }}>
            <h4>Context API 예시</h4>
            <p>현재 테마: {theme}</p>
            <button onClick={toggleTheme}>테마 전환</button>
        </div>
    );
}

function ProfileCard() {
    const { theme } = useContext(ThemeContext);
    return (
        <div style={{ border: `1px solid ${theme === 'dark' ? 'white' : 'black'}`, padding: '10px', marginTop: '10px' }}>
            <h5>프로필 카드</h5>
            <p>이 카드는 현재 {theme} 테마를 사용 중입니다.</p>
        </div>
    );
}

// --- 2. Redux (혹은 유사 라이브러리 - Zustand) ---
// Redux는 예측 가능한 상태 컨테이너입니다.
// 액션(Action) -> 디스패치(Dispatch) -> 리듀서(Reducer) -> 스토어(Store) -> 상태(State)
// (여기서는 개념만 설명하고, Zustand로 간략한 예시)

// Redux의 3가지 핵심 원칙:
// 1. Single source of truth: 앱의 모든 상태는 하나의 거대한 객체 트리 안에 있습니다.
// 2. State is read-only: 상태는 액션에 의해서만 변경될 수 있습니다.
// 3. Changes are made with pure functions: 변경 사항은 순수 함수인 리듀서에 의해서만 이루어집니다.

// --- Zustand (가볍고 빠르며 간결한 상태 관리 라이브러리) ---
// Redux와 유사하지만 더 간단한 API를 제공합니다.
// (설치: `npm install zustand`)

// 2-1. Zustand 스토어 생성
// import { create } from 'zustand'; // 실제 사용 시

// 가상의 Zustand 스토어 (create 함수를 직접 사용할 수 없으므로 객체로 표현)
const createZustandStore = (set) => ({
    count: 0,
    increment: () => set(state => ({ count: state.count + 1 })),
    decrement: () => set(state => ({ count: state.count - 1 })),
    reset: () => set({ count: 0 }),
    message: 'Hello Zustand',
    updateMessage: (newMessage) => set({ message: newMessage }),
});

// 실제 Zustand 사용 예시:
// const useStore = create(createZustandStore);

// Zustand 대체 (useReducer를 사용하여 간략하게 Redux/Zustand 패턴을 모방)
const zustandInitialState = { count: 0, message: 'Hello Zustand (mock)' };
function zustandReducer(state, action) {
    switch (action.type) {
        case 'INCREMENT':
            return { ...state, count: state.count + 1 };
        case 'DECREMENT':
            return { ...state, count: state.count - 1 };
        case 'RESET':
            return { ...state, count: 0 };
        case 'UPDATE_MESSAGE':
            return { ...state, message: action.payload };
        default:
            return state;
    }
}

function ZustandCounter() {
    const [state, dispatch] = useReducer(zustandReducer, zustandInitialState);

    return (
        <div style={{ border: '1px solid lightgray', padding: '10px', margin: '10px' }}>
            <h3>Zustand (useReducer로 모방) 예시</h3>
            <p>카운트: {state.count}</p>
            <p>메시지: {state.message}</p>
            <button onClick={() => dispatch({ type: 'INCREMENT' })}>증가</button>
            <button onClick={() => dispatch({ type: 'DECREMENT' })}>감소</button>
            <button onClick={() => dispatch({ type: 'RESET' })}>초기화</button>
            <button onClick={() => dispatch({ type: 'UPDATE_MESSAGE', payload: 'Message Updated!' })}>
                메시지 업데이트
            </button>
        </div>
    );
}


function App() {
    return (
        <div style={{ padding: '20px', border: '1px solid #eee' }}>
            <h1>React 상태 관리 학습</h1>

            <ThemeProvider>
                <ThemeDisplay />
                <ProfileCard />
            </ThemeProvider>
            <hr />

            <ZustandCounter />
            <hr />

            <p>React에서 전역 상태 관리는 Context API로 간단한 상태를, Redux나 Zustand로 복잡한 상태를 관리하는 것이 일반적입니다.</p>
            <p>어떤 도구를 선택할지는 프로젝트의 규모와 복잡성, 팀의 선호도에 따라 달라집니다.</p>
        </div>
    );
}

// ReactDOM.render(<App />, document.getElementById('root'));
