# 실무 JavaScript 코드 학습 계획

순수 JS로 기초를 다지고 브라우저/Node 환경 모두에서 안전하게 사용할 수 있는 패턴을 익히는 로드맵입니다. 각 단계는 간단한 bad/good 대비와 실행 방법을 제공합니다.

---

### 학습 로드맵

| 단계 | 주제 | 학습 목표 | 상태 |
| :-- | :--- | :--- | :--- |
| **Step 1** | **기본 문법** | 변수 선언(`let/const`), 스코프, 기본 연산 이해 | 완료 |
| **Step 2** | **함수와 스코프** | 함수 선언/표현식, 클로저, this 바인딩 | 완료 |
| **Step 3** | **비동기 처리** | 콜백, Promise, async/await 흐름 이해 | 완료 |
| **Step 4** | **객체·프로토타입** | 프로토타입 체인, 객체 생성 패턴 | 완료 |
| **Step 5** | **배열·고차함수** | `map/filter/reduce` 활용 | 완료 |
| **Step 6** | **DOM & 이벤트** | DOM 선택/조작, 이벤트 버블링 | 완료 |
| **Step 7** | **모듈 시스템** | ES Modules vs CommonJS | 완료 |
| **Step 8** | **에러 처리/디버깅** | `try/catch`, 콘솔·브레이크포인트 활용 | 완료 |
| **Step 9** | **Fetch/API 통신** | fetch, AJAX, CORS 기본 | 완료 |
| **Step 10** | **성능 & 번들링 개념** | 이벤트 루프, Webpack/Vite 개요 | 완료 |

---

### 빠른 실행 안내 (Step 1~3)
```bash
node Step1_JavaScriptBasicSyntax.js
node Step2_FunctionsAndScope.js
node Step3_AsynchronousProcessing.js
```
> Node 18+ 권장. bad 예시는 주석으로 남겨두었으니 풀어 보며 차이를 확인하세요.

---

### 각 단계별 간단 노트
- **Step1 기본 문법**: `var` 대신 `let/const`, 템플릿 리터럴 사용.  
- **Step2 함수/스코프**: 화살표 함수의 `this`는 상위 스코프를 캡처한다는 점 주의.  
- **Step3 비동기**: 콜백 중첩(bad) ↔ `async/await`와 `Promise.all`(good).
- **Step4~6 최신 문법**: 옵셔널 체이닝 `obj?.a?.b`, Null 병합 `value ?? default`로 안전한 접근.  
- **Step7 모듈**: ES Modules를 기본으로 사용, CJS와 혼용 시 확장자/`type: module` 설정 주의.

### 추가 심화
- ES202x 최신 문법(Optional Chaining, Nullish Coalescing)
- 브라우저/Node 공통 모듈 작성 패턴 (ESM 기본, CJS 래퍼)
- 테스트 입문: `vitest` 또는 `jest`로 단위 테스트 추가

### 파일 위치
`content/languages/javascript/Step1_JavaScriptBasicSyntax.js` 등 각 Step 파일에 예제와 주석이 있습니다.
