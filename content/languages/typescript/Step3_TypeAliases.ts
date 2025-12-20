// TypeScript 타입 별칭 (Type Aliases)
// 복잡한 타입 정의를 위한 타입 별칭 활용 및 인터페이스와의 차이점

// 나쁜 예시: 복잡하고 반복적인 타입을 매번 길게 작성하여 코드 가독성을 해치거나, 재사용성을 떨어뜨립니다.
// 좋은 예시: 타입 별칭을 사용하여 복잡한 타입을 간결하게 재정의하고, 코드의 가독성 및 재사용성을 높입니다.

// --- 1. 타입 별칭의 기본 사용 ---
// 원시 타입, 유니온 타입, 인터섹션 타입, 튜플, 함수 등 모든 타입에 별칭을 부여할 수 있습니다.
type MyString = string;
let text: MyString = "안녕하세요";
console.log(`MyString 타입 변수: ${text}`);

type MyNumber = number;
let count: MyNumber = 100;
console.log(`MyNumber 타입 변수: ${count}`);

// --- 2. 유니온 타입 (Union Types)에 별칭 사용 ---
// 여러 타입 중 하나를 가질 수 있음을 나타냅니다.
type StringOrNumber = string | number;
let value1: StringOrNumber = "hello";
let value2: StringOrNumber = 123;
// let value3: StringOrNumber = true; // Error: Type 'boolean' is not assignable to type 'StringOrNumber'.

function printId(id: StringOrNumber) {
    console.log(`ID: ${id}`);
}
printId("abc");
printId(123);

// --- 3. 객체 타입에 별칭 사용 ---
// 인터페이스와 유사하게 객체의 구조를 정의할 수 있습니다.
type Point = {
    x: number;
    y: number;
};

function printCoord(pt: Point) {
    console.log(`X 좌표: ${pt.x}, Y 좌표: ${pt.y}`);
}
printCoord({ x: 10, y: 20 });

// --- 4. 인터섹션 타입 (Intersection Types)에 별칭 사용 ---
// 여러 타입을 모두 만족하는 타입을 생성합니다.
type Person = {
    name: string;
    age: number;
};

type Employee = {
    employeeId: string;
    department: string;
};

type FullEmployee = Person & Employee; // Person과 Employee의 모든 속성을 포함

const fullEmployee: FullEmployee = {
    name: "홍길동",
    age: 30,
    employeeId: "E123",
    department: "개발"
};
console.log(`전체 직원 정보: 이름 - ${fullEmployee.name}, 부서 - ${fullEmployee.department}`);


// --- 5. 함수 타입에 별칭 사용 ---
type GreetFunction = (name: string) => string;

const sayHello: GreetFunction = (name) => `Hello, ${name}!`;
console.log(sayHello("TypeScript"));

// --- 6. 인터페이스와 타입 별칭의 차이점 ---

// 1) 확장 (Extends)
// 인터페이스는 `extends` 키워드를 사용하여 확장할 수 있습니다.
interface IBase {
    id: number;
}
interface IExtended extends IBase {
    name: string;
}

// 타입 별칭은 인터섹션(&)을 사용하여 확장과 유사한 효과를 낼 수 있습니다.
type TBase = {
    id: number;
};
type TExtended = TBase & { name: string };


// 2) 구현 (Implements)
// 클래스는 인터페이스를 `implements` 할 수 있습니다.
interface Shape {
    draw(): void;
}
class Circle implements Shape {
    draw() { console.log("원을 그립니다."); }
}

// 타입 별칭은 `implements` 할 수 없습니다.
// class Square implements TBase { } // Error: A class can only implement an interface or a class with a 'constructor' member.


// 3) 선언적 병합 (Declaration Merging)
// 인터페이스는 동일한 이름으로 여러 번 선언되어도 자동으로 병합됩니다.
interface MergedInterface {
    a: number;
}
interface MergedInterface {
    b: string;
}
const merged: MergedInterface = { a: 1, b: "hi" }; // { a: number; b: string; }

// 타입 별칭은 동일한 이름으로 여러 번 선언할 수 없으며, 병합되지 않습니다.
// type MergedType { a: number; }
// type MergedType { b: string; } // Error: Duplicate identifier 'MergedType'.


// 4) 원시 타입, 유니온 타입 등 표현
// 타입 별칭은 원시 타입, 유니온 타입, 튜플 등 모든 타입을 표현할 수 있습니다.
type MyStringOrNumber = string | number;
type MyTuple = [string, number];

// 인터페이스는 객체 타입만 표현할 수 있습니다.


// --- 결론 ---
// - 복잡한 객체 구조를 정의하고 클래스와 함께 사용할 때는 **인터페이스**가 더 적합합니다 (확장 및 구현 용이).
// - 유니온 타입, 인터섹션 타입, 원시 타입, 튜플 등 객체 외의 다양한 타입을 조합할 때는 **타입 별칭**이 더 유용합니다.
// - 대부분의 경우 두 가지 모두 사용할 수 있지만, 프로젝트의 컨벤션과 특정 사용 사례에 따라 선택하는 것이 좋습니다.

// 학습 포인트: 타입 별칭과 인터페이스는 TypeScript 코드의 가독성과 유지보수성을 높이는 데 핵심적인 역할을 합니다.
// 각자의 특징과 장단점을 이해하고 적절한 상황에 맞는 것을 선택하는 연습이 중요합니다.
