// React 폼 다루기
// 제어 컴포넌트와 비제어 컴포넌트를 이용한 폼 데이터 처리

// 나쁜 예시: 폼 데이터를 수동으로 DOM에서 가져오거나, React의 상태 관리와 동기화하지 않아 일관성 없는 동작 유발.
// 좋은 예시: 제어 컴포넌트(Controlled Components)를 사용하여 폼 입력 값을 React 상태로 관리하고,
// 필요에 따라 비제어 컴포넌트(Uncontrolled Components)와 `useRef`를 활용.

import React, { useState, useRef } from 'react';

// --- 1. 제어 컴포넌트 (Controlled Components) ---
// 폼 요소의 입력 값이 React의 상태(state)에 의해 제어됩니다.
// 입력 값의 모든 변화를 상태로 관리하고, 상태가 업데이트되면 폼 요소도 다시 렌더링됩니다.
// 대부분의 폼 입력에서 권장되는 방식입니다.

function ControlledForm() {
    const [name, setName] = useState('');
    const [essay, setEssay] = useState('당신의 경험을 작성해주세요.');
    const [flavor, setFlavor] = useState('coconut');

    const handleNameChange = (event) => {
        setName(event.target.value);
    };

    const handleEssayChange = (event) => {
        setEssay(event.target.value);
    };

    const handleFlavorChange = (event) => {
        setFlavor(event.target.value);
    };

    const handleSubmit = (event) => {
        event.preventDefault(); // 폼의 기본 제출 동작 방지 (페이지 리로드 방지)
        alert(`제출된 값:\n이름: ${name}\n에세이: ${essay}\n선택한 맛: ${flavor}`);
    };

    return (
        <div style={{ border: '1px solid lightgray', padding: '10px', margin: '10px' }}>
            <h3>제어 컴포넌트 (Controlled Form)</h3>
            <form onSubmit={handleSubmit}>
                <label>
                    이름:
                    <input type="text" value={name} onChange={handleNameChange} />
                </label>
                <p>입력된 이름: {name}</p>
                <br />
                <label>
                    에세이:
                    <textarea value={essay} onChange={handleEssayChange} />
                </label>
                <p>입력된 에세이: {essay.substring(0, 20)}...</p>
                <br />
                <label>
                    선호하는 맛:
                    <select value={flavor} onChange={handleFlavorChange}>
                        <option value="grapefruit">자몽</option>
                        <option value="lime">라임</option>
                        <option value="coconut">코코넛</option>
                        <option value="mango">망고</option>
                    </select>
                </label>
                <p>선택한 맛: {flavor}</p>
                <br />
                <button type="submit">제출</button>
            </form>
        </div>
    );
}


// --- 2. 비제어 컴포넌트 (Uncontrolled Components) ---
// 폼 요소의 입력 값이 DOM 자체에 의해 관리됩니다.
// React 상태를 사용하지 않고, `ref`를 사용하여 DOM 요소에 직접 접근하여 값을 가져옵니다.
// 간단한 폼이나, 기존 라이브러리와 통합할 때 유용할 수 있지만, 일반적으로 제어 컴포넌트가 더 유연합니다.

function UncontrolledForm() {
    const fileInputRef = useRef(null); // 파일 입력 요소에 대한 ref
    const nameInputRef = useRef(null); // 일반 입력 요소에 대한 ref

    const handleSubmit = (event) => {
        event.preventDefault();
        alert (`
            제출된 파일: ${fileInputRef.current ? fileInputRef.current.files[0].name : '없음'}
            제출된 이름: ${nameInputRef.current ? nameInputRef.current.value : '없음'}
        `);
    };

    return (
        <div style={{ border: '1px solid lightgray', padding: '10px', margin: '10px' }}>
            <h3>비제어 컴포넌트 (Uncontrolled Form) - useRef 사용</h3>
            <form onSubmit={handleSubmit}>
                <label>
                    이름:
                    <input type="text" ref={nameInputRef} defaultValue="기본 이름" />
                </label>
                <br />
                <label>
                    파일 업로드:
                    <input type="file" ref={fileInputRef} />
                </label>
                <br />
                <button type="submit">제출</button>
            </form>
        </div>
    );
}

// --- 3. 여러 개의 입력 요소 다루기 ---
// `name` 속성을 사용하여 여러 입력 요소를 하나의 핸들러 함수로 처리할 수 있습니다.

function MultipleInputsForm() {
    const [inputs, setInputs] = useState({
        username: '',
        email: '',
        password: ''
    });

    const handleChange = (event) => {
        const { name, value } = event.target; // event.target.name과 event.target.value
        setInputs(prevInputs => ({
            ...prevInputs, // 기존 입력 값들을 복사
            [name]: value // 변경된 입력 요소의 name에 해당하는 값만 업데이트
        }));
    };

    const handleSubmit = (event) => {
        event.preventDefault();
        alert (`
            사용자명: ${inputs.username}
            이메일: ${inputs.email}
            비밀번호: ${inputs.password}
        `);
    };

    return (
        <div style={{ border: '1px solid lightgray', padding: '10px', margin: '10px' }}>
            <h3>여러 개의 입력 요소 다루기</h3>
            <form onSubmit={handleSubmit}>
                <label>
                    사용자명:
                    <input type="text" name="username" value={inputs.username} onChange={handleChange} />
                </label>
                <br />
                <label>
                    이메일:
                    <input type="email" name="email" value={inputs.email} onChange={handleChange} />
                </label>
                <br />
                <label>
                    비밀번호:
                    <input type="password" name="password" value={inputs.password} onChange={handleChange} />
                </label>
                <br />
                <button type="submit">회원가입</button>
            </form>
            <p>현재 입력 상태: {JSON.stringify(inputs)}</p>
        </div>
    );
}

function App() {
    return (
        <div style={{ padding: '20px', border: '1px solid #eee' }}>
            <h1>React 폼 다루기 학습</h1>

            <ControlledForm />
            <UncontrolledForm />
            <MultipleInputsForm />

            <p>대부분의 경우 제어 컴포넌트를 사용하여 React의 상태 관리 이점을 최대한 활용하는 것이 좋습니다.</p>
        </div>
    );
}

// ReactDOM.render(<App />, document.getElementById('root'));
