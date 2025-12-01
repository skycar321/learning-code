// Rust Step 5: 컬렉션 (Collections)
// `Vec`, `String`, `HashMap` 등 Rust 표준 라이브러리 컬렉션 활용

// 나쁜 예시: 고정 길이 배열만 사용하거나, 직접 복잡한 데이터 구조를 구현하여 비효율적인 코드 작성.
// 좋은 예시: Rust 표준 라이브러리에서 제공하는 컬렉션(`Vec`, `String`, `HashMap` 등)을 활용하여
// 데이터를 효율적으로 저장하고 관리하며, 타입 안전성을 유지.

// 학습 포인트: Rust의 컬렉션은 다양한 데이터 저장 및 관리 요구사항을 충족시키며, 소유권 규칙과 결합하여 안전한 메모리 관리를 제공합니다.

fn main() {
    // --- 1. `Vec<T>` (벡터) ---
    // 가변 길이의 동일한 타입 요소를 저장하는 컬렉션 (다른 언어의 ArrayList와 유사)
    println!("--- Vec<T> (벡터) ---");

    // 빈 벡터 생성
    let mut v: Vec<i32> = Vec::new(); // 타입 어노테이션 필요 (초기에는 비어있으므로 추론 불가)
    v.push(5);
    v.push(6);
    v.push(7);
    println!("벡터 v: {:?}", v);

    // `vec!` 매크로를 사용하여 초기화
    let mut v2 = vec![1, 2, 3]; // 타입 추론 가능
    println!("벡터 v2: {:?}", v2);

    // 요소 접근 (인덱싱)
    let third = &v2[2]; // 불변 참조
    println!("세 번째 요소: {}", third);

    // `get` 메서드를 사용한 안전한 접근 (`Option<T>`)
    match v2.get(2) {
        Some(third) => println!("get 메서드로 얻은 세 번째 요소: {}", third),
        None => println!("세 번째 요소가 없습니다."),
    }

    // 벡터 순회
    for i in &v2 { // 불변 참조로 순회
        println!("벡터 요소: {}", i);
    }
    for i in &mut v2 { // 가변 참조로 순회 (값 변경 가능)
        *i += 50; // 역참조하여 값 변경
    }
    println!("변경 후 벡터 v2: {:?}", v2);

    // --- 2. `String` (문자열) ---
    // 가변 길이의 UTF-8 인코딩 문자열 (힙에 저장)
    println!("\n--- String (문자열) ---");

    // 빈 String 생성
    let mut s = String::new();

    // `to_string()` 메서드로 `&str`에서 `String` 생성
    let s1 = "initial contents".to_string();
    let s2 = String::from("hello"); // String::from 함수

    s.push_str("foo"); // 문자열 리터럴을 추가
    s.push('b'); // 단일 문자를 추가
    println!("문자열 s: {}", s);

    // 문자열 연결
    let s3 = String::from("Hello, ");
    let s4 = String::from("world!");
    let s5 = s3 + &s4; // s3의 소유권은 s5로 이동합니다. s3는 더 이상 사용할 수 없습니다.
    // println!("s3: {}", s3); // 에러!
    println!("연결된 문자열 s5: {}", s5);

    // format! 매크로 (소유권 이동 없음)
    let tic = String::from("tic");
    let tac = String::from("tac");
    let toe = String::from("toe");
    let tictactoe = format!("{}-{}-{}", tic, tac, toe); // tic, tac, toe는 여전히 유효
    println!("format! 매크로: {}", tictactoe);

    // 문자열 인덱싱 (Rust에서는 인덱싱이 까다로움)
    // Rust의 String은 UTF-8로 인코딩되어 있어, 문자열을 바이트, 스칼라 값, grapheme cluster로 해석할 수 있습니다.
    // s5[0]; // 에러: String을 인덱싱할 수 없습니다.

    // 문자열 슬라이싱 (주의 필요)
    let hello = "안녕하세요"; // 15바이트 (한글 한 글자는 3바이트)
    // let s_slice = &hello[0..3]; // "안"
    // let s_slice_fail = &hello[0..2]; // 런타임 panic!: byte index is not on a character boundary

    // --- 3. `HashMap<K, V>` (해시맵) ---
    // 키-값 쌍을 저장하는 컬렉션 (다른 언어의 Hash Map, Dictionary와 유사)
    println!("\n--- HashMap<K, V> ---");

    use std::collections::HashMap;

    let mut scores = HashMap::new();

    // 값 삽입
    scores.insert(String::from("Blue"), 10);
    scores.insert(String::from("Yellow"), 50);
    println!("해시맵 scores: {:?}", scores);

    // 키를 통해 값 접근 (`Option<V>`)
    let team_name = String::from("Blue");
    let score = scores.get(&team_name); // 참조를 넘겨야 합니다.

    match score {
        Some(s) => println!("Blue 팀 점수: {}", s),
        None => println!("Blue 팀 점수를 찾을 수 없습니다."),
    }

    // 해시맵 순회
    for (key, value) in &scores {
        println!("{}: {}", key, value);
    }

    // 값 업데이트 (키가 존재하면 업데이트, 없으면 삽입)
    scores.insert(String::from("Blue"), 25);
    println!("Blue 팀 점수 업데이트: {:?}", scores);

    // `entry()` 메서드를 사용한 값 업데이트 (키가 없을 때만 삽입)
    scores.entry(String::from("Yellow")).or_insert(30); // Yellow는 이미 있으므로 변경 없음
    scores.entry(String::from("Red")).or_insert(40); // Red는 없으므로 40 삽입
    println!("entry() 사용 후 scores: {:?}", scores);

    // 기존 값을 기반으로 값 업데이트
    let text = "hello world wonderful world";
    let mut map = HashMap::new();

    for word in text.split_whitespace() {
        let count = map.entry(word).or_insert(0); // 키가 없으면 0을 삽입하고, 값에 대한 가변 참조 반환
        *count += 1; // 가변 참조를 역참조하여 값 증가
    }
    println!("단어 카운트: {:?}", map);

    // 학습 포인트: Rust의 컬렉션은 소유권과 빌림 규칙에 따라 안전하게 작동합니다.
    // `Vec`은 동적 배열, `String`은 가변 문자열, `HashMap`은 키-값 저장에 사용됩니다.
    // 문자열 인덱싱은 UTF-8 인코딩 특성 때문에 주의가 필요합니다.
}
