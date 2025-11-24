// JavaScript 객체와 프로토타입
// 객체 리터럴, 생성자 함수, 클래스, 프로토타입 체인 이해

// 나쁜 예시: 객체를 생성할 때마다 중복된 메서드를 새로 정의하여 메모리를 낭비하거나, 프로토타입 체인을 이해하지 못해 비효율적인 상속 구현.
// 좋은 예시: 객체 리터럴, 생성자 함수, 클래스를 적절히 활용하고 프로토타입 체인을 이해하여 효율적인 객체 생성 및 상속 구현.

// --- 1. 객체 리터럴 (Object Literal) ---
// 가장 간단한 객체 생성 방법, 단일 객체를 생성할 때 유용
console.log("--- 객체 리터럴 예시 ---");
const person1 = {
    name: "Alice",
    age: 30,
    greet: function() {
        return `Hello, my name is ${this.name}`;
    }
};
console.log(person1.greet());
console.log(person1.name);

// --- 2. 생성자 함수 (Constructor Function) ---
// 여러 객체를 동일한 구조로 생성할 때 유용 (ES5 이하에서 클래스 역할)
console.log("\n--- 생성자 함수 예시 ---");
function Person(name, age) {
    this.name = name;
    this.age = age;
    // this.greet = function() { return `Hello, my name is ${this.name}`; }; // 나쁜 예시: 매번 새로운 함수 생성
}

// 프로토타입을 이용한 메서드 공유 (좋은 예시)
Person.prototype.greet = function() {
    return `Hello, my name is ${this.name}`;
};

const person2 = new Person("Bob", 25);
const person3 = new Person("Charlie", 35);
console.log(person2.greet());
console.log(person3.greet());
console.log(person2.greet === person3.greet); // true (동일한 함수를 공유)

// --- 3. 클래스 (Class) - ES6 ---
// 생성자 함수의 문법적 설탕(Syntactic Sugar)으로, 객체 지향 패턴을 더 명확하게 표현
console.log("\n--- 클래스 예시 ---");
class Animal {
    constructor(name) {
        this.name = name;
    }
    speak() {
        return `${this.name} makes a sound.`;
    }
}

class Dog extends Animal { // 상속
    constructor(name, breed) {
        super(name); // 부모 클래스의 생성자 호출
        this.breed = breed;
    }
    speak() { // 메서드 오버라이딩
        return `${this.name} barks!`;
    }
    fetch(item) {
        return `${this.name} fetches ${item}`;
    }
}

const myDog = new Dog("Buddy", "Golden Retriever");
console.log(myDog.speak());
console.log(myDog.fetch("ball"));
console.log(myDog instanceof Dog); // true
console.log(myDog instanceof Animal); // true

// --- 4. 프로토타입 체인 (Prototype Chain) ---
// JavaScript 객체는 `__proto__` 속성을 통해 자신의 부모 객체(프로토타입)에 접근합니다.
// 어떤 속성이나 메서드를 찾을 때, 현재 객체에 없으면 프로토타입으로 거슬러 올라가며 찾습니다.
console.log("\n--- 프로토타입 체인 예시 ---");
const protoObj = {
    protoProp: "I am a prototype property"
};

const childObj = Object.create(protoObj); // protoObj를 프로토타입으로 하는 객체 생성
childObj.childProp = "I am a child property";

console.log(childObj.childProp); // I am a child property (자신에게서 찾음)
console.log(childObj.protoProp); // I am a prototype property (프로토타입에서 찾음)

// 프로토타입 체인의 끝은 Object.prototype 이고 그 위에는 null
console.log(childObj.__proto__ === protoObj); // true
console.log(protoObj.__proto__ === Object.prototype); // true
console.log(Object.prototype.__proto__ === null); // true

// 배열의 경우
const myArray = [1, 2, 3];
console.log(myArray.__proto__ === Array.prototype); // true
console.log(Array.prototype.__proto__ === Object.prototype); // true
