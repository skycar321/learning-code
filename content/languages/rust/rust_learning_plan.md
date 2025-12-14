# 실무 Rust 코드 학습 계획

Rust의 소유권/빌림 모델을 이해하고 안전한 시스템 코드를 작성하기 위한 단계별 로드맵입니다. 각 단계는 bad/good 대비와 실행 방법을 제공합니다.

---

### 학습 로드맵

| 단계 | 주제 | 학습 목표 | 상태 |
| :-- | :--- | :--- | :--- |
| **Step 1** | **기본 문법 & Cargo** | 변수, 불변/가변, `cargo run`/`cargo build` 흐름 이해 | 완료 |
| **Step 2** | **소유권과 빌림** | move/borrow, 불변·가변 참조 규칙 체득 | 완료 |
| **Step 3** | **구조체 & 열거형** | 데이터 모델링, 패턴 매칭 | 완료 |
| **Step 4** | **에러 처리** | `Result`, `Option`, `?` 연산자 | 완료 |
| **Step 5** | **컬렉션** | `Vec`, `String`, `HashMap` 사용 | 완료 |
| **Step 6** | **트레잇** | 공통 동작 추상화, 디폴트 구현 | 완료 |
| **Step 7** | **제네릭 & 라이프타임** | 제네릭 제약, 라이프타임 명시 | 완료 |
| **Step 8** | **모듈 시스템** | `mod`, `pub`, 경로 관리 | 완료 |
| **Step 9** | **테스트 & 문서화** | `cargo test`, 문서 주석 | 완료 |
| **Step 10** | **스마트 포인터 & 동시성** | `Box`, `Rc`, `Arc`, `Mutex`, `Send/Sync` 이해 | 완료 |
| **Step 11** | **배포 & 크로스컴파일** | 릴리스 빌드, 타겟 설정 | 진행중 |

---

### 빠른 실행 안내 (Step 1~3)
```bash
rustc Step1_BasicSyntaxAndCargo.rs -o step1 && ./step1
rustc Step2_Ownership.rs -o step2 && ./step2
rustc Step3_StructsAndEnums.rs -o step3 && ./step3
```
> bad 예시를 주석 해제해 보면 소유권/빌림 규칙을 컴파일러가 즉시 잡아줍니다.

---

### 각 단계별 간단 노트
- **소유권/빌림**: 동일 스코프의 가변 참조는 1개만, 불변 참조는 여러 개 가능.  
- **에러 처리**: `Result<T, E>`를 반환하고 호출 측에서 `?`로 위임.  
- **라이프타임**: 참조의 생존 범위를 명시해 데이터 레이스 없는 안전성 확보.

### 추가: async Rust 입문
- 런타임: `tokio`를 가장 많이 사용. `Cargo.toml`에 `tokio = { version = "1", features = ["full"] }`
- 예시:
```rust
#[tokio::main]
async fn main() {
    let r = reqwest::get("https://example.com").await.unwrap().text().await.unwrap();
    println!("{}", r);
}
```
- clippy/fmt: `cargo fmt`, `cargo clippy`로 스타일·린트 자동 점검.

### 추가 심화
- `clippy`/`rustfmt`로 코드 품질 자동 점검  
- `cargo bench`로 성능 확인, `criterion` 벤치마킹  
- `tokio`/`async-std`로 async Rust 익히기

### 파일 위치
`content/languages/rust/Step1_BasicSyntaxAndCargo.rs` 등 Step 파일을 참고하세요.
