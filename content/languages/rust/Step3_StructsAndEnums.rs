// Rust Step 3: 구조체와 열거형 (Structs & Enums)
// 사용자 정의 타입을 정의하고 패턴 매칭을 통해 데이터 처리

// 나쁜 예시: 관련된 데이터들을 개별 변수로 관리하여 코드의 응집도를 떨어뜨리고,
// 여러 가지 상태를 마법의 숫자나 문자열로 표현하여 가독성 저해.
// 좋은 예시: 구조체를 사용하여 관련된 데이터들을 하나의 단위로 묶고,
// 열거형을 사용하여 가능한 값의 집합을 명확히 정의하여 타입 안전성과 가독성을 높임.

// 학습 포인트: 구조체와 열거형은 Rust에서 복잡한 데이터를 모델링하는 기본 블록입니다.

// --- 1. 구조체 (Structs) ---
// 관련된 데이터들을 이름으로 묶어 하나의 사용자 정의 타입을 만듭니다.

// 1-1. 필드(field)를 가진 구조체
#[derive(Debug)] // 디버그 출력을 위한 Trait 자동 구현
struct User {
    active: bool,
    username: String,
    email: String,
    sign_in_count: u64,
}

fn main() {
    let user1 = User {
        active: true,
        username: String::from("someuser123"),
        email: String::from("someone@example.com"),
        sign_in_count: 1,
    };

    println!("사용자 1 이름: {}", user1.username);
    // user1.active = false; // 에러: 구조체 인스턴스는 기본적으로 불변입니다.
    // user1.username = String::from("anotheruser"); // 에러: 구조체 인스턴스는 기본적으로 불변입니다.

    // 가변 구조체 인스턴스
    let mut user2 = User {
        active: true,
        username: String::from("anotheruser456"),
        email: String::from("another@example.com"),
        sign_in_count: 5,
    };
    user2.active = false; // 가변이므로 변경 가능
    user2.email = String::from("newemail@example.com");
    println!("사용자 2의 새 이메일: {}", user2.email);

    // 구조체 업데이트 문법 (Struct Update Syntax)
    // 기존 구조체의 일부 필드만 변경하고 싶을 때 유용
    let user3 = User {
        email: String::from("third@example.com"),
        ..user1 // user1의 나머지 필드들을 복사 (user1의 소유권은 이동됨)
    };
    // println!("User1: {:?}", user1); // 에러: user1의 소유권이 user3으로 이동됨.
    println!("User3: {:?}", user3); // {:?}는 Debug Trait을 사용하여 구조체 전체를 출력

    // 1-2. 튜플 구조체 (Tuple Structs)
    // 이름 없는 필드를 가진 튜플과 유사한 구조체. 주로 튜플에 이름을 부여할 때 사용.
    struct Color(i32, i32, i32);
    struct Point(i32, i32, i32);

    let black = Color(0, 0, 0);
    let origin = Point(0, 0, 0);
    // let x = black; // 에러: 서로 다른 타입의 튜플 구조체이므로 직접 대입 불가

    // 1-3. 유닛-라이크 구조체 (Unit-Like Structs)
    // 필드가 없는 구조체. 주로 Trait을 구현할 때 사용.
    struct AlwaysEqual;
    let subject = AlwaysEqual;

    // --- 2. 열거형 (Enums) ---
    // 특정 값들 중 하나를 나타내는 타입을 정의합니다.

    // 2-1. 단순 열거형
    enum IpAddrKind {
        V4,
        V6,
    }

    let four = IpAddrKind::V4;
    let six = IpAddrKind::V6;

    // 2-2. 열거형에 데이터 포함
    // 열거형의 각 variant(변형)에 서로 다른 타입의 데이터를 직접 저장할 수 있습니다.
    #[derive(Debug)]
    enum IpAddr {
        V4(String), // V4 variant는 String을 가집니다.
        V6(String), // V6 variant도 String을 가집니다.
    }

    let home = IpAddr::V4(String::from("127.0.0.1"));
    let loopback = IpAddr::V6(String::from("::1"));
    println!("홈 주소: {:?}", home);
    println!("루프백 주소: {:?}", loopback);

    // 더 복잡한 열거형 예시: 메시지 타입
    #[derive(Debug)]
    enum Message {
        Quit,                            // 데이터 없음
        Move { x: i32, y: i32 },         // 익명 구조체 포함
        Write(String),                   // String 포함
        ChangeColor(i32, i32, i32),      // 튜플 포함
    }

    let m1 = Message::Quit;
    let m2 = Message::Move { x: 10, y: 20 };
    let m3 = Message::Write(String::from("hello"));
    let m4 = Message::ChangeColor(255, 0, 0);

    println!("메시지: {:?}, {:?}, {:?}, {:?}", m1, m2, m3, m4);

    // 2-3. `impl`을 이용한 열거형 메서드
    impl Message {
        fn call(&self) {
            match self {
                Message::Quit => println!("Quit 메시지 호출."),
                Message::Move { x, y } => println!("Move 메시지 호출: x={}, y={}", x, y),
                Message::Write(text) => println!("Write 메시지 호출: {}", text),
                Message::ChangeColor(r, g, b) => println!("ChangeColor 메시지 호출: r={}, g={}, b={}", r, g, b),
            }
        }
    }
    m2.call();
    m3.call();

    // --- 3. `match` 표현식과 패턴 매칭 (Pattern Matching) ---
    // 열거형 값을 처리할 때 `match` 표현식을 사용하여 가능한 모든 variant를 처리합니다.
    // `match`는 철저해야 합니다 (모든 경우를 커버해야 함).
    fn route(ip_kind: IpAddrKind) {
        match ip_kind {
            IpAddrKind::V4 => println!("IPv4 주소입니다."),
            IpAddrKind::V6 => println!("IPv6 주소입니다."),
        }
    }
    route(four);
    route(six);

    // `Option` 열거형 (표준 라이브러리)
    // `Option<T>`는 값이 있거나 없을 수 있음을 나타내는 열거형.
    // `Some(T)`: 값이 존재함. `None`: 값이 없음.
    // 이는 다른 언어의 `null` 개념을 안전하게 처리하는 Rust 방식입니다.
    let some_number = Some(5);
    let some_char = Some('e');
    let no_number: Option<i32> = None; // None을 사용할 때는 타입을 명시해야 합니다.

    // `match`와 `Option`
    fn plus_one_option(x: Option<i32>) -> Option<i32> {
        match x {
            None => None, // None이면 None 반환
            Some(i) => Some(i + 1), // Some(값)이면 값에 1을 더하여 Some으로 반환
        }
    }
    let five_opt = Some(5);
    let six_opt = plus_one_option(five_opt);
    let none_opt = plus_one_option(None);

    println!("five_opt: {:?}", five_opt);
    println!("six_opt: {:?}", six_opt);
    println!("none_opt: {:?}", none_opt);

    // `if let` (한 가지 경우만 처리하고 싶을 때)
    if let Some(value) = five_opt {
        println!("five_opt의 값: {}", value);
    } else {
        println!("five_opt는 None입니다.");
    }

    // 학습 포인트: 구조체와 열거형은 데이터 모델링과 타입 안전성 보장에 중요한 역할을 합니다.
    // 특히 열거형과 `match` 표현식은 강력한 패턴 매칭 기능을 제공하여 코드를 간결하고 안전하게 만듭니다.
    // `Option` 열거형을 통해 `null` 관련 오류를 컴파일 시점에 방지할 수 있습니다.
}
