// React 성능 최적화 및 테스트
// `React.memo`, `useCallback`, `useMemo` 등 성능 최적화 기법 및 테스트 전략

// 나쁜 예시: 모든 컴포넌트가 불필요하게 리렌더링되어 성능 저하를 초래하거나,
// 테스트 코드를 작성하지 않아 버그 발견이 어렵고 코드 변경에 대한 안정성 부족.
// 좋은 예시: `React.memo`, `useCallback`, `useMemo` 등을 사용하여 불필요한 렌더링을 방지하고,
// 단위, 통합, E2E 테스트를 통해 코드의 품질과 안정성을 확보.

import React, { useState, useCallback, useMemo, memo } from 'react';

// --- 1. 성능 최적화 ---

// 1-1. `React.memo` (고차 컴포넌트)
// Props가 변경되지 않으면 컴포넌트의 리렌더링을 건너뛰도록 합니다.
// 함수형 컴포넌트에만 적용 가능하며, 클래스형 컴포넌트의 `PureComponent`와 유사합니다.

const ExpensiveComponent = memo(({ count, onIncrement }) => {
    console.log('ExpensiveComponent 렌더링');
    // 복잡한 계산이나 DOM 조작이 있다고 가정
    const result = useMemo(() => {
        let sum = 0;
        for (let i = 0; i < 100000000; i++) {
            sum += i;
        }
        return sum;
    }, []); // 이 계산은 컴포넌트가 처음 마운트될 때 한 번만 수행됩니다.

    return (
        <div style={{ border: '1px solid lightgray', padding: '10px', margin: '10px' }}>
            <h4>ExpensiveComponent</h4>
            <p>props.count: {count}</p>
            <p>복잡한 계산 결과: {result}</p>
            <button onClick={onIncrement}>부모 카운트 증가</button>
        </div>
    );
});

// 1-2. `useCallback` (함수 메모이제이션)
// 불필요한 함수 재생성을 방지하여 자식 컴포넌트의 불필요한 리렌더링을 막습니다.
// 특히 `React.memo`로 래핑된 자식 컴포넌트에 함수를 props로 전달할 때 유용합니다.

function ParentWithCallback() {
    const [count, setCount] = useState(0);
    const [toggle, setToggle] = useState(false);

    // count가 변경될 때만 이 함수가 재생성됩니다.
    const handleIncrement = useCallback(() => {
        setCount(prevCount => prevCount + 1);
    }, []); // 의존성 배열이 비어 있으므로 컴포넌트가 처음 마운트될 때 한 번만 생성됩니다.

    return (
        <div style={{ border: '1px solid lightgray', padding: '10px', margin: '10px' }}>
            <h3>useCallback 예시</h3>
            <p>부모 카운트: {count}</p>
            <button onClick={() => setToggle(!toggle)}>토글 (이것만 바꿔도 자식은 리렌더링 안 됨)</button>
            <ExpensiveComponent count={count} onIncrement={handleIncrement} />
        </div>
    );
}

// 1-3. `useMemo` (값 메모이제이션)
// 불필요한 값(객체, 배열, 계산 결과)의 재생성을 방지합니다.
// 의존성 배열에 있는 값이 변경될 때만 해당 값을 다시 계산합니다.

function ParentWithMemo() {
    const [num1, setNum1] = useState(0);
    const [num2, setNum2] = useState(0);
    const [text, setText] = useState('');

    // num1 또는 num2가 변경될 때만 합계가 다시 계산됩니다.
    const sum = useMemo(() => {
        console.log('sum 값 다시 계산!');
        return num1 + num2;
    }, [num1, num2]);

    // text가 변경될 때만 이 객체가 다시 생성됩니다.
    const displayInfo = useMemo(() => ({
        message: `현재 합계: ${sum}`,
        inputText: text
    }), [sum, text]);

    return (
        <div style={{ border: '1px solid lightgray', padding: '10px', margin: '10px' }}>
            <h3>useMemo 예시</h3>
            <p>숫자 1: <input type="number" value={num1} onChange={(e) => setNum1(parseInt(e.target.value))} /></p>
            <p>숫자 2: <input type="number" value={num2} onChange={(e) => setNum2(parseInt(e.target.value))} /></p>
            <p>텍스트: <input type="text" value={text} onChange={(e) => setText(e.target.value)} /></p>
            <p>{displayInfo.message}</p>
            <p>입력된 텍스트: {displayInfo.inputText}</p>
        </div>
    );
}


// --- 2. React 애플리케이션 테스트 전략 ---

console.log("\n--- React 테스트 전략 ---");

console.log("\n1. 단위 테스트 (Unit Tests):");
console.log("   - 개별 컴포넌트, Hook, 유틸리티 함수 등 가장 작은 단위를 격리하여 테스트합니다.");
console.log("   - **도구**: Jest (테스트 러너), React Testing Library (DOM을 사용자 관점에서 테스트)");
console.log("   - **예시**: 특정 props가 전달될 때 컴포넌트가 올바르게 렌더링되는지, 버튼 클릭 시 상태가 올바르게 변경되는지 등.");

// 예시 코드 (실제 파일은 .test.js나 .spec.js)
/*
// MyComponent.test.js
import { render, screen, fireEvent } from '@testing-library/react';
import MyComponent from './MyComponent';

test('renders learn react link', () => {
  render(<MyComponent />);
  const linkElement = screen.getByText(/learn react/i);
  expect(linkElement).toBeInTheDocument();
});

test('button click updates count', () => {
  render(<Counter />);
  const button = screen.getByRole('button', { name: /증가/i });
  fireEvent.click(button);
  expect(screen.getByText(/현재 카운트: 1/i)).toBeInTheDocument();
});
*/

console.log("\n2. 통합 테스트 (Integration Tests):");
console.log("   - 여러 컴포넌트가 함께 작동하는 방식이나, 외부 API와의 상호작용 등을 테스트합니다.");
console.log("   - **도구**: Jest + React Testing Library, Mock Service Worker (MSW)로 API Mocking.");
console.log("   - **예시**: 로그인 플로우 전체, 장바구니에 아이템 추가 및 결제 과정 등.");

console.log("\n3. 종단 간 테스트 (End-to-End Tests - E2E Tests):");
console.log("   - 실제 브라우저 환경에서 사용자의 관점으로 애플리케이션의 전체 흐름을 테스트합니다.");
console.log("   - **도구**: Cypress, Playwright, Selenium.");
console.log("   - **예시**: 실제 사용자처럼 웹사이트를 방문하여 로그인, 제품 검색, 주문 완료까지의 전체 시나리오 테스트.");

console.log("\n테스트는 애플리케이션의 안정성을 높이고, 개발 과정에서 발생할 수 있는 오류를 미리 발견하며, ");
console.log("코드 변경에 대한 자신감을 줍니다. 특히 협업이나 대규모 프로젝트에서 필수적입니다.");


function App() {
    const [parentCount, setParentCount] = useState(0);

    const incrementParentCount = useCallback(() => {
        setParentCount(prev => prev + 1);
    }, []);

    return (
        <div style={{ padding: '20px', border: '1px solid #eee' }}>
            <h1>React 성능 최적화 및 테스트 학습</h1>

            <ParentWithCallback />
            <ParentWithMemo />

            <div style={{ marginTop: '20px', border: '1px solid #ddd', padding: '10px' }}>
                <h3>성능 최적화 요약</h3>
                <ul>
                    <li><code>React.memo</code>: Props 변경이 없을 시 컴포넌트 리렌더링 방지.</li>
                    <li><code>useCallback</code>: 의존성 배열 기반으로 함수를 메모이제이션하여 불필요한 함수 재생성 방지.</li>
                    <li><code>useMemo</code>: 의존성 배열 기반으로 값(계산 결과)을 메모이제이션하여 불필요한 값 재생성 방지.</li>
                    <li>적절한 <code>key</code> prop 사용, 조건부 렌더링 최적화 등.</li>
                </ul>
            </div>

            <div style={{ marginTop: '20px', border: '1px solid #ddd', padding: '10px' }}>
                <h3>테스트 요약</h3>
                <ul>
                    <li>단위 테스트: 개별 기능. (Jest, React Testing Library)</li>
                    <li>통합 테스트: 여러 기능 조합. (Jest, React Testing Library, MSW)</li>
                    <li>E2E 테스트: 사용자 관점 전체 흐름. (Cypress, Playwright)</li>
                </ul>
            </div>
        </div>
    );
}

// ReactDOM.render(<App />, document.getElementById('root'));
