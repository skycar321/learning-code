// Rust Step 7: 제네릭과 생명 주기 (Generics & Lifetimes)
// 코드 재사용성과 타입 안전성을 높이는 제네릭 및 생명 주기 심화 학습

// 나쁜 예시: `any` 타입 대신 모든 타입에 대해 코드를 중복해서 작성하여 유지보수성 저해.
// 좋은 예시: 제네릭을 사용하여 여러 타입에서 동작하는 재사용 가능한 함수, 구조체, 열거형, 트레잇을 만들고,
// 생명 주기를 명시하여 참조의 유효성을 컴파일 타임에 보장.

// 학습 포인트: 제네릭은 코드의 중복을 줄이고 추상화를 높여주며, 생명 주기는 Rust의 메모리 안전성 규칙을 컴파일러에게 알려줍니다.

// --- 1. 제네릭 (Generics) ---
// 여러 타입에서 동작하는 코드 요소를 정의할 수 있게 해주는 기능.
// 함수, 구조체, 열거형, 메서드, 트레잇 정의에 사용됩니다.

// 1-1. 제네릭 함수
// `T`는 타입 매개변수 (Type Parameter)
fn largest<T: PartialOrd + Copy>(list: &[T]) -> T { // `PartialOrd`와 `Copy` 트레잇 바운드
    let mut largest = list[0];
    for &item in list.iter() {
        if item > largest {
            largest = item;
        }
    }
    largest
}

// `Clone` 대신 `Copy` 트레잇 바운드를 사용하는 것이 더 효율적일 수 있습니다.
// `Copy`는 비트 단위 복사, `Clone`은 깊은 복사 (힙 데이터까지 복사)
fn largest_clone<T: PartialOrd + Clone>(list: &[T]) -> T {
    let mut largest = list[0].clone();
    for item in list.iter() {
        if item.clone() > largest { // `item`은 참조이므로 `clone()`으로 역참조 후 복사
            largest = item.clone();
        }
    }
    largest
}

// 1-2. 제네릭 구조체
struct Point<T, U> {
    x: T,
    y: U,
}

impl<T, U> Point<T, U> {
    fn mixup<V, W>(self, other: Point<V, W>) -> Point<T, W> {
        Point {
            x: self.x,
            y: other.y,
        }
    }
}

// 1-3. 제네릭 열거형
// `Option<T>`와 `Result<T, E>`는 이미 제네릭 열거형입니다.
// enum Option<T> { Some(T), None, }
// enum Result<T, E> { Ok(T), Err(E), }

// --- 2. 생명 주기 (Lifetimes) ---
// Rust 컴파일러가 참조가 유효한 기간(스코프)을 알 수 있도록 하는 기능.
// Dangling References를 방지하여 메모리 안전성을 보장합니다.
// 모든 참조에는 생명 주기가 있습니다. 대부분은 컴파일러가 추론합니다.
// 함수 시그니처에서 생명 주기를 명시해야 하는 경우는 주로 "두 개 이상의 참조를 인자로 받고, 반환 값도 참조인 경우" 입니다.

// 2-1. 생명 주기 어노테이션 (`'a`)
// `'a`는 생명 주기 매개변수입니다. `'a`는 '어떤 생명 주기'를 의미합니다.
// 이 함수는 `x`와 `y`의 생명 주기 중 더 짧은 생명 주기 동안만 유효한 참조를 반환합니다.
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}

// 2-2. 구조체 정의의 생명 주기 어노테이션
// 구조체가 참조를 저장할 경우, 해당 참조의 생명 주기를 명시해야 합니다.
struct ImportantExcerpt<'a> {
    part: &'a str,
}

// 2-3. 생명 주기 생략 규칙 (Lifetime Elision Rules)
// 컴파일러는 특정 패턴에서 생명 주기를 자동으로 추론합니다.
// - 입력 생명 주기 규칙:
//   - 각 입력 매개변수에 고유한 생명 주기 매개변수가 할당됩니다.
//   - 입력 매개변수가 하나뿐이면, 그 생명 주기가 모든 출력 생명 주기에 할당됩니다.
//   - 여러 입력 생명 주기 매개변수가 있지만 그 중 하나가 `&self` 또는 `&mut self`라면, `self`의 생명 주기가 모든 출력 생명 주기에 할당됩니다.
// - 위 규칙으로 생명 주기를 추론할 수 없을 때만 수동으로 어노테이션을 추가해야 합니다.

fn main() {
    // 제네릭 함수 사용
    let number_list = vec![34, 50, 25, 100, 65];
    let result_num = largest(&number_list);
    println!("가장 큰 숫자: {}", result_num);

    let char_list = vec!['y', 'm', 'a', 'q'];
    let result_char = largest(&char_list);
    println!("가장 큰 문자: {}", result_char);

    // 제네릭 구조체 사용
    let integer_and_float_point = Point { x: 5, y: 10.4 };
    let integer_point = Point { x: 5, y: 10 };
    println!("integer_point: x={}, y={}", integer_point.x, integer_point.y);

    let p1 = Point { x: 5, y: 10.4 };
    let p2 = Point { x: "Hello", y: 'c' };
    let p3 = p1.mixup(p2);
    println!("p3.x = {}, p3.y = {}", p3.x, p3.y);


    // 생명 주기 사용
    let string1 = String::from("Long string is long");
    {
        let string2 = String::from("xyz");
        let result = longest(string1.as_str(), string2.as_str());
        println!("더 긴 문자열: {}", result);
    }
    // string2는 이 스코프 밖에서 드롭되지만, longest가 반환한 result는 string1의 생명 주기를 따르므로 유효합니다.

    let novel = String::from("Call me Ishmael. Some years ago...");
    let first_sentence = novel.split('.').next().expect("점 '.'을 찾을 수 없습니다.");
    let i = ImportantExcerpt {
        part: first_sentence,
    };
    println!("중요 발췌문: {}", i.part);

    // 학습 포인트: 제네릭과 생명 주기는 Rust의 안전하고 고성능의 코드를 작성하는 데 필수적인 개념입니다.
    // 제네릭은 코드의 추상화와 재사용성을 높여주며, 생명 주기는 컴파일 타임에 메모리 안전성을 보장합니다.
    // 이 두 가지를 올바르게 사용하는 것은 Rust의 진정한 강점을 활용하는 방법입니다.
}
