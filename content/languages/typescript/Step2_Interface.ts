// TypeScript 인터페이스 (Interface)
// 객체, 함수, 클래스 타입 정의를 위한 인터페이스 활용

// 나쁜 예시: `any` 타입이나 너무 일반적인 `object` 타입만 사용하여 객체 구조를 명확히 정의하지 않아 코드의 예측 가능성을 떨어뜨립니다.
// 좋은 예시: 인터페이스를 사용하여 객체의 속성 타입, 함수의 시그니처, 클래스의 구현 계약을 명확하게 정의하여 코드의 안정성과 가독성을 높입니다.

// 1. 객체의 타입 정의 (Object Type Definition)
interface LabeledValue {
    label: string; // 필수 속성
    size?: number; // 선택적 속성 (optional property)
    readonly id: number; // 읽기 전용 속성 (readonly property)
    [propName: string]: any; // 인덱스 시그니처 (index signature): 추가적인 속성 허용
}

function printLabel(labeledObj: LabeledValue) {
    console.log(`라벨: ${labeledObj.label}`);
    if (labeledObj.size) {
        console.log(`크기: ${labeledObj.size}`);
    }
    console.log(`ID: ${labeledObj.id}`);
    if (labeledObj.location) {
        console.log(`위치: ${labeledObj.location}`);
    }
}

let myObj = { id: 123, size: 10, label: "크기가 10인 객체", location: "Seoul" };
printLabel(myObj);

// myObj.id = 456; // Error: Cannot assign to 'id' because it is a read-only property.


// 2. 함수 타입 정의 (Function Types)
interface SearchFunc {
    (source: string, subString: string): boolean; // 함수의 매개변수와 반환 타입 정의
}

let mySearch: SearchFunc;
mySearch = function(src: string, sub: string): boolean {
    let result = src.search(sub);
    return result > -1;
};
console.log(`'hello world'에 'world'가 포함되어 있나요? ${mySearch("hello world", "world")}`);


// 3. 인덱서블 타입 정의 (Indexable Types)
interface StringArray {
    [index: number]: string; // 숫자 인덱스를 가진 문자열 배열
}

let myArray: StringArray;
myArray = ["Bob", "Fred"];
console.log(`myArray[0]: ${myArray[0]}`);

interface Dictionary {
    [index: string]: string; // 문자열 인덱스를 가진 사전 (객체)
    length: number; // 인덱스 시그니처와 함께 다른 속성도 정의 가능
}

// let myDictionary: Dictionary = { "name": "Alice", "age": "30" }; // Error: 'age' should be string but was number

// 4. 클래스 타입 정의 (Class Types)
// 인터페이스는 클래스가 특정 구조를 가지도록 강제하는 "계약" 역할을 합니다.
// 인터페이스는 클래스의 인스턴스 부분(속성과 메서드)에 대한 타입 검사만 수행합니다.
// 스태틱(static) 부분은 검사하지 않습니다.

interface ClockInterface {
    currentTime: Date;
    setTime(d: Date): void;
}

// class Clock implements ClockInterface {
//     currentTime: Date = new Date();
//     setTime(d: Date) {
//         this.currentTime = d;
//     }
//     constructor(h: number, m: number) {} // 생성자는 인터페이스로 정의 불가
// }

// 인터페이스는 또한 클래스를 정의할 때 확장(extends)할 수 있습니다.
interface Shape {
    color: string;
}

interface PenStroke {
    penWidth: number;
}

interface Square extends Shape, PenStroke {
    sideLength: number;
}

let square = {} as Square; // 타입 단언 (type assertion)
square.color = "blue";
square.sideLength = 10;
square.penWidth = 5.0;
console.log(`정사각형 색상: ${square.color}, 길이: ${square.sideLength}, 펜 굵기: ${square.penWidth}`);


// 5. 인터페이스 확장 (Extending Interfaces)
interface BasicPerson {
    name: string;
    age: number;
}

interface Employee extends BasicPerson { // BasicPerson 인터페이스 확장
    employeeId: string;
    department: string;
}

const employee: Employee = {
    name: "Jane Doe",
    age: 40,
    employeeId: "EMP001",
    department: "Engineering"
};
console.log(`직원: ${employee.name}, 부서: ${employee.department}`);

// 학습 포인트: 인터페이스는 코드의 구조를 명확히 하고, 타입 안정성을 확보하며, 다른 개발자와의 협업을 용이하게 합니다.
// 특히 객체의 형태를 미리 약속해야 하는 상황(API 응답, 데이터 모델 등)에서 매우 유용합니다.
