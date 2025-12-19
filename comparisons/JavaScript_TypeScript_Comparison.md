# JavaScript vs TypeScript 비교

> JavaScript와 TypeScript의 핵심 차이점과 타입 시스템을 비교하여 각 언어의 특징을 이해합니다.

---

## 1. 언어 개요

| 항목 | JavaScript | TypeScript |
|:-----|:-----------|:-----------|
| **타입 시스템** | 동적 타입 (런타임) | 정적 타입 (컴파일 타임) |
| **컴파일** | 인터프리터 | 트랜스파일 (TS → JS) |
| **타입 검사** | 런타임 에러 | 컴파일 타임 에러 |
| **IDE 지원** | 기본 수준 | 강력한 자동완성, 리팩토링 |
| **학습 곡선** | 낮음 | 중간 |
| **생태계** | 모든 JS 라이브러리 | JS 라이브러리 + @types |

---

## 2. 변수 선언과 타입

### JavaScript (동적 타입)
```javascript
// JavaScript - 타입 추론 없음, 런타임에 타입 결정

// 나쁜 예시: 타입 혼용으로 인한 버그
let value = 10;
value = "문자열";  // 에러 없음 - 런타임에 문제 발생 가능
value = { key: 1 }; // 에러 없음

function add(a, b) {
    return a + b;  // 숫자? 문자열? 객체?
}
add(1, 2);       // 3
add("1", "2");   // "12" - 의도치 않은 결과
add(1, "2");     // "12" - 타입 강제 변환

// 좋은 예시: JSDoc으로 타입 힌트 제공
/**
 * @param {number} a - 첫 번째 숫자
 * @param {number} b - 두 번째 숫자
 * @returns {number} 두 숫자의 합
 */
function addNumbers(a, b) {
    if (typeof a !== 'number' || typeof b !== 'number') {
        throw new Error('숫자만 입력 가능합니다');
    }
    return a + b;
}
```

### TypeScript (정적 타입)
```typescript
// TypeScript - 컴파일 타임 타입 검사

// 좋은 예시: 명시적 타입 선언
let value: number = 10;
// value = "문자열";  // 컴파일 에러!
// value = { key: 1 }; // 컴파일 에러!

function add(a: number, b: number): number {
    return a + b;
}
add(1, 2);        // 3
// add("1", "2");  // 컴파일 에러!
// add(1, "2");    // 컴파일 에러!

// 타입 추론 활용
let count = 0;  // number로 추론
let name = "홍길동";  // string으로 추론
let items = [1, 2, 3];  // number[]로 추론
```

---

## 3. 함수 타입

### JavaScript
```javascript
// JavaScript - 함수 시그니처 불명확

// 나쁜 예시: 매개변수와 반환 타입 불명확
function processUser(user) {
    // user가 어떤 구조인지 알 수 없음
    return user.name.toUpperCase();  // name이 있는지 확인 불가
}

// 좋은 예시: 방어적 프로그래밍
function processUserSafe(user) {
    if (!user || typeof user.name !== 'string') {
        throw new Error('유효하지 않은 사용자');
    }
    return user.name.toUpperCase();
}

// 콜백 함수
function fetchData(url, callback) {
    // callback의 시그니처가 불명확
    fetch(url)
        .then(res => res.json())
        .then(data => callback(null, data))
        .catch(err => callback(err, null));
}
```

### TypeScript
```typescript
// TypeScript - 명확한 함수 시그니처

// 인터페이스로 타입 정의
interface User {
    id: number;
    name: string;
    email: string;
    age?: number;  // 선택적 속성
}

// 좋은 예시: 명확한 타입 정의
function processUser(user: User): string {
    return user.name.toUpperCase();  // IDE 자동완성 지원
}

// 콜백 함수 타입 정의
type Callback<T> = (error: Error | null, data: T | null) => void;

function fetchData<T>(url: string, callback: Callback<T>): void {
    fetch(url)
        .then(res => res.json())
        .then(data => callback(null, data))
        .catch(err => callback(err, null));
}

// 화살표 함수 타입
const multiply: (a: number, b: number) => number = (a, b) => a * b;

// 함수 오버로딩
function format(value: string): string;
function format(value: number): string;
function format(value: string | number): string {
    if (typeof value === 'string') {
        return value.trim();
    }
    return value.toFixed(2);
}
```

---

## 4. 객체와 인터페이스

### JavaScript
```javascript
// JavaScript - 객체 구조 불명확

// 나쁜 예시: 객체 구조가 문서화되지 않음
const user = {
    name: "홍길동",
    age: 30
};

function greet(person) {
    console.log(`안녕하세요, ${person.name}님!`);
    // person.nickname 접근해도 에러 없음 (undefined 반환)
}

// 좋은 예시: 객체 생성 함수로 구조 명시
function createUser(name, age, email) {
    return {
        name,
        age,
        email,
        createdAt: new Date()
    };
}
```

### TypeScript
```typescript
// TypeScript - 인터페이스와 타입으로 구조 정의

// 인터페이스 정의
interface User {
    id: number;
    name: string;
    email: string;
    age?: number;  // 선택적
    readonly createdAt: Date;  // 읽기 전용
}

// 인터페이스 확장
interface Admin extends User {
    role: 'admin';
    permissions: string[];
}

// 타입 별칭
type UserRole = 'admin' | 'user' | 'guest';

type UserWithRole = User & {
    role: UserRole;
};

// 좋은 예시: 명확한 타입 사용
const user: User = {
    id: 1,
    name: "홍길동",
    email: "hong@example.com",
    createdAt: new Date()
};

function greet(person: User): void {
    console.log(`안녕하세요, ${person.name}님!`);
    // person.nickname 접근 시 컴파일 에러!
}

// 제네릭 인터페이스
interface ApiResponse<T> {
    data: T;
    status: number;
    message: string;
}

const userResponse: ApiResponse<User> = {
    data: user,
    status: 200,
    message: '성공'
};
```

---

## 5. 배열과 제네릭

### JavaScript
```javascript
// JavaScript - 배열 타입 미지정

// 나쁜 예시: 혼합 타입 배열
const mixed = [1, "two", { three: 3 }, [4]];

// 배열 메서드 사용 시 타입 불확실
const doubled = mixed.map(item => item * 2);  // NaN 포함 가능

// 좋은 예시: 일관된 타입 유지
const numbers = [1, 2, 3, 4, 5];
const doubledNumbers = numbers.map(n => n * 2);
```

### TypeScript
```typescript
// TypeScript - 제네릭으로 타입 안전성 확보

// 배열 타입 명시
const numbers: number[] = [1, 2, 3, 4, 5];
const names: Array<string> = ["홍길동", "김철수"];

// 튜플 타입
const tuple: [string, number] = ["age", 30];
const [key, value] = tuple;  // key: string, value: number

// 제네릭 함수
function first<T>(arr: T[]): T | undefined {
    return arr[0];
}

const firstNumber = first(numbers);  // number | undefined
const firstName = first(names);      // string | undefined

// 제네릭 클래스
class Stack<T> {
    private items: T[] = [];

    push(item: T): void {
        this.items.push(item);
    }

    pop(): T | undefined {
        return this.items.pop();
    }

    peek(): T | undefined {
        return this.items[this.items.length - 1];
    }
}

const numberStack = new Stack<number>();
numberStack.push(1);
// numberStack.push("문자열");  // 컴파일 에러!
```

---

## 6. Null/Undefined 처리

### JavaScript
```javascript
// JavaScript - null 체크가 필수

// 나쁜 예시: null 체크 누락
function getLength(str) {
    return str.length;  // str이 null이면 런타임 에러
}

// 좋은 예시: 옵셔널 체이닝과 널 병합
function getLengthSafe(str) {
    return str?.length ?? 0;
}

// 방어적 프로그래밍
function processData(data) {
    if (data == null) {  // null 또는 undefined
        return null;
    }
    return data.value;
}
```

### TypeScript
```typescript
// TypeScript - 컴파일 타임에 null 안전성 확보

// strictNullChecks 활성화 시
function getLength(str: string): number {
    return str.length;  // str은 반드시 string
}

// null 가능성 명시
function getLengthNullable(str: string | null): number {
    // return str.length;  // 컴파일 에러! null 체크 필요
    return str?.length ?? 0;
}

// Non-null assertion (확신할 때만 사용)
function assertNonNull(value: string | null): string {
    return value!;  // null이 아님을 단언 (주의해서 사용)
}

// 타입 가드
function isString(value: unknown): value is string {
    return typeof value === 'string';
}

function process(value: unknown): void {
    if (isString(value)) {
        console.log(value.toUpperCase());  // value는 string으로 추론
    }
}

// 옵셔널 속성과 Required
interface Config {
    host: string;
    port?: number;
}

type RequiredConfig = Required<Config>;  // 모든 속성 필수
type PartialConfig = Partial<Config>;     // 모든 속성 선택적
```

---

## 7. 클래스와 접근 제한자

### JavaScript
```javascript
// JavaScript - 접근 제한자 없음 (ES2022에서 # 프라이빗 필드 추가)

class User {
    // ES2022 프라이빗 필드
    #password;

    constructor(name, email, password) {
        this.name = name;        // public
        this.email = email;      // public
        this.#password = password;  // private
    }

    // public 메서드
    greet() {
        return `안녕하세요, ${this.name}입니다.`;
    }

    // 비밀번호 검증 (프라이빗 필드 사용)
    checkPassword(input) {
        return this.#password === input;
    }
}

const user = new User("홍길동", "hong@test.com", "secret");
// user.#password;  // 문법 에러
```

### TypeScript
```typescript
// TypeScript - 명확한 접근 제한자

class User {
    // public: 어디서나 접근 가능 (기본값)
    public name: string;

    // protected: 클래스와 서브클래스에서만 접근
    protected email: string;

    // private: 해당 클래스에서만 접근
    private password: string;

    // readonly: 읽기 전용
    readonly id: number;

    constructor(
        id: number,
        name: string,
        email: string,
        password: string
    ) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.password = password;
    }

    // 축약 문법 (매개변수 속성)
    // constructor(
    //     public readonly id: number,
    //     public name: string,
    //     protected email: string,
    //     private password: string
    // ) {}

    checkPassword(input: string): boolean {
        return this.password === input;
    }
}

// 상속
class Admin extends User {
    constructor(
        id: number,
        name: string,
        email: string,
        password: string,
        public permissions: string[]
    ) {
        super(id, name, email, password);
    }

    getEmail(): string {
        return this.email;  // protected 접근 가능
        // return this.password;  // 에러! private 접근 불가
    }
}

// 추상 클래스
abstract class Shape {
    abstract getArea(): number;

    describe(): string {
        return `면적: ${this.getArea()}`;
    }
}

class Circle extends Shape {
    constructor(private radius: number) {
        super();
    }

    getArea(): number {
        return Math.PI * this.radius ** 2;
    }
}
```

---

## 8. 유니온 타입과 타입 가드

### TypeScript 전용 기능
```typescript
// 유니온 타입
type ID = string | number;

function processId(id: ID): void {
    // 타입 좁히기 (Narrowing)
    if (typeof id === 'string') {
        console.log(id.toUpperCase());  // string 메서드 사용 가능
    } else {
        console.log(id.toFixed(2));     // number 메서드 사용 가능
    }
}

// 판별 유니온 (Discriminated Unions)
interface Circle {
    kind: 'circle';
    radius: number;
}

interface Rectangle {
    kind: 'rectangle';
    width: number;
    height: number;
}

type Shape = Circle | Rectangle;

function getArea(shape: Shape): number {
    switch (shape.kind) {
        case 'circle':
            return Math.PI * shape.radius ** 2;
        case 'rectangle':
            return shape.width * shape.height;
        default:
            // 철저한 검사 (exhaustive check)
            const _exhaustive: never = shape;
            return _exhaustive;
    }
}

// 사용자 정의 타입 가드
interface Fish {
    swim(): void;
}

interface Bird {
    fly(): void;
}

function isFish(pet: Fish | Bird): pet is Fish {
    return (pet as Fish).swim !== undefined;
}

function move(pet: Fish | Bird): void {
    if (isFish(pet)) {
        pet.swim();  // Fish로 확정
    } else {
        pet.fly();   // Bird로 확정
    }
}
```

---

## 9. 유틸리티 타입

### TypeScript 유틸리티 타입
```typescript
interface User {
    id: number;
    name: string;
    email: string;
    age: number;
}

// Partial<T> - 모든 속성을 선택적으로
type PartialUser = Partial<User>;
// { id?: number; name?: string; email?: string; age?: number; }

// Required<T> - 모든 속성을 필수로
type RequiredUser = Required<PartialUser>;

// Pick<T, K> - 특정 속성만 선택
type UserBasic = Pick<User, 'id' | 'name'>;
// { id: number; name: string; }

// Omit<T, K> - 특정 속성 제외
type UserWithoutEmail = Omit<User, 'email'>;
// { id: number; name: string; age: number; }

// Readonly<T> - 모든 속성을 읽기 전용으로
type ReadonlyUser = Readonly<User>;

// Record<K, V> - 키-값 타입 정의
type UserRoles = Record<string, 'admin' | 'user' | 'guest'>;
const roles: UserRoles = {
    hong: 'admin',
    kim: 'user'
};

// ReturnType<T> - 함수 반환 타입 추출
function createUser(): User {
    return { id: 1, name: '홍길동', email: 'hong@test.com', age: 30 };
}
type CreatedUser = ReturnType<typeof createUser>;  // User

// Parameters<T> - 함수 매개변수 타입 추출
function updateUser(id: number, data: Partial<User>): void {}
type UpdateParams = Parameters<typeof updateUser>;  // [number, Partial<User>]
```

---

## 10. 비교표 요약

| 기능 | JavaScript | TypeScript |
|:-----|:-----------|:-----------|
| **타입 안전성** | 없음 (런타임 에러) | 있음 (컴파일 타임 검사) |
| **인터페이스** | 없음 | `interface`, `type` |
| **제네릭** | 없음 | 완전 지원 |
| **접근 제한자** | #private만 | public, protected, private |
| **열거형** | 없음 | `enum` |
| **데코레이터** | Stage 3 | 지원 (실험적) |
| **IDE 지원** | 기본 | 강력한 자동완성/리팩토링 |
| **빌드 설정** | 불필요 | tsconfig.json 필요 |
| **런타임** | 직접 실행 | JS로 트랜스파일 필요 |

---

## 11. 선택 가이드

| 상황 | 권장 |
|:-----|:-----|
| 소규모 스크립트, 빠른 프로토타입 | JavaScript |
| 중/대규모 프로젝트 | TypeScript |
| 팀 협업 | TypeScript (명확한 계약) |
| 레거시 JS 프로젝트 | 점진적 TypeScript 도입 |
| Node.js 백엔드 | TypeScript (안정성) |
| React/Vue/Angular | TypeScript (생태계 지원 좋음) |
