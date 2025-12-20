import React, { useState, useEffect } from 'react';

/**
 * React useEffect 패턴 비교: Good vs Bad
 * 
 * 주제: useEffect의 올바른 사용법과 흔한 실수 (무한 루프, 메모리 누수, 오래된 클로저)
 * 
 * [학습 목표]
 * 1. 의존성 배열(Dependency Array)의 중요성을 이해한다.
 * 2. Cleanup 함수가 왜 필요한지, 언제 실행되는지 배운다.
 * 3. 비동기 작업(API) 취소 패턴(AbortController)을 익힌다.
 */

/* ========================================================================
 * [BAD EXAMPLE 1] 무한 루프 (Infinite Loop)
 * 
 * 문제점:
 * 1. 의존성 배열이 없음: 렌더링마다 Effect가 실행됨.
 * 2. Effect 내부에서 상태 변경: 렌더링 -> Effect -> setState -> 렌더링 -> ... 무한 반복.
 * ======================================================================== */
export function BadInfiniteLoop() {
    const [count, setCount] = useState(0);

    useEffect(() => {
        console.log("Effect ran");
        // [BAD] 의존성 배열 없이 상태를 변경하면 무한 루프 발생
        // setCount(count + 1); 
    }); // 의존성 배열 누락!

    return <div>Count: {count}</div>;
}

/* ========================================================================
 * [BAD EXAMPLE 2] 메모리 누수 (Memory Leak)
 * 
 * 문제점:
 * 1. Cleanup 함수 누락: 컴포넌트가 사라져도 이벤트 리스너나 타이머가 계속 살아있음.
 * 2. 중복 등록: 재렌더링 때마다 리스너가 계속 추가됨 (메모리 폭발).
 * ======================================================================== */
export function BadMemoryLeak() {
    const [size, setSize] = useState(0);

    useEffect(() => {
        const handleResize = () => setSize(window.innerWidth);
        
        // [BAD] 리스너만 등록하고 해제하지 않음
        window.addEventListener('resize', handleResize);
        
        // return () => window.removeEventListener(...); // 이게 빠짐!
    }, []);

    return <div>Window Width: {size}</div>;
}

/* ========================================================================
 * [BAD EXAMPLE 3] 오래된 클로저 (Stale Closure)
 * 
 * 문제점:
 * 1. 의존성 거짓말: Effect 내부에서 `count`를 쓰는데 의존성 배열(`[]`)에 안 넣음.
 * 2. 결과: Effect는 처음 렌더링 시점의 `count` 값(0)만 영원히 기억함.
 * ======================================================================== */
export function BadStaleClosure() {
    const [count, setCount] = useState(0);

    useEffect(() => {
        const timer = setInterval(() => {
            console.log("Current count is:", count); // 항상 0만 출력됨
            // [BAD] 'count'는 항상 초기값(0)이므로, 0 + 1 = 1로만 설정됨
            setCount(count + 1); 
        }, 1000);

        return () => clearInterval(timer);
    }, []); // [BAD] count가 바뀌어도 이 Effect는 재실행되지 않음

    return <div>Count: {count}</div>;
}

/* ========================================================================
 * [GOOD EXAMPLE] 올바른 useEffect 사용법
 * 
 * 해결책:
 * 1. 의존성 배열 준수: Effect에서 쓰는 모든 변수는 deps에 포함.
 * 2. Cleanup 제공: 리스너 해제, 타이머 취소, API 요청 취소.
 * 3. 함수형 업데이트: 이전 상태에 의존할 때는 `setCount(prev => prev + 1)` 사용.
 * ======================================================================== */
export function GoodUseEffect({ userId }) {
    const [user, setUser] = useState(null);
    const [width, setWidth] = useState(0);
    const [seconds, setSeconds] = useState(0);

    // 1. 이벤트 리스너: Cleanup 필수
    useEffect(() => {
        const handleResize = () => setWidth(window.innerWidth);
        window.addEventListener('resize', handleResize);
        
        // [GOOD] 컴포넌트 언마운트 시 또는 재실행 전 청소
        return () => window.removeEventListener('resize', handleResize);
    }, []); // 빈 배열: 마운트/언마운트 시 1회 실행

    // 2. 타이머 & Stale Closure 해결: 함수형 업데이트 사용
    useEffect(() => {
        const timer = setInterval(() => {
            // [GOOD] prevSeconds는 항상 최신값임
            setSeconds(prev => prev + 1);
        }, 1000);

        return () => clearInterval(timer);
    }, []); 

    // 3. API 호출 & Race Condition 방지 (AbortController)
    useEffect(() => {
        if (!userId) return;

        const controller = new AbortController(); // 요청 취소용 컨트롤러

        async function fetchUser() {
            try {
                const res = await fetch(`https://api.example.com/users/${userId}`, {
                    signal: controller.signal
                });
                const data = await res.json();
                setUser(data);
            } catch (err) {
                if (err.name === 'AbortError') {
                    console.log('Fetch aborted'); // 언마운트 등으로 인한 취소는 에러 아님
                } else {
                    console.error('Fetch error:', err);
                }
            }
        }

        fetchUser();

        // [GOOD] userId가 바뀌거나 컴포넌트가 사라지면 이전 요청 취소
        return () => controller.abort();
    }, [userId]); // [GOOD] userId가 바뀔 때마다 재실행

    return (
        <div>
            <h2>Good useEffect Examples</h2>
            <p>Window Width: {width}</p>
            <p>Seconds: {seconds}</p>
            <p>User: {user ? user.name : 'Loading...'}</p>
        </div>
    );
}
