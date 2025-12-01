// Step1_KotlinBasicsAndFeatures.kt
// Kotlin 기본 문법 및 특징 학습을 위한 코드 예시입니다.
// 이 파일은 Kotlin 언어의 기본적인 문법, 변수, 데이터 타입, 널 안전성,
// 흐름 제어, 함수, 그리고 확장 함수와 같은 Kotlin만의 특징을 이해하는 데 중점을 둡니다.
//
// Kotlin은 간결하고 안전하며 현대적인 기능을 제공하여 개발 생산성을 높여줍니다.

package com.example.kotlinbasics

import java.time.LocalDateTime

// -----------------------------------------------------------------------------
// 학습 포인트 1: Kotlin 소개 및 환경 설정 (개념)
// - Kotlin은 JetBrains에서 개발한 정적으로 타입이 지정된 프로그래밍 언어입니다.
// - JVM에서 실행되며 Java와 100% 호환됩니다.
// - IntelliJ IDEA, Android Studio에서 쉽게 개발 환경을 설정할 수 있습니다.
// -----------------------------------------------------------------------------
fun initMessage() {
    println("--- 1단계: Kotlin 기본 문법 및 특징 ---")
    println("현재 시간: ${LocalDateTime.now()}")
    println("")
}

// -----------------------------------------------------------------------------
// 학습 포인트 2: 변수 및 데이터 타입 (val, var, 타입 추론)
// - `val`: 읽기 전용 변수 (Java의 `final`과 유사). 한 번 할당되면 변경 불가.
// - `var`: 읽기-쓰기 변수 (Java의 일반 변수와 유사). 언제든지 변경 가능.
// - 타입 추론: 대부분의 경우 Kotlin 컴파일러가 변수의 타입을 자동으로 추론합니다.
// - 모든 데이터 타입은 객체이며, 기본 타입과 래퍼 타입의 구분이 없습니다.
// -----------------------------------------------------------------------------
fun variablesAndDataTypes() {
    println("2.1. 변수 선언")
    // val (Value): 변경 불가능한 변수
    val greeting: String = "Hello Kotlin" // 타입 명시적 선언
    val year = 2016 // 타입 추론 (Int)
    // year = 2020 // 컴파일 에러: val 변수는 재할당 불가

    // var (Variable): 변경 가능한 변수
    var count: Int = 10 // 타입 명시적 선언
    var message = "Welcome" // 타입 추론 (String)
    message = "Good morning" // var 변수는 재할당 가능
    println("val greeting: $greeting, year: $year")
    println("var count: $count, message: $message")

    // 나쁜 예시: `var`를 불필요하게 사용하거나, `val`로 선언해야 할 것을 `var`로 선언하는 것.
    // - 코드의 안정성을 해치고, 의도치 않은 변경을 허용하여 버그 발생 가능성을 높입니다.
    // - 변경이 필요 없는 경우 항상 `val`을 사용하는 것이 좋습니다 (불변성).
    var unnecessaryVar = "이 변수는 변경되지 않습니다."
    // ...
    // unnecessaryVar = "변경될 일이 없습니다." // 굳이 var를 쓸 필요 없음

    println("2.2. 데이터 타입")
    val anInt: Int = 10
    val aLong: Long = 100L
    val aDouble: Double = 3.14
    val aFloat: Float = 3.14f
    val aBoolean: Boolean = true
    val aChar: Char = 'K'
    val aString: String = "Kotlin"
    println("anInt ($anInt) is type ${anInt::class.simpleName}")
    println("")
}

// -----------------------------------------------------------------------------
// 학습 포인트 3: 널 안전성(Null Safety)
// - Kotlin은 NullPointerException (NPE)을 방지하기 위해 널 안전성 기능을 제공합니다.
// - 기본적으로 모든 타입은 널을 허용하지 않습니다. 널을 허용하려면 `?`를 붙여야 합니다.
// -----------------------------------------------------------------------------
fun nullSafety() {
    println("3. 널 안전성 (Null Safety)")

    // 널 불가능 타입 (Non-nullable type)
    var nonNullableName: String = "Alice"
    // nonNullableName = null // 컴파일 에러: Null cannot be a value of a non-null type String

    // 널 가능 타입 (Nullable type)
    var nullableName: String? = "Bob"
    nullableName = null // 가능

    // 널 가능 타입 사용 시 안전한 호출 (`?.`)
    // `?.` 연산자는 객체가 널이 아니면 호출하고, 널이면 전체 표현식은 널이 됩니다.
    val length = nullableName?.length // nullableName이 null이면 length도 null
    println("nullableName의 길이: $length") // null

    nullableName = "Charlie"
    val newLength = nullableName?.length // Charlie의 길이 (7)
    println("nullableName의 새로운 길이: $newLength") // 7

    // 엘비스 연산자 (`?:`)
    // `?.`로 인해 널이 된 경우 기본값을 제공합니다.
    val nameLength = nullableName?.length ?: 0 // nullableName이 null이면 0 반환
    println("nullableName의 길이 (엘비스): $nameLength") // 7

    nullableName = null
    val defaultLength = nullableName?.length ?: -1 // nullableName이 null이므로 -1 반환
    println("nullableName의 길이 (엘비스, null): $defaultLength") // -1

    // `!!` 연산자 (Null Assertion Operator): NPE 발생 위험
    // 널이 아님을 강제로 단언합니다. 객체가 널이면 NPE가 발생합니다.
    // 나쁜 예시: `!!` 연산자를 남용하는 것.
    // - 널이 될 가능성이 있는 곳에 `!!`를 사용하면 널 안전성을 포기하는 것과 같습니다.
    // - `?.`나 `?:`를 사용하여 안전하게 처리하는 것이 좋습니다.
    val nameNotNull: String = "David"
    val sureLength = nameNotNull.length // 안전
    // val nullableVar: String? = null
    // val riskyLength = nullableVar!!.length // 런타임 NPE 발생

    println("")
}

// -----------------------------------------------------------------------------
// 학습 포인트 4: 흐름 제어 (Control Flow)
// - `if`는 표현식으로 사용 가능 (값을 반환).
// - `when`은 Java의 `switch`를 대체하며 더 강력합니다.
// - `for`는 `in` 키워드와 함께 사용됩니다.
// -----------------------------------------------------------------------------
fun controlFlow() {
    println("4.1. `if` 표현식")
    val age = 20
    val status = if (age >= 18) {
        "성인" // if 블록의 마지막 표현식이 값으로 반환됩니다.
    } else {
        "미성년자"
    }
    println("나이 $age: $status")

    // 나쁜 예시: `if` 블록이 단일 라인일 때 중괄호를 생략하는 것.
    // - 코드 가독성을 해치고, 오류를 유발할 수 있습니다. 항상 중괄호를 사용하는 것이 좋습니다.
    // if (age > 10) println("Young") else println("Old")

    println("4.2. `when` 표현식")
    val dayOfWeek = 3
    val dayName = when (dayOfWeek) {
        1 -> "월요일"
        2 -> "화요일"
        in 3..5 -> "수요일 ~ 금요일" // 범위 체크
        else -> "주말"
    }
    println("요일 $dayOfWeek: $dayName")

    when (status) {
        is String -> println("상태는 문자열 타입입니다.") // 타입 체크
        else -> println("알 수 없는 타입입니다.")
    }

    println("4.3. `for` 루프")
    val fruits = listOf("Apple", "Banana", "Cherry")
    for (fruit in fruits) {
        println("과일: $fruit")
    }
    for (index in fruits.indices) { // 인덱스 순회
        println("인덱스 $index: ${fruits[index]}")
    }
    for ((index, fruit) in fruits.withIndex()) { // 인덱스와 값 동시에 순회
        println("인덱스 $index, 과일: $fruit")
    }

    println("4.4. `while` 루프")
    var i = 0
    while (i < 3) {
        println("while 루프: $i")
        i++
    }
    println("")
}

// -----------------------------------------------------------------------------
// 학습 포인트 5: 함수 (Functions)
// - Kotlin 함수는 `fun` 키워드로 선언합니다.
// - 기본 파라미터(Default Parameters), 명명된 인자(Named Arguments) 지원.
// - 단일 표현식 함수(Single-Expression Functions).
// - 확장 함수(Extension Functions): 기존 클래스에 새 함수를 추가.
// - 중위 함수(Infix Functions): 특정 조건의 함수를 중위 표기법으로 호출.
// - 고차 함수(Higher-Order Functions): 함수를 인자로 받거나 함수를 반환. (Step 3에서 심화)
// -----------------------------------------------------------------------------
fun functions() {
    println("5.1. 기본 함수")
    fun add(a: Int, b: Int): Int {
        return a + b
    }
    println("5 + 3 = ${add(5, 3)}")

    // 단일 표현식 함수
    fun subtract(a: Int, b: Int) = a - b
    println("5 - 3 = ${subtract(5, 3)}")

    // 기본 파라미터 및 명명된 인자
    fun greet(name: String, message: String = "안녕하세요") {
        println("$message, $name!")
    }
    greet("김철수") // 기본 메시지 사용
    greet("이영희", "반갑습니다") // 메시지 오버라이드
    greet(message = "어서오세요", name = "박민수") // 명명된 인자 사용

    println("5.2. 확장 함수 (Extension Functions)")
    // String 클래스에 `lastChar`라는 새로운 함수를 추가합니다.
    fun String.lastChar(): Char {
        return this[this.length - 1]
    }
    println("'Kotlin'의 마지막 문자: ${"Kotlin".lastChar()}")

    // 나쁜 예시: 기존 클래스에 너무 많은 확장 함수를 추가하여 코드를 이해하기 어렵게 만드는 것.
    // - 확장 함수는 기존 클래스의 기능을 보완하거나, 특정 도메인 로직을 더 간결하게 표현할 때 사용해야 합니다.
    // - 무분별한 사용은 코드 베이스를 파편화시킬 수 있습니다.

    println("5.3. 중위 함수 (Infix Functions)")
    // `infix` 키워드를 사용하면 점(.)과 괄호 없이 함수를 호출할 수 있습니다.
    // 확장 함수이거나, 하나의 파라미터만 가져야 합니다.
    infix fun Int.times(str: String) = str.repeat(this)
    println(3 times "Hello ") // "Hello Hello Hello "

    println("")
}

// -----------------------------------------------------------------------------
// 학습 팁:
// - Kotlin 공식 문서 (kotlinlang.org)를 참조하며 학습하세요.
// - IntelliJ IDEA 또는 Android Studio의 코드 자동 완성 및 리팩토링 기능을 적극 활용하세요.
// - `try.kotlinlang.org`에서 온라인으로 Kotlin 코드를 실행해볼 수 있습니다.
// -----------------------------------------------------------------------------

fun main() {
    initMessage()
    variablesAndDataTypes()
    nullSafety()
    controlFlow()
    functions()

    println("--- 1단계 학습 완료 ---")
}

/*
이 코드를 실행하려면:

1. IntelliJ IDEA 또는 Android Studio 설치.
2. 새 Kotlin 프로젝트 생성 (JVM 또는 Console Application 템플릿).
3. `src/main/kotlin/Main.kt` 파일 내용을 이 파일의 내용으로 교체.
4. IDE에서 `main` 함수를 실행하거나, 터미널에서 `kotlinc Step1_KotlinBasicsAndFeatures.kt -include-runtime -d Step1.jar` 후 `java -jar Step1.jar` 실행.
   (간단하게는 IDE에서 실행하는 것이 가장 편리합니다.)
*/
