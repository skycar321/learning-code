// Rust Step 8: 모듈 시스템 (Modules)
// 코드 조직화를 위한 모듈, 크레이트, 패키지 시스템 이해

// 나쁜 예시: 모든 코드를 하나의 파일에 작성하여 코드량이 많아지고 재사용성 및 유지보수성 저해.
// 좋은 예시: 모듈 시스템을 사용하여 코드를 논리적으로 분리하고, 공개/비공개 범위를 명확히 하며,
// Cargo 패키지 시스템을 통해 의존성을 효율적으로 관리.

// 학습 포인트: Rust의 모듈 시스템은 코드의 구조화, 재사용성, 그리고 접근 제어를 위한 핵심 기능입니다.

// --- 1. 크레이트 (Crates) ---
// Rust에서 컴파일 단위 (코드의 가장 작은 단위).
// - **바이너리 크레이트 (Binary Crate)**: 실행 가능한 프로그램을 생성합니다. `main` 함수를 포함.
// - **라이브러리 크레이트 (Library Crate)**: 다른 프로그램에서 사용할 수 있는 라이브러리를 생성합니다. `main` 함수 없음.
// `Cargo.toml` 파일의 `[lib]` 또는 `[bin]` 섹션에 정의됩니다.

// --- 2. 패키지 (Packages) ---
// 하나 이상의 크레이트(라이브러리/바이너리)와 `Cargo.toml` 파일로 구성됩니다.
// `Cargo.toml`은 패키지의 메타데이터와 의존성 정보를 포함합니다.

// --- 3. 모듈 (Modules) ---
// 크레이트 내부에서 코드를 조직화하는 단위.
// - `mod` 키워드를 사용하여 정의.
// - 파일 시스템 구조를 따라갈 수도 있습니다 (예: `src/lib.rs`는 루트 모듈).
// - `pub` 키워드를 사용하여 외부로 공개. 기본적으로 모든 것은 비공개.

// --- 모듈 예시 (main.rs 또는 lib.rs 내에서) ---

// `front_of_house`라는 모듈 정의
mod front_of_house {
    pub mod hosting { // `hosting` 모듈은 `front_of_house` 외부에서 `pub`으로 접근 가능
        pub fn add_to_waitlist() { // `add_to_waitlist` 함수는 `hosting` 외부에서 `pub`으로 접근 가능
            println!("테이블 대기 목록에 추가됨.");
            seat_at_table(); // 동일 모듈 내 함수 호출
        }

        fn seat_at_table() { // 이 함수는 `hosting` 모듈 내부에서만 접근 가능
            println!("손님을 테이블에 앉힘.");
        }
    }

    mod serving { // `serving` 모듈은 `front_of_house` 내부에서만 접근 가능
        fn take_order() {
            println!("주문 받음.");
        }
        fn serve_order() {
            println!("주문 서빙.");
        }
        fn take_payment() {
            println!("결제 받음.");
        }
    }
}

// --- `use` 키워드 ---
// 모듈 경로를 짧게 만들어 코드 가독성을 높입니다.
// `use`는 경로를 스코프로 가져오는 것이지, 아이템을 공개(public)하는 것이 아닙니다.
use crate::front_of_house::hosting; // `crate`는 현재 크레이트의 루트를 의미.

fn main() {
    println!("--- Rust 모듈 시스템 ---");

    // `front_of_house` 모듈의 `hosting` 모듈에 있는 `add_to_waitlist` 함수 호출
    // `use` 키워드를 사용했으므로 `hosting::add_to_waitlist()`로 호출 가능
    hosting::add_to_waitlist();

    // `use` 키워드 없이 전체 경로를 사용하여 호출
    crate::front_of_house::hosting::add_to_waitlist();

    // --- `super` 키워드 ---
    // 현재 모듈의 부모 모듈을 참조합니다.

    // --- `pub use` (Re-exporting) ---
    // `pub use`는 아이템을 현재 스코프에 가져오고, 동시에 다른 코드도 이 아이템을 가져갈 수 있도록 공개합니다.
    pub mod customer_service {
        // `hosting` 모듈을 `customer_service` 모듈의 일부로 가져오고, 외부로도 공개합니다.
        pub use crate::front_of_house::hosting;

        pub fn serve_customer() {
            hosting::add_to_waitlist(); // `use` 덕분에 짧은 경로로 호출
            println!("고객 응대 완료.");
        }
    }
    customer_service::serve_customer();

    // --- 파일 시스템으로 모듈 분리 ---
    // 모듈이 커지면 별도의 파일로 분리하는 것이 일반적입니다.
    // - `src/main.rs` (또는 `src/lib.rs`)는 크레이트 루트입니다.
    // - `mod garden;`을 `src/main.rs`에 선언하면 `garden` 모듈을 정의하고
    //   `src/garden.rs` 또는 `src/garden/mod.rs` 파일을 찾습니다.

    // 예시: `src/garden.rs` 파일이 있다고 가정
    // pub mod garden {
    //     pub struct Vegetable {
    //         pub name: String,
    //         id: i32,
    //     }
    //     impl Vegetable {
    //         pub fn new(name: String) -> Vegetable {
    //             Vegetable { name, id: 1 }
    //         }
    //     }
    // }
    //
    // fn main() {
    //     let plant = garden::Vegetable::new(String::from("당근"));
    //     println!("이 식물의 이름은 {}입니다.", plant.name);
    //     // println!("이 식물의 ID는 {}입니다.", plant.id); // Error: `id`는 비공개 필드입니다.
    // }

    // --- `pub(crate)` 와 `pub(super)` ---
    // 더 세밀한 접근 제어를 위해 사용됩니다.
    // `pub(crate)`: 현재 크레이트 내에서만 공개.
    // `pub(super)`: 부모 모듈 내에서만 공개.

    // --- Cargo.toml과 의존성 관리 ---
    // `Cargo.toml` 파일의 `[dependencies]` 섹션에 외부 크레이트를 추가합니다.
    // [dependencies]
    // rand = "0.8.5"
    //
    // 이후 `use rand::Rng;` 와 같이 사용 가능합니다.
    use rand::Rng;
    let secret_number = rand::thread_rng().gen_range(1..=100);
    println!("생성된 비밀 숫자 (rand 크레이트 사용): {}", secret_number);


    // 학습 포인트: Rust의 모듈 시스템은 코드를 체계적으로 정리하고, 공개/비공개 범위를 명확히 하여
    // 대규모 프로젝트의 관리와 협업을 용이하게 합니다.
    // `pub`과 `use` 키워드를 적절히 사용하여 접근성과 가독성을 높이는 것이 중요합니다.
}
