// TypeScript 함수 (Functions)
// 함수 오버로딩, 선택적 매개변수, 기본 매개변수, Rest 매개변수

// 나쁜 예시: `any` 타입을 매개변수나 반환 타입으로 사용하거나, 함수의 시그니처를 명확하게 정의하지 않아 호출 시 예상치 못한 동작을 유발.
// 좋은 예시: 함수의 매개변수와 반환 타입, 오버로딩 등을 명확하게 정의하여 타입 안정성을 확보하고 가독성을 높임.

// --- 1. 기본 함수 정의 ---
// 매개변수와 반환 값에 타입을 명시합니다.
function add(x: number, y: number): number {
    return x + y;
}
console.log(`add(10, 20): ${add(10, 20)}`);

// 함수 표현식 (Function Expression)
let myAdd: (x: number, y: number) => number = function(x: number, y: number): number {
    return x + y;
};
console.log(`myAdd(5, 7): ${myAdd(5, 7)}`);

// --- 2. 선택적 매개변수 (Optional Parameters) ---
// 매개변수 이름 뒤에 `?`를 붙여 선택적 매개변수로 만듭니다.
// 선택적 매개변수는 항상 필수 매개변수 뒤에 와야 합니다.
function buildName(firstName: string, lastName?: string): string {
    if (lastName) {
        return firstName + " " + lastName;
    } else {
        return firstName;
    }
}
let result1 = buildName("Bob"); // Bob
let result2 = buildName("Bob", "Adams"); // Bob Adams
// let result3 = buildName("Bob", "Adams", "Sr."); // Error: Expected 2 arguments, but got 3.
console.log(`buildName("Bob"): ${result1}`);
console.log(`buildName("Bob", "Adams"): ${result2}`);


// --- 3. 기본 매개변수 (Default Parameters) ---
// 매개변수에 기본값을 할당하여 선택적 매개변수처럼 동작하게 합니다.
// 기본값이 있는 매개변수는 필수 매개변수 뒤에 오거나, 필수 매개변수 앞에 올 수도 있지만 이때는 `undefined`를 전달해야 합니다.
function buildNameWithDefault(firstName: string, lastName: string = "Smith"): string {
    return firstName + " " + lastName;
}
let result4 = buildNameWithDefault("Bob"); // Bob Smith
let result5 = buildNameWithDefault("Bob", "Adams"); // Bob Adams
let result6 = buildNameWithDefault("Bob", undefined); // Bob Smith
// let result7 = buildNameWithDefault("Bob", "Adams", "Sr."); // Error: Expected 2 arguments, but got 3.
console.log(`buildNameWithDefault("Bob"): ${result4}`);
console.log(`buildNameWithDefault("Bob", "Adams"): ${result5}`);
console.log(`buildNameWithDefault("Bob", undefined): ${result6}`);


// --- 4. Rest 매개변수 (Rest Parameters) ---
// 매개변수의 개수를 알 수 없을 때 배열 형태로 매개변수를 받습니다.
function sumAllNumbers(firstNum: number, ...restOfNumbers: number[]): number {
    let total = firstNum;
    for (let i = 0; i < restOfNumbers.length; i++) {
        total += restOfNumbers[i];
    }
    return total;
}
let sum1 = sumAllNumbers(1, 2, 3, 4, 5); // 첫 번째 인자는 firstNum에 할당, 나머지는 restOfNumbers 배열에 할당
console.log(`sumAllNumbers(1, 2, 3, 4, 5): ${sum1}`);

let sum2 = sumAllNumbers(10);
console.log(`sumAllNumbers(10): ${sum2}`);


// --- 5. 함수 오버로딩 (Function Overloads) ---
// 하나의 함수에 대해 여러 개의 시그니처를 정의하여 다양한 타입의 인자를 처리할 수 있게 합니다.
// 오버로드 시그니처는 구현 시그니처 앞에 와야 하며, 실제 구현은 가장 일반적인 타입으로 작성해야 합니다.

function reverse(string: string): string;
function reverse(array: any[]): any[];
function reverse(value: string | any[]): string | any[] {
    if (typeof value === "string") {
        return value.split("").reverse().join("");
    } else {
        return value.slice().reverse(); // 원본 배열을 수정하지 않도록 slice() 사용
    }
}

console.log(`reverse("hello"): ${reverse("hello")}`);
console.log(`reverse([1, 2, 3]): ${reverse([1, 2, 3])}`);
// console.log(reverse(123)); // Error: No overload matches this call.

// 오버로딩 사용 예시 (객체 생성)
interface Coordinate {
    x: number;
    y: number;
}

function makePoint(x: number, y: number): Coordinate;
function makePoint(coord: Coordinate): Coordinate;
function makePoint(xOrCoord: number | Coordinate, y?: number): Coordinate {
    if (typeof xOrCoord === 'number' && typeof y === 'number') {
        return { x: xOrCoord, y: y };
    } else if (typeof xOrCoord === 'object' && xOrCoord !== null && 'x' in xOrCoord && 'y' in xOrCoord) {
        return { x: xOrCoord.x, y: xOrCoord.y };
    }
    throw new Error("Invalid arguments for makePoint");
}

let point1 = makePoint(10, 20);
let point2 = makePoint({ x: 30, y: 40 });
console.log(`makePoint(10, 20): X=${point1.x}, Y=${point1.y}`);
console.log(`makePoint({ x: 30, y: 40 }): X=${point2.x}, Y=${point2.y}`);


// 학습 포인트: TypeScript의 함수 기능들을 활용하여 함수의 의도를 명확히 하고,
// 다양한 사용 케이스를 타입 안전하게 처리할 수 있습니다.
// 특히 오버로딩은 여러 인자 타입에 대응하는 유연한 함수를 만들 때 유용합니다.
