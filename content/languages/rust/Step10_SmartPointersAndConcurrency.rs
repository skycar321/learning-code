// Rust Step 10: 스마트 포인터와 동시성 (Smart Pointers & Concurrency)
// `Box`, `Rc`, `Arc`, `Mutex` 등 스마트 포인터 및 다중 스레드 프로그래밍

// 나쁜 예시: `null` 포인터 역참조, 이중 해제와 같은 메모리 오류를 발생시키거나,
// 스레드 간 데이터 경쟁 조건을 제어하지 않아 예측 불가능한 버그 발생.
// 좋은 예시: Rust의 스마트 포인터와 동시성 프리미티브를 사용하여 메모리 안전하고 데이터 경쟁이 없는 다중 스레드 애플리케이션을 구축.

// 학습 포인트: Rust의 스마트 포인터는 스택에 저장되지만 힙에 있는 데이터를 가리키며, 소유권 개념을 확장하여 다양한 메모리 관리 패턴을 가능하게 합니다.
// 동시성 프리미티브는 안전하고 효율적인 다중 스레드 프로그래밍을 지원합니다.

// --- 1. 스마트 포인터 (Smart Pointers) ---
// 일반 참조와 달리 추가적인 메타데이터나 기능을 제공하는 포인터.
// Rust의 소유권 규칙을 확장하여 특정 상황에서 유연성을 제공합니다.

// 1-1. `Box<T>` (힙 할당 데이터)
// - 데이터를 힙에 할당하고 스택에 포인터를 남깁니다.
// - 컴파일 타임에 크기를 알 수 없는 타입 (예: 재귀 타입)이나, 데이터가 클 때 스택 오버플로우를 피하기 위해 사용됩니다.
// - `Box<T>`는 데이터를 '소유'합니다. (`Drop` 트레잇 구현)

enum List {
    Cons(i32, Box<List>),
    Nil,
}

use std::rc::Rc; // 참조 카운팅 (Reference Counting)
use std::sync::{Arc, Mutex}; // 아토믹 참조 카운팅, 뮤텍스 (동시성)
use std::thread;
use std::time::Duration;

fn main() {
    println!("---\n--- 1. Box<T> 예시 ---");
    let b = Box::new(5); // 힙에 5를 할당하고 b는 그 포인터를 소유
    println!("b = {}", b);

    // 재귀적 타입 예시
    let list = List::Cons(1, Box::new(List::Cons(2, Box::new(List::Nil))));
    // println!("재귀 리스트: {:?}", list); // Display Trait을 구현하지 않아 직접 출력은 어려움


    // 1-2. `Rc<T>` (참조 카운팅)
    // - 동일한 데이터에 대해 여러 소유자를 허용합니다. (imuttable 공유)
    // - 데이터가 여러 부분에서 소유될 수 있지만, 수정은 불가능합니다.
    // - 마지막 `Rc<T>`가 스코프 밖으로 벗어날 때 데이터가 해제됩니다. (단일 스레드 환경)

    println!("\n---\n--- 2. Rc<T> 예시 ---");
    let a = Rc::new(ListRc::Cons(5, Rc::new(ListRc::Cons(10, Rc::new(ListRc::Nil)))));
    println!("a를 생성했을 때 카운트: {}", Rc::strong_count(&a)); // 1
    let b = ListRc::Cons(3, Rc::clone(&a)); // Rc::clone은 깊은 복사 대신 참조 카운트만 증가
    println!("b를 생성했을 때 카운트: {}", Rc::strong_count(&a)); // 2
    {
        let c = ListRc::Cons(4, Rc::clone(&a));
        println!("c를 생성했을 때 카운트: {}", Rc::strong_count(&a)); // 3
    } // c가 스코프 밖으로 벗어나면 카운트 감소
    println!("c가 스코프 밖으로 벗어났을 때 카운트: {}", Rc::strong_count(&a)); // 2

    // --- 3. `RefCell<T>` (내부 가변성) ---
    // - `Rc<T>`와 함께 사용하여, 여러 소유자가 가변 데이터에 접근할 수 있도록 합니다. (단일 스레드 환경)
    // - 런타임에 불변 참조 규칙을 강제합니다. (빌림 규칙 위반 시 `panic!`)
    // use std::cell::RefCell;
    // let value = Rc::new(RefCell::new(5));
    // let a = Rc::clone(&value);
    // let b = Rc::clone(&value);
    // *value.borrow_mut() += 10; // 가변 참조를 얻어 값 변경
    // println!("RefCell 값: {:?}", value);


    // --- 4. 동시성 (Concurrency) ---
    // 여러 작업이 동시에 실행되는 것. Rust는 데이터 경쟁을 방지하여 안전한 동시성을 제공합니다.

    // 4-1. 스레드 (Threads)
    // - `std::thread::spawn`을 사용하여 새로운 스레드를 생성합니다.

    println!("\n---\n--- 3. 스레드 예시 ---");
    let handle = thread::spawn(|| {
        for i in 1..10 {
            println!("자식 스레드: {}", i);
            thread::sleep(Duration::from_millis(1));
        }
    });

    for i in 1..5 {
        println!("메인 스레드: {}", i);
        thread::sleep(Duration::from_millis(1));
    }

    handle.join().unwrap(); // 자식 스레드가 완료될 때까지 기다립니다.


    // 4-2. 메시지 전달 (Message Passing)
    // - `std::sync::mpsc` (Multiple Producer, Single Consumer) 채널을 사용하여 스레드 간에 데이터를 안전하게 전달합니다.

    // use std::sync::mpsc;
    // let (tx, rx) = mpsc::channel(); // 송신기(tx)와 수신기(rx) 생성
    // thread::spawn(move || {
    //     let val = String::from("hi");
    //     tx.send(val).unwrap(); // 송신기로 데이터 전송. val의 소유권이 이동됨.
    // });
    // let received = rx.recv().unwrap(); // 수신기로 데이터 수신
    // println!("메인 스레드에서 수신: {}", received);


    // 4-3. `Mutex<T>` (뮤텍스)
    // - 다중 스레드 환경에서 데이터에 대한 동시 접근을 제어하여 데이터 경쟁을 방지합니다.
    // - `Mutex`는 `lock()` 메서드를 통해 `MutexGuard`를 반환하고, 이 `MutexGuard`는 `Deref` 및 `Drop` 트레잇을 구현하여
    //   스코프를 벗어나면 자동으로 락을 해제합니다.

    println!("\n---\n--- 4. Mutex<T> 예시 ---");
    let counter_mutex = Arc::new(Mutex::new(0)); // Arc와 Mutex 함께 사용 (여러 스레드에서 공유 가능한 Mutex)
    let mut handles = vec![];

    for _ in 0..10 {
        let counter_mutex_clone = Arc::clone(&counter_mutex); // Arc::clone으로 참조 카운트 증가
        let handle = thread::spawn(move || {
            let mut num = counter_mutex_clone.lock().unwrap(); // 락을 획득
            *num += 1; // 데이터 변경
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.join().unwrap();
    }

    println!("Mutex를 사용한 최종 카운트: {}", *counter_mutex.lock().unwrap());

    // 4-4. `Arc<T>` (Atomic Reference Counting)
    // - `Rc<T>`와 유사하지만, 스레드 간에 안전하게 공유할 수 있도록 아토믹 연산을 사용합니다.
    // - 다중 스레드 환경에서 `Rc<T>`처럼 여러 소유자가 데이터를 공유할 수 있도록 합니다.

    // 학습 포인트: Rust의 스마트 포인터와 동시성 프리미티브는 컴파일 타임에 안전성을 보장하면서도 유연하고 효율적인 메모리 관리 및 다중 스레드 프로그래밍을 가능하게 합니다.
    // `Box`는 힙 할당, `Rc`는 단일 스레드 참조 공유, `Arc`는 다중 스레드 참조 공유, `Mutex`는 스레드 간 데이터 경쟁 방지에 사용됩니다.
}

// `Rc`를 사용하는 재귀적 리스트 정의
enum ListRc {
    Cons(i32, Rc<ListRc>),
    Nil,
}
