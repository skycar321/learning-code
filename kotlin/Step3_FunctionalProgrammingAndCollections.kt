// Step3_FunctionalProgrammingAndCollections.kt
// Kotlin 함수형 프로그래밍 및 컬렉션 학습을 위한 코드 예시입니다.
// 이 파일은 Kotlin의 람다식, 고차 함수, 컬렉션의 다양한 연산자(map, filter, forEach, reduce),
// 그리고 지연 평가(Lazy Evaluation)를 지원하는 시퀀스(Sequences) 사용법을 보여줍니다.
//
// Kotlin은 함수형 프로그래밍 스타일을 강력하게 지원하여,
// 간결하고 가독성 높은 코드를 작성하고 데이터를 효율적으로 처리할 수 있게 합니다.

package com.example.kotlinfunctional

// -----------------------------------------------------------------------------
// 학습 포인트 1: 람다식(Lambdas) 및 익명 함수(Anonymous Functions)
// - 람다식: 이름이 없는 함수 리터럴. 코드를 함수처럼 전달할 때 사용됩니다.
// - `{ 파라미터 -> 바디 }` 형태로 작성. 마지막 표현식의 값이 반환됩니다.
// - 익명 함수: `fun(파라미터): 반환타입 { 바디 }` 형태로 작성. 람다식보다 구문이 더 명시적.
// -----------------------------------------------------------------------------
fun lambdaAndAnonymousFunctions() {
    println("1. 람다식 및 익명 함수")

    // 1.1. 람다식 예시
    val sumLambda: (Int, Int) -> Int = { a, b -> a + b }
    println("람다식 덧셈 (5, 3): ${sumLambda(5, 3)}")

    // 람다 파라미터가 하나일 경우 `it` 키워드로 생략 가능
    val printMessage: (String) -> Unit = { message -> println("메시지: $message") }
    printMessage("람다식 메시지")

    // `it` 사용 예시
    val square: (Int) -> Int = { it * it }
    println("람다식 제곱 (4): ${square(4)}")

    // 1.2. 익명 함수 예시
    val subtractAnon = fun(a: Int, b: Int): Int {
        return a - b
    }
    println("익명 함수 뺄셈 (10, 3): ${subtractAnon(10, 3)}")

    // 나쁜 예시: 람다식을 너무 복잡하게 만들거나, 한 줄로 표현하기 어려운 로직에 람다식을 사용하는 것.
    // - 람다식은 간결성을 위한 것이므로, 복잡한 로직은 일반 함수로 분리하는 것이 가독성에 좋습니다.
    // val complexLambda = { a: Int, b: Int ->
    //     // 여러 줄의 복잡한 로직
    //     val result = a + b
    //     if (result > 10) result * 2 else result
    // }
    println("")
}

// -----------------------------------------------------------------------------
// 학습 포인트 2: 고차 함수(Higher-Order Functions)
// - 함수를 파라미터로 받거나, 함수를 반환하는 함수.
// - Kotlin의 함수형 프로그래밍의 핵심 요소입니다.
// -----------------------------------------------------------------------------
fun higherOrderFunctions() {
    println("2. 고차 함수")

    // 2.1. 함수를 파라미터로 받는 고차 함수
    fun operateOnNumbers(a: Int, b: Int, operation: (Int, Int) -> Int): Int {
        return operation(a, b)
    }

    val resultSum = operateOnNumbers(10, 5) { x, y -> x + y }
    println("덧셈 연산 결과: $resultSum")

    val resultSub = operateOnNumbers(10, 5, fun(x: Int, y: Int): Int { return x - y })
    println("뺄셈 연산 결과: $resultSub")

    // 2.2. 함수를 반환하는 고차 함수
    fun getMultiplier(factor: Int): (Int) -> Int {
        return { number -> number * factor }
    }

    val multiplyBy2 = getMultiplier(2)
    val multiplyBy3 = getMultiplier(3)

    println("5 * 2 = ${multiplyBy2(5)}")
    println("5 * 3 = ${multiplyBy3(5)}")

    // 나쁜 예시: 고차 함수를 과도하게 중첩하여 코드의 흐름을 파악하기 어렵게 만드는 것.
    // - 고차 함수는 추상화를 통해 코드를 간결하게 만들지만, 너무 깊게 중첩되면 오히려 역효과가 날 수 있습니다.
    println("")
}

// -----------------------------------------------------------------------------
// 학습 포인트 3: 컬렉션(Collections) (List, Set, Map)
// - 불변(Immutable) 컬렉션과 가변(Mutable) 컬렉션.
// - 불변 컬렉션: `listOf()`, `setOf()`, `mapOf()`. 생성 후 변경 불가.
// - 가변 컬렉션: `mutableListOf()`, `mutableSetOf()`, `mutableMapOf()`. 생성 후 변경 가능.
// -----------------------------------------------------------------------------
fun collections() {
    println("3. 컬렉션")

    // 3.1. 불변 컬렉션
    val immutableList = listOf(1, 2, 3)
    // immutableList.add(4) // 컴파일 에러: 불변 리스트는 변경 불가
    println("불변 리스트: $immutableList")

    val immutableSet = setOf("Apple", "Banana", "Cherry")
    println("불변 Set: $immutableSet")

    val immutableMap = mapOf("one" to 1, "two" to 2)
    println("불변 Map: $immutableMap")

    // 3.2. 가변 컬렉션
    val mutableList = mutableListOf(1, 2, 3)
    mutableList.add(4)
    mutableList.removeAt(0)
    println("가변 리스트: $mutableList")

    val mutableMap = mutableMapOf("one" to 1, "two" to 2)
    mutableMap["three"] = 3
    println("가변 Map: $mutableMap")

    // 나쁜 예시: 가변 컬렉션을 불변 컬렉션이 필요한 곳에 사용하거나,
    // - 불변성이 중요한 상황에서 가변 컬렉션을 외부에 노출하는 것.
    // - 데이터의 무결성을 해치고, 동시성 문제의 원인이 될 수 있습니다.
    println("")
}

// -----------------------------------------------------------------------------
// 학습 포인트 4: 컬렉션 연산 (Collection Operations)
// - `map`: 각 요소를 변환하여 새 컬렉션 생성.
// - `filter`: 조건에 맞는 요소만 필터링하여 새 컬렉션 생성.
// - `forEach`: 각 요소에 대해 작업 수행 (단말 연산).
// - `reduce` / `fold`: 컬렉션의 요소를 단일 값으로 누적.
// -----------------------------------------------------------------------------
fun collectionOperations() {
    println("4. 컬렉션 연산")

    val numbers = listOf(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

    // map: 각 요소를 제곱하여 새 리스트 생성
    val squares = numbers.map { it * it }
    println("제곱된 숫자: $squares")

    // filter: 짝수만 필터링하여 새 리스트 생성
    val evens = numbers.filter { it % 2 == 0 }
    println("짝수: $evens")

    // forEach: 각 요소를 출력
    print("각 숫자 출력: ")
    numbers.forEach { print("$it ") }
    println()

    // reduce: 모든 숫자를 합산 (초기값 없이 첫 요소를 시작 값으로 사용)
    val sum = numbers.reduce { acc, number -> acc + number }
    println("모든 숫자의 합 (reduce): $sum")

    // fold: 초기값을 제공하여 모든 숫자를 합산
    val sumWithInitial = numbers.fold(0) { acc, number -> acc + number }
    println("모든 숫자의 합 (fold): $sumWithInitial")

    // 나쁜 예시: `for` 루프를 사용하여 `filter`, `map`과 같은 연산을 수동으로 구현하는 것.
    // - 코드가 길어지고 가독성이 떨어지며, 오류 발생 가능성이 높아집니다.
    // - 컬렉션 연산자를 사용하면 간결하고 표현력 높은 코드를 작성할 수 있습니다.
    // val oldWayFiltered = mutableListOf<Int>()
    // for (num in numbers) {
    //     if (num % 2 == 0) {
    //         oldWayFiltered.add(num)
    //     }
    // }
    // println("기존 방식 필터링: $oldWayFiltered")

    println("")
}

// -----------------------------------------------------------------------------
// 학습 포인트 5: 시퀀스(Sequences) - 지연 평가(Lazy Evaluation)
// - 컬렉션 연산은 기본적으로 즉시 평가(Eager Evaluation)됩니다.
// - 시퀀스(`asSequence()`)는 지연 평가(Lazy Evaluation)를 사용하여 대규모 컬렉션 처리 시 성능을 최적화할 수 있습니다.
// - 각 단계별로 모든 요소를 처리하는 대신, 요소 하나하나를 파이프라인처럼 처리합니다.
// -----------------------------------------------------------------------------
fun sequences() {
    println("5. 시퀀스 (Sequences) - 지연 평가")

    val numbers = listOf(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

    // 일반 컬렉션 연산 (즉시 평가)
    println("일반 컬렉션 연산 (즉시 평가):")
    val resultEager = numbers
        .filter {
            println("  Filter eager: $it") // 모든 요소에 대해 필터가 먼저 실행
            it % 2 == 0
        }
        .map {
            println("  Map eager: $it") // 필터링된 모든 요소에 대해 맵이 실행
            it * 2
        }
        .take(2) // 처음 2개만 가져옴
    println("결과 (즉시 평가): $resultEager")

    // 시퀀스 연산 (지연 평가)
    println("시퀀스 연산 (지연 평가):")
    val resultLazy = numbers.asSequence()
        .filter {
            println("  Filter lazy: $it") // 필요한 요소에 대해서만 필터가 실행
            it % 2 == 0
        }
        .map {
            println("  Map lazy: $it") // 필터링된 필요한 요소에 대해서만 맵이 실행
            it * 2
        }
        .take(2) // 처음 2개만 가져옴
        .toList() // 최종 결과를 얻기 위해 toList() 호출 시 평가 시작
    println("결과 (지연 평가): $resultLazy")

    // 나쁜 예시: 지연 평가가 필요 없는 작은 컬렉션에 `asSequence()`를 불필요하게 사용하는 것.
    // - 오히려 오버헤드가 발생하여 성능이 저하될 수 있습니다.
    // - 대규모 데이터 처리, 무한 컬렉션, 또는 복잡하게 체인된 연산에서만 `asSequence()`를 사용하는 것이 좋습니다.
    println("")
}

// -----------------------------------------------------------------------------
// 학습 팁:
// - 컬렉션 연산자를 조합하여 복잡한 데이터 처리 로직을 간결하게 표현하는 연습을 하세요.
// - `null`이 될 수 있는 컬렉션(`List<String?>`)과 널이 될 수 없는 컬렉션(`List<String>`)
//   의 차이를 이해하고 적절히 사용하세요.
// -----------------------------------------------------------------------------

fun main() {
    println("--- 3단계: 함수형 프로그래밍 및 컬렉션 ---")
    lambdaAndAnonymousFunctions()
    higherOrderFunctions()
    collections()
    collectionOperations()
    sequences()
    println("--- 3단계 학습 완료 ---")
}

/*
이 코드를 실행하려면:

1. IntelliJ IDEA 또는 Android Studio 설치.
2. 새 Kotlin 프로젝트 생성 (JVM 또는 Console Application 템플릿).
3. `src/main/kotlin/Main.kt` 파일 내용을 이 파일의 내용으로 교체.
4. IDE에서 `main` 함수를 실행합니다.
*/
