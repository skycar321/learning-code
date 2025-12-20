// React 이벤트 핸들링
// React에서 이벤트 처리 방식 및 합성 이벤트 이해

// 나쁜 예시: 일반 JavaScript DOM 이벤트와 React 이벤트를 혼동하거나, 불필요하게 이벤트 리스너를 남용.
// 좋은 예시: React의 합성 이벤트 시스템을 이해하고, 효율적이고 React스러운 방식으로 이벤트를 처리.

import React, { useState } from 'react';

function EventHandlingExamples() {
    const [clickCount, setClickCount] = useState(0);
    const [inputValue, setInputValue] = useState('');
    const [isToggleOn, setIsToggleOn] = useState(true);

    // --- 1. 기본 이벤트 핸들링 ---
    // 이벤트 이름은 camelCase로 작성합니다. (onClick, onChange 등)
    // 이벤트 핸들러는 함수로 전달합니다. (HTML에서 문자열과 다름)
    const handleClick = (event) => {
        // React의 합성 이벤트 (SyntheticEvent) 객체
        // 브라우저의 네이티브 이벤트를 래핑하여 모든 브라우저에서 동일한 인터페이스를 제공합니다.
        console.log('[클릭 이벤트]', event);
        console.log('클릭 이벤트 타입:', event.type); // click
        // event.persist(); // React 17 이전에는 비동기적으로 이벤트 객체에 접근하려면 persist() 필요
        setClickCount(prevCount => prevCount + 1);
    };

    // --- 2. 이벤트 객체 전달 ---
    // React는 자동으로 이벤트 객체를 핸들러의 첫 번째 인자로 전달합니다.

    // --- 3. this 바인딩 (함수형 컴포넌트에서는 필요 없음) ---
    // 클래스형 컴포넌트에서는 `this` 바인딩이 필요했지만, 함수형 컴포넌트와 화살표 함수에서는 자동으로 `this`가 컨텍스트에 바인딩되므로 걱정할 필요가 없습니다.

    // --- 4. 이벤트 핸들러에 인자 전달 ---
    // 콜백 함수를 사용하여 이벤트 핸들러에 추가 인자를 전달할 수 있습니다.
    const handleParameterizedClick = (message, event) => {
        console.log('[파라미터 이벤트]', message, event);
        alert(message);
    };

    // --- 5. 폼 요소 이벤트 (onChange) ---
    // <input>, <textarea>, <select>와 같은 폼 요소는 `onChange` 이벤트를 사용하여 사용자 입력을 감지합니다.
    // `event.target.value`를 통해 현재 입력 값을 얻을 수 있습니다.
    const handleInputChange = (event) => {
        setInputValue(event.target.value);
    };

    const handleFormSubmit = (event) => {
        event.preventDefault(); // 기본 폼 제출 동작 방지
        alert(`제출된 값: ${inputValue}`);
    };

    // --- 6. 토글 버튼 예시 ---
    const handleToggle = () => {
        setIsToggleOn(prevIsToggleOn => !prevIsToggleOn);
    };

    // --- 7. 이벤트 버블링 및 캡처링 (합성 이벤트) ---
    // React의 이벤트 시스템은 브라우저의 네이티브 이벤트와 유사하게 버블링/캡처링 단계를 가집니다.
    // `event.stopPropagation()`을 사용하여 이벤트 전파를 중지할 수 있습니다.
    const handleParentClick = () => {
        console.log("부모 div 클릭!");
    };

    const handleChildClick = (event) => {
        event.stopPropagation(); // 이벤트 버블링 중지
        console.log("자식 버튼 클릭!");
    };


    return (
        <div style={{ padding: '20px', border: '1px solid #eee' }}>
            <h1>React 이벤트 핸들링 학습</h1>

            <div style={{ border: '1px solid lightgray', padding: '10px', margin: '10px' }}>
                <h3>기본 클릭 이벤트</h3>
                <button onClick={handleClick}>클릭하세요 ({clickCount}번)</button>
            </div>

            <div style={{ border: '1px solid lightgray', padding: '10px', margin: '10px' }}>
                <h3>인자 전달 클릭 이벤트</h3>
                {/* 인자를 전달할 때는 익명 함수 또는 화살표 함수를 사용합니다. */}
                <button onClick={(event) => handleParameterizedClick('Hello from React!', event)}>
                    인자 전달 버튼
                </button>
            </div>

            <div style={{ border: '1px solid lightgray', padding: '10px', margin: '10px' }}>
                <h3>폼 입력 이벤트 (onChange)</h3>
                <form onSubmit={handleFormSubmit}>
                    <input type="text" value={inputValue} onChange={handleInputChange} placeholder="텍스트를 입력하세요" />
                    <p>현재 입력 값: {inputValue}</p>
                    <button type="submit">제출</button>
                </form>
            </div>

            <div style={{ border: '1px solid lightgray', padding: '10px', margin: '10px' }}>
                <h3>토글 버튼</h3>
                <button onClick={handleToggle}>
                    {isToggleOn ? '켜짐' : '꺼짐'}
                </button>
            </div>

            <div style={{ border: '1px solid lightgray', padding: '10px', margin: '10px' }} onClick={handleParentClick}>
                <h3>이벤트 버블링 예시 (콘솔 확인)</h3>
                <p>부모 영역을 클릭하거나 아래 버튼을 클릭해보세요.</p>
                <button onClick={handleChildClick}>자식 버튼 (버블링 중지)</button>
            </div>

            <p>React의 이벤트 시스템은 브라우저의 네이티브 이벤트를 래핑하여 크로스 브라우징 호환성을 제공하는 합성 이벤트를 사용합니다.</p>
            <p>함수형 컴포넌트에서는 화살표 함수를 사용하여 이벤트 핸들러를 정의하는 것이 일반적입니다.</p>
        </div>
    );
}

function App() {
    return (
        <div>
            <EventHandlingExamples />
        </div>
    );
}

// ReactDOM.render(<App />, document.getElementById('root'));
