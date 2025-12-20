// Rust Step 4: 에러 처리 (Error Handling)
// `Result`와 `Option` 열거형을 이용한 견고한 에러 처리

// 나쁜 예시: 에러를 무시하거나 `panic!`을 남용하여 프로그램이 예상치 못하게 종료.
// 좋은 예시: `Option`과 `Result` 열거형을 사용하여 에러 발생 가능성을 명시하고,
// `match`, `if let`, `?` 연산자 등으로 에러를 예측 가능하고 안전하게 처리.

// 학습 포인트: Rust는 `null`이나 예외(Exception) 대신 `Option`과 `Result`라는 열거형을 통해 에러를 명시적으로 처리합니다.

use std::fs::File;
use std::io::{self, Read}; // io 모듈에서 self(모듈 자체)와 Read 트레잇을 가져옵니다.

fn main() {
    // --- 1. `panic!` (복구 불가능한 에러) ---
    // 복구할 수 없는 심각한 버그나 프로그램의 논리적 오류가 발생했을 때 사용합니다.
    // `panic!`이 호출되면 프로그램은 스택을 풀고 종료됩니다.
    // 일반적으로 라이브러리 개발 시 사용자가 잘못된 값을 전달할 때 사용됩니다.

    // panic!("복구 불가능한 에러 발생!"); // 이 코드가 실행되면 프로그램은 즉시 종료됩니다.

    // 배열 인덱스 초과 접근 시 `panic!` 발생 (Rust가 자동으로 처리)
    let v = vec![1, 2, 3];
    // v[99]; // 런타임에 panic! 발생: index out of bounds

    // --- 2. `Option<T>` (값이 없음을 표현) ---
    // 값이 존재할 수도 있고 (`Some(T)`), 존재하지 않을 수도 있음 (`None`).
    // 다른 언어의 `null`을 대체하는 안전한 방식.

    let some_number = Some(5); // Option<i32>
    let some_string = Some("a string"); // Option<&str>
    let no_number: Option<i32> = None; // None을 사용할 때는 타입을 명시해야 함

    // `match`를 사용하여 `Option` 값 처리 (철저해야 함)
    fn plus_one(x: Option<i32>) -> Option<i32> {
        match x {
            None => {
                println!("입력값이 None입니다.");
                None
            },
            Some(i) => {
                println!("입력값: {}", i);
                Some(i + 1)
            },
        }
    }

    let five = Some(5);
    let six = plus_one(five);
    let none = plus_one(None);
    println!("five: {:?}, six: {:?}, none: {:?}", five, six, none);

    // `if let`을 사용하여 특정 `Some` 값만 처리 (간결)
    if let Some(val) = five {
        println!("if let으로 얻은 값: {}", val);
    } else {
        println!("if let: 값이 없습니다.");
    }

    // `unwrap()`과 `expect()` (값 강제 추출)
    // `Some` 값을 강제로 추출합니다. `None`일 경우 `panic!` 발생.
    // `unwrap()`: `None`일 경우 기본 `panic!` 메시지.
    // `expect("메시지")`: `None`일 경우 지정된 메시지와 함께 `panic!`.
    let unwrapped_five = five.unwrap();
    println!("unwrap으로 얻은 값: {}", unwrapped_five);
    // let unwrapped_none = none.unwrap(); // 런타임에 panic! 발생
    // let expected_none = none.expect("이 값은 반드시 존재해야 합니다!"); // 런타임에 panic! 발생

    // --- 3. `Result<T, E>` (복구 가능한 에러 표현) ---
    // 성공적인 값 (`Ok(T)`) 또는 에러 (`Err(E)`) 중 하나를 반환할 수 있는 열거형.
    // 파일 입출력, 네트워크 통신 등 실패할 가능성이 있는 작업에 사용.

    // 파일 열기 예시 (`Result<File, Error>`)
    let greeting_file_result = File::open("hello.txt");

    let greeting_file = match greeting_file_result {
        Ok(file) => {
            println!("파일을 성공적으로 열었습니다.");
            file
        },
        Err(error) => match error.kind() {
            // 파일을 찾을 수 없을 때만 파일을 생성
            io::ErrorKind::NotFound => match File::create("hello.txt") {
                Ok(fc) => {
                    println!("hello.txt 파일을 생성했습니다.");
                    fc
                },
                Err(e) => panic!("파일 생성 실패: {:?}", e),
            },
            // 다른 종류의 에러는 `panic!`
            other_error => panic!("파일 열기 실패: {:?}", other_error),
        },
    };
    // greeting_file 변수를 사용하거나, 단순히 예외 처리 로직으로만 활용.


    // --- 4. 에러 전파 (Propagating Errors) ---
    // `?` 연산자를 사용하여 `Result` 값을 간결하게 처리하고 에러를 호출자에게 전파합니다.
    // `?`는 `Result::Err`이면 `return Err(e)`를, `Result::Ok`이면 `Ok` 값을 추출합니다.
    fn read_username_from_file() -> Result<String, io::Error> {
        let mut f = File::open("username.txt")?; // 에러 발생 시 즉시 반환
        let mut username = String::new();
        f.read_to_string(&mut username)?; // 에러 발생 시 즉시 반환
        Ok(username) // 성공 시 Ok 값 반환
    }

    // 위 함수와 동일한 `match` 표현식
    // fn read_username_from_file_verbose() -> Result<String, io::Error> {
    //     let f_result = File::open("username.txt");
    //     let mut f = match f_result {
    //         Ok(file) => file,
    //         Err(e) => return Err(e),
    //     };
    //     let mut username = String::new();
    //     match f.read_to_string(&mut username) {
    //         Ok(_) => Ok(username),
    //         Err(e) => Err(e),
    //     }
    // }

    let username_result = read_username_from_file();
    match username_result {
        Ok(name) => println!("사용자 이름: {}", name),
        Err(e) => println!("사용자 이름 읽기 실패: {:?}", e),
    }

    // `.map_err()` 또는 `.and_then()` 등을 활용한 에러 처리 (고급)
    // `std::fs::read_to_string` 함수는 위 코드를 더 간결하게 만듭니다.
    let username_simple_result = std::fs::read_to_string("username_simple.txt");
    match username_simple_result {
        Ok(name) => println!("간결한 사용자 이름: {}", name),
        Err(e) => println!("간결한 사용자 이름 읽기 실패: {:?}", e),
    }

    // 학습 포인트: Rust의 에러 처리 전략은 `Option`과 `Result` 열거형을 중심으로 컴파일 타임에 에러를 강제합니다.
    // `unwrap()`과 `expect()`는 개발 초기에 프로토타이핑을 위해 사용하거나, 복구할 수 없는 에러에만 사용하고,
    // 프로덕션 코드에서는 `match`, `if let`, `?` 연산자를 사용하여 에러를 명시적으로 처리하는 것이 중요합니다.
}
