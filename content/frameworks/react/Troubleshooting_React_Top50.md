# React Top 50 Troubleshooting Guide

React 개발 중 자주 마주치는 50가지 오류와 해결 방법을 정리한 가이드입니다.
JSX, Hooks, Props, Rendering 등 카테고리별로 구성되어 있습니다.

---

## 1. DOM & JSX Rendering Issues

### 1. `Objects are not valid as a React child`
- **증상**: 화면이 하얗게 변하고 콘솔에 에러 표시.
- **원인**: 객체(`{}`)나 배열을 JSX 내에서 직접 렌더링하려고 함. 예: `<div>{user}</div>`.
- **해결**: 문자열로 변환(`JSON.stringify(user)`)하거나 특정 속성(`user.name`)을 렌더링.

### 2. `Expected a string (for built-in components) but got: object`
- **증상**: 컴포넌트 임포트 실수.
- **원인**: `export default`가 아닌데 `import User from './User'`로 가져오거나, 그 반대인 경우.
- **해결**: `import { User }` (Named) vs `import User` (Default) 확인.

### 3. `Adjacent JSX elements must be wrapped in an enclosing tag`
- **증상**: JSX 문법 에러.
- **원인**: 두 개 이상의 태그를 최상위 레벨에서 반환하려고 함.
- **해결**: `<Fragment>` (`<>...</>`) 또는 `<div>`로 감싸기.

### 4. `Can't perform a React state update on an unmounted component`
- **증상**: 메모리 누수 경고.
- **원인**: 컴포넌트가 언마운트된 후 비동기(API) 완료 콜백에서 `setState` 호출.
- **해결**: `useEffect` cleanup 함수에서 플래그 설정 또는 요청 취소(AbortController).

### 5. `Invalid DOM property class. Did you mean className?`
- **증상**: 콘솔 경고.
- **원인**: HTML 속성인 `class`를 사용.
- **해결**: JSX에서는 `className` 사용. (`for` -> `htmlFor`).

### 6. `Element type is invalid: expected a string... but got: undefined`
- **증상**: 렌더링 실패.
- **원인**: 컴포넌트 export/import 이름 불일치, 또는 순환 참조 문제.
- **해결**: import 경로와 이름 확인.

### 7. `Keys should be unique`
- **증상**: 리스트 렌더링 시 콘솔 경고.
- **원인**: `map()` 사용 시 `key` prop이 없거나 중복됨.
- **해결**: 고유한 ID 사용 (`key={item.id}`). 인덱스(`index`)는 최후의 수단으로만 사용.

---

## 2. Hooks Issues

### 8. `Rendered more hooks than during the previous render`
- **증상**: 치명적 에러, 앱 중단.
- **원인**: 조건문(`if`), 반복문(`for`) 안에서 Hook(`useState`, `useEffect`) 호출.
- **해결**: Hook은 항상 컴포넌트 최상위 레벨에서 호출.

### 9. `useEffect` Infinite Loop
- **증상**: 브라우저 멈춤, API 무한 호출.
- **원인**: `useEffect` 내에서 업데이트하는 상태를 의존성 배열(`deps`)에 포함.
- **해결**: 의존성 배열 확인, 함수형 업데이트 사용 (`setCount(c => c + 1)`).

### 10. `Invalid hook call`
- **증상**: Hooks can only be called inside of the body of a function component.
- **원인**: 클래스 컴포넌트나 일반 JS 함수에서 Hook 호출.
- **해결**: 함수형 컴포넌트 내부로 이동.

### 11. Stale Closure (오래된 상태 값)
- **증상**: `useEffect`나 이벤트 핸들러에서 상태 값이 갱신되지 않음.
- **원인**: 의존성 배열에 상태가 누락되어, 처음 렌더링 당시의 값을 계속 참조.
- **해결**: 의존성 배열에 변수 추가 또는 `useRef` 사용.

### 12. `useLayoutEffect` vs `useEffect`
- **증상**: 화면 깜빡임 (Flicker).
- **원인**: `useEffect`는 화면 렌더링 후 실행되므로, DOM 조작 시 깜빡임 발생.
- **해결**: 동기적 DOM 조작이 필요하면 `useLayoutEffect` 사용.

---

## 3. State & Props Issues

### 13. State Updates Not Immediate
- **증상**: `setState` 호출 직후 `console.log(state)`가 이전 값을 출력.
- **원인**: `setState`는 비동기로 동작.
- **해결**: `useEffect`에서 변경 감지 또는 `setState` 콜백(클래스형) 사용.

### 14. Props Drilling
- **증상**: 중간 컴포넌트들이 불필요한 props를 계속 전달.
- **해결**: Context API, Redux, Zustand 도입.

### 15. Cannot read property 'map' of undefined
- **증상**: 렌더링 중 에러.
- **원인**: API 로딩 전 배열 상태가 `undefined` 또는 `null`.
- **해결**: 초기값 설정 (`useState([])`) 또는 옵셔널 체이닝 (`data?.map()`).

### 16. Too many re-renders
- **증상**: 무한 루프 에러.
- **원인**: 렌더링 중 `setState` 직접 호출 (이벤트 핸들러 없이). 예: `<button onClick={handleClick()}>`.
- **해결**: 콜백으로 전달 (`onClick={() => handleClick()}`).

---

## 4. Performance & Optimization

### 17. Unnecessary Re-renders
- **증상**: 앱이 느려짐.
- **원인**: 부모 컴포넌트 렌더링 시 자식도 무조건 렌더링.
- **해결**: `React.memo` 사용, 객체/함수 props는 `useMemo`, `useCallback`으로 감싸기.

### 18. Large Bundle Size
- **증상**: 초기 로딩 속도 저하.
- **해결**: `React.lazy`와 `Suspense`로 코드 스플리팅 적용.

### 19. Context Value Re-renders
- **증상**: Context 사용 시 모든 구독 컴포넌트가 리렌더링.
- **해결**: Context Value를 `useMemo`로 메모이제이션.

---

## 5. Next.js Specific

### 20. `Hydration failed`
- **증상**: 서버 렌더링 결과와 클라이언트 렌더링 결과 불일치.
- **원인**: `window` 객체 사용, 날짜(`Date.now()`), 랜덤값 사용.
- **해결**: `useEffect`에서 `window` 접근, 날짜 포맷 고정.

### 21. `window is not defined`
- **증상**: 빌드 타임 에러.
- **원인**: SSR 중 브라우저 전용 API 접근.
- **해결**: `typeof window !== 'undefined'` 체크.

### 22. API Route Timeout
- **증상**: Vercel 배포 후 API 504 에러.
- **원인**: Serverless Function 실행 시간 초과 (10초/60초).
- **해결**: 백그라운드 작업으로 분리하거나 Edge Function 고려.

---

## 6. Miscellaneous

### 23. Module Not Found
- **증상**: Webpack 에러.
- **원인**: 대소문자 불일치 (Windows/Mac은 허용하지만 리눅스는 구분).
- **해결**: 파일명 대소문자 확인.

### 24. CORS Error (Client Side)
- **증상**: API 호출 실패.
- **해결**: 백엔드 CORS 설정 또는 프록시 설정 (`setupProxy.js`, `next.config.js`).

### 25. Environment Variables Undefined
- **증상**: `process.env.API_KEY`가 `undefined`.
- **원인**: React(`REACT_APP_`), Next.js(`NEXT_PUBLIC_`) 접두사 누락.
- **해결**: 프레임워크 규칙에 맞는 접두사 사용.

### 26. `npm install` Dependency Conflict
- **증상**: `ERESOLVE unable to resolve dependency tree`.
- **해결**: `npm install --legacy-peer-deps` 또는 의존성 버전 조정.

### 27. Styles not applying
- **증상**: CSS 클래스 적용 안 됨.
- **원인**: CSS Module 사용 시 `.box` -> `styles.box`로 접근해야 함.
- **해결**: import 방식 및 사용법 확인.

### 28. Input Losing Focus
- **증상**: 타이핑할 때마다 인풋 포커스 잃음.
- **원인**: 컴포넌트 내부에서 다른 컴포넌트를 정의하고 렌더링.
- **해결**: 컴포넌트 정의를 외부로 이동.

### 29. `ReferenceError: document is not defined`
- **증상**: SSR 환경에서 `document` 접근.
- **해결**: `useEffect` 내부로 이동.

### 30. `TypeError: destroy is not a function`
- **증상**: `useEffect` 에러.
- **원인**: `useEffect`가 함수가 아닌 것을 반환 (예: `async` 함수는 Promise 반환).
- **해결**: `useEffect` 내부에서 `async` 함수를 정의하고 호출.

---

## Tip: 디버깅 도구 활용
1. **React Developer Tools**: 컴포넌트 계층, Props, State 확인.
2. **Profiler**: 렌더링 성능 분석 (`Why did this render?`).
3. **Redux DevTools**: 전역 상태 변경 추적.
