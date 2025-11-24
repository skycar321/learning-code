// Step4_AsynchronousProgramming.kt
// Kotlin 비동기 프로그래밍 학습을 위한 코드 예시입니다.
// 이 파일은 Kotlin 코루틴(Coroutines)의 핵심 개념인 `launch`, `async` 빌더,
// `suspend` 함수, 코루틴 스코프, 구조화된 동시성, 그리고 코루틴 내 예외 처리 방법을 보여줍니다.
//
// 코루틴은 경량 스레드와 같은 개념으로, 비동기 작업을 더 간결하고 효율적으로 작성할 수 있게 합니다.
// 콜백 헬(Callback Hell)이나 복잡한 비동기 로직을 선형적인 코드로 표현할 수 있게 해줍니다.

package com.example.kotlinasync

import kotlinx.coroutines.* // 코루틴 관련 함수 및 클래스
import java.lang.ArithmeticException
import kotlin.random.Random
import kotlin.time.Duration.Companion.milliseconds
import kotlin.time.Duration.Companion.seconds
import kotlin.time.measureTime

// -----------------------------------------------------------------------------
// 학습 포인트 1: 코루틴(Coroutines) 소개
// - 경량 스레드: 스레드보다 훨씬 적은 리소스를 사용하여 수십만 개를 동시에 실행 가능.
// - `suspend` 함수: 코루틴 내에서만 호출 가능한 특별한 함수. 실행을 일시 중단(suspend)하고 나중에 재개(resume)할 수 있습니다.
// - 비동기 작업을 동기적인 코드처럼 작성할 수 있게 해줍니다.
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// 학습 포인트 2: `launch`, `async` 빌더
// - `launch`: 결과를 반환하지 않는 비동기 작업을 시작합니다. `Job` 객체를 반환.
// - `async`: 결과를 반환하는 비동기 작업을 시작합니다. `Deferred<T>` 객체를 반환하며, `await()`를 호출하여 결과를 기다릴 수 있습니다.
// -----------------------------------------------------------------------------
suspend fun doWork(name: String, delayMillis: Long): String {
    println("작업 $name 시작 (Thread: ${Thread.currentThread().name})")
    delay(delayMillis) // suspend 함수: 코루틴을 블록하지 않고 일시 중단
    println("작업 $name 완료 (Thread: ${Thread.currentThread().name})")
    return "결과: $name 완료!"
}

fun coroutineBuilders() = runBlocking { // runBlocking은 메인 스레드를 블록하여 코루틴이 완료될 때까지 기다림 (학습 용이)
    println("2. `launch`, `async` 빌더")

    // 2.1. `launch` 예시: 결과를 기다리지 않는 비동기 작업
    val job1 = launch {
        doWork("A", 1000)
    }
    val job2 = launch {
        doWork("B", 500)
    }
    println("launch된 작업들이 백그라운드에서 실행됩니다.")
    job1.join() // job1이 완료될 때까지 기다림
    job2.join() // job2가 완료될 때까지 기다림
    println("모든 launch된 작업 완료.")

    // 2.2. `async` 예시: 결과를 반환하는 비동기 작업
    val deferred1 = async {
        doWork("C", 800)
    }
    val deferred2 = async {
        doWork("D", 300)
    }
    println("async된 작업들이 백그라운드에서 실행됩니다.")
    val resultC = deferred1.await() // deferred1의 결과를 기다림
    val resultD = deferred2.await() // deferred2의 결과를 기다림
    println("async 결과: $resultC, $resultD")

    // 나쁜 예시: `runBlocking`을 과도하게 사용하여 비동기 코드의 장점(논블로킹)을 상실하는 것.
    // - `runBlocking`은 주로 메인 함수나 테스트 코드에서 비동기 코드를 동기적으로 실행해야 할 때 사용합니다.
    // - 실제 애플리케이션에서는 UI 스레드 등을 블록하지 않도록 주의해야 합니다.
    println("")
}

// -----------------------------------------------------------------------------
// 학습 포인트 3: `suspend` 함수 (Suspend Functions)
// - 코루틴 내에서만 호출될 수 있으며, 코루틴의 실행을 일시 중단하고 나중에 재개할 수 있습니다.
// - 비동기 작업을 동기적인 코드처럼 순차적으로 작성할 수 있게 해주는 핵심 기능입니다.
// -----------------------------------------------------------------------------
suspend fun fetchDataFromNetwork(): String {
    println("네트워크에서 데이터 가져오기 시작...")
    delay(2.seconds) // 2초 동안 일시 중단 (네트워크 요청 시뮬레이션)
    println("네트워크 데이터 가져오기 완료.")
    return "네트워크 데이터"
}

suspend fun processData(data: String): String {
    println("데이터 처리 시작...")
    delay(1.seconds) // 1초 동안 일시 중단 (데이터 처리 시뮬레이션)
    println("데이터 처리 완료.")
    return "처리된 데이터: $data"
}

fun suspendFunctions() = runBlocking {
    println("3. `suspend` 함수")
    val elapsedTime = measureTime {
        val data = fetchDataFromNetwork() // 2초
        val processed = processData(data) // 1초
        println("최종 결과: $processed")
    }
    println("총 경과 시간: $elapsedTime") // 약 3초
    println("")
}

// -----------------------------------------------------------------------------
// 학습 포인트 4: 스코프(Scope) (CoroutineScope, GlobalScope)
// - 코루틴의 생명 주기를 관리하고, 구조화된 동시성(Structured Concurrency)을 제공합니다.
// - `CoroutineScope`: 특정 객체(예: ViewModel, Activity)의 생명 주기와 연결되어
//   해당 객체가 파괴될 때 모든 자식 코루틴을 자동으로 취소합니다.
// - `GlobalScope`: 애플리케이션의 전체 생명 주기 동안 지속되는 코루틴을 실행할 때 사용.
//   하지만 남용하면 자원 누수나 예외 처리 문제가 발생할 수 있으므로 주의해야 합니다.
// -----------------------------------------------------------------------------
fun coroutineScopes() = runBlocking {
    println("4. 스코프 (CoroutineScope, GlobalScope)")

    // 4.1. `GlobalScope` 예시 (애플리케이션 생명 주기 동안 지속)
    val job = GlobalScope.launch {
        repeat(5) { i ->
            println("GlobalScope 작업 $i... (Thread: ${Thread.currentThread().name})")
            delay(300.milliseconds)
        }
    }
    delay(1000.milliseconds) // 메인 코루틴은 잠시 대기
    job.cancelAndJoin() // GlobalScope 작업 취소 및 완료 대기
    println("GlobalScope 작업이 취소되었습니다.")

    // 4.2. `coroutineScope` 빌더 (현재 코루틴 내에 새로운 스코프 생성)
    // - 자식 코루틴의 완료를 기다렸다가 다음 코드로 진행.
    // - `SupervisorJob`과 함께 사용하여 자식 코루틴 하나의 실패가 다른 자식 코루틴에 영향을 미치지 않도록 할 수 있습니다.
    println("coroutineScope 블록 시작")
    coroutineScope { // 새로운 코루틴 스코프 생성
        val jobA = launch {
            doWork("E", 700)
            println("E 작업 완료 (부모 스코프 내)")
        }
        val jobF = launch {
            doWork("F", 400)
            println("F 작업 완료 (부모 스코프 내)")
        }
        jobA.join() // 자식 jobA 완료까지 기다림
        jobF.join() // 자식 jobF 완료까지 기다림
    }
    println("coroutineScope 블록 완료.")
    println("")
}

// -----------------------------------------------------------------------------
// 학습 포인트 5: 구조화된 동시성 (Structured Concurrency)
// - 코루틴은 계층적인 구조를 가지며, 부모 코루틴이 취소되면 모든 자식 코루틴도 함께 취소됩니다.
// - 부모 코루틴은 모든 자식 코루틴이 완료될 때까지 기다립니다.
// - 이로써 코루틴 누수(Coroutine Leak)를 방지하고, 코드의 예측 가능성을 높입니다.
// -----------------------------------------------------------------------------
fun structuredConcurrency() = runBlocking {
    println("5. 구조화된 동시성")

    val parentJob = launch {
        println("부모 코루틴 시작")
        val childJob1 = launch {
            repeat(3) { i ->
                delay(200.milliseconds)
                println("  자식 코루틴 1: $i")
            }
        }
        val childJob2 = async {
            delay(500.milliseconds)
            println("  자식 코루틴 2 완료")
            "Child 2 Result"
        }
        // 부모 코루틴은 자식 코루틴들이 완료될 때까지 기다립니다.
        childJob1.join()
        println("자식 1 결과: ${childJob2.await()}")
        println("부모 코루틴 완료")
    }
    parentJob.join() // 모든 자식 코루틴이 완료될 때까지 부모가 기다림
    println("모든 작업 완료.")

    println("\n부모 취소 시 자식도 취소되는 예시:")
    val parentJobWithCancellation = launch {
        val child = launch {
            try {
                repeat(1000) { i ->
                    println("  취소될 자식 $i")
                    delay(100.milliseconds)
                }
            } finally {
                println("  자식 코루틴: finally 블록 실행 (취소됨)")
            }
        }
        delay(500.milliseconds)
        println("부모 코루틴 취소 중...")
        // child.cancel() // 명시적으로 자식 취소
    }
    // 부모 job이 완료되기 전에 메인 스레드가 끝나면 자식도 자동으로 취소됩니다.
    parentJobWithCancellation.join()
    println("부모 코루틴이 종료되었습니다.")
    println("")
}

// -----------------------------------------------------------------------------
// 학습 포인트 6: 예외 처리 (Exception Handling)
// - 코루틴 내에서 발생하는 예외는 부모-자식 관계에 따라 전파됩니다.
// - `CoroutineExceptionHandler`: 코루틴 계층의 최상단에서 처리되지 않은 예외를 캐치.
// - `SupervisorJob`: 자식 코루틴 하나의 실패가 다른 자식 코루틴에 영향을 미치지 않도록 합니다.
// -----------------------------------------------------------------------------
fun coroutineExceptionHandling() = runBlocking {
    println("6. 예외 처리")

    // 6.1. 자식 예외가 부모로 전파되는 경우 (기본 동작)
    val jobWithException = GlobalScope.launch { // GlobalScope는 부모-자식 관계를 엄격하게 따르지 않음
        val child = launch {
            try {
                delay(100.milliseconds)
                throw ArithmeticException("나누기 0 에러!") // 이 예외는 부모로 전파
            } catch (e: Exception) {
                println("자식 코루틴에서 예외 캐치: ${e.message}")
            }
        }
        child.join()
        println("부모 코루틴 계속 실행") // 자식에서 캐치했으므로 부모는 계속 실행
    }
    jobWithException.join() // GlobalScope.launch는 잡을 반환하므로 join으로 기다려야 함

    println("\n6.2. `CoroutineExceptionHandler` 사용 예시")
    val handler = CoroutineExceptionHandler { _, exception ->
        println("CoroutineExceptionHandler에서 예외 캐치: $exception with suppressed ${exception.suppressedExceptions.contentToString()}")
    }

    val scope = CoroutineScope(Job() + handler) // Job()에 핸들러를 추가하여 스코프 생성
    val jobHandled = scope.launch {
        launch {
            delay(200.milliseconds)
            throw IllegalStateException("첫 번째 자식에서 발생한 예외")
        }
        launch {
            delay(500.milliseconds)
            println("두 번째 자식 코루틴은 계속 실행됩니다.") // 첫 번째 자식의 예외가 전파되어 여기도 취소될 수 있음
        }
    }
    jobHandled.join()

    println("\n6.3. `SupervisorJob` 사용 예시")
    val supervisor = SupervisorJob()
    val supervisedScope = CoroutineScope(Dispatchers.Default + supervisor)

    val child1 = supervisedScope.launch {
        delay(100.milliseconds)
        throw IllegalArgumentException("감독받는 자식 1에서 발생한 예외")
    }

    val child2 = supervisedScope.launch {
        try {
            delay(500.milliseconds)
            println("감독받는 자식 2는 계속 실행됩니다.")
        } catch (e: Exception) {
            println("감독받는 자식 2에서 예외 캐치: ${e.message}")
        }
    }

    delay(1000.milliseconds) // 코루틴들이 실행될 시간을 줌
    supervisor.cancel() // SupervisorJob을 취소하면 모든 자식도 취소됨
    // child1.join() // join()을 사용하여 각 자식의 완료를 기다려야 정확한 동작 확인
    // child2.join()

    println("\n나쁜 예시: `try-catch`로 모든 코루틴 내 예외를 획일적으로 처리하거나,")
    println("           예외 발생 시 코루틴을 적절히 취소하지 않아 자원 누수를 일으키는 것.")
    println("좋은 예시: 구조화된 동시성을 따르고, `CoroutineExceptionHandler`와 `SupervisorJob`을")
    println("           적절히 사용하여 예외 처리 정책을 명확히 하는 것.")

    println("")
}


fun main() {
    println("--- 4단계: 비동기 프로그래밍 ---")
    coroutineBuilders()
    suspendFunctions()
    coroutineScopes()
    structuredConcurrency()
    coroutineExceptionHandling()
    println("--- 4단계 학습 완료 ---")
}

/*
이 코드를 실행하려면:

1. IntelliJ IDEA 또는 Android Studio 설치.
2. 새 Kotlin 프로젝트 생성 (JVM 또는 Console Application 템플릿).
3. `build.gradle.kts` (또는 `build.gradle`) 파일에 코루틴 라이브러리 추가:
   ```kotlin
   // build.gradle.kts
   dependencies {
       implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3") // 또는 최신 버전
       implementation("org.jetbrains.kotlinx:kotlinx-coroutines-jdk8:1.7.3") // JVM 프로젝트의 경우
       testImplementation(kotlin("test"))
   }
   ```
   ```groovy
   // build.gradle
   dependencies {
       implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3'
       implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-jdk8:1.7.3'
       testImplementation 'org.jetbrains.kotlin:kotlin-test'
   }
   ```
4. `src/main/kotlin/Main.kt` 파일 내용을 이 파일의 내용으로 교체.
5. IDE에서 `main` 함수를 실행합니다.
*/
