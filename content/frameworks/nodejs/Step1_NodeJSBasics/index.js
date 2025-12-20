// nodejs/Step1_NodeJSBasics/index.js
// Node.js 학습 계획 - 1단계: Node.js 기본 개념 및 시작
// 이 파일은 Node.js 애플리케이션의 메인 엔트리 포인트인 `index.js` 파일입니다.
// CommonJS 모듈 시스템과 간단한 콘솔 출력을 통해 Node.js의 기본 동작을 보여줍니다.

// -----------------------------------------------------------------------------
// 학습 포인트 1: CommonJS 모듈 시스템
// - Node.js의 기본 모듈 시스템으로, `require()` 함수를 사용하여 모듈을 임포트하고,
// - `module.exports`를 사용하여 모듈을 내보냅니다.
// - `ES Modules` (ESM)는 `import/export` 구문을 사용하며, `.mjs` 확장자를 사용하거나
//   `package.json`에 `"type": "module"`을 설정하여 사용할 수 있습니다.
// -----------------------------------------------------------------------------
const myModule = require('./myModule'); // `myModule.js` 파일 임포트 (아직 생성되지 않음)

console.log("--- 1단계: Node.js 기본 개념 및 시작 ---");

console.log("Hello from Node.js!");

// -----------------------------------------------------------------------------
// 학습 포인트 2: 메인 엔트리 포인트
// - `package.json`의 `"main": "index.js"` 설정에 따라 이 파일이 애플리케이션의 시작점이 됩니다.
// - `npm start` 명령 실행 시 `node index.js`가 호출됩니다.
// -----------------------------------------------------------------------------

// 임포트한 모듈의 함수 호출
console.log(myModule.greet('Alice'));
console.log(myModule.add(5, 3));

// -----------------------------------------------------------------------------
// 학습 포인트 3: `process` 객체
// - 현재 Node.js 프로세스에 대한 정보를 제공하고 제어할 수 있는 전역 객체입니다.
// - `process.argv`: 명령줄 인자 배열.
// - `process.env`: 환경 변수 객체.
// - `process.exit()`: 프로세스 종료.
// -----------------------------------------------------------------------------
console.log(`Node.js 버전: ${process.version}`);
console.log(`현재 플랫폼: ${process.platform}`);
console.log(`스크립트 실행 경로: ${process.argv[1]}`);

// 명령줄 인자 사용 예시
if (process.argv.length > 2) {
    console.log(`첫 번째 명령줄 인자: ${process.argv[2]}`);
} else {
    console.log("명령줄 인자가 제공되지 않았습니다.");
}

// 환경 변수 사용 예시
console.log(`NODE_ENV 환경 변수: ${process.env.NODE_ENV || 'development'}`);

// 나쁜 예시: `process.exit()`를 사용하여 비동기 작업이 완료되기 전에 프로세스를 종료하는 것.
// - 파일 쓰기, 네트워크 요청 등 비동기 작업이 정상적으로 마무리되지 않을 수 있습니다.
// - 비동기 작업 완료를 기다린 후 종료해야 합니다. (예: `process.exit(0)`는 성공, `process.exit(1)`는 실패)

console.log("--- 1단계 학습 완료 ---");

/*
이 코드를 실행하려면:

1. `package.json` 파일과 함께 `nodejs/Step1_NodeJSBasics` 디렉토리에 이 파일을 `index.js`로 저장.
2. `nodejs/Step1_NodeJSBasics` 디렉토리에 `myModule.js` 파일을 생성.
3. 터미널에서 `nodejs/Step1_NodeJSBasics` 디렉토리로 이동.
4. `npm start` 명령으로 애플리케이션 실행.
5. `npm run dev` 명령으로 개발 모드 실행 (파일 변경 시 자동 재시작).
6. 명령줄 인자를 포함하여 실행: `node index.js "my_argument"`
*/
