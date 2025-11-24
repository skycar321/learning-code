// Rust Step 9: 테스트와 문서화 (Testing & Documentation)
// 단위 테스트, 통합 테스트 작성 및 `cargo doc`을 활용한 문서화

// 나쁜 예시: 테스트 코드를 작성하지 않거나, 문서화를 소홀히 하여 코드 변경 시 버그 발생 가능성 높고,
// 다른 개발자가 코드를 이해하고 사용하기 어려움.
// 좋은 예시: 견고한 테스트 스위트를 구축하여 코드의 정확성을 보장하고,
// Rust의 문서화 도구를 활용하여 코드를 쉽게 이해하고 사용할 수 있도록 함.

// 학습 포인트: 테스트와 문서화는 소프트웨어 품질을 보장하고 개발 효율성을 높이는 데 필수적입니다.

// --- 1. 테스트 (Testing) ---
// Rust는 `cargo test` 명령어를 사용하여 테스트를 실행합니다.

// 1-1. 단위 테스트 (Unit Tests)
// - 개별적인, 격리된 코드 단위를 테스트합니다.
// - 일반적으로 테스트 대상 코드와 동일한 파일에 `#[cfg(test)]` 속성을 가진 모듈 내부에 작성합니다.
// - `assert!`, `assert_eq!`, `assert_ne!` 등의 매크로를 사용하여 예상 결과와 실제 결과를 비교합니다.

pub fn add_two(a: i32) -> i32 {
    a + 2
}

#[cfg(test)] // 이 모듈은 `cargo test`를 실행할 때만 컴파일됩니다.
mod tests {
    use super::*; // 부모 모듈의 아이템(예: add_two 함수)을 현재 스코프로 가져옵니다.

    #[test] // 이 함수가 테스트 함수임을 나타냅니다.
    fn it_adds_two() {
        assert_eq!(4, add_two(2)); // `assert_eq!` 매크로 사용
    }

    #[test]
    fn another_test() {
        assert_ne!(5, add_two(2)); // `assert_ne!` 매크로 사용
    }

    #[test]
    #[should_panic(expected = "값을 0으로 나눌 수 없습니다.")] // 패닉이 발생하는 테스트
    fn test_divide_by_zero_panic() {
        divide(10, 0);
    }

    #[test]
    #[ignore] // `cargo test -- --ignored`로만 실행
    fn expensive_test() {
        // 이 테스트는 실행 시간이 오래 걸리므로 기본적으로 무시합니다.
        println!("매우 비싼 테스트 실행!");
        assert!(true);
    }
}

// `panic!`이 발생하는 함수
fn divide(numerator: i32, denominator: i32) -> i32 {
    if denominator == 0 {
        panic!("값을 0으로 나눌 수 없습니다.");
    }
    numerator / denominator
}

// 1-2. 통합 테스트 (Integration Tests)
// - 라이브러리의 공용 API를 외부에서 사용하는 것처럼 테스트합니다.
// - `tests` 디렉토리 (크레이트 루트의 `src`와 동일 레벨) 내부에 별도의 파일로 작성합니다.
// - `cargo test` 명령어가 자동으로 이 파일들을 찾아 테스트합니다.

// (src/lib.rs 파일에 정의된 라이브러리 함수라고 가정)
// pub fn greeting(name: &str) -> String {
//     format!("Hello, {}!", name)
// }

// (tests/integration_test.rs 파일에 작성)
/*
use my_crate::greeting; // 라이브러리 크레이트 이름으로 함수를 가져옵니다.

#[test]
fn test_greeting_with_name() {
    assert_eq!(greeting("Alice"), "Hello, Alice!");
}
*/

// --- 2. 문서화 (Documentation) ---
// Rust는 `///`로 작성된 문서 주석을 사용하여 코드를 문서화합니다.
// `cargo doc` 명령어를 사용하여 HTML 형식의 문서 사이트를 생성할 수 있습니다.

/// 주어진 두 숫자의 합을 반환하는 함수입니다.
///
/// # 예시 (Examples)
/// ```
/// let result = my_crate::add(2, 3);
/// assert_eq!(result, 5);
/// ```
///
/// # 파라미터 (Parameters)
/// * `a`: 첫 번째 숫자 (i32)
/// * `b`: 두 번째 숫자 (i32)
///
/// # 반환 (Returns)
/// 두 숫자의 합 (i32)
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}

/// `Article`은 뉴스 기사를 표현하는 구조체입니다.
///
/// 이 구조체는 뉴스 기사의 제목, 작성자, 내용 등을 저장합니다.
pub struct Article {
    /// 기사의 제목입니다.
    pub title: String,
    /// 기사의 작성자입니다.
    pub author: String,
    /// 기사의 내용입니다.
    pub content: String,
}

impl Article {
    /// 새로운 `Article` 인스턴스를 생성합니다.
    ///
    /// # 파라미터 (Parameters)
    /// * `title`: 기사의 제목
    /// * `author`: 기사의 작성자
    /// * `content`: 기사의 내용
    ///
    /// # 반환 (Returns)
    /// 새로 생성된 `Article` 인스턴스
    pub fn new(title: String, author: String, content: String) -> Article {
        Article { title, author, content }
    }

    /// 기사의 전문을 반환합니다.
    pub fn get_full_text(&self) -> String {
        format!("{} - By {}: {}", self.title, self.author, self.content)
    }
}


fn main() {
    println!("테스트와 문서화 예시를 확인하세요.");
    println!("`cargo test` 명령어로 단위 및 통합 테스트를 실행할 수 있습니다.");
    println!("`cargo doc --open` 명령어로 HTML 문서를 생성하고 브라우저에서 열 수 있습니다.");

    let article = Article::new(
        String::from("Rust 언어 소개"),
        String::from("김러스트"),
        String::from("Rust는 성능, 안전성, 동시성을 목표로 하는 프로그래밍 언어입니다.")
    );
    println!("{}", article.get_full_text());

    // 테스트 함수는 `main` 함수가 실행될 때 컴파일되지 않습니다.
    // `cargo test` 명령어로만 실행됩니다.
}
