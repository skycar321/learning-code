// Step2_ObjectOrientedProgramming.kt
// Kotlin 객체 지향 프로그래밍 학습을 위한 코드 예시입니다.
// 이 파일은 Kotlin의 클래스, 객체, 생성자, 상속, 인터페이스,
// 데이터 클래스, Enum 클래스, 그리고 싱글톤 패턴 구현을 보여줍니다.
//
// Kotlin은 간결하면서도 강력한 객체 지향 기능을 제공하여
// Java보다 적은 코드로 동일한 기능을 구현할 수 있도록 돕습니다.

package com.example.kotlinoop

import java.time.LocalDate

// -----------------------------------------------------------------------------
// 학습 포인트 1: 클래스(Classes) 및 객체(Objects)
// - `class` 키워드로 클래스를 선언합니다.
// - Kotlin 클래스는 기본적으로 `final`이므로 상속 가능하게 하려면 `open` 키워드를 붙여야 합니다.
// -----------------------------------------------------------------------------

// 1.1. 기본 클래스 (기본 생성자)
// `open` 키워드를 붙여야 상속 가능
open class Animal(val name: String) {
    var age: Int = 0 // 초기화 필요
    // 나쁜 예시: 모든 필드를 `var`로 선언하거나 `public`으로 노출하여 캡슐화를 해치는 것.
    // - `val`로 불변성을 유지하고, 필요에 따라 `private set` 등을 사용하여
    // - 외부에서의 직접적인 변경을 막는 것이 좋습니다.

    init { // 초기화 블록
        println("$name이라는 이름의 동물이 생성되었습니다.")
    }

    open fun makeSound() { // 상속받는 클래스에서 오버라이드 가능하도록 `open` 키워드
        println("$name 이 소리를 냅니다.")
    }
}

// 1.2. 보조 생성자
class Person(val firstName: String, val lastName: String) {
    var age: Int = 0
    var hobby: String = "없음"

    // 보조 생성자: `this`를 사용하여 주 생성자를 호출해야 합니다.
    constructor(firstName: String, lastName: String, age: Int) : this(firstName, lastName) {
        this.age = age
        println("${firstName} ${lastName} (나이: $age)가 생성되었습니다.")
    }

    constructor(firstName: String, lastName: String, age: Int, hobby: String) : this(firstName, lastName, age) {
        this.hobby = hobby
        println("${firstName} ${lastName} (나이: $age, 취미: $hobby)가 생성되었습니다.")
    }

    fun introduce() {
        println("안녕하세요, 저는 $firstName $lastName 입니다. 나이는 $age이고 취미는 $hobby 입니다.")
    }
}

// -----------------------------------------------------------------------------
// 학습 포인트 2: 상속(Inheritance) 및 인터페이스(Interfaces)
// - 상속: `open` 클래스를 `:` 뒤에 명시하여 상속받습니다.
// - 오버라이드: `@Override` 대신 `override` 키워드 사용. `open` 메서드만 오버라이드 가능.
// - 인터페이스: `interface` 키워드로 선언하며, 추상 메서드와 기본 구현(default implementation)을 가질 수 있습니다.
// -----------------------------------------------------------------------------

// 인터페이스 선언
interface Pet {
    val petName: String // 추상 프로퍼티
    fun play() // 추상 메서드
    fun feed() { // 기본 구현을 가진 메서드 (Java 8의 default method와 유사)
        println("$petName 에게 밥을 줍니다.")
    }
}

// Dog 클래스는 Animal을 상속받고 Pet 인터페이스를 구현합니다.
class Dog(name: String, override val petName: String) : Animal(name), Pet {
    override fun makeSound() {
        println("$name 이(가) 멍멍 짖습니다.")
    }

    override fun play() {
        println("$petName 이(가) 공을 물어옵니다.")
    }
}

// Cat 클래스는 Animal을 상속받고 Pet 인터페이스를 구현합니다.
class Cat(name: String, override val petName: String) : Animal(name), Pet {
    override fun makeSound() {
        println("$name 이(가) 야옹 야옹 웁니다.")
    }

    override fun play() {
        println("$petName 이(가) 쥐 장난감과 놉니다.")
    }
}

// -----------------------------------------------------------------------------
// 학습 포인트 3: 데이터 클래스(Data Classes)
// - 데이터를 저장하는 목적의 클래스를 간결하게 정의할 수 있습니다.
// - `equals()`, `hashCode()`, `toString()`, `componentN()`, `copy()` 메서드를 자동으로 생성합니다.
// -----------------------------------------------------------------------------
data class Product(val id: String, val name: String, val price: Double) {
    // 나쁜 예시: `data class`를 사용하지 않고 데이터를 저장하는 클래스마다
    // - `equals()`, `hashCode()`, `toString()` 등을 수동으로 구현하는 것.
    // - 코드 중복과 오류 발생 가능성을 높입니다.
}

// -----------------------------------------------------------------------------
// 학습 포인트 4: Enum 클래스 (Enum Classes)
// - 상수 집합을 정의하는 클래스. Java의 Enum과 유사하지만 더 많은 기능을 제공합니다.
// - 생성자, 메서드, 인터페이스 구현이 가능합니다.
// -----------------------------------------------------------------------------
enum class Color(val rgb: Int) {
    RED(0xFF0000),
    GREEN(0x00FF00),
    BLUE(0x0000FF);

    fun printColor() {
        println("색상: $name, RGB 값: ${String.format("#%06X", rgb)}")
    }

    // 나쁜 예시: Enum 대신 상수를 직접 정의하거나, `when` 문으로 모든 케이스를 처리하는 것.
    // - 타입 안전성을 해치고, 새로운 상수가 추가될 때 모든 `when` 문을 수정해야 합니다.
}

// -----------------------------------------------------------------------------
// 학습 포인트 5: 싱글톤 패턴(Singleton Pattern) - `object` 키워드
// - 클래스의 인스턴스를 단 하나만 생성하도록 보장하는 디자인 패턴.
// - Kotlin에서는 `object` 키워드를 사용하여 매우 간결하게 싱글톤을 구현할 수 있습니다.
// -----------------------------------------------------------------------------
object DatabaseManager {
    init {
        println("DatabaseManager 싱글톤 인스턴스가 생성되었습니다.")
    }

    fun connect() {
        println("데이터베이스에 연결합니다.")
    }

    fun disconnect() {
        println("데이터베이스 연결을 해제합니다.")
    }

    // 나쁜 예시: 싱글톤 패턴을 직접 구현하여 복잡한 `private constructor`와 `static` 인스턴스를 만드는 것.
    // - Kotlin의 `object` 키워드를 사용하면 훨씬 간결하고 안전하게 싱글톤을 만들 수 있습니다.
    // - 게으른 초기화(Lazy initialization)를 자동으로 지원합니다.
}


fun main() {
    println("--- 2단계: 객체 지향 프로그래밍 ---")

    println("\n1. 클래스 및 객체:")
    val myAnimal = Animal("강아지")
    myAnimal.age = 5
    myAnimal.makeSound()
    println("${myAnimal.name}의 나이: ${myAnimal.age}")

    val person1 = Person("홍", "길동", 30)
    person1.introduce()
    val person2 = Person("이", "순신", 45, "역사 공부")
    person2.introduce()

    println("\n2. 상속 및 인터페이스:")
    val myDog = Dog("초코", "초코")
    myDog.age = 2
    myDog.makeSound()
    myDog.play()
    myDog.feed() // 인터페이스의 기본 구현 메서드 호출

    val myCat = Cat("나비", "나비")
    myCat.makeSound()
    myCat.play()

    println("\n3. 데이터 클래스:")
    val product1 = Product("P001", "Laptop", 1200.0)
    val product2 = Product("P001", "Laptop", 1200.0)
    val product3 = Product("P002", "Mouse", 25.0)

    println("product1: $product1") // toString() 자동 생성
    println("product1 == product2: ${product1 == product2}") // equals() 자동 생성 (true)
    println("product1 == product3: ${product1 == product3}") // (false)

    val updatedProduct1 = product1.copy(price = 1250.0) // copy() 자동 생성
    println("updatedProduct1: $updatedProduct1")

    println("\n4. Enum 클래스:")
    val redColor = Color.RED
    redColor.printColor()
    println("GREEN의 RGB 값: ${Color.GREEN.rgb}")

    println("\n5. 싱글톤 패턴 (object):")
    DatabaseManager.connect()
    DatabaseManager.disconnect()
    // `object`는 인스턴스를 하나만 가집니다.
    val manager1 = DatabaseManager
    val manager2 = DatabaseManager
    println("manager1 == manager2: ${manager1 == manager2}") // 항상 true

    println("\n--- 2단계 학습 완료 ---")
}

/*
이 코드를 실행하려면:

1. IntelliJ IDEA 또는 Android Studio 설치.
2. 새 Kotlin 프로젝트 생성 (JVM 또는 Console Application 템플릿).
3. `src/main/kotlin/Main.kt` 파일 내용을 이 파일의 내용으로 교체.
4. IDE에서 `main` 함수를 실행합니다.
*/
