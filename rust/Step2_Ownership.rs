// Rust Step 2: 소유권 (Ownership)
// 소유권, 빌림(Borrowing), 생명 주기(Lifetimes) 개념을 통한 메모리 안전성 확보

// 나쁜 예시: 다른 언어처럼 메모리를 수동으로 관리하거나, Dangling Pointer와 같은 문제 발생.
// 좋은 예시: Rust의 소유권 규칙을 이해하고 활용하여 컴파일 타임에 메모리 안전성을 보장하고, 런타임 오버헤드 없이 안전한 코드를 작성.

// 학습 포인트: 소유권 시스템은 Rust의 가장 독특하고 강력한 기능 중 하나입니다. 이를 이해하는 것이 Rust 프로그래밍의 핵심입니다.

fn main() {
    // --- 1. 소유권 규칙 (Ownership Rules) ---
    // 1. Rust의 각 값은 `owner`라고 불리는 변수를 가집니다.
    // 2. 한 번에 하나의 owner만 존재할 수 있습니다.
    // 3. owner가 스코프 밖으로 벗어나면, 값은 버려집니다. (drop)

    // 예시: 문자열 (String)
    // String 타입은 힙(heap)에 저장되는 가변 크기의 문자열입니다.
    let s1 = String::from("hello"); // s1이 "hello"를 소유합니다.
    // let s2 = s1; // s1의 소유권이 s2로 '이동' (move)합니다. s1은 더 이상 유효하지 않습니다.
    // println!("s1: {}", s1); // 에러 발생: s1은 이미 이동되었으므로 사용할 수 없습니다.
    // 소유권 이동 후에는 이전 변수를 사용할 수 없어 데이터 경쟁 상태를 방지합니다.

    let s2 = s1.clone(); // s1을 복제하여 s2가 새로운 소유권을 가집니다.
    println!("s1: {}, s2: {}", s1, s2); // 이제 s1과 s2 모두 유효합니다.

    // Copy 트레잇이 구현된 타입 (스택에 저장되는 고정 크기 타입)
    // 정수, 부동 소수점, 불리언, char, 고정 크기 배열 등은 소유권 이동 대신 '복사'됩니다.
    let x = 5;
    let y = x; // x의 값이 y로 복사됩니다. x는 여전히 유효합니다.
    println!("x: {}, y: {}", x, y);

    // --- 2. 함수와 소유권 ---
    // 함수 호출 시 값의 소유권이 이동될 수 있습니다.
    let s = String::from("world"); // s가 "world"를 소유합니다.
    takes_ownership(s); // s의 소유권이 함수 내부로 이동합니다. s는 이제 유효하지 않습니다.
    // println!("s: {}", s); // 에러 발생: s는 이미 이동되었습니다.

    let x_val = 5; // x_val은 Copy 트레잇이 구현된 타입이므로 복사됩니다.
    makes_copy(x_val); // x_val의 값이 복사됩니다. x_val은 여전히 유효합니다.
    println!("x_val: {}", x_val); // 사용 가능

    // --- 3. 빌림 (Borrowing) ---
    // 소유권을 이동시키지 않고 다른 함수에서 값을 '참조'하게 하는 방법. `&` 연산자를 사용합니다.
    // 빌려온 참조는 기본적으로 불변입니다.
    let s_borrow = String::from("hello borrowing");
    calculate_length(&s_borrow); // s_borrow의 참조를 빌려줍니다. s_borrow는 여전히 유효합니다.
    println!("s_borrow: {}", s_borrow);

    // 가변 참조 (Mutable References): `&mut` 연산자를 사용합니다.
    // 한 번에 하나의 가변 참조만 존재할 수 있습니다. (데이터 경쟁 방지)
    let mut s_mutable = String::from("mutable string");
    change_string(&mut s_mutable); // s_mutable의 가변 참조를 빌려줍니다.
    println!("s_mutable: {}", s_mutable);

    // let r1 = &mut s_mutable;
    // let r2 = &mut s_mutable; // 에러 발생: 두 개 이상의 가변 참조는 동시에 존재할 수 없습니다.

    // 불변 참조와 가변 참조는 동시에 존재할 수 없습니다.
    // let r3 = &s_mutable; // 에러 발생: 불변 참조와 가변 참조는 동시에 존재 불가
    // let r4 = &mut s_mutable;

    // --- 4. Dangling References (매달린 참조) 방지 ---
    // Rust 컴파일러는 Dangling References를 컴파일 시점에 방지합니다.
    // let reference_to_nothing = dangle(); // 에러 발생: `String`이 반환되기 전에 드롭됩니다.

    // --- 5. 생명 주기 (Lifetimes) ---
    // 참조가 유효한 스코프를 컴파일러에게 알려주는 기능.
    // Dangling References를 방지하고 참조의 유효성을 검사하는 데 사용됩니다.
    // Rust의 생명 주기 규칙은 컴파일 타임에만 존재하며, 런타임 성능에 영향을 주지 않습니다.

    let string1 = String::from("abcd");
    let string2 = "xyz";

    let result = longest(string1.as_str(), string2);
    println!("더 긴 문자열: {}", result);

    // --- 생명 주기 문법 ('a) ---
    // `longest<'a>(x: &'a str, y: &'a str) -> &'a str`
    // 이 구문은 `x`와 `y`가 최소한 `'a` 생명 주기만큼 유효하며, 반환되는 참조도 `'a` 생명 주기만큼 유효함을 의미합니다.
    // 즉, 반환되는 참조는 입력 참조 중 더 짧은 생명 주기만큼만 유효할 수 있습니다.

    // --- 정리 ---
    // 소유권: 메모리가 자동으로 관리됩니다. (할당/해제)
    // 빌림: 소유권을 이동시키지 않고 안전하게 참조를 사용합니다.
    // 생명 주기: 참조가 유효한 스코프를 컴파일러에게 알려 Dangling References를 방지합니다.
} // s1, s2, x, y 등 모든 변수들은 이 스코프 밖으로 벗어나 드롭(drop)됩니다.

fn takes_ownership(some_string: String) { // some_string이 소유권을 받습니다.
    println!("소유권을 받은 문자열: {}", some_string);
} // some_string이 스코프 밖으로 벗어나 드롭됩니다.

fn makes_copy(some_integer: i32) { // some_integer의 값이 복사됩니다.
    println!("복사된 정수: {}", some_integer);
} // some_integer가 스코프 밖으로 벗어나 드롭됩니다.

fn calculate_length(s: &String) -> usize { // s는 String의 불변 참조를 빌립니다.
    s.len()
} // s가 스코프 밖으로 벗어나도 s_borrow는 여전히 유효합니다.

fn change_string(some_string: &mut String) { // some_string은 String의 가변 참조를 빌립니다.
    some_string.push_str(", world");
}

// fn dangle() -> &String { // 에러가 발생하는 함수 예시
//     let s = String::from("hello"); // s는 이 함수 내부에서 생성됩니다.
//     &s // s의 참조를 반환하려고 하지만, s는 함수 종료 시 드롭됩니다. (Dangling Reference)
// }

// 생명 주기 어노테이션을 사용하는 함수
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}
