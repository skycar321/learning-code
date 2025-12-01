# 실무 Rust 코드 학습 계획

안녕하세요! 미래의 멋진 Rust 개발자 여러분!

이 학습 계획은 여러분이 단순한 문법 지식을 넘어, 실제 프로젝트에서 마주하게 될 상황에 대비하여 견고하고 유지보수하기 쉬운 Rust 코드를 구성하는 데 필요한 핵심 역량을 길러주기 위해 기획되었습니다. 각 단계에서 제시하는 '나쁜 예시'를 통해 흔히 저지르는 실수를 파악하고, '좋은 예시'를 통해 모범 사례와 그 배경에 있는 원칙을 깊이 있게 이해하는 것이 중요합니다.

각 학습 주제는 상세한 설명과 코드 예시를 포함하며, '왜', '어떤 상황에서', '이 해당 패턴을 사용해야 하는지'를 깊이 있게 이해하는 학습이 되도록 합니다. 주도적인 학습을 위해 직접 예시 코드를 실행해보고, 나쁜 코드를 좋은 코드로 리팩토링하는 연습을 해볼 것을 강력히 추천합니다! 모든 학습 과정을 성공적으로 마치고 나면, 여러분은 자신감 넘치는 개발자로 성장해 있을 것입니다. 자, 그럼 시작해볼까요!

---

### **학습 로드맵**

| 단계 | 주제 | 학습 목표 | 상태 |
| :-- | :--- | :--- | :--- |
| **Step 1** | **Rust 기본 문법과 Cargo** | 변수, 자료형, 함수, 제어 흐름 등 Rust 기본 문법 및 Cargo 사용법 이해 | 완료 |
| **Step 2** | **소유권(Ownership)** | 소유권, 빌림(Borrowing), 라이프타임(Lifetimes) 개념을 통한 메모리 안전성 확보 | 완료 |
| **Step 3** | **구조체와 열거형(Structs & Enums)** | 사용자 정의 타입을 정의하고 패턴 매칭을 통해 데이터 처리 | 완료 |
| **Step 4** | **에러 처리 (Error Handling)** | \`Result\`와 \`Option\` 열거형을 이용한 견고한 에러 처리 | 완료 |
| **Step 5** | **컬렉션(Collections)** | \`Vec\`, \`String\`, \`HashMap\` 등 Rust 표준 라이브러리 컬렉션 사용법 | 완료 |
| **Step 6** | **트레이트(Traits)** | 공유 동작을 정의하고 다형성을 구현하는 트레이트 학습 | 완료 |
| **Step 7** | **제네릭과 라이프타임 (Generics & Lifetimes)** | 코드 재사용성과 안전성을 높이는 제네릭 및 라이프타임 심화 학습 | 완료 |
| **Step 8** | **모듈 시스템(Modules)** | 코드 조직화를 위한 모듈, 크레이트, 패키지 시스템 이해 | 완료 |
| **Step 9** | **테스팅과 문서화(Testing & Documentation)** | 단위 테스트, 통합 테스트 작성 및 \`cargo doc\`를 이용한 문서화 | 완료 |
| **Step 10** | **스마트 포인터와 동시성(Smart Pointers & Concurrency)** | \`Box\`, \`Rc\`, \`Arc\`, \`Mutex\` 등 스마트 포인터 및 다중 스레드 프로그래밍 | 완료 |

---

### **각 단계별 상세 내용 (예시)**

#### **Step 1: Rust 기본 문법과 Cargo**
- **나쁜 예시**: 변수를 \`mut\` 없이 변경하거나, Cargo를 사용하지 않고 \`rustc\` 명령어로 수동 컴파일.
- **좋은 예시**: 불변성(immutability)을 기본으로 하고, \`cargo new\`, \`cargo build\`, \`cargo run\` 등 Cargo 명령어를 사용하여 프로젝트 관리.
- **학습 포인트**: Rust는 기본적으로 불변성을 지향하며 Cargo는 프로젝트 생성, 빌드, 테스트, 의존성 관리를 담당하는 필수 도구입니다.

---

### **생성될 Rust 파일 목록**

\`c:/Users/Nam/Documents/Cursor/Workspace/origin/learning-code/rust\` 경로에 다음 파일들이 생성될 예정입니다. 이 파일들은 나쁜 예시와 좋은 예시 코드를 포함하며, 상세한 주석을 통해 각 패턴을 심층적으로 학습할 수 있도록 구성될 것입니다.

\`\`\`
learning-code/rust/
├── Step1_BasicSyntaxAndCargo.rs
├── Step2_Ownership.rs
├── Step3_StructsAndEnums.rs
├── Step4_ErrorHandling.rs
├── Step5_Collections.rs
├── Step6_Traits.rs
├── Step7_GenericsAndLifetimes.rs
├── Step8_ModuleSystem.rs
├── Step9_TestingAndDocumentation.rs
├── Step10_SmartPointersAndConcurrency.rs
\`\`\`

---

### **추가 학습 권장 사항**

| 주제 | 설명 | 난이도 |
|:-----|:-----|:------:|
| **Async/Await** | tokio, async-std를 활용한 비동기 프로그래밍 | 중급 |
| **Unsafe Rust** | 안전하지 않은 코드 작성과 FFI | 고급 |
| **웹 프레임워크** | Actix-web, Axum, Rocket 등 웹 개발 | 중급 |
| **매크로** | 선언적/절차적 매크로를 활용한 메타프로그래밍 | 고급 |
| **WebAssembly** | Rust로 WASM 모듈 작성 및 브라우저 통합 | 중급 |
