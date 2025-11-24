// TypeScript 클래스 (Class)
// TypeScript 클래스의 접근 제어자, 상속, 인터페이스 구현

// 나쁜 예시: 모든 클래스 멤버를 public으로 선언하여 외부에서 무분별하게 접근하고 수정할 수 있게 만듭니다.
// 좋은 예시: `public`, `private`, `protected`, `readonly`와 같은 접근 제어자를 사용하여 캡슐화를 강화하고, 상속과 인터페이스 구현으로 재사용성과 확장성 있는 코드를 작성합니다.

// --- 1. 클래스 기본 ---
class Greeter {
    // 속성 (Property)
    greeting: string;

    // 생성자 (Constructor)
    constructor(message: string) {
        this.greeting = message;
    }

    // 메서드 (Method)
    greet() {
        return "Hello, " + this.greeting;
    }
}

let greeter = new Greeter("world");
console.log(greeter.greet());

// --- 2. 상속 (Inheritance) ---
class Animal {
    name: string;
    constructor(theName: string) { this.name = theName; }
    move(distanceInMeters: number = 0) {
        console.log(`${this.name}가 ${distanceInMeters}m 이동했습니다.`);
    }
}

class Snake extends Animal {
    constructor(name: string) { super(name); } // 부모 클래스 생성자 호출
    move(distanceInMeters = 5) {
        console.log("꿈틀거립니다...");
        super.move(distanceInMeters); // 부모 클래스의 메서드 호출
    }
}

class Horse extends Animal {
    constructor(name: string) { super(name); }
    move(distanceInMeters = 45) {
        console.log("질주합니다...");
        super.move(distanceInMeters);
    }
}

let sam = new Snake("샘 뱀");
let tom: Animal = new Horse("톰 말"); // 다형성 (Polymorphism)

sam.move();
tom.move(34);


// --- 3. 접근 제어자 (Access Modifiers) ---
// public (기본값): 모든 곳에서 접근 가능
// private: 클래스 내부에서만 접근 가능
// protected: 클래스 내부 및 파생 클래스(자식 클래스) 내부에서 접근 가능
// readonly: 생성 시 또는 선언 시에만 값을 할당할 수 있으며, 이후에는 변경 불가

class Person {
    public name: string; // public (기본값)
    private age: number; // private
    protected gender: string; // protected
    readonly birthYear: number; // readonly

    constructor(name: string, age: number, gender: string, birthYear: number) {
        this.name = name;
        this.age = age;
        this.gender = gender;
        this.birthYear = birthYear;
    }

    public getAge(): number { // public 메서드
        return this.age;
    }

    protected getGender(): string { // protected 메서드
        return this.gender;
    }

    // private setAge(newAge: number): void { // private 메서드 (클래스 내부에서만 사용)
    //     this.age = newAge;
    // }
}

class Employee extends Person {
    private employeeId: string;

    constructor(name: string, age: number, gender: string, birthYear: number, employeeId: string) {
        super(name, age, gender, birthYear); // 부모 클래스 생성자 호출
        this.employeeId = employeeId;
    }

    public getEmployeeInfo(): string {
        // console.log(this.age); // Error: Property 'age' is private and only accessible within class 'Person'.
        console.log(`성별 (protected): ${this.gender}`); // protected 멤버 접근 가능
        return `${this.name} (ID: ${this.employeeId}, 나이: ${this.getAge()}, 성별: ${this.getGender()})`;
    }
}

let alice = new Person("Alice", 30, "Female", 1993);
console.log(alice.name);
// console.log(alice.age); // Error: Property 'age' is private
// console.log(alice.gender); // Error: Property 'gender' is protected
// alice.birthYear = 1994; // Error: Cannot assign to 'birthYear' because it is a read-only property.

let bob = new Employee("Bob", 35, "Male", 1988, "EMP001");
console.log(bob.name);
console.log(bob.getAge());
console.log(bob.getEmployeeInfo());


// --- 4. 매개변수 속성 (Parameter Properties) ---
// 생성자의 매개변수에 접근 제어자를 붙이면 해당 이름의 속성으로 자동 선언됩니다.
class Car {
    constructor(public brand: string, public readonly year: number, private _mileage: number) {}

    get mileage(): number { // getter
        return this._mileage;
    }

    set mileage(value: number) { // setter
        if (value < this._mileage) {
            throw new Error("주행 거리는 줄어들 수 없습니다.");
        }
        this._mileage = value;
    }
}

let myCar = new Car("Hyundai", 2020, 50000);
console.log(myCar.brand);
console.log(myCar.year);
console.log(myCar.mileage);
myCar.mileage = 55000;
console.log(myCar.mileage);
// myCar.year = 2021; // Error: Cannot assign to 'year' because it is a read-only property.


// --- 5. 추상 클래스 (Abstract Classes) ---
// 추상 클래스는 다른 클래스들이 파생될 수 있는 기본 클래스이며, 직접 인스턴스화할 수 없습니다.
// 추상 메서드를 포함할 수 있으며, 파생 클래스에서 반드시 구현되어야 합니다.
abstract class Department {
    constructor(public name: string) {}

    printName(): void {
        console.log("Department name: " + this.name);
    }

    abstract printMeeting(): void; // 추상 메서드는 구현부가 없습니다.
}

class AccountingDepartment extends Department {
    constructor() {
        super("회계 부서"); // 파생 클래스의 생성자에서 super() 호출 필수
    }

    printMeeting(): void { // 추상 메서드 구현
        console.log("회계 부서는 매주 월요일 오전에 회의를 진행합니다.");
    }

    generateReports(): void {
        console.log("회계 보고서를 생성합니다.");
    }
}

// let department = new Department(); // Error: Cannot create an instance of an abstract class.
let accounting = new AccountingDepartment();
accounting.printName();
accounting.printMeeting();
accounting.generateReports();


// --- 6. 인터페이스 구현 (Implementing Interfaces) ---
// 클래스는 하나 또는 여러 개의 인터페이스를 구현할 수 있습니다.
interface GreeterInterface {
    greeting: string;
    sayHello(): string;
}

class MyGreeter implements GreeterInterface {
    greeting: string;
    constructor(message: string) {
        this.greeting = message;
    }
    sayHello(): string {
        return "안녕하세요, " + this.greeting;
    }
}

let customGreeter = new MyGreeter("TypeScript!");
console.log(customGreeter.sayHello());

// 학습 포인트: TypeScript의 클래스는 ES6 클래스 문법에 타입과 접근 제어자 등 추가 기능을 제공하여,
// 더 견고하고 객체 지향적인 코드 작성을 가능하게 합니다.
