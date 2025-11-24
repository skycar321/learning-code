# 동시성 처리 비교: Java vs Rust vs Python

## 목차
1. [동시성 개념 소개](#동시성-개념-소개)
2. [Java 동시성](#java-동시성)
3. [Rust 동시성](#rust-동시성)
4. [Python 동시성](#python-동시성)
5. [코드 예시: 나쁜 예시 vs 좋은 예시](#코드-예시-나쁜-예시-vs-좋은-예시)
6. [비교표](#비교표)

---

## 동시성 개념 소개

### 동시성(Concurrency) vs 병렬성(Parallelism)

- **동시성(Concurrency)**: 여러 작업을 번갈아가며 처리하는 것 (논리적 개념)
- **병렬성(Parallelism)**: 여러 작업을 실제로 동시에 처리하는 것 (물리적 개념)

```
동시성 (하나의 코어에서):
Task A: ████----████----████
Task B: ----████----████----

병렬성 (여러 코어에서):
Core 1, Task A: ████████████████
Core 2, Task B: ████████████████
```

### 주요 동시성 모델

1. **쓰레드 기반**: OS 쓰레드를 직접 사용
2. **이벤트 기반/비동기**: 이벤트 루프와 콜백 사용
3. **액터 모델**: 메시지 전달 기반의 독립적인 액터
4. **CSP (Communicating Sequential Processes)**: 채널을 통한 통신

---

## Java 동시성

### Thread

Java의 가장 기본적인 동시성 단위입니다.

```java
// 방법 1: Thread 클래스 상속
class MyThread extends Thread {
    @Override
    public void run() {
        System.out.println("쓰레드 실행 중: " + Thread.currentThread().getName());
    }
}

// 방법 2: Runnable 인터페이스 구현
Runnable task = () -> {
    System.out.println("람다로 정의된 작업");
};

Thread thread = new Thread(task);
thread.start();  // start()로 실행 (run() 아님!)
thread.join();   // 쓰레드 종료 대기
```

### ExecutorService

쓰레드 풀을 관리하는 고수준 API입니다.

```java
import java.util.concurrent.*;

// ExecutorService 생성 방법들
ExecutorService fixedPool = Executors.newFixedThreadPool(4);      // 고정 크기 풀
ExecutorService cachedPool = Executors.newCachedThreadPool();     // 동적 크기 풀
ExecutorService singleThread = Executors.newSingleThreadExecutor(); // 단일 쓰레드
ScheduledExecutorService scheduled = Executors.newScheduledThreadPool(2); // 스케줄링

// 작업 제출
Future<String> future = fixedPool.submit(() -> {
    // 비동기 작업
    Thread.sleep(1000);
    return "결과";
});

// 결과 대기
String result = future.get();  // 블로킹
String resultWithTimeout = future.get(5, TimeUnit.SECONDS);  // 타임아웃

// 종료
fixedPool.shutdown();  // 새 작업 거부, 기존 작업 완료 대기
fixedPool.shutdownNow();  // 즉시 종료 시도
```

### CompletableFuture

Java 8에서 도입된 비동기 프로그래밍 API입니다.

```java
import java.util.concurrent.CompletableFuture;

// 비동기 작업 생성
CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> {
    // 비동기로 실행되는 작업
    return fetchDataFromApi();
});

// 체이닝
CompletableFuture<Integer> result = future
    .thenApply(data -> parseData(data))       // 동기 변환
    .thenApplyAsync(parsed -> process(parsed)) // 비동기 변환
    .thenCompose(processed -> saveAsync(processed)) // 다른 CompletableFuture와 연결
    .exceptionally(ex -> {
        logger.error("오류 발생", ex);
        return defaultValue;
    });

// 여러 작업 조합
CompletableFuture<Void> allOf = CompletableFuture.allOf(future1, future2, future3);
CompletableFuture<Object> anyOf = CompletableFuture.anyOf(future1, future2, future3);

// 결과 결합
CompletableFuture<String> combined = future1.thenCombine(future2,
    (result1, result2) -> result1 + result2);
```

### Virtual Threads (Java 21+)

Project Loom에서 도입된 경량 쓰레드입니다.

```java
// Virtual Thread 생성
Thread vThread = Thread.ofVirtual().start(() -> {
    System.out.println("가상 쓰레드에서 실행");
});

// Virtual Thread ExecutorService
try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    // 수백만 개의 동시 작업도 처리 가능
    for (int i = 0; i < 1_000_000; i++) {
        executor.submit(() -> {
            // I/O 바운드 작업에 적합
            return fetchData();
        });
    }
}
```

---

## Rust 동시성

### std::thread

Rust의 기본 쓰레드 API입니다.

```rust
use std::thread;
use std::time::Duration;

// 쓰레드 생성
let handle = thread::spawn(|| {
    println!("쓰레드에서 실행 중");
    thread::sleep(Duration::from_millis(100));
    42  // 반환값
});

// 결과 대기
let result = handle.join().unwrap();  // Result<T, Box<dyn Any + Send>>

// 쓰레드에 데이터 전달 (move 클로저)
let data = vec![1, 2, 3];
let handle = thread::spawn(move || {
    // data의 소유권이 이 쓰레드로 이동
    println!("데이터: {:?}", data);
});
```

### Arc와 Mutex

쓰레드 간 안전한 데이터 공유를 위한 타입입니다.

```rust
use std::sync::{Arc, Mutex, RwLock};
use std::thread;

// Arc: Atomic Reference Counting (쓰레드 안전한 Rc)
// Mutex: 상호 배제 잠금
let counter = Arc::new(Mutex::new(0));

let handles: Vec<_> = (0..10).map(|_| {
    let counter = Arc::clone(&counter);
    thread::spawn(move || {
        let mut num = counter.lock().unwrap();
        *num += 1;
    })
}).collect();

for handle in handles {
    handle.join().unwrap();
}

println!("결과: {}", *counter.lock().unwrap());

// RwLock: 읽기-쓰기 잠금 (여러 읽기 또는 하나의 쓰기)
let data = Arc::new(RwLock::new(vec![1, 2, 3]));

// 읽기 (여러 쓰레드가 동시에 가능)
let read_guard = data.read().unwrap();

// 쓰기 (배타적 접근)
let mut write_guard = data.write().unwrap();
write_guard.push(4);
```

### 채널 (Channel)

메시지 전달 방식의 동시성입니다.

```rust
use std::sync::mpsc;  // Multi-Producer, Single-Consumer
use std::thread;

// 채널 생성
let (tx, rx) = mpsc::channel();

// 여러 송신자
let tx1 = tx.clone();
thread::spawn(move || {
    tx.send("안녕하세요").unwrap();
});

thread::spawn(move || {
    tx1.send("반갑습니다").unwrap();
});

// 수신
for received in rx {
    println!("받은 메시지: {}", received);
}

// 동기 채널 (버퍼 크기 제한)
let (tx, rx) = mpsc::sync_channel(3);  // 버퍼 크기 3
```

### Tokio (비동기 런타임)

Rust의 대표적인 비동기 런타임입니다.

```rust
use tokio;
use tokio::time::{sleep, Duration};

// 비동기 함수 정의
async fn fetch_data(url: &str) -> Result<String, reqwest::Error> {
    let response = reqwest::get(url).await?;
    response.text().await
}

// 메인 함수
#[tokio::main]
async fn main() {
    // 단일 비동기 작업
    let result = fetch_data("https://api.example.com").await;

    // 여러 작업 동시 실행
    let (result1, result2) = tokio::join!(
        fetch_data("https://api1.example.com"),
        fetch_data("https://api2.example.com")
    );

    // 비동기 작업 스폰
    let handle = tokio::spawn(async {
        sleep(Duration::from_secs(1)).await;
        "완료"
    });

    // 타임아웃
    let result = tokio::time::timeout(
        Duration::from_secs(5),
        fetch_data("https://slow-api.example.com")
    ).await;

    // select: 여러 future 중 하나 선택
    tokio::select! {
        result = fetch_data("https://api1.com") => println!("API1: {:?}", result),
        result = fetch_data("https://api2.com") => println!("API2: {:?}", result),
        _ = sleep(Duration::from_secs(10)) => println!("타임아웃"),
    }
}

// Tokio 동기화 기본 요소
use tokio::sync::{Mutex, RwLock, Semaphore, mpsc, broadcast, oneshot};

async fn tokio_primitives_example() {
    // 비동기 Mutex
    let mutex = tokio::sync::Mutex::new(0);
    let guard = mutex.lock().await;

    // 비동기 채널
    let (tx, mut rx) = mpsc::channel(100);  // 버퍼 크기 100

    tokio::spawn(async move {
        tx.send("메시지").await.unwrap();
    });

    while let Some(msg) = rx.recv().await {
        println!("받음: {}", msg);
    }
}
```

---

## Python 동시성

### threading

Python의 쓰레드 모듈입니다. GIL로 인해 진정한 병렬 실행은 불가능합니다.

```python
import threading
import time

# 기본 쓰레드 생성
def worker(name):
    print(f"쓰레드 {name} 시작")
    time.sleep(1)
    print(f"쓰레드 {name} 종료")

thread = threading.Thread(target=worker, args=("A",))
thread.start()
thread.join()  # 쓰레드 종료 대기

# 클래스 기반 쓰레드
class MyThread(threading.Thread):
    def __init__(self, name):
        super().__init__()
        self.name = name

    def run(self):
        print(f"쓰레드 {self.name} 실행 중")

# Lock을 사용한 동기화
lock = threading.Lock()
counter = 0

def increment():
    global counter
    with lock:  # 컨텍스트 매니저로 안전한 잠금
        counter += 1

# RLock: 재진입 가능 잠금
rlock = threading.RLock()

# Condition: 조건 변수
condition = threading.Condition()

def consumer():
    with condition:
        condition.wait()  # 신호 대기
        print("소비자 활성화")

def producer():
    with condition:
        condition.notify_all()  # 모든 대기자에게 신호

# Semaphore: 동시 접근 수 제한
semaphore = threading.Semaphore(3)  # 최대 3개 쓰레드 동시 접근

def limited_resource():
    with semaphore:
        # 최대 3개의 쓰레드만 이 블록에 동시 진입 가능
        access_resource()

# Event: 쓰레드 간 신호
event = threading.Event()

def waiter():
    event.wait()  # 이벤트 설정 대기
    print("이벤트 수신!")

def setter():
    event.set()  # 이벤트 설정

# ThreadPoolExecutor
from concurrent.futures import ThreadPoolExecutor, as_completed

with ThreadPoolExecutor(max_workers=4) as executor:
    futures = [executor.submit(worker, i) for i in range(10)]

    for future in as_completed(futures):
        result = future.result()
```

### multiprocessing

진정한 병렬 처리를 위한 프로세스 기반 병렬화입니다. GIL을 우회합니다.

```python
import multiprocessing as mp
from multiprocessing import Pool, Queue, Pipe, Manager

# 기본 프로세스 생성
def worker(name):
    print(f"프로세스 {name}, PID: {mp.current_process().pid}")

process = mp.Process(target=worker, args=("A",))
process.start()
process.join()

# 프로세스 풀
def square(x):
    return x ** 2

if __name__ == "__main__":
    with Pool(processes=4) as pool:
        # map: 순서 보장
        results = pool.map(square, range(10))

        # imap: 이터레이터 반환 (메모리 효율)
        for result in pool.imap(square, range(10)):
            print(result)

        # apply_async: 비동기 실행
        async_result = pool.apply_async(square, (10,))
        print(async_result.get())  # 결과 대기

# Queue: 프로세스 간 통신
queue = mp.Queue()

def producer(q):
    q.put("메시지")

def consumer(q):
    msg = q.get()
    print(f"받음: {msg}")

# Pipe: 양방향 통신
parent_conn, child_conn = mp.Pipe()

def pipe_worker(conn):
    conn.send("자식에서 보낸 메시지")
    print(f"자식이 받음: {conn.recv()}")

# Manager: 공유 상태
with Manager() as manager:
    shared_list = manager.list()
    shared_dict = manager.dict()

    def modifier(lst, dct):
        lst.append(1)
        dct["key"] = "value"

# ProcessPoolExecutor
from concurrent.futures import ProcessPoolExecutor

with ProcessPoolExecutor(max_workers=4) as executor:
    results = list(executor.map(square, range(10)))
```

### asyncio

Python의 비동기 프로그래밍 프레임워크입니다.

```python
import asyncio
import aiohttp  # 비동기 HTTP 클라이언트

# 코루틴 정의
async def fetch_data(url: str) -> str:
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            return await response.text()

# 비동기 함수 실행
async def main():
    # 단일 코루틴 실행
    result = await fetch_data("https://api.example.com")

    # 여러 코루틴 동시 실행
    results = await asyncio.gather(
        fetch_data("https://api1.example.com"),
        fetch_data("https://api2.example.com"),
        fetch_data("https://api3.example.com"),
        return_exceptions=True  # 예외도 결과로 반환
    )

    # Task 생성 및 관리
    task = asyncio.create_task(fetch_data("https://api.example.com"))
    result = await task

    # 타임아웃
    try:
        result = await asyncio.wait_for(
            fetch_data("https://slow-api.example.com"),
            timeout=5.0
        )
    except asyncio.TimeoutError:
        print("타임아웃 발생")

    # 첫 번째 완료된 작업
    done, pending = await asyncio.wait(
        [task1, task2, task3],
        return_when=asyncio.FIRST_COMPLETED
    )

# 이벤트 루프 실행
asyncio.run(main())

# 동기화 기본 요소
async def sync_primitives():
    # Lock
    lock = asyncio.Lock()
    async with lock:
        # 배타적 접근
        pass

    # Semaphore
    semaphore = asyncio.Semaphore(10)
    async with semaphore:
        # 최대 10개 동시 접근
        pass

    # Event
    event = asyncio.Event()
    await event.wait()  # 이벤트 대기
    event.set()  # 이벤트 설정

    # Queue
    queue = asyncio.Queue()
    await queue.put("item")
    item = await queue.get()

# 비동기 제너레이터
async def async_generator():
    for i in range(10):
        await asyncio.sleep(0.1)
        yield i

async def consume():
    async for item in async_generator():
        print(item)

# 비동기 컨텍스트 매니저
class AsyncResource:
    async def __aenter__(self):
        await self.connect()
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.disconnect()

async def use_resource():
    async with AsyncResource() as resource:
        await resource.do_something()
```

---

## 코드 예시: 나쁜 예시 vs 좋은 예시

### Java

#### 나쁜 예시

```java
// 나쁜 예시 1: 동기화 없이 공유 상태 접근
public class UnsafeCounter {
    private int count = 0;  // 동기화 없음!

    public void increment() {
        count++;  // 경쟁 상태 발생 가능
    }

    public int getCount() {
        return count;
    }
}

// 나쁜 예시 2: 무한 루프로 쓰레드 점유
public void badLoop() {
    new Thread(() -> {
        while (running) {  // volatile 없이 플래그 체크
            // CPU 100% 사용
        }
    }).start();
}

// 나쁜 예시 3: ExecutorService 종료하지 않음
public void badExecutorUsage() {
    ExecutorService executor = Executors.newFixedThreadPool(4);
    executor.submit(() -> doWork());
    // shutdown() 호출 안함 - 리소스 누수!
}

// 나쁜 예시 4: Future.get() 예외 처리 누락
public void badFutureHandling() throws Exception {
    Future<String> future = executor.submit(() -> riskyOperation());
    String result = future.get();  // InterruptedException, ExecutionException 무시
}

// 나쁜 예시 5: synchronized 과다 사용
public class OverSynchronized {
    public synchronized void methodA() { /* ... */ }
    public synchronized void methodB() { /* ... */ }
    public synchronized void methodC() { /* ... */ }
    // 모든 메서드가 같은 락 사용 - 병목 발생
}

// 나쁜 예시 6: 데드락 가능성
public void deadlockProne() {
    synchronized (lockA) {
        synchronized (lockB) {
            // 다른 쓰레드가 lockB -> lockA 순서로 잠그면 데드락
        }
    }
}
```

#### 좋은 예시

```java
import java.util.concurrent.*;
import java.util.concurrent.atomic.*;

// 좋은 예시 1: AtomicInteger 사용
public class SafeCounter {
    private final AtomicInteger count = new AtomicInteger(0);

    public void increment() {
        count.incrementAndGet();  // 원자적 연산
    }

    public int getCount() {
        return count.get();
    }
}

// 좋은 예시 2: volatile 플래그 사용
public class GracefulShutdown {
    private volatile boolean running = true;

    public void start() {
        new Thread(() -> {
            while (running) {
                doWork();
                // 적절한 sleep 또는 wait
                try {
                    Thread.sleep(100);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    break;
                }
            }
        }).start();
    }

    public void stop() {
        running = false;
    }
}

// 좋은 예시 3: try-with-resources로 ExecutorService 관리
public void goodExecutorUsage() {
    try (ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor()) {
        executor.submit(() -> doWork());
    }  // 자동으로 shutdown 호출 (Java 19+)

    // 또는 명시적 종료
    ExecutorService executor = Executors.newFixedThreadPool(4);
    try {
        executor.submit(() -> doWork());
    } finally {
        executor.shutdown();
        try {
            if (!executor.awaitTermination(60, TimeUnit.SECONDS)) {
                executor.shutdownNow();
            }
        } catch (InterruptedException e) {
            executor.shutdownNow();
            Thread.currentThread().interrupt();
        }
    }
}

// 좋은 예시 4: CompletableFuture로 안전한 비동기 처리
public CompletableFuture<String> goodAsyncHandling() {
    return CompletableFuture.supplyAsync(() -> riskyOperation())
        .exceptionally(ex -> {
            logger.error("비동기 작업 실패", ex);
            return "기본값";
        })
        .orTimeout(5, TimeUnit.SECONDS)
        .exceptionallyCompose(ex -> {
            if (ex instanceof TimeoutException) {
                return CompletableFuture.completedFuture("타임아웃 기본값");
            }
            return CompletableFuture.failedFuture(ex);
        });
}

// 좋은 예시 5: 세분화된 락 사용
public class FinelGrainedLocking {
    private final Object lockA = new Object();
    private final Object lockB = new Object();

    public void methodA() {
        synchronized (lockA) {
            // lockA만 필요한 작업
        }
    }

    public void methodB() {
        synchronized (lockB) {
            // lockB만 필요한 작업
        }
    }
}

// 좋은 예시 6: 데드락 방지 - 일관된 잠금 순서
public void deadlockFree() {
    // 항상 같은 순서로 잠금 획득
    Object first = System.identityHashCode(lockA) < System.identityHashCode(lockB) ? lockA : lockB;
    Object second = first == lockA ? lockB : lockA;

    synchronized (first) {
        synchronized (second) {
            // 안전한 작업
        }
    }
}

// 좋은 예시 7: ReadWriteLock 사용
public class CachedData {
    private final ReadWriteLock lock = new ReentrantReadWriteLock();
    private Object data;

    public Object getData() {
        lock.readLock().lock();
        try {
            return data;
        } finally {
            lock.readLock().unlock();
        }
    }

    public void setData(Object data) {
        lock.writeLock().lock();
        try {
            this.data = data;
        } finally {
            lock.writeLock().unlock();
        }
    }
}
```

### Rust

#### 나쁜 예시

```rust
// 나쁜 예시 1: unwrap() 사용 (패닉 발생)
fn bad_thread_handling() {
    let handle = std::thread::spawn(|| {
        // 작업
    });
    handle.join().unwrap();  // 패닉 발생 시 프로그램 종료
}

// 나쁜 예시 2: Mutex 잠금 오래 유지
fn bad_mutex_usage() {
    let data = Arc::new(Mutex::new(vec![]));
    let guard = data.lock().unwrap();

    // 긴 작업 수행 - 다른 쓰레드 블로킹
    expensive_operation();

    // guard가 스코프 끝까지 유지됨
}

// 나쁜 예시 3: 채널 수신자 무한 대기
fn bad_channel_usage() {
    let (tx, rx) = std::sync::mpsc::channel::<i32>();

    // tx가 드롭되면 rx.recv()는 Err 반환
    // 하지만 무한 루프에서 처리 안함
    loop {
        let msg = rx.recv().unwrap();  // 송신자 종료 시 패닉
    }
}

// 나쁜 예시 4: async에서 블로킹 호출
async fn bad_async() {
    // std::thread::sleep은 블로킹 - 런타임 전체가 멈춤!
    std::thread::sleep(std::time::Duration::from_secs(1));

    // std::fs 블로킹 I/O
    let content = std::fs::read_to_string("file.txt").unwrap();
}
```

#### 좋은 예시

```rust
use std::sync::{Arc, Mutex, mpsc};
use std::thread;
use tokio::sync::RwLock;

// 좋은 예시 1: 에러 처리와 함께 쓰레드 관리
fn good_thread_handling() -> Result<(), Box<dyn std::error::Error>> {
    let handle = thread::spawn(|| -> Result<i32, &'static str> {
        // 작업
        Ok(42)
    });

    match handle.join() {
        Ok(Ok(result)) => println!("결과: {}", result),
        Ok(Err(e)) => eprintln!("쓰레드 내부 오류: {}", e),
        Err(_) => eprintln!("쓰레드 패닉 발생"),
    }
    Ok(())
}

// 좋은 예시 2: 최소한의 Mutex 잠금
fn good_mutex_usage() {
    let data = Arc::new(Mutex::new(vec![]));

    // 잠금을 최소 범위로 제한
    {
        let mut guard = data.lock().unwrap();
        guard.push(1);
    }  // 여기서 잠금 해제

    // 잠금 없이 비싼 연산 수행
    expensive_operation();
}

// 좋은 예시 3: 채널 종료 처리
fn good_channel_usage() {
    let (tx, rx) = mpsc::channel::<i32>();

    thread::spawn(move || {
        for i in 0..10 {
            tx.send(i).unwrap();
        }
        // tx 드롭 - 채널 종료 신호
    });

    // 종료 시 루프 종료
    while let Ok(msg) = rx.recv() {
        println!("받음: {}", msg);
    }
    println!("채널 종료됨");
}

// 좋은 예시 4: async에서 적절한 비동기 호출
async fn good_async() {
    // tokio의 비동기 sleep 사용
    tokio::time::sleep(tokio::time::Duration::from_secs(1)).await;

    // tokio의 비동기 파일 I/O
    let content = tokio::fs::read_to_string("file.txt").await.unwrap();

    // 블로킹 작업은 spawn_blocking 사용
    let result = tokio::task::spawn_blocking(|| {
        // CPU 집약적 또는 블로킹 작업
        heavy_computation()
    }).await.unwrap();
}

// 좋은 예시 5: 구조화된 동시성
async fn structured_concurrency() {
    let result = tokio::spawn(async {
        let (a, b, c) = tokio::join!(
            fetch_data_a(),
            fetch_data_b(),
            fetch_data_c(),
        );
        process(a?, b?, c?)
    }).await;

    match result {
        Ok(Ok(data)) => println!("성공: {:?}", data),
        Ok(Err(e)) => eprintln!("작업 오류: {}", e),
        Err(e) => eprintln!("태스크 패닉: {}", e),
    }
}

// 좋은 예시 6: Tokio 채널 사용
async fn tokio_channel_example() {
    let (tx, mut rx) = tokio::sync::mpsc::channel(100);

    tokio::spawn(async move {
        for i in 0..10 {
            if tx.send(i).await.is_err() {
                break;  // 수신자 종료
            }
        }
    });

    while let Some(msg) = rx.recv().await {
        println!("받음: {}", msg);
    }
}
```

### Python

#### 나쁜 예시

```python
# 나쁜 예시 1: GIL 무시하고 threading으로 CPU 집약적 작업
import threading

def cpu_intensive(n):
    return sum(i * i for i in range(n))

# CPU 집약적 작업에 threading 사용 - 성능 향상 없음
threads = [threading.Thread(target=cpu_intensive, args=(10000000,)) for _ in range(4)]
for t in threads:
    t.start()
for t in threads:
    t.join()

# 나쁜 예시 2: 락 없이 공유 상태 수정
counter = 0

def increment():
    global counter
    for _ in range(100000):
        counter += 1  # 경쟁 상태!

threads = [threading.Thread(target=increment) for _ in range(4)]
for t in threads:
    t.start()
for t in threads:
    t.join()
print(counter)  # 400000이 아닐 수 있음

# 나쁜 예시 3: async 함수에서 블로킹 호출
import asyncio
import time

async def bad_async():
    time.sleep(1)  # 이벤트 루프 블로킹!
    result = open("large_file.txt").read()  # 블로킹 I/O
    return result

# 나쁜 예시 4: 예외 처리 없는 쓰레드
def risky_worker():
    raise Exception("오류 발생")  # 예외가 조용히 무시됨

thread = threading.Thread(target=risky_worker)
thread.start()
thread.join()
# 예외가 발생했지만 알 수 없음

# 나쁜 예시 5: 데드락 가능 코드
lock_a = threading.Lock()
lock_b = threading.Lock()

def worker_1():
    with lock_a:
        with lock_b:  # worker_2가 lock_b -> lock_a 순서면 데드락
            pass

def worker_2():
    with lock_b:
        with lock_a:  # 데드락!
            pass
```

#### 좋은 예시

```python
import asyncio
import threading
import multiprocessing as mp
from concurrent.futures import ThreadPoolExecutor, ProcessPoolExecutor
from typing import List
import logging

logger = logging.getLogger(__name__)

# 좋은 예시 1: CPU 집약적 작업에 multiprocessing 사용
def cpu_intensive(n: int) -> int:
    return sum(i * i for i in range(n))

def good_cpu_parallel():
    with ProcessPoolExecutor(max_workers=4) as executor:
        results = list(executor.map(cpu_intensive, [10000000] * 4))
    return results

# 좋은 예시 2: 락을 사용한 안전한 공유 상태
class SafeCounter:
    def __init__(self):
        self._count = 0
        self._lock = threading.Lock()

    def increment(self):
        with self._lock:
            self._count += 1

    @property
    def count(self):
        with self._lock:
            return self._count

def good_thread_safety():
    counter = SafeCounter()

    def increment():
        for _ in range(100000):
            counter.increment()

    threads = [threading.Thread(target=increment) for _ in range(4)]
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    print(counter.count)  # 항상 400000

# 좋은 예시 3: async에서 블로킹 작업 처리
async def good_async():
    # 블로킹 sleep 대신 async sleep
    await asyncio.sleep(1)

    # 블로킹 I/O는 run_in_executor 사용
    loop = asyncio.get_event_loop()
    content = await loop.run_in_executor(
        None,  # 기본 ThreadPoolExecutor 사용
        lambda: open("large_file.txt").read()
    )

    # CPU 집약적 작업은 ProcessPoolExecutor 사용
    with ProcessPoolExecutor() as pool:
        result = await loop.run_in_executor(pool, cpu_intensive, 1000000)

    return content, result

# 좋은 예시 4: 예외 처리가 있는 쓰레드
def worker_with_exception_handling():
    try:
        risky_operation()
    except Exception as e:
        logger.exception("워커에서 오류 발생")

# ThreadPoolExecutor로 예외 캡처
def good_exception_handling():
    with ThreadPoolExecutor(max_workers=4) as executor:
        futures = [executor.submit(risky_operation) for _ in range(4)]

        for future in futures:
            try:
                result = future.result()
            except Exception as e:
                logger.error(f"작업 실패: {e}")

# 좋은 예시 5: 데드락 방지 - 일관된 순서 또는 타임아웃
def deadlock_free():
    lock_a = threading.Lock()
    lock_b = threading.Lock()

    # 방법 1: 항상 같은 순서로 락 획득
    def worker_safe():
        with lock_a:
            with lock_b:
                pass

    # 방법 2: 타임아웃 사용
    def worker_with_timeout():
        acquired_a = lock_a.acquire(timeout=1)
        if acquired_a:
            try:
                acquired_b = lock_b.acquire(timeout=1)
                if acquired_b:
                    try:
                        # 작업 수행
                        pass
                    finally:
                        lock_b.release()
                else:
                    logger.warning("lock_b 획득 타임아웃")
            finally:
                lock_a.release()
        else:
            logger.warning("lock_a 획득 타임아웃")

# 좋은 예시 6: 구조화된 동시성 with asyncio
async def structured_concurrency():
    async def fetch_with_timeout(url: str, timeout: float) -> str:
        try:
            return await asyncio.wait_for(fetch_data(url), timeout=timeout)
        except asyncio.TimeoutError:
            logger.warning(f"타임아웃: {url}")
            return ""

    results = await asyncio.gather(
        fetch_with_timeout("https://api1.com", 5.0),
        fetch_with_timeout("https://api2.com", 5.0),
        fetch_with_timeout("https://api3.com", 5.0),
        return_exceptions=True
    )

    for i, result in enumerate(results):
        if isinstance(result, Exception):
            logger.error(f"작업 {i} 실패: {result}")
        else:
            logger.info(f"작업 {i} 성공: {result}")

# 좋은 예시 7: asyncio 세마포어로 동시 요청 제한
async def rate_limited_requests(urls: List[str], max_concurrent: int = 10):
    semaphore = asyncio.Semaphore(max_concurrent)

    async def fetch_with_limit(url: str) -> str:
        async with semaphore:
            return await fetch_data(url)

    return await asyncio.gather(
        *[fetch_with_limit(url) for url in urls]
    )

# 좋은 예시 8: Queue를 사용한 생산자-소비자 패턴
import queue

def producer_consumer_pattern():
    q = queue.Queue(maxsize=100)
    stop_event = threading.Event()

    def producer():
        for i in range(1000):
            q.put(i)
        stop_event.set()

    def consumer():
        while not stop_event.is_set() or not q.empty():
            try:
                item = q.get(timeout=1)
                process(item)
                q.task_done()
            except queue.Empty:
                continue

    prod_thread = threading.Thread(target=producer)
    cons_threads = [threading.Thread(target=consumer) for _ in range(4)]

    prod_thread.start()
    for t in cons_threads:
        t.start()

    prod_thread.join()
    q.join()  # 모든 작업 완료 대기
    for t in cons_threads:
        t.join()
```

---

## 비교표

### 동시성 모델 비교

| 특성 | Java | Rust | Python |
|------|------|------|--------|
| **OS 쓰레드** | Thread | std::thread | threading |
| **경량 쓰레드** | Virtual Thread (21+) | tokio::task | - |
| **쓰레드 풀** | ExecutorService | rayon, tokio | ThreadPoolExecutor |
| **프로세스** | ProcessBuilder | std::process | multiprocessing |
| **비동기** | CompletableFuture | async/await + tokio | asyncio |
| **채널** | BlockingQueue | mpsc, crossbeam | queue.Queue |
| **GIL** | 없음 | 없음 | 있음 (CPython) |

### 동기화 기본 요소 비교

| 동기화 방식 | Java | Rust | Python |
|-------------|------|------|--------|
| **Mutex** | synchronized, ReentrantLock | Mutex<T> | threading.Lock |
| **RW Lock** | ReentrantReadWriteLock | RwLock<T> | - (직접 구현) |
| **세마포어** | Semaphore | tokio::sync::Semaphore | threading.Semaphore |
| **원자적 변수** | AtomicInteger 등 | AtomicUsize 등 | - |
| **조건 변수** | Condition | Condvar | threading.Condition |

### 비동기 기능 비교

| 기능 | Java (CompletableFuture) | Rust (tokio) | Python (asyncio) |
|------|--------------------------|--------------|------------------|
| **정의** | supplyAsync | async fn | async def |
| **대기** | join(), get() | .await | await |
| **조합** | thenCompose | and_then, ? | 직접 구현 |
| **병렬 실행** | allOf | join! | gather |
| **첫 완료** | anyOf | select! | wait(FIRST_COMPLETED) |
| **타임아웃** | orTimeout | timeout | wait_for |
| **에러 처리** | exceptionally | ? 연산자 | try/except |

### 언어별 장단점

| 언어 | 장점 | 단점 |
|------|------|------|
| **Java** | - 풍부한 동시성 API<br>- Virtual Threads로 경량 동시성<br>- 성숙한 생태계 | - 보일러플레이트 코드<br>- 메모리 사용량 큼<br>- Checked Exception 번거로움 |
| **Rust** | - 컴파일 타임 경쟁 상태 방지<br>- 제로 코스트 추상화<br>- 메모리 안전성 보장 | - 러닝 커브 높음<br>- 빌드 시간 김<br>- 소유권 시스템 복잡 |
| **Python** | - 간단한 문법<br>- asyncio 사용 용이<br>- 빠른 프로토타이핑 | - GIL로 진정한 병렬성 제한<br>- CPU 작업에 부적합<br>- 타입 안전성 약함 |

### 사용 사례별 권장

| 사용 사례 | Java | Rust | Python |
|-----------|------|------|--------|
| **I/O 바운드** | CompletableFuture, Virtual Thread | tokio async/await | asyncio |
| **CPU 바운드** | ExecutorService (병렬) | rayon, std::thread | multiprocessing |
| **고성능 서버** | Netty, Virtual Thread | tokio, actix | - (다른 언어 권장) |
| **스크립팅/자동화** | - | - | asyncio, threading |
| **시스템 프로그래밍** | - | std::thread, tokio | - |
| **마이크로서비스** | Virtual Thread | tokio | FastAPI + asyncio |
