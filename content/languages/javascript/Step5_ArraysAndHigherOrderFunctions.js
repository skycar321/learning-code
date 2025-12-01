// JavaScript 배열과 고차 함수
// `map`, `filter`, `reduce` 등 배열 메서드와 활용법 학습

// 나쁜 예시: 배열을 반복할 때 `for` 루프만 고집하여 코드가 장황해지고 가독성이 떨어짐.
// 좋은 예시: `map`, `filter`, `reduce` 등 고차 함수를 사용하여 간결하고 선언적인 코드를 작성.

const numbers = [1, 2, 3, 4, 5];
const users = [
    { id: 1, name: 'Alice', age: 30, isActive: true },
    { id: 2, name: 'Bob', age: 25, isActive: false },
    { id: 3, name: 'Charlie', age: 35, isActive: true },
    { id: 4, name: 'David', age: 25, isActive: true }
];

console.log("--- 원본 배열 ---");
console.log("숫자 배열:", numbers);
console.log("사용자 배열:", users);

// --- 1. forEach() ---
// 배열의 각 요소에 대해 콜백 함수를 실행. 반환 값 없음.
console.log("\n--- forEach() 예시 ---");
numbers.forEach(num => {
    console.log(`forEach - 숫자: ${num}`);
});

// --- 2. map() ---
// 배열의 각 요소에 대해 콜백 함수를 실행하고, 새로운 배열을 반환.
console.log("\n--- map() 예시 ---");
const doubledNumbers = numbers.map(num => num * 2);
console.log("두 배 된 숫자 배열:", doubledNumbers); // [2, 4, 6, 8, 10]

const userNames = users.map(user => user.name);
console.log("사용자 이름 배열:", userNames); // ['Alice', 'Bob', 'Charlie', 'David']

// --- 3. filter() ---
// 배열의 각 요소에 대해 콜백 함수를 실행하고, 조건을 만족하는 요소로만 구성된 새로운 배열을 반환.
console.log("\n--- filter() 예시 ---");
const evenNumbers = numbers.filter(num => num % 2 === 0);
console.log("짝수 배열:", evenNumbers); // [2, 4]

const activeUsers = users.filter(user => user.isActive);
console.log("활성 사용자 배열:", activeUsers);
// [{ id: 1, name: 'Alice', age: 30, isActive: true }, { id: 3, name: 'Charlie', age: 35, isActive: true }, ...]

const youngActiveUsers = users
    .filter(user => user.isActive && user.age < 30)
    .map(user => user.name);
console.log("30세 미만 활성 사용자 이름:", youngActiveUsers); // ['Alice', 'David']


// --- 4. reduce() ---
// 배열의 각 요소에 대해 콜백 함수를 실행하여 하나의 누적 값을 반환.
console.log("\n--- reduce() 예시 ---");
const sumOfNumbers = numbers.reduce((accumulator, currentValue) => accumulator + currentValue, 0);
console.log("숫자 배열의 합계:", sumOfNumbers); // 15

const totalAge = users.reduce((acc, user) => acc + user.age, 0);
console.log("사용자 나이의 총합:", totalAge); // 130

// 사용자 이름과 나이를 매핑한 객체 생성
const userMap = users.reduce((acc, user) => {
    acc[user.name] = user.age;
    return acc;
}, {});
console.log("사용자 이름-나이 매핑:", userMap); // { Alice: 30, Bob: 25, Charlie: 35, David: 25 }


// --- 5. find() ---
// 조건을 만족하는 첫 번째 요소를 반환. 없으면 undefined.
console.log("\n--- find() 예시 ---");
const userBob = users.find(user => user.name === 'Bob');
console.log("Bob 사용자:", userBob); // { id: 2, name: 'Bob', age: 25, isActive: false }

// --- 6. some() ---
// 배열의 어떤 요소라도 조건을 만족하면 true 반환.
console.log("\n--- some() 예시 ---");
const hasOldUser = users.some(user => user.age > 35);
console.log("35세 초과 사용자가 있나요?:", hasOldUser); // false

// --- 7. every() ---
// 배열의 모든 요소가 조건을 만족하면 true 반환.
console.log("\n--- every() 예시 ---");
const allActive = users.every(user => user.isActive);
console.log("모든 사용자가 활성 상태인가요?:", allActive); // false

// --- 기타 유용한 배열 메서드 ---
// concat(), slice(), splice(), join(), reverse(), sort() 등
