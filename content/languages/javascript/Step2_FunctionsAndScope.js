// JavaScript 함수와 스코프
// 함수 선언/표현식, 화살표 함수, 클로저, 스코프 체인 학습

// 나쁜 예시: 전역 변수를 과도하게 사용하거나, 스코프를 고려하지 않아 변수 충돌 및 유지보수 어려움.
// 좋은 예시: 각 스코프의 규칙을 이해하고, 클로저 등을 활용하여 데이터를 안전하게 캡슐화.

// --- 함수 선언식 (Function Declaration) ---
// 호이스팅(Hoisting) 발생: 함수가 선언되기 전에 호출 가능
console.log(declareFunction()); // "함수 선언식 호출"
function declareFunction() {
    return "함수 선언식 호출";
}

// --- 함수 표현식 (Function Expression) ---
// 호이스팅 발생 안 함: 함수가 정의된 후에만 호출 가능
// console.log(expressFunction()); // TypeError: expressFunction is not a function
const expressFunction = function() {
    return "함수 표현식 호출";
};
console.log(expressFunction());

// --- 화살표 함수 (Arrow Function) ---
// 간결한 문법, 항상 익명 함수, 자신만의 this, arguments, super, new.target 없음
const arrowFunction = () => "화살표 함수 호출";
console.log(arrowFunction());

const multiply = (a, b) => a * b;
console.log("곱셈 (화살표 함수):", multiply(5, 3));

// --- 스코프 (Scope) ---
// 1. 전역 스코프 (Global Scope)
let globalVar = "전역 변수";

function outerFunction() {
    // 2. 함수 스코프 (Function Scope) - var 키워드
    var functionScopedVar = "함수 스코프 변수";
    console.log("outerFunction 내부 - 전역 변수:", globalVar);
    console.log("outerFunction 내부 - 함수 스코프 변수:", functionScopedVar);

    if (true) {
        // 3. 블록 스코프 (Block Scope) - let, const 키워드
        let blockScopedVar = "블록 스코프 변수";
        console.log("if 블록 내부 - 전역 변수:", globalVar);
        console.log("if 블록 내부 - 함수 스코프 변수:", functionScopedVar);
        console.log("if 블록 내부 - 블록 스코프 변수:", blockScopedVar);
    }
    // console.log("outerFunction 내부 - 블록 스코프 변수:", blockScopedVar); // ReferenceError: blockScopedVar is not defined
}

outerFunction();
console.log("전역 - 전역 변수:", globalVar);
// console.log("전역 - 함수 스코프 변수:", functionScopedVar); // ReferenceError: functionScopedVar is not defined

// --- 스코프 체인 (Scope Chain) ---
// 함수는 자신이 정의된 스코프(렉시컬 스코프)를 기억하고, 해당 스코프의 상위 스코프에 접근할 수 있습니다.
let x = 10; // 전역 스코프

function foo() {
    let y = 20; // foo 스코프
    function bar() {
        let z = 30; // bar 스코프
        console.log("bar 내부:", x + y + z); // 10 + 20 + 30 = 60
    }
    bar();
}
foo();

// --- 클로저 (Closure) ---
// 함수와 함수가 선언된 렉시컬 환경의 조합.
// 외부 함수의 실행이 끝나더라도 외부 함수의 변수에 접근할 수 있는 내부 함수.
function makeCounter() {
    let count = 0; // makeCounter의 렉시컬 환경에 속한 변수
    return function() { // 클로저 함수
        count++;
        return count;
    };
}

const counter1 = makeCounter();
console.log("Counter1:", counter1()); // 1
console.log("Counter1:", counter1()); // 2

const counter2 = makeCounter(); // 새로운 렉시컬 환경 생성
console.log("Counter2:", counter2()); // 1
console.log("Counter1:", counter1()); // 3 (counter1은 자신만의 count를 유지)

// 클로저를 이용한 정보 은닉
function createPerson(name) {
    let _name = name; // private 변수처럼 사용

    return {
        getName: function() {
            return _name;
        },
        setName: function(newName) {
            _name = newName;
        }
    };
}

const person = createPerson("김철수");
console.log("Person 이름:", person.getName()); // 김철수
person.setName("이영희");
console.log("Person 변경된 이름:", person.getName()); // 이영희
// console.log(person._name); // Undefined, 외부에서 직접 접근 불가
