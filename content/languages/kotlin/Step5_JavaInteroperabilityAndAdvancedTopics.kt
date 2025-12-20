// Step5_JavaInteroperabilityAndAdvancedTopics.kt
// Kotlin Java 상호 운용성 및 고급 주제 학습을 위한 코드 예시입니다.
// 이 파일은 Kotlin 코드가 Java 코드와 어떻게 매끄럽게 상호 작용하는지 보여줍니다.
// 또한 어노테이션, 제네릭, 위임(Delegation)과 같은 고급 Kotlin 기능에 대해서도 다룹니다.
//
// Kotlin의 주요 강점 중 하나는 기존의 방대한 Java 라이브러리 및 프레임워크와
// 완벽하게 호환된다는 점입니다. 이를 통해 기존 Java 프로젝트에 Kotlin을 점진적으로
// 도입하거나, Java 라이브러리를 Kotlin 프로젝트에서 사용하는 것이 매우 쉽습니다.

package com.example.kotlinadvanced

import java.io.IOException
import java.util.* // Java의 util 패키지 임포트
import kotlin.reflect.full.declaredMemberProperties // 리플렉션을 위한 임포트

// --- Java 코드 예시 (JavaInteroperability.java 파일에 별도로 작성되었다고 가정) ---
/*
// JavaInteroperability.java
package com.example.kotlinadvanced;

public class JavaInteroperability {
    private String javaName;
    private int javaAge;

    public JavaInteroperability(String javaName, int javaAge) {
        this.javaName = javaName;
        this.javaAge = javaAge;
    }

    public String getJavaName() {
        return javaName;
    }

    public void setJavaName(String javaName) {
        this.javaName = javaName;
    }

    public int getJavaAge() {
        return javaAge;
    }

    public void setJavaAge(int javaAge) {
        this.javaAge = javaAge;
    }

    public void printMessage(String message) {
        System.out.println("Java에서 받은 메시지: " + message);
    }

    public static String getStaticMessage() {
        return "Java의 정적 메시지";
    }

    // Checked Exception 예시 (Kotlin에서 다룰 때 차이점)
    public void throwCheckedException() throws IOException {
        throw new IOException("Java Checked Exception 발생!");
    }
}
*/

// -----------------------------------------------------------------------------
// 학습 포인트 1: Java 코드와 Kotlin 코드의 상호 운용 (Interoperability with Java Code)
// - Kotlin은 Java 클래스, 인터페이스, 메서드를 직접 호출할 수 있습니다.
// - Java의 Getter/Setter는 Kotlin에서 프로퍼티처럼 접근할 수 있습니다.
// - Java의 Checked Exception은 Kotlin에서 Unchecked Exception처럼 처리됩니다.
// -----------------------------------------------------------------------------
fun javaInteroperability() {
    println("1. Java 코드와의 상호 운용")

    // Java 클래스의 인스턴스 생성
    val javaObj = JavaInteroperability("Java Person", 25)

    // Java의 Getter/Setter를 Kotlin의 프로퍼티처럼 접근
    println("Java 객체 이름: ${javaObj.javaName}, 나이: ${javaObj.javaAge}")
    javaObj.javaAge = 26 // Setter 호출
    println("Java 객체 변경된 나이: ${javaObj.javaAge}")

    // Java 메서드 호출
    javaObj.printMessage("Kotlin에서 Java 메서드 호출!")

    // Java의 정적 메서드 호출 (클래스 이름을 직접 사용)
    println("Java의 정적 메시지: ${JavaInteroperability.getStaticMessage()}")

    // Java의 Checked Exception 처리 (Kotlin에서는 Unchecked처럼 처리)
    try {
        javaObj.throwCheckedException()
    } catch (e: IOException) {
        println("Kotlin에서 Java Checked Exception (${e.message}) 처리됨.")
    }

    // 나쁜 예시: Java의 `null`을 고려하지 않고 `!!` 연산자를 남용하는 것.
    // - Java에서 넘어오는 객체는 널 가능성(Nullability)이 불확실하므로,
    // - Kotlin에서 사용할 때는 `?` (널 허용 타입)으로 받고 안전 호출(`?.`)을 사용해야 합니다.
    val nullableJavaString: String? = null // Java에서 넘어온 String이 널일 수 있다고 가정
    // val length = nullableJavaString!!.length // NPE 발생 가능성이 큰 나쁜 예시
    val length = nullableJavaString?.length ?: 0 // 안전한 처리
    println("Nullable Java String 길이 (안전하게 처리): $length")

    println("")
}

// -----------------------------------------------------------------------------
// 학습 포인트 2: 어노테이션(Annotations)
// - Kotlin은 Java와 동일한 어노테이션을 사용할 수 있으며, 자체적인 어노테이션도 정의할 수 있습니다.
// - 어노테이션은 컴파일러, 런타임, 코드 생성 도구 등에 메타데이터를 제공하는 데 사용됩니다.
// -----------------------------------------------------------------------------

// Kotlin 사용자 정의 어노테이션
// `@Target`은 어노테이션이 적용될 수 있는 대상(클래스, 함수, 프로퍼티 등)을 지정합니다.
// `@Retention`은 어노테이션 정보가 유지되는 시점(SOURCE, BINARY, RUNTIME)을 지정합니다.
@Target(AnnotationTarget.CLASS, AnnotationTarget.FUNCTION, AnnotationTarget.PROPERTY)
@Retention(AnnotationRetention.RUNTIME) // 런타임 시에도 어노테이션 정보를 유지
annotation class CustomInfo(val author: String, val date: String = "2023-01-01")

@CustomInfo(author = "Alice", date = "2023-11-24")
class AnnotatedClass {
    @CustomInfo(author = "Bob")
    fun annotatedMethod() {
        println("어노테이션이 적용된 메서드")
    }

    @field:CustomInfo(author = "Charlie") // 프로퍼티의 필드에 어노테이션 적용
    var annotatedProperty: String = "속성"
}

fun annotations() {
    println("2. 어노테이션")
    val annotatedClass = AnnotatedClass::class
    val classAnnotation = annotatedClass.findAnnotation<CustomInfo>() // 리플렉션을 통해 어노테이션 정보 가져오기
    println("클래스 어노테이션: ${classAnnotation?.author}, ${classAnnotation?.date}")

    val methodAnnotation = annotatedClass.declaredMemberProperties.first().annotations.find { it is CustomInfo } as CustomInfo?
    // val methodAnnotation = annotatedClass.declaredFunctions.first { it.name == "annotatedMethod" }.findAnnotation<CustomInfo>()
    // println("메서드 어노테이션: ${methodAnnotation?.author}")

    println("나쁜 예시: 어노테이션을 사용하여 모든 로직을 처리하려 하거나,")
    println("           문서화 없이 어노테이션의 의미를 파악하기 어렵게 만드는 것.")
    println("좋은 예시: 어노테이션을 메타데이터 제공, 코드 생성, 프레임워크 통합 등")
    println("           정해진 목적에 맞게 사용하여 코드의 가독성과 유지보수성을 높이는 것.")
    println("")
}

// -----------------------------------------------------------------------------
// 학습 포인트 3: 리플렉션(Reflection)
// - 런타임에 클래스, 프로퍼티, 함수 등에 대한 정보를 조회하고 조작할 수 있게 합니다.
// - `kotlin-reflect` 라이브러리가 필요합니다. (`build.gradle`에 추가 필요)
// -----------------------------------------------------------------------------
fun reflection() {
    println("3. 리플렉션")
    val person = Person("David", 40)
    val personKClass = person::class // Person의 KClass 인스턴스 (Kotlin Reflection)

    println("클래스 이름: ${personKClass.simpleName}")

    // 프로퍼티 순회
    for (prop in personKClass.declaredMemberProperties) {
        // prop.get(person) // 프로퍼티의 값을 가져옴
        println("  프로퍼티: ${prop.name}, 값: ${prop.call(person)}, 타입: ${prop.returnType}")
    }

    // 나쁜 예시: 리플렉션을 과도하게 사용하여 코드 가독성과 성능을 저하시키는 것.
    // - 리플렉션은 동적인 처리가 필요한 프레임워크, 라이브러리 개발에 적합합니다.
    // - 일반적인 비즈니스 로직에서는 사용을 지양해야 합니다.
    println("")
}

// -----------------------------------------------------------------------------
// 학습 포인트 4: 제네릭(Generics)
// - 타입 파라미터를 사용하여 클래스, 인터페이스, 함수를 정의하여
//   다양한 타입에서 동작하도록 재사용 가능한 코드를 작성할 수 있게 합니다.
// - 타입 안정성을 유지하면서 코드의 유연성을 높입니다.
// -----------------------------------------------------------------------------
class Box<T>(var item: T) { // `T`는 타입 파라미터 (Type Parameter)
    fun getItem(): T {
        return item
    }

    fun setItem(newItem: T) {
        this.item = newItem
    }
}

// 제네릭 함수
fun <T> printList(list: List<T>) {
    list.forEach { println(it) }
}

// 제네릭 확장 함수 (타입 제한)
fun <T : Number> List<T>.sumOfNumbers(): Double { // `T`는 `Number` 타입의 서브 타입이어야 함
    return this.sumOf { it.toDouble() }
}

fun generics() {
    println("4. 제네릭")
    val intBox = Box(123)
    println("intBox의 값: ${intBox.getItem()}")

    val stringBox = Box("Hello Generics")
    println("stringBox의 값: ${stringBox.getItem()}")

    val numbers = listOf(1, 2, 3, 4, 5)
    printList(numbers)

    val names = listOf("Alice", "Bob")
    printList(names)

    println("숫자 리스트 합계: ${numbers.sumOfNumbers()}")

    // 나쁜 예시: 제네릭을 사용하지 않고 `Any` 타입을 사용하여 모든 타입을 처리하는 것.
    // - 런타임에 타입 캐스팅 오류가 발생할 수 있으며, 타입 안전성을 해칩니다.
    // - 코드의 가독성을 떨어뜨리고, 컴파일러가 타입 오류를 미리 잡아주지 못합니다.
    println("")
}

// -----------------------------------------------------------------------------
// 학습 포인트 5: 위임(Delegation)
// - 객체 지향 디자인 패턴 중 하나로, 한 객체가 다른 객체의 메서드 호출을 처리하도록 합니다.
// - Kotlin은 `by` 키워드를 통해 클래스 위임을 언어적으로 지원하여 상속의 대안으로 사용될 수 있습니다.
// -----------------------------------------------------------------------------

// 인터페이스
interface Worker {
    fun work()
    fun takeBreak()
}

// 인터페이스 구현 클래스
class Developer : Worker {
    override fun work() {
        println("코드를 개발합니다.")
    }

    override fun takeBreak() {
        println("커피를 마십니다.")
    }
}

// 위임을 사용하는 클래스
class TeamLead(worker: Worker) : Worker by worker { // Developer 인스턴스에 `work`와 `takeBreak`를 위임
    // TeamLead 고유의 메서드
    fun manageTeam() {
        println("팀을 관리합니다.")
    }

    // 위임된 메서드를 오버라이드할 수도 있습니다.
    override fun work() {
        println("팀 리드로서 코드를 개발합니다. (위임 오버라이드)")
    }

    // 나쁜 예시: 위임을 사용하지 않고 모든 메서드를 수동으로 구현하여 보일러플레이트 코드를 늘리는 것.
    // - 특히 인터페이스의 메서드가 많을수록 코드 중복과 유지보수 부담이 커집니다.
    // - 상속 대신 위임을 사용하면 `상속`의 `강한 결합`을 피하면서 `코드 재사용`을 할 수 있습니다.
}

fun delegation() {
    println("5. 위임 (Delegation)")
    val developer = Developer()
    val teamLead = TeamLead(developer)

    teamLead.work() // 위임된 메서드 (오버라이드된 버전)
    teamLead.takeBreak() // 위임된 메서드
    teamLead.manageTeam() // TeamLead 고유의 메서드
    println("")
}

// -----------------------------------------------------------------------------
// 학습 포인트 6: DSL(Domain Specific Language) 구축 (개념)
// - Kotlin은 람다, 확장 함수, 중위 함수 등을 활용하여 특정 도메인에 특화된
//   언어처럼 보이는 구문을 만들 수 있게 합니다. (예: Gradle Kotlin DSL)
// -----------------------------------------------------------------------------
fun dslConcept() {
    println("6. DSL 구축 (개념)")
    println("  - Kotlin은 DSL을 구축하기에 매우 적합한 언어입니다.")
    println("  - 예를 들어, HTML 생성, SQL 쿼리 빌더, Gradle 빌드 스크립트 등에서 활용됩니다.")
    println("  - 간결하고 가독성 높은 코드로 특정 도메인 로직을 표현할 수 있습니다.")
    println("나쁜 예시: 모든 기능을 DSL로 만들려 하거나, DSL이 아닌 곳에 DSL 스타일을 적용하는 것.")
    println("좋은 예시: 도메인에 특화된 복잡한 로직을 명확하고 간결하게 표현하기 위해 DSL을 사용하는 것.")
    println("")
}

// -----------------------------------------------------------------------------
// 학습 포인트 7: 코틀린 멀티플랫폼(Kotlin Multiplatform) 소개 (개념)
// - 단일 코드베이스로 iOS, Android, 웹, 데스크톱 등 다양한 플랫폼용 앱을 구축할 수 있게 합니다.
// - 공통 비즈니스 로직을 Kotlin으로 작성하고 플랫폼별 UI만 네이티브로 구현합니다.
// -----------------------------------------------------------------------------
fun kotlinMultiplatformConcept() {
    println("7. 코틀린 멀티플랫폼 (Kotlin Multiplatform) 소개 (개념)")
    println("  - Kotlin Multiplatform은 공통 비즈니스 로직을 단일 코드베이스로 작성하고,")
    println("  - 각 플랫폼(iOS, Android, Web, Desktop)의 특성에 맞는 UI는 네이티브 기술로 구현할 수 있게 합니다.")
    println("  - 코드 재사용성을 극대화하고 플랫폼별 경험을 유지할 수 있는 장점이 있습니다.")
    println("나쁜 예시: 모든 코드를 공통 모듈에 넣어 플랫폼별 특성을 무시하거나, 각 플랫폼의 장점을 활용하지 못하는 것.")
    println("좋은 예시: 핵심 비즈니스 로직, 데이터 모델, 네트워크 계층 등을 공통 모듈로 만들고,")
    println("           UI/UX는 각 플랫폼의 네이티브 기능을 최대한 활용하여 구현하는 것.")
    println("")
}

fun main() {
    println("--- 5단계: Java 상호 운용성 및 고급 주제 ---")
    javaInteroperability()
    annotations()
    reflection()
    generics()
    delegation()
    dslConcept()
    kotlinMultiplatformConcept()
    println("--- 5단계 학습 완료 ---")
}

/*
이 코드를 실행하려면:

1. IntelliJ IDEA 또는 Android Studio 설치.
2. 새 Kotlin 프로젝트 생성 (JVM 또는 Console Application 템플릿).
3. 프로젝트 루트에 `JavaInteroperability.java` 파일을 생성 (패키지명 일치 확인).
   ```java
   // JavaInteroperability.java
   package com.example.kotlinadvanced;

   import java.io.IOException;

   public class JavaInteroperability {
       private String javaName;
       private int javaAge;

       public JavaInteroperability(String javaName, int javaAge) {
           this.javaName = javaName;
           this.javaAge = javaAge;
       }

       public String getJavaName() {
           return javaName;
       }

       public void setJavaName(String javaName) {
           this.javaName = javaName;
       }

       public int getJavaAge() {
           return javaAge;
       }

       public void setJavaAge(int javaAge) {
           this.javaAge = javaAge;
       }

       public void printMessage(String message) {
           System.out.println("Java에서 받은 메시지: " + message);
       }

       public static String getStaticMessage() {
           return "Java의 정적 메시지";
       }

       // Checked Exception 예시 (Kotlin에서 다룰 때 차이점)
       public void throwCheckedException() throws IOException {
           throw new IOException("Java Checked Exception 발생!");
       }
   }
   ```
4. `build.gradle.kts` (또는 `build.gradle`) 파일에 `kotlin-reflect` 라이브러리 추가:
   ```kotlin
   // build.gradle.kts
   dependencies {
       implementation("org.jetbrains.kotlin:kotlin-reflect") // 리플렉션 사용을 위해
       // ... 기타 의존성
   }
   ```
   ```groovy
   // build.gradle
   dependencies {
       implementation 'org.jetbrains.kotlin:kotlin-reflect'
       // ... 기타 의존성
   }
   ```
5. `src/main/kotlin/Main.kt` 파일 내용을 이 파일의 내용으로 교체.
6. IDE에서 `main` 함수를 실행합니다.
*/
