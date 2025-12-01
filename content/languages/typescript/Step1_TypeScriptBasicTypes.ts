// TypeScript 기본 타입
// `string`, `number`, `boolean`, `any`, `void`, `null`, `undefined` 등 기본 타입 이해

// 나쁜 예시: 모든 변수를 `any` 타입으로 선언하여 TypeScript의 타입 검사 이점을 포기합니다.
// 좋은 예시: 각 변수에 적절한 기본 타입을 명시적으로 지정하거나, 타입 추론을 활용하여 코드의 안정성을 높입니다.

// 1. Boolean
let isDone: boolean = false;
isDone = true;
// isDone = 1; // Type 'number' is not assignable to type 'boolean'.

// 2. Number
let decimal: number = 6;
let hex: number = 0xf00d;
let binary: number = 0b1010;
let octal: number = 0o744;
// decimal = "hello"; // Type 'string' is not assignable to type 'number'.

// 3. String
let fullName: string = "Bob Smith";
let age: number = 30;
let sentence: string = `Hello, my name is ${fullName}. I'll be ${age + 1} years old next month.`;
console.log(sentence);

// 4. Array
let list1: number[] = [1, 2, 3];
let list2: Array<number> = [1, 2, 3]; // 제네릭 배열 타입
// list1.push("4"); // Argument of type 'string' is not assignable to parameter of type 'number'.

// 5. Tuple (튜플)
// 요소의 타입과 개수가 고정된 배열을 표현
let x: [string, number];
x = ["hello", 10]; // 순서와 타입이 일치해야 합니다.
// x = [10, "hello"]; // Type 'number' is not assignable to type 'string'.
// x[2] = "world"; // Tuple type '[string, number]' of length '2' has no element at index '2'.

// 6. Enum (열거형)
// 숫자 집합에 이름을 부여
enum Color { Red, Green, Blue }
let c: Color = Color.Green;
console.log(c); // 1 (기본적으로 0부터 시작)

enum Color2 { Red = 1, Green = 2, Blue = 4 }
let c2: Color2 = Color2.Green;
console.log(c2); // 2

// 7. Any (어떤 타입이든 허용)
// TypeScript의 타입 검사를 일시적으로 우회할 때 사용. 최대한 사용을 자제하는 것이 좋습니다.
let notSure: any = 4;
notSure = "maybe a string instead";
notSure = false;
notSure.ifItExists(); // 타입 검사를 하지 않으므로 오류를 방지하지 못합니다.
let anyList: any[] = [1, true, "free"];
anyList[1] = 100;

// 8. Void (리턴 값이 없는 함수)
function warnUser(): void {
    console.log("This is my warning message");
}
// let unusable: void = undefined;
// unusable = null; // --strictNullChecks가 아닌 경우 가능

// 9. Null and Undefined
let u: undefined = undefined;
let n: null = null;
// 다른 모든 타입의 서브 타입이므로 `--strictNullChecks`가 아니면 다른 타입에도 할당 가능.
// 예를 들어, `let a: number = undefined;` 가 `--strictNullChecks`가 없으면 허용됨.

// 10. Never (절대 반환하지 않는 함수)
// 항상 에러를 발생시키거나, 절대 끝나지 않는 타입
function error(message: string): never {
    throw new Error(message);
}

function infiniteLoop(): never {
    while (true) {}
}

// 11. Object (객체 타입)
// 원시 타입이 아닌 모든 타입을 나타냄
declare function create(o: object | null): void;
create({ prop: 0 });
create(null);
// create(42); // Argument of type 'number' is not assignable to parameter of type 'object | null'.

// 타입 추론 (Type Inference)
// TypeScript는 변수를 선언하고 초기화할 때 타입을 자동으로 추론합니다.
let inferredString = "this is a string"; // string으로 추론
// inferredString = 10; // Type 'number' is not assignable to type 'string'.

let inferredNumber = 123; // number로 추론
// inferredNumber = "hello"; // Type 'string' is not assignable to type 'number'.

// 명시적 타입 지정 (Type Annotation)
let explicitString: string = "explicit type";
let explicitNumber: number = 456;

// 학습 포인트: `any` 타입의 사용을 최소화하고, 가능한 한 구체적인 타입을 명시하여 TypeScript의 장점을 최대한 활용해야 합니다.
// `string`, `number`, `boolean`은 소문자로 사용해야 합니다 (JavaScript 원시 타입).
// `String`, `Number`, `Boolean`은 JavaScript의 래퍼 객체를 의미하며, TypeScript에서 지양됩니다.
