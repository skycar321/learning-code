// React 함수형 컴포넌트와 Hooks
// `useState`, `useEffect`, `useContext` 등 Hooks 사용법 학습

// 나쁜 예시: 클래스형 컴포넌트를 사용하여 `this` 바인딩 문제, 복잡한 라이프사이클 메서드 로직 등으로 코드 가독성과 재사용성 저해.
// 좋은 예시: 함수형 컴포넌트와 Hooks를 사용하여 상태 관리, 라이프사이클 처리, 컨텍스트 사용 등을 간결하고 모듈화된 방식으로 구현.

import React, { useState, useEffect, useContext, createContext, useReducer, useCallback, useMemo } from 'react';

// --- 1. useState (상태 관리 Hook) ---
// 함수형 컴포넌트에서 상태를 관리할 수 있게 해줍니다.

function Counter() {
    const [count, setCount] = useState(0); // [현재 상태, 상태 업데이트 함수] = useState(초기값)

    return (
        <div style={{ border: '1px solid lightgray', padding: '10px', margin: '10px' }}>
            <h3>useState 예시</h3>
            <p>현재 카운트: {count}</p>
            <button onClick={() => setCount(count + 1)}>증가</button>
            <button onClick={() => setCount(prevCount => prevCount - 1)}>감소 (이전 상태 활용)</button>
        </div>
    );
}

// --- 2. useEffect (부수 효과 Hook) ---
// 컴포넌트가 렌더링될 때마다 특정 작업을 수행할 수 있게 해줍니다.
// (데이터 가져오기, 구독 설정, DOM 직접 조작 등)

function Timer() {
    const [seconds, setSeconds] = useState(0);

    // 컴포넌트가 마운트되거나 업데이트될 때마다 실행
    useEffect(() => {
        const intervalId = setInterval(() => {
            setSeconds(prevSeconds => prevSeconds + 1);
        }, 1000);

        // 클린업 함수: 컴포넌트가 언마운트되거나 다음 효과가 실행되기 전에 실행됩니다.
        // 메모리 누수를 방지하고 불필요한 구독을 해제합니다.
        return () => clearInterval(intervalId);
    }, []); // 의존성 배열이 비어있으면 마운트될 때 한 번만 실행되고, 언마운트될 때 클린업 함수 실행.
           // 여기에 변수를 넣으면 해당 변수가 변경될 때마다 효과가 재실행됩니다.

    return (
        <div style={{ border: '1px solid lightgray', padding: '10px', margin: '10px' }}>
            <h3>useEffect 예시</h3>
            <p>타이머: {seconds}초</p>
        </div>
    );
}

// --- 3. useContext (컨텍스트 Hook) ---
// 컴포넌트 트리 깊숙이 있는 자식 컴포넌트에게도 props 드릴링 없이 데이터를 전달할 수 있게 해줍니다.

// 컨텍스트 생성
const ThemeContext = createContext('light'); // 기본값 'light'

function ThemeToggle() {
    const theme = useContext(ThemeContext); // 컨텍스트 값 사용

    return (
        <div style={{ border: '1px solid lightgray', padding: '10px', margin: '10px', backgroundColor: theme === 'dark' ? '#333' : '#fff', color: theme === 'dark' ? '#fff' : '#333' }}>
            <h3>useContext 예시</h3>
            <p>현재 테마: {theme}</p>
        </div>
    );
}

// --- 4. 기타 Hooks (useReducer, useCallback, useMemo) ---

// useReducer: 복잡한 상태 로직을 관리할 때 useState의 대안으로 사용. (Redux와 유사)
const initialState = { count: 0 };
function reducer(state, action) {
    switch (action.type) {
        case 'increment': return { count: state.count + 1 };
        case 'decrement': return { count: state.0 - 1 };
        default: throw new Error();
    }
}

function ReducerCounter() {
    const [state, dispatch] = useReducer(reducer, initialState);
    return (
        <div style={{ border: '1px solid lightgray', padding: '10px', margin: '10px' }}>
            <h3>useReducer 예시</h3>
            <p>카운트: {state.count}</p>
            <button onClick={() => dispatch({ type: 'increment' })}>증가</button>
            <button onClick={() => dispatch({ type: 'decrement' })}>감소</button>
        </div>
    );
}

// useCallback: 함수를 메모이제이션하여 불필요한 리렌더링을 방지.
function ParentComponent() {
    const [count, setCount] = useState(0);
    const [text, setText] = useState('');

    // count가 변경될 때만 이 함수가 재생성됩니다.
    const handleClick = useCallback(() => {
        setCount(count + 1);
    }, [count]);

    return (
        <div style={{ border: '1px solid lightgray', padding: '10px', margin: '10px' }}>
            <h3>useCallback 예시</h3>
            <p>카운트: {count}</p>
            <button onClick={handleClick}>증가 (useCallback)</button>
            <input type="text" value={text} onChange={(e) => setText(e.target.value)} placeholder="텍스트 입력" />
            <ChildComponentWithCallback onClick={handleClick} /> {/* 이 컴포넌트는 text가 바뀌어도 리렌더링되지 않습니다 */}
        </div>
    );
}

// ChildComponentWithCallback (React.memo로 래핑하여 props가 바뀌지 않으면 리렌더링 안 함)
const ChildComponentWithCallback = React.memo(({ onClick }) => {
    console.log('ChildComponentWithCallback 렌더링');
    return <button onClick={onClick}>자식 버튼 (useCallback)</button>;
});


// useMemo: 값(결과)을 메모이제이션하여 불필요한 계산을 방지.
function MemoExample() {
    const [number, setNumber] = useState(0);
    const [dark, setDark] = useState(false);

    // number가 변경될 때만 expensiveCalculation이 다시 실행됩니다.
    const expensiveValue = useMemo(() => {
        console.log('Expensive Calculation...');
        return number * 2; // 복잡한 계산 가정
    }, [number]);

    const themeStyle = useMemo(() => {
        return {
            backgroundColor: dark ? 'black' : 'white',
            color: dark ? 'white' : 'black'
        };
    }, [dark]); // dark 값이 변경될 때만 themeStyle 객체가 재생성

    return (
        <div style={{ border: '1px solid lightgray', padding: '10px', margin: '10px' }}>
            <h3>useMemo 예시</h3>
            <input type="number" value={number} onChange={(e) => setNumber(parseInt(e.target.value))} />
            <div style={themeStyle}>계산된 값: {expensiveValue}</div>
            <button onClick={() => setDark(prevDark => !prevDark)}>테마 토글</button>
        </div>
    );
}


function App() {
    const [theme, setTheme] = useState('light');

    return (
        <div style={{ padding: '20px', border: '1px solid #eee' }}>
            <h1>함수형 컴포넌트와 Hooks 학습</h1>
            
            <Counter />
            <Timer />
            
            {/* ThemeContext.Provider로 하위 컴포넌트에 'dark' 테마 제공 */}
            <ThemeContext.Provider value={theme}>
                <ThemeToggle />
                <button onClick={() => setTheme(prevTheme => prevTheme === 'light' ? 'dark' : 'light')}>
                    테마 변경
                </button>
            </ThemeContext.Provider>
            
            <ReducerCounter />
            <ParentComponent />
            <MemoExample />
            
            <p>Hooks는 함수형 컴포넌트에서 React 상태와 라이프사이클 기능을 사용할 수 있게 해줍니다.</p>
        </div>
    );
}

// ReactDOM.render(<App />, document.getElementById('root'));
