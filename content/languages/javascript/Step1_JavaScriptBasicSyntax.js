// JavaScript 기본 문법
// 변수, 자료형, 연산자, 조건문, 반복문 등 ES6+ 기본 문법 이해

// 나쁜 예시: `var` 키워드를 사용하여 변수를 선언하고, 전역 스코프 오염이나 호이스팅 문제를 야기합니다.
// 좋은 예시: `let`과 `const` 키워드를 사용하여 블록 스코프를 준수하고, 변수의 재할당 여부를 명확히 합니다.

// --- 변수 선언 ---
// var (나쁜 예시) - 재선언, 재할당 가능, 함수 스코프
var oldVar = "옛날 변수";
var oldVar = "재선언도 가능";
oldVar = "재할당도 가능";
console.log("var:", oldVar);

// let (좋은 예시) - 재선언 불가, 재할당 가능, 블록 스코프
let newLet = "새로운 변수";
// let newLet = "재선언 불가"; // SyntaxError: 'newLet' has already been declared
newLet = "재할당 가능";
console.log("let:", newLet);

// const (좋은 예시) - 재선언 불가, 재할당 불가, 블록 스코프 (상수)
const newConst = "상수 변수";
// const newConst = "재선언 불가"; // SyntaxError: 'newConst' has already been declared
// newConst = "재할당 불가"; // TypeError: Assignment to constant variable.
console.log("const:", newConst);

// --- 자료형 ---
// 원시 자료형 (Primitives)
let str = "Hello, JavaScript!"; // 문자열 (String)
let num = 123; // 숫자 (Number) - 정수 및 실수 모두 포함
let floatNum = 123.45;
let bool = true; // 불리언 (Boolean)
let undef = undefined; // Undefined - 값이 할당되지 않은 상태
let nul = null; // Null - 의도적으로 값이 없음을 나타냄
let sym = Symbol('id'); // Symbol - ES6에서 추가된 유일한 값
let bigInt = 1234567890123456789012345678901234567890n; // BigInt - ES2020에서 추가된 임의 정밀도의 정수

console.log("자료형:", typeof str, typeof num, typeof bool, typeof undef, typeof nul, typeof sym, typeof bigInt);

// 객체 자료형 (Object)
let obj = { name: "Alice", age: 30 }; // 객체 (Object)
let arr = [1, 2, 3]; // 배열 (Array) - 객체의 일종
let func = function() {}; // 함수 (Function) - 객체의 일종

console.log("객체 자료형:", typeof obj, typeof arr, typeof func);

// --- 연산자 ---
// 산술 연산자: +, -, *, /, %, **
console.log("산술 연산:", 10 + 3, 10 - 3, 10 * 3, 10 / 3, 10 % 3, 2 ** 3);

// 할당 연산자: =, +=, -=, *=, /=, %=, **=
let x = 10;
x += 5; // x = x + 5;
console.log("할당 연산:", x);

// 비교 연산자: ==, ===, !=, !==, <, >, <=, >=
console.log("비교 연산 (동등):", 10 == '10', 10 === '10'); // == 값만 비교, === 값과 타입 모두 비교
console.log("비교 연산 (부등):", 10 != '10', 10 !== '10');
console.log("비교 연산 (크기):", 10 > 5, 10 <= 10);

// 논리 연산자: && (AND), || (OR), ! (NOT)
console.log("논리 연산:", true && false, true || false, !true);

// --- 조건문 (if, else if, else) ---
let score = 85;
if (score >= 90) {
    console.log("A 학점");
} else if (score >= 80) {
    console.log("B 학점");
} else {
    console.log("C 학점 이하");
}

// switch 문
let day = '월요일';
switch (day) {
    case '월요일':
        console.log("한 주의 시작!");
        break;
    case '금요일':
        console.log("불금!");
        break;
    default:
        console.log("평범한 요일");
}

// --- 반복문 (for, while, do...while, for...of, for...in) ---
// for 루프
for (let i = 0; i < 3; i++) {
    console.log("for 루프:", i);
}

// while 루프
let i = 0;
while (i < 3) {
    console.log("while 루프:", i);
    i++;
}

// do...while 루프 (최소 한 번은 실행)
let j = 0;
do {
    console.log("do...while 루프:", j);
    j++;
} while (j < 3);

// for...of (이터러블 객체 순회: 배열, 문자열 등)
const colors = ['red', 'green', 'blue'];
for (const color of colors) {
    console.log("for...of:", color);
}

// for...in (객체의 속성 이름 순회)
const car = { brand: 'Hyundai', model: 'Sonata' };
for (const key in car) {
    console.log(`for...in: ${key}: ${car[key]}`);
}

// --- 템플릿 리터럴 (Template Literals) ---
// 백틱(``)을 사용하여 문자열 내부에 변수나 표현식을 쉽게 포함할 수 있습니다.
const product = "노트북";
const price = 1200000;
console.log(`제품: ${product}, 가격: ${price}원`);

// --- 화살표 함수 (Arrow Functions) ---
// 함수를 더 간결하게 작성할 수 있는 ES6 문법
const addNumbers = (a, b) => a + b;
console.log("화살표 함수 덧셈:", addNumbers(5, 7));

// --- 스프레드 연산자 (...) ---
// 배열이나 객체를 복사하거나 병합할 때 유용
const arr1 = [1, 2, 3];
const arr2 = [...arr1, 4, 5]; // [1, 2, 3, 4, 5]
console.log("스프레드 연산자 (배열):", arr2);

const obj1 = { a: 1, b: 2 };
const obj2 = { ...obj1, c: 3 }; // { a: 1, b: 2, c: 3 }
console.log("스프레드 연산자 (객체):", obj2);
