// React 컴포넌트 라이프사이클
// 함수형 컴포넌트에서 `useEffect`를 이용한 라이프사이클 관리

// 나쁜 예시: 클래스형 컴포넌트의 복잡한 라이프사이클 메서드(componentDidMount, componentDidUpdate, componentWillUnmount)를 사용하여
// 로직이 여러 메서드에 분산되거나, 의도치 않은 버그 발생.
// 좋은 예시: `useEffect` Hook을 사용하여 컴포넌트의 마운트, 업데이트, 언마운트 시점에 필요한 작업을 간결하고 명확하게 처리.

import React, { useState, useEffect } from 'react';

// --- useEffect를 이용한 마운트, 업데이트, 언마운트 처리 ---

function LifecycleTracker() {
    const [count, setCount] = useState(0);
    const [text, setText] = useState('');

    // 1. 마운트 시 한 번만 실행 (componentDidMount 역할)
    // 의존성 배열을 비워두면 컴포넌트가 처음 렌더링될 때만 실행됩니다.
    useEffect(() => {
        console.log('[useEffect] 컴포넌트가 마운트되었습니다.');
        // 주로 초기 데이터 로딩, 구독 설정 (cleanup 필요), DOM 조작 등에 사용됩니다.

        // 클린업 함수: 컴포넌트가 언마운트될 때 실행 (componentWillUnmount 역할)
        return () => {
            console.log('[useEffect cleanup] 컴포넌트가 언마운트됩니다.');
            // 구독 해제, 타이머 클리어, 이벤트 리스너 제거 등 정리 작업에 사용됩니다.
        };
    }, []); // 빈 의존성 배열


    // 2. 업데이트 시마다 실행 (componentDidUpdate 역할)
    // 의존성 배열이 없으면 (생략하면) 모든 렌더링 후 실행됩니다. (상태 변경, props 변경 등)
    useEffect(() => {
        console.log('[useEffect] 컴포넌트가 렌더링될 때마다 (업데이트 포함) 실행됩니다.');
        // 주의: 무한 루프를 피하려면 의존성 배열을 적절히 사용해야 합니다.
    });


    // 3. 특정 상태(props)가 변경될 때 실행 (componentDidUpdate 역할)
    // 의존성 배열에 `count`를 넣으면 `count`가 변경될 때마다 실행됩니다.
    useEffect(() => {
        console.log(`[useEffect] count가 ${count}로 변경되었습니다.`);
        // `count`를 사용하여 어떤 부수 효과를 발생시킬 때 사용됩니다.
    }, [count]); // `count`가 의존성 배열에 포함

    // 4. 또 다른 특정 상태가 변경될 때 실행
    useEffect(() => {
        if (text) { // 초기 렌더링 시 text는 빈 문자열이므로 실행되지 않도록 조건 추가
            console.log(`[useEffect] text가 '${text}'로 변경되었습니다.`);
        }
    }, [text]);


    return (
        <div style={{ border: '1px solid #ccc', padding: '15px', margin: '15px' }}>
            <h3>컴포넌트 라이프사이클 추적 (useEffect)</h3>
            <p>카운트: {count}</p>
            <button onClick={() => setCount(prev => prev + 1)}>카운트 증가</button>
            <br /><br />
            <input
                type="text"
                value={text}
                onChange={(e) => setText(e.target.value)}
                placeholder="텍스트 입력"
            />
            <p>입력된 텍스트: {text}</p>
            <p>콘솔을 열어 라이프사이클 훅의 실행 순서를 확인하세요.</p>
        </div>
    );
}

function App() {
    const [showTracker, setShowTracker] = useState(true);

    return (
        <div style={{ padding: '20px', border: '1px solid #eee' }}>
            <h1>React 컴포넌트 라이프사이클 학습</h1>
            
            <button onClick={() => setShowTracker(!showTracker)}>
                {showTracker ? 'Lifecycle Tracker 숨기기' : 'Lifecycle Tracker 보이기'}
            </button>
            
            {showTracker && <LifecycleTracker />}
            
            <p>함수형 컴포넌트에서는 `useEffect` 하나로 클래스형 컴포넌트의 `componentDidMount`, `componentDidUpdate`, `componentWillUnmount`의 역할을 모두 수행할 수 있습니다.</p>
            <p>의존성 배열을 사용하여 `useEffect`의 실행 시점을 제어하는 것이 핵심입니다.</p>
        </div>
    );
}

// ReactDOM.render(<App />, document.getElementById('root'));
