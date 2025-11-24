// JavaScript 에러 핸들링과 디버깅
// `try-catch`, `throw`를 이용한 에러 처리 및 개발자 도구 활용

// 나쁜 예시: 에러가 발생해도 처리하지 않고 프로그램이 강제 종료되거나, 광범위하게 `try-catch`를 사용하여 실제 에러 원인을 파악하기 어렵게 만듭니다.
// 좋은 예시: 특정 에러 상황을 예측하여 적절하게 `try-catch`로 처리하고, `throw`로 사용자 정의 에러를 발생시켜 디버깅을 용이하게 합니다.

console.log("--- 에러 핸들링 (try-catch, throw) ---");

function divide(a, b) {
    if (b === 0) {
        // 특정 조건에서 에러 객체를 생성하여 던집니다.
        throw new Error("0으로 나눌 수 없습니다."); // Error 객체 사용
    }
    return a / b;
}

try {
    let result = divide(10, 2);
    console.log("나눗셈 결과:", result);

    result = divide(10, 0); // 여기서 에러가 발생하여 catch 블록으로 이동
    console.log("이 줄은 실행되지 않습니다."); // 이 줄은 실행되지 않음

} catch (error) { // 발생한 에러 객체를 받습니다.
    console.error("에러 발생:", error.message); // error.message로 에러 메시지 접근
    console.error("스택 트레이스:", error.stack); // 에러가 발생한 위치를 추적
} finally {
    console.log("try-catch-finally 블록이 종료되었습니다. (에러 발생 여부와 상관없이 항상 실행)");
}

console.log("\n--- 사용자 정의 에러 ---");

// 사용자 정의 에러 클래스 (Error 클래스 상속)
class CustomError extends Error {
    constructor(message) {
        super(message); // 부모 클래스(Error)의 생성자 호출
        this.name = "CustomError"; // 에러 이름 설정
    }
}

function processData(data) {
    if (data === null || data === undefined) {
        throw new CustomError("처리할 데이터가 유효하지 않습니다.");
    }
    if (typeof data !== 'string') {
        throw new TypeError("데이터는 문자열이어야 합니다.");
    }
    return data.toUpperCase();
}

try {
    console.log(processData("hello world"));
    console.log(processData(null)); // CustomError 발생
    console.log(processData(123)); // TypeError 발생 (이 줄은 실행되지 않음)
} catch (error) {
    if (error instanceof CustomError) {
        console.error("사용자 정의 에러:", error.name, error.message);
    } else if (error instanceof TypeError) {
        console.error("타입 에러:", error.name, error.message);
    } else {
        console.error("알 수 없는 에러:", error.name, error.message);
    }
}

console.log("\n--- 디버깅 (브라우저 개발자 도구) ---");
console.log("1. **콘솔(Console)**: `console.log`, `console.error`, `console.warn` 등을 사용하여 변수 값, 메시지 출력.");
console.log("2. **소스(Sources)**: 자바스크립트 코드에 중단점(breakpoint)을 설정하여 코드 실행을 일시 중지하고, 변수 값 변화를 추적.");
console.log("3. **네트워크(Network)**: 네트워크 요청 및 응답을 확인하여 API 통신 문제 파악.");
console.log("4. **엘리먼트(Elements)**: DOM 구조 및 스타일 변경 사항을 실시간으로 확인.");
console.log("5. **성능(Performance)**: 애플리케이션의 성능 병목 현상 분석.");

// 디버거 사용 예시 (브라우저 콘솔에서 `debugger;` 키워드를 사용하거나 개발자 도구에서 직접 중단점 설정)
function debugExample() {
    let a = 10;
    let b = 20;
    // debugger; // 이 지점에서 코드 실행이 일시 중지됩니다.
    let sum = a + b;
    console.log("디버그 예시 합계:", sum);
}
debugExample();

console.log("\n개발자 도구를 적극적으로 활용하여 에러를 찾고 수정하는 연습을 해야 합니다.");
