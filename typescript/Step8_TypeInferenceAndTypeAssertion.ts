// TypeScript 타입 추론과 타입 단언
// TypeScript의 타입 추론 이해 및 `as` 키워드를 이용한 타입 단언

// 나쁜 예시: `any` 타입을 남용하거나, 불필요하게 타입 단언을 사용하여 타입 안정성을 해칩니다.
// 좋은 예시: TypeScript의 강력한 타입 추론 기능을 신뢰하고, 필요한 경우에만 타입 단언을 사용하여 컴파일러에게 추가 정보를 제공합니다.

// --- 1. 타입 추론 (Type Inference) ---
// TypeScript는 변수를 초기화하거나 함수를 호출할 때 자동으로 타입을 결정합니다.

let myString = "Hello world"; // `myString`은 `string` 타입으로 추론됩니다.
// myString = 123; // Error: Type 'number' is not assignable to type 'string'.

let myNumber = 123; // `myNumber`는 `number` 타입으로 추론됩니다.
let myBoolean = true; // `myBoolean`은 `boolean` 타입으로 추론됩니다.

let myArray = [1, 2, "3"]; // `myArray`는 `(string | number)[]` 타입으로 추론됩니다.
// myArray.push(true); // Error: Argument of type 'boolean' is not assignable to parameter of type 'string | number'.

function greet(name: string) {
    return `Hello, ${name}`;
}
let greeting = greet("Alice"); // `greeting`은 `string` 타입으로 추론됩니다.
// greeting = 123; // Error: Type 'number' is not assignable to type 'string'.

// 컨텍스트에 의한 타입 추론
window.addEventListener("click", (event) => {
    // `event` 객체는 자동으로 `MouseEvent` 타입으로 추론됩니다.
    console.log(event.button);
    // console.log(event.key); // Error: Property 'key' does not exist on type 'MouseEvent'.
});

// --- 2. 타입 단언 (Type Assertions) ---
// 개발자가 TypeScript 컴파일러보다 특정 값의 타입을 더 잘 알고 있다고 판단될 때 사용합니다.
// 타입 단언은 런타임에 영향을 주지 않으며, 컴파일 시에만 사용됩니다.
// 두 가지 형태: `<Type>value` 또는 `value as Type` (JSX와 충돌 가능성 때문에 `as` 키워드 선호)

// 예시 1: DOM 요소
// `document.getElementById`는 `HTMLElement | null`을 반환합니다.
// 우리는 이 요소가 `HTMLInputElement`임을 확신할 때 `as`를 사용하여 단언할 수 있습니다.
const myCanvas = document.getElementById("my_canvas") as HTMLCanvasElement;
if (myCanvas) {
    const ctx = myCanvas.getContext("2d"); // 이제 ctx는 CanvasRenderingContext2D 타입으로 추론됩니다.
    // console.log(myCanvas.value); // Error: Property 'value' does not exist on type 'HTMLCanvasElement'.
    // HTMLInputElement였다면 value 접근 가능
}

// 예시 2: 서버에서 받은 데이터
interface APIResponse {
    data: any; // 서버에서 받은 데이터의 타입이 명확하지 않을 때 (any 사용은 지양)
}

interface UserProfile {
    name: string;
    email: string;
}

const response: APIResponse = { data: { name: "Bob", email: "bob@example.com" } };

// 서버 응답이 특정 UserProfile 형태임을 단언
const userProfile = response.data as UserProfile;
console.log(`사용자 이름: ${userProfile.name}`);
console.log(`사용자 이메일: ${userProfile.email}`);
// userProfile.age = 30; // Error: Property 'age' does not exist on type 'UserProfile'.

// 이중 단언 (Double Assertion)
// `any`를 거쳐 다른 타입으로 단언하는 것은 강력하지만, 주의해서 사용해야 합니다.
// 컴파일러에게 "나는 이 타입이 맞다고 확신한다"고 말하는 것이므로 잘못된 타입을 강제하면 런타임 오류로 이어질 수 있습니다.
// let strLength: number = ("hello" as any as number).length; // 컴파일 에러는 없지만 런타임에 undefined가 될 수 있음.
// console.log(strLength); // undefined (실제 문자열 길이를 얻으려면 .length 사용)
let someValue: any = "this is a string";
let strLength: number = (someValue as string).length;
console.log(`문자열 길이: ${strLength}`);

// 타입 단언은 타입 검사를 회피하는 수단이 아니라, 컴파일러가 알지 못하는 타입 정보를 개발자가 알려주는 용도로 사용해야 합니다.
// 불필요한 타입 단언은 코드의 안정성을 떨어뜨릴 수 있으므로, 항상 신중하게 사용해야 합니다.

// 학습 포인트: TypeScript의 타입 추론은 대부분의 상황에서 충분히 강력합니다.
// 타입 단언은 컴파일러의 경고를 무시하고 싶을 때 사용하지만, 이는 잠재적인 런타임 오류의 위험을 감수하는 것이므로 최소한으로 사용해야 합니다.
// 가능하다면 타입 가드(Type Guards)나 제네릭(Generics)을 사용하여 안전하게 타입을 좁히는 방법을 고려해야 합니다.
