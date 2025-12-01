// TypeScript 제네릭 (Generics)
// 재사용 가능한 컴포넌트 생성을 위한 제네릭 활용

// 나쁜 예시: `any` 타입을 사용하여 여러 타입의 데이터를 처리하려 하여 타입 안전성을 잃거나,
// 각 타입별로 유사한 코드를 반복하여 작성하여 코드 중복을 초래합니다.
// 좋은 예시: 제네릭을 사용하여 여러 타입에서 동작하는 재사용 가능한 함수, 인터페이스, 클래스를 만들고,
// 동시에 타입 안전성도 유지하여 코드 중복을 줄이고 유연성을 높입니다.

// --- 1. 제네릭 함수 (Generic Functions) ---
// 함수에 타입 변수를 추가하여 다양한 타입에서 동작하도록 합니다.
function identity<T>(arg: T): T {
    return arg;
}

let output1 = identity<string>("myString"); // 명시적으로 string 타입을 지정
let output2 = identity("myString");       // 타입 추론으로 string 타입이 됨
let output3 = identity(123);              // 타입 추론으로 number 타입이 됨

console.log(`identity("myString"): ${output1} (${typeof output1})`);
console.log(`identity(123): ${output3} (${typeof output3})`);


// 여러 타입 변수 사용
function pair<T, U>(arg1: T, arg2: U): [T, U] {
    return [arg1, arg2];
}
let myPair = pair("hello", 123);
console.log(`pair("hello", 123): [${myPair[0]}, ${myPair[1]}]`);


// --- 2. 제네릭 인터페이스 (Generic Interfaces) ---
// 인터페이스에 타입 변수를 추가하여 다양한 타입의 객체에 대한 계약을 정의합니다.
interface GenericIdentityFn<T> {
    (arg: T): T;
}

let myIdentity: GenericIdentityFn<number> = identity;
console.log(`myIdentity(456): ${myIdentity(456)}`);


interface Box<T> {
    value: T;
}

let stringBox: Box<string> = { value: "문자열" };
let numberBox: Box<number> = { value: 123 };
console.log(`stringBox: ${stringBox.value}`);
console.log(`numberBox: ${numberBox.value}`);


// --- 3. 제네릭 클래스 (Generic Classes) ---
// 클래스에 타입 변수를 추가하여 다양한 타입의 데이터를 다루는 클래스를 만듭니다.
class GenericNumber<T> {
    zeroValue: T;
    add: (x: T, y: T) => T;

    constructor(zero: T, addFunction: (x: T, y: T) => T) {
        this.zeroValue = zero;
        this.add = addFunction;
    }
}

let myGenericNumber = new GenericNumber<number>(0, (x, y) => x + y);
console.log(`myGenericNumber.add(10, 20): ${myGenericNumber.add(10, 20)}`);

let stringCombiner = new GenericNumber<string>("", (x, y) => x + y);
console.log(`stringCombiner.add("Hello, ", "Generics!"): ${stringCombiner.add("Hello, ", "Generics!")}`);


// --- 4. 제네릭 제약 조건 (Generic Constraints) ---
// 모든 타입에서 동작하는 것이 아니라, 특정 속성이나 메서드를 가진 타입으로 제한할 때 사용합니다.
interface Lengthwise {
    length: number;
}

function loggingIdentity<T extends Lengthwise>(arg: T): T {
    console.log(`길이: ${arg.length}`); // now we know it has a .length property
    return arg;
}

// loggingIdentity(3); // Error: Argument of type 'number' is not assignable to parameter of type 'Lengthwise'.
loggingIdentity({ length: 10, value: 3 }); // { length: 10, value: 3 }
loggingIdentity("hello world"); // string은 length 속성을 가짐
loggingIdentity([1, 2, 3]); // 배열은 length 속성을 가짐

// 키 제약 조건 (keyof)
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
    return obj[key];
}

let user = { id: 1, name: "Alice", email: "alice@example.com" };
let id = getProperty(user, "id");
let name = getProperty(user, "name");
// let address = getProperty(user, "address"); // Error: Argument of type '"address"' is not assignable to parameter of type '"id" | "name" | "email"'.
console.log(`user.id: ${id}`);
console.log(`user.name: ${name}`);


// 학습 포인트: 제네릭은 코드의 재사용성을 높이고, 타입 추론을 통해 타입 안전성을 유지하며,
// 유연하고 확장 가능한 컴포넌트를 설계하는 데 필수적인 기능입니다.
// 복잡한 타입 시스템을 다룰 때 강력한 도구가 됩니다.
