// Step3_ConcurrencyProgramming.go
// Golang 동시성 프로그래밍 학습을 위한 코드 예시입니다.
// 이 파일은 Go의 핵심 강점인 고루틴(Goroutines)과 채널(Channels)을 사용하여
// 동시성 애플리케이션을 작성하는 방법을 보여줍니다.
// 또한 `select` 문, `sync` 패키지(Mutex, WaitGroup) 사용법을 다룹니다.
//
// Go의 동시성 모델은 CSP(Communicating Sequential Processes)에 기반하며,
// "Do not communicate by sharing memory; instead, share memory by communicating."
// (메모리를 공유하여 통신하지 말고, 통신하여 메모리를 공유하라)는 철학을 따릅니다.

package main

import (
	"fmt"
	"sync" // Mutex, WaitGroup
	"time" // time.Sleep
)

// -----------------------------------------------------------------------------
// 학습 포인트 1: 동시성(Concurrency) vs 병렬성(Parallelism) (개념)
// - 동시성: 여러 작업을 동시에 처리하는 것처럼 보이는 것 (단일 코어에서도 가능).
//   - 예: 한 손으로 공 저글링 (하나의 코어가 여러 고루틴을 빠르게 전환).
// - 병렬성: 여러 작업을 실제로 동시에 처리하는 것 (멀티 코어 필요).
//   - 예: 여러 손으로 공 저글링 (여러 코어가 여러 고루틴을 동시에 실행).
// - Go는 동시성을 쉽게 구현할 수 있도록 고루틴과 채널을 제공합니다.
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// 학습 포인트 2: 고루틴(Goroutines)
// - Go 런타임이 관리하는 경량 스레드. 수십만 개의 고루틴을 동시에 실행할 수 있습니다.
// - `go` 키워드를 함수 호출 앞에 붙여 고루틴으로 실행합니다.
// - 메인 고루틴이 종료되면 모든 다른 고루틴도 종료됩니다.
// -----------------------------------------------------------------------------
func sayHello(name string) {
	for i := 0; i < 3; i++ {
		time.Sleep(100 * time.Millisecond) // 100ms 대기
		fmt.Printf("Hello, %s (%d)\n", name, i)
	}
}

// -----------------------------------------------------------------------------
// 학습 포인트 3: 채널(Channels)
// - 고루틴 간에 데이터를 주고받는 통로. 고루틴 간의 안전한 통신을 보장합니다.
// - `make(chan Type)`: 타입 `Type`을 전송할 수 있는 채널 생성.
// - `<-chan Type`: 읽기 전용 채널.
// - `chan<- Type`: 쓰기 전용 채널.
// - 버퍼링 채널 (Buffered Channel): `make(chan Type, N)` - N개까지 버퍼링 가능.
//   - 버퍼가 가득 차면 송신자 블록, 버퍼가 비어있으면 수신자 블록.
// - 비버퍼링 채널 (Unbuffered Channel): `make(chan Type)` - 송신자와 수신자가 동시에 준비되어야 함 (Synchronous).
// -----------------------------------------------------------------------------
func producer(ch chan<- int) {
	for i := 0; i < 5; i++ {
		fmt.Printf("Producer: sending %d\n", i)
		ch <- i // 채널에 데이터 전송 (send)
		time.Sleep(50 * time.Millisecond)
	}
	close(ch) // 채널 닫기: 더 이상 보낼 데이터가 없음을 알림
}

func consumer(ch <-chan int, wg *sync.WaitGroup) {
	defer wg.Done()
	for num := range ch { // 채널이 닫힐 때까지 데이터를 반복해서 받음
		fmt.Printf("Consumer: received %d\n", num)
		time.Sleep(100 * time.Millisecond)
	}
	fmt.Println("Consumer: 채널이 닫혔습니다.")
}

// 나쁜 예시: 채널을 통해 동기화하지 않고 전역 변수를 공유하여 경쟁 조건(Race Condition) 발생
// - `sum = sum + 1`과 같은 연산은 여러 고루틴에서 동시에 접근할 경우 예상치 못한 결과 발생.
// - 해결책: `sync.Mutex` 또는 채널을 통해 안전하게 접근.
var sharedCounter int
var badExampleWg sync.WaitGroup

func incrementBadExample() {
	defer badExampleWg.Done()
	for i := 0; i < 1000; i++ {
		sharedCounter++
	}
}

// -----------------------------------------------------------------------------
// 학습 포인트 4: `select` 문
// - 여러 채널 연산(송신 또는 수신)을 동시에 기다릴 수 있게 합니다.
// - 준비된 채널 연산 중 하나를 무작위로 선택하여 실행합니다.
// - `default` 케이스를 포함하면 어떤 채널도 준비되지 않았을 때 블록되지 않고 바로 실행.
// -----------------------------------------------------------------------------
func worker(id int, jobs <-chan int, results chan<- int) {
	for j := range jobs {
		fmt.Printf("Worker %d: started job %d\n", id, j)
		time.Sleep(time.Second) // 작업 시뮬레이션
		fmt.Printf("Worker %d: finished job %d\n", id, j)
		results <- j * 2
	}
}

func selectExample(quit chan bool) {
	tick := time.Tick(100 * time.Millisecond)   // 100ms마다 이벤트
	boom := time.After(500 * time.Millisecond) // 500ms 후에 한 번 이벤트

	for {
		select {
		case <-tick:
			fmt.Println("tick.")
		case <-boom:
			fmt.Println("BOOM!")
			return // 함수 종료
		case <-quit:
			fmt.Println("Quit!")
			return
		default: // 어떤 케이스도 준비되지 않았을 때 실행
			// fmt.Println("    .") // 너무 많은 출력을 피하기 위해 주석 처리
			time.Sleep(50 * time.Millisecond)
		}
	}
}

// -----------------------------------------------------------------------------
// 학습 포인트 5: `sync` 패키지
// - `sync.Mutex`: 상호 배제(Mutual Exclusion) 락. 공유 자원에 대한 동시 접근 제어.
//   - `Lock()`: 락 획득, `Unlock()`: 락 해제. `defer mu.Unlock()` 패턴 권장.
// - `sync.WaitGroup`: 여러 고루틴의 완료를 기다릴 때 사용.
//   - `Add(N)`: 기다릴 고루틴 개수 증가.
//   - `Done()`: 고루틴 하나 완료.
//   - `Wait()`: 모든 고루틴 완료 대기.
// -----------------------------------------------------------------------------

var (
	safeCounter int
	mutex       sync.Mutex // Mutex 인스턴스
)

func incrementSafeCounter(wg *sync.WaitGroup) {
	defer wg.Done()
	for i := 0; i < 1000; i++ {
		mutex.Lock()   // 락 획득
		safeCounter++  // 공유 자원에 안전하게 접근
		mutex.Unlock() // 락 해제
	}
}

func main() {
	fmt.Println("--- 3단계: 동시성 프로그래밍 ---")

	fmt.Println("\n2. 고루틴 예시:")
	go sayHello("Alice") // 고루틴으로 실행
	go sayHello("Bob")   // 고루틴으로 실행
	sayHello("Main")     // 메인 고루틴으로 실행 (블록킹)
	time.Sleep(200 * time.Millisecond) // 모든 고루틴이 종료될 시간을 주기 위해 잠시 대기
	fmt.Println("모든 고루틴 완료.")

	fmt.Println("\n3. 채널 예시 (비버퍼링):")
	ch := make(chan int) // 비버퍼링 채널 생성
	var wg sync.WaitGroup
	wg.Add(1) // Consumer 고루틴 하나를 기다림

	go producer(ch)
	go consumer(ch, &wg) // Consumer 고루틴은 채널이 닫힐 때까지 데이터를 받음

	wg.Wait() // Consumer 고루틴이 Done()을 호출할 때까지 기다림
	fmt.Println("Producer-Consumer 완료.")

	fmt.Println("\n3.2. 채널 예시 (버퍼링):")
	bufferedCh := make(chan string, 2) // 버퍼 크기 2인 버퍼링 채널
	bufferedCh <- "첫 번째" // 버퍼가 비어있으므로 블록되지 않음
	bufferedCh <- "두 번째" // 버퍼가 비어있으므로 블록되지 않음
	// bufferedCh <- "세 번째" // 버퍼가 가득 찼으므로 이 시점에서 블록됨

	fmt.Println("버퍼링 채널에 데이터 송신 완료.")
	fmt.Println("수신: ", <-bufferedCh)
	fmt.Println("수신: ", <-bufferedCh)
	close(bufferedCh) // 채널 닫기
	// <-bufferedCh // 채널이 닫혔고 데이터가 없으므로 블록됨 (이후 for range를 사용)
	fmt.Println("버퍼링 채널 수신 완료.")

	fmt.Println("\n3.3. 경쟁 조건 (Race Condition) 나쁜 예시:")
	sharedCounter = 0
	badExampleWg.Add(2)
	go incrementBadExample()
	go incrementBadExample()
	badExampleWg.Wait()
	// 예상치 못한 결과가 나올 수 있습니다 (2000이 아닌 값).
	fmt.Printf("경쟁 조건 (나쁜 예시) 후 sharedCounter: %d (2000이 아닐 수 있음)\n", sharedCounter)
	// `go run -race Step3_ConcurrencyProgramming.go` 명령어로 경쟁 조건을 감지할 수 있습니다.

	fmt.Println("\n5. `sync.Mutex`를 사용한 안전한 카운터:")
	safeCounter = 0
	var safeWg sync.WaitGroup
	safeWg.Add(2)
	go incrementSafeCounter(&safeWg)
	go incrementSafeCounter(&safeWg)
	safeWg.Wait()
	fmt.Printf("Mutex 사용 후 safeCounter: %d (항상 2000이어야 함)\n", safeCounter)

	fmt.Println("\n4. `select` 문 예시:")
	quit := make(chan bool)
	go func() {
		time.Sleep(700 * time.Millisecond) // 메인 고루틴이 종료되기 전에 selectExample을 종료시킴
		quit <- true
	}()
	selectExample(quit)

	fmt.Println("\n--- 3단계 학습 완료 ---")
}

/*
이 코드를 실행하려면:

1. Go SDK 설치 (golang.org에서 다운로드 및 설치).
2. 터미널 또는 명령 프롬프트에서 이 파일이 있는 디렉토리로 이동.
3. `go run Step3_ConcurrencyProgramming.go` 명령을 실행.

경쟁 조건(Race Condition)을 확인하려면:
`go run -race Step3_ConcurrencyProgramming.go` 명령을 실행하여
sharedCounter가 2000이 아닌 값이 나올 때 경고 메시지를 확인할 수 있습니다.
*/
