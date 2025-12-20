// Rust Step 1: Rust 기본 문법과 Cargo
// 변수, 자료형, 함수, 제어 흐름 등 Rust 기본 문법 및 Cargo 사용법 이해

// 나쁜 예시: 변수를 `mut` 없이 변경하거나, Cargo를 사용하지 않고 `rustc` 명령어로 수동 컴파일.
// 좋은 예시: 불변성(immutability)을 기본으로 하고, `cargo new`, `cargo build`, `cargo run` 등 Cargo 명령어를 활용하여 프로젝트 관리.

// 학습 포인트: Rust는 기본적으로 불변성을 지향하며, Cargo는 프로젝트 생성, 빌드, 테스트, 의존성 관리 등을 담당하는 필수 도구입니다.

fn main() {
    // --- 1. 변수와 불변성 (Variables and Immutability) ---
    // Rust에서 변수는 기본적으로 불변(immutable)입니다.
    // let x = 5;
    // println!("x의 값: {}", x);
    // x = 6; // 에러 발생: `x`는 불변이므로 재할당 불가
    // println!("x의 값: {}", x);

    // 가변(mutable) 변수를 선언하려면 `mut` 키워드를 사용합니다.
    let mut y = 5;
    println!("y의 초기 값: {}", y);
    y = 6; // `y`는 가변이므로 재할당 가능
    println!("y의 변경된 값: {}", y);

    // 상수 (Constants): `const` 키워드를 사용하며, 타입 어노테이션이 필수이고, 대문자로 명명합니다.
    const MAX_POINTS: u32 = 100_000;
    println!("최대 점수: {}", MAX_POINTS);

    // --- 2. 섀도잉 (Shadowing) ---
    // 동일한 이름의 새 변수를 선언하여 이전 변수를 "가리는" 것.
    // `mut`과 달리 타입을 변경할 수도 있습니다.
    let z = 5;
    let z = z + 1; // z는 이제 6
    let z = z * 2; // z는 이제 12
    println!("섀도잉된 z의 값: {}", z);

    let spaces = "   ";
    let spaces = spaces.len(); // `spaces`는 이제 숫자
    println!("공백의 길이: {}", spaces);

    // --- 3. 자료형 (Data Types) ---
    // Rust는 정적 타입 언어이므로 컴파일 시 모든 변수의 타입을 알아야 합니다.
    // 대부분 타입 추론이 가능하지만, 필요한 경우 명시적 타입 어노테이션을 사용할 수 있습니다.

    // 정수형 (Integer Types): i8, i16, i32, i64, i128 (부호 있는), u8, u16, u32, u64, u128 (부호 없는)
    let guess: u32 = "42".parse().expect("숫자가 아닙니다!"); // 타입 어노테이션 필요
    println!("추측한 숫자: {}", guess);

    // 부동 소수점형 (Floating-Point Types): f32, f64
    let f1 = 2.0; // f64로 추론
    let f2: f32 = 3.0; // f32 타입 명시

    // 불리언형 (Boolean Type): bool
    let t = true;
    let f: bool = false;

    // 문자형 (Character Type): char (유니코드 스칼라 값)
    let c = 'z';
    let heart_eyed_cat = '😻';

    // 튜플형 (Tuple Type): 고정된 길이를 가진 이종 타입의 값들을 묶음
    let tup: (i32, f64, u8) = (500, 6.4, 1);
    let (x, y, z) = tup; // 구조 분해 할당 (destructuring)
    println!("튜플의 값: x={}, y={}, z={}", x, y, z);
    let five_hundred = tup.0; // 인덱스로 접근
    println!("튜플의 첫 번째 값: {}", five_hundred);

    // 배열형 (Array Type): 고정된 길이를 가진 동종 타입의 값들을 묶음
    let a = [1, 2, 3, 4, 5];
    let months = ["January", "February", "March", "April", "May", "June", "July",
                  "August", "September", "October", "November", "December"];
    let first_month = months[0];
    println!("배열의 첫 번째 요소: {}", first_month);

    // --- 4. 함수 (Functions) ---
    // `fn` 키워드로 정의. 매개변수에 타입 어노테이션 필수.
    // 반환 타입은 `->` 뒤에 명시. 마지막 표현식이 반환 값 (세미콜론 없음).
    another_function(5, 6);
    let result = five();
    println!("five()의 반환 값: {}", result);
    let plus_one_result = plus_one(5);
    println!("plus_one(5)의 반환 값: {}", plus_one_result);

    // --- 5. 제어 흐름 (Control Flow) ---

    // if/else 표현식
    let number = 3;
    if number < 5 {
        println!("조건이 5보다 작습니다.");
    } else {
        println!("조건이 5보다 크거나 같습니다.");
    }

    let condition = true;
    let num_if = if condition { 5 } else { 6 }; // if는 표현식으로 값 반환 가능
    println!("num_if의 값: {}", num_if);

    // loop 표현식 (무한 루프)
    let mut counter = 0;
    let loop_result = loop {
        counter += 1;
        if counter == 10 {
            break counter * 2; // break는 값 반환 가능
        }
    };
    println!("loop 결과: {}", loop_result);

    // while 루프
    let mut number_while = 3;
    while number_while != 0 {
        println!("{}!", number_while);
        number_while -= 1;
    }
    println!("LIFTOFF!!!");

    // for 루프 (컬렉션 순회)
    let arr_for = [10, 20, 30, 40, 50];
    for element in arr_for.iter() {
        println!("for 루프 요소: {}", element);
    }

    // 범위(Range)와 rev()를 사용한 역순 순회
    for number_for in (1..4).rev() {
        println!("{}!", number_for);
    }

    // --- 6. Cargo 사용법 (Rust의 빌드 시스템 및 패키지 매니저) ---
    println!("\n--- Cargo 사용법 ---");
    println!("`cargo new <프로젝트명>`: 새로운 Rust 프로젝트를 생성합니다.");
    println!("`cargo build`: 프로젝트를 빌드합니다.");
    println!("`cargo run`: 빌드 후 프로젝트를 실행합니다.");
    println!("`cargo check`: 코드를 컴파일하지만 실행 파일은 생성하지 않습니다. 빠른 오류 검사.");
    println!("`cargo test`: 프로젝트의 테스트를 실행합니다.");
    println!("`cargo update`: 의존성을 업데이트합니다.");
    println!("`cargo add <크레이트명>`: 새 의존성 크레이트를 추가합니다 (Rust 1.62+).");
    println!("`Cargo.toml` 파일에서 의존성 및 프로젝트 설정을 관리합니다.");
}

// 매개변수와 반환 타입이 있는 함수
fn another_function(x: i32, y: i32) {
    println!("\nanother_function 호출: x={}, y={}", x, y);
}

// 반환 값이 있는 함수 (마지막 표현식)
fn five() -> i32 {
    5 // 세미콜론이 없으면 표현식으로 간주하여 반환
}

fn plus_one(x: i32) -> i32 {
    x + 1 // 세미콜론이 없으면 표현식으로 간주하여 반환
}
