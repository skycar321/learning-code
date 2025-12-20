// JavaScript 모듈 시스템
// CommonJS, ES Modules 등 모듈 시스템 이해 및 활용

// 나쁜 예시: 모든 스크립트를 전역 스코프에 정의하여 변수 충돌을 일으키거나, 스크립트 간의 의존성 관리가 어려움.
// 좋은 예시: 모듈 시스템을 사용하여 코드를 기능별로 분리하고, 명시적인 의존성 관리를 통해 재사용성과 유지보수성을 높임.

// --- 1. CommonJS (주로 Node.js 환경) ---
// `require`로 모듈을 불러오고, `module.exports`로 모듈을 내보냅니다.
// 이 예시는 브라우저 환경에서 직접 실행되지 않고 Node.js 환경을 가정합니다.

/*
// moduleA.js
const add = (a, b) => a + b;
const subtract = (a, b) => a - b;

module.exports = {
    add,
    subtract
};

// main.js
const math = require('./moduleA'); // 모듈 불러오기
console.log("CommonJS - 덧셈:", math.add(10, 5));
console.log("CommonJS - 뺄셈:", math.subtract(10, 5));

// 한 번에 내보내는 대신, 개별적으로 내보낼 수도 있습니다.
// moduleB.js
exports.greet = (name) => `Hello, ${name}!`;

// main.js
const { greet } = require('./moduleB');
console.log("CommonJS - 인사:", greet("Alice"));
*/

// --- 2. ES Modules (ECMAScript Modules, 브라우저 및 Node.js 최신 버전) ---
// `import`와 `export` 키워드를 사용합니다.
// 브라우저에서 사용할 때는 `<script type="module"></script>` 태그를 사용해야 합니다.
// Node.js에서는 .mjs 확장자를 사용하거나 package.json에 "type": "module"을 설정해야 합니다.

// 이 파일은 .js 확장자이므로, 직접 export/import 구문을 사용할 경우
// 브라우저에서는 <script type="module"> 태그 안에서, Node.js에서는 설정 변경 후 가능합니다.

// mathUtils.js 파일 (가정)
/*
export const multiply = (a, b) => a * b;
export const divide = (a, b) => a / b;

export default function power(base, exponent) { // 기본 내보내기
    return base ** exponent;
}
*/

// main.js 또는 다른 모듈 파일 (가정)
/*
// 모든 것을 한 번에 가져오기
import * as math from './mathUtils.js';
console.log("ES Module - 곱셈:", math.multiply(2, 4));

// 특정 이름으로 가져오기
import { divide } from './mathUtils.js';
console.log("ES Module - 나눗셈:", divide(10, 2));

// 기본 내보내기 가져오기 (원하는 이름으로)
import calculatePower from './mathUtils.js';
console.log("ES Module - 거듭제곱:", calculatePower(2, 3));

// 이름 변경하여 가져오기
import { multiply as times } from './mathUtils.js';
console.log("ES Module - 곱셈 (별칭):", times(3, 5));
*/

console.log("이 파일은 JavaScript 모듈 시스템의 개념을 설명합니다.");
console.log("실제 동작을 보려면 별도의 파일로 CommonJS 또는 ES Modules 예제를 작성하고 실행해야 합니다.");
console.log("브라우저에서는 `<script type=\"module\">`을 사용하고, Node.js에서는 `.mjs` 확장자 또는 `\"type\": \"module\"` 설정을 참고하세요.");

// CommonJS와 ES Modules의 주요 차이점:
// - 문법: require/module.exports vs import/export
// - 로딩 방식: CommonJS는 동기적 로딩, ES Modules는 비동기적 로딩 (정적 분석 가능)
// - `this` 값: CommonJS는 모듈 내부에서 `this`가 `module.exports`를 가리키지만, ES Modules는 `undefined`
// - 호환성: CommonJS는 Node.js 표준, ES Modules는 JavaScript 표준 (브라우저 및 Node.js 모두 지원 목표)
