// nodejs/Step1_NodeJSBasics/myModule.js
// Node.js 학습 계획 - 1단계: Node.js 기본 개념 및 시작
// 이 파일은 Node.js의 CommonJS 모듈 시스템에서 모듈을 내보내는(`module.exports`) 방법을 보여주는 `myModule.js`입니다.
//
// 모듈을 사용하면 코드를 여러 파일로 분리하여 관리하고 재사용할 수 있습니다.

// -----------------------------------------------------------------------------
// 학습 포인트 1: `module.exports`를 이용한 모듈 내보내기
// - `module.exports` 객체에 함수, 객체, 변수 등을 할당하여 외부로 내보낼 수 있습니다.
// - 내보낸 요소들은 `require()` 함수를 통해 다른 파일에서 임포트하여 사용할 수 있습니다.
// -----------------------------------------------------------------------------

/**
 * 주어진 이름으로 환영 메시지를 반환합니다.
 * @param {string} name - 환영할 사람의 이름.
 * @returns {string} 환영 메시지.
 */
function greet(name) {
    return `Hello, ${name} from myModule!`;
}

/**
 * 두 숫자의 합을 반환합니다.
 * @param {number} a - 첫 번째 숫자.
 * @param {number} b - 두 번째 숫자.
 * @returns {number} 두 숫자의 합.
 */
function add(a, b) {
    return a + b;
}

// 나쁜 예시: `module.exports`에 직접 함수를 할당하여 여러 함수를 내보내지 못하는 것.
// - `module.exports = greet;`와 같이 할당하면 `index.js`에서 `myModule.add()`를 호출할 수 없습니다.
// - 여러 요소를 내보내려면 객체 형태로 묶어서 내보내야 합니다.

// 여러 함수를 객체 형태로 내보냅니다.
module.exports = {
    greet, // `greet: greet`와 동일
    add,   // `add: add`와 동일
};

/*
이 코드를 실행하려면:

1. `index.js` 파일과 함께 `nodejs/Step1_NodeJSBasics` 디렉토리에 이 파일을 `myModule.js`로 저장.
2. `index.js`에서 이 모듈을 `require('./myModule')`로 임포트하여 사용합니다.
*/
