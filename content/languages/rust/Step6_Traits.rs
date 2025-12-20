// Rust Step 6: 트레잇 (Traits)
// 공유 동작을 정의하고 다형성을 구현하는 트레잇 학습

// 나쁜 예시: 모든 타입에 대해 동일한 기능을 개별적으로 구현하여 코드 중복을 초래하거나,
// 타입 간의 공통된 동작을 정의할 수 없어 유연성이 떨어짐.
// 좋은 예시: 트레잇을 사용하여 다양한 타입이 공유할 수 있는 동작을 정의하고,
// 제네릭과 함께 사용하여 코드 재사용성을 높이고 다형성을 구현.

// 학습 포인트: 트레잇은 Rust의 인터페이스와 유사하며, 공유 동작을 추상화하여 코드의 유연성과 재사용성을 높이는 강력한 메커니즘입니다.

// --- 1. 트레잇 정의 (Defining a Trait) ---
// 트레잇은 메서드 시그니처의 집합으로, 이 트레잇을 구현하는 모든 타입이 가져야 하는 동작을 정의합니다.
pub trait Summary {
    // 기본 구현(default implementation)을 제공할 수 있습니다.
    fn summarize_author(&self) -> String {
        String::from("(Read more from an unknown author)")
    }

    // 기본 구현이 없는 메서드
    fn summarize(&self) -> String;
}

// --- 2. 트레잇 구현 (Implementing a Trait) ---
// 특정 타입에 대해 트레잇의 메서드를 구현합니다.
pub struct NewsArticle {
    pub headline: String,
    pub location: String,
    pub author: String,
    pub content: String,
}

impl Summary for NewsArticle {
    fn summarize(&self) -> String {
        format!("{}, by {} ({})", self.headline, self.author, self.location)
    }

    fn summarize_author(&self) -> String {
        format!("@{}", self.author)
    }
}

pub struct Tweet {
    pub username: String,
    pub content: String,
    pub reply: bool,
    pub retweet: bool,
}

impl Summary for Tweet {
    fn summarize(&self) -> String {
        format!("{}: {}", self.username, self.content)
    }
}

// --- 3. 트레잇을 매개변수로 사용 (Trait as Parameters) ---
// 함수 매개변수에 트레잇 바운드(trait bound)를 사용하여 특정 트레잇을 구현하는 모든 타입을 받을 수 있습니다.
// 이는 다른 언어의 '인터페이스를 매개변수로 받는 것'과 유사한 다형성을 제공합니다.

// 3-1. `impl Trait` 구문 (간결한 문법)
pub fn notify_impl_trait(item: &impl Summary) { // Summary 트레잇을 구현하는 어떤 타입의 참조든 받을 수 있습니다.
    println!("속보! {}", item.summarize());
}

// 3-2. 트레잇 바운드 구문 (명시적인 문법)
// `pub fn notify_trait_bound<T: Summary>(item: &T)`
pub fn notify_trait_bound<T>(item: &T)
where
    T: Summary, // `where` 절을 사용하여 트레잇 바운드 명시
{
    println!("최신 뉴스! {}", item.summarize());
}

// 여러 트레잇 바운드 지정
// pub fn notify_multiple(item: &(impl Summary + Display)) { ... }
// pub fn notify_multiple<T: Summary + Display>(item: &T) { ... }
// pub fn notify_multiple<T>(item: &T) where T: Summary + Display { ... }

// --- 4. 트레잇을 반환 타입으로 사용 (Returning Trait) ---
// `impl Trait` 구문을 사용하여 트레잇을 구현하는 어떤 타입이든 반환할 수 있습니다.
// 단, 반환하는 모든 타입은 동일해야 합니다.
fn returns_summarizable() -> impl Summary {
    Tweet {
        username: String::from("horse_ebooks"),
        content: String::from("of course, as you probably already know, people"),
        reply: false,
        retweet: false,
    }
}

// --- 5. 트레잇의 기본 구현 오버라이딩 ---
// `NewsArticle`에서 `summarize_author`를 오버라이딩한 것을 확인할 수 있습니다.

fn main() {
    let tweet = Tweet {
        username: String::from("rustacean"),
        content: String::from("Rust 트레잇은 정말 강력해요!"),
        reply: false,
        retweet: false,
    };
    println!("트윗 요약: {}", tweet.summarize());
    println!("트윗 저자: {}", tweet.summarize_author());

    let article = NewsArticle {
        headline: String::from("펭귄, 남극에서 새로운 기술 발견!"),
        location: String::from("남극"),
        author: String::from("기자 박철수"),
        content: String::from("남극의 펭귄들이 놀라운 기술을 발견했다는 소식입니다..."),
    };
    println!("기사 요약: {}", article.summarize());
    println!("기사 저자: {}", article.summarize_author()); // 오버라이딩된 구현 사용

    // 트레잇을 매개변수로 사용하는 함수 호출
    notify_impl_trait(&tweet);
    notify_trait_bound(&article);

    // 트레잇을 반환하는 함수 호출
    let item = returns_summarizable();
    println!("반환된 아이템 요약: {}", item.summarize());

    // --- 6. 파생 트레잇 (Derive Traits) ---
    // Rust는 일부 트레잇을 `#[derive]` 속성을 사용하여 자동으로 구현해줍니다.
    // (예: `Debug`, `Clone`, `Copy`, `PartialEq`, `Eq`, `PartialOrd`, `Ord`, `Hash`)
    #[derive(Debug, PartialEq, Clone, Copy)] // Debug, PartialEq, Clone, Copy 트레잇 자동 구현
    struct Point {
        x: i32,
        y: i32,
    }

    let p1 = Point { x: 1, y: 2 };
    let p2 = Point { x: 1, y: 2 };
    let p3 = Point { x: 3, y: 4 };

    println!("p1: {:?}", p1);
    println!("p1 == p2: {}", p1 == p2); // PartialEq 덕분에 비교 가능
    let p1_clone = p1.clone(); // Clone 덕분에 복제 가능
    println!("p1_clone: {:?}", p1_clone);

    // --- 7. 고립 규칙 (Orphan Rule) ---
    // 트레잇을 구현할 때, 해당 트레잇이나 타입 중 적어도 하나는 현재 크레이트(crate)에서 정의되어야 합니다.
    // 즉, 외부 트레잇을 외부 타입에 구현할 수 없습니다. (예: `std::Vec`에 `Summary` 트레잇 구현 불가)
    // 이는 다른 크레이트들이 기존 타입에 새로운 동작을 정의하여 충돌하는 것을 방지합니다.

    // 학습 포인트: 트레잇은 Rust의 제네릭 프로그래밍, 다형성, 그리고 코드 재사용의 핵심입니다.
    // `impl Trait` 구문은 간결함을 제공하며, 트레잇 바운드는 더 명시적인 제약을 줍니다.
    // 기본 구현을 제공하여 중복 코드를 줄일 수도 있습니다.
}
