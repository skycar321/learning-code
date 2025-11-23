# 실무 Java 코드 학습 계획

안녕하세요! 실무에서 자주 사용되는 Java 문법과 모범 사례를 단계별로 학습할 수 있도록 학습 계획을 구성했습니다.

각 단계는 특정 주제에 초점을 맞추며, **나쁜 예시(Bad Practice)**와 **좋은 예시(Good Practice)**를 비교하여 보여줍니다. 모든 코드는 즉시 실행하여 결과를 확인할 수 있도록 `main` 메소드를 포함하여 제공될 예정입니다.

**각 Java 파일은 상세한 한글 주석과 JavaDoc을 포함하고 있어, '언제', '어떤 상황에서', '왜' 해당 패턴을 사용해야 하는지에 대한 깊이 있는 이해를 돕습니다.**

아래 계획을 검토하시고, 이대로 진행해도 좋을지 의견을 들려주세요.

---

### **학습 로드맵**

| 단계 | 주제 | 학습 목표 |
| :-- | :--- | :--- |
| **Step 1** | **변수와 상수 (Variables & Constants)** | '마법의 숫자'를 지양하고, `final`을 사용한 상수의 중요성을 이해합니다. |
| **Step 2** | **Null 처리 (Null Handling)** | `if (obj != null)` 반복을 피하고, `Optional`을 사용하여 더 안전하고 표현력 있는 코드를 작성하는 법을 배웁니다. |
| **Step 3** | **문자열 처리 (String Manipulation)** | 반복문 안에서 `+` 연산자로 문자열을 합치는 것의 비효율성을 이해하고, `StringBuilder` 또는 `String.format`을 사용하는 방법을 익힙니다. |
| **Step 4** | **컬렉션과 스트림 (Collections & Streams)** | `for` 루프를 사용하여 컬렉션을 다루는 전통적인 방식과, Java 8부터 도입된 `Stream API`를 사용한 함수형 프로그래밍 방식을 비교하고 학습합니다. |
| **Step 5** | **예외 처리 (Exception Handling)** | 광범위한 `Exception`을 잡는 것의 위험성을 배우고, 구체적인 예외를 정의하고 처리하는 방법의 중요성을 이해합니다. |
| **Step 6** | **객체 생성 (Object Creation)** | 생성자의 한계를 이해하고, 빌더 패턴(Builder Pattern)을 사용하여 명확하고 유연하게 객체를 생성하는 방법을 배웁니다. |
| **Step 7** | **인터페이스와 구현체 (Interfaces & Implementations)** | 구체적인 클래스에 의존하는 코드의 단점을 파악하고, 인터페이스를 기반으로 프로그래밍하는 것의 유연성과 확장성을 학습합니다. |

---

### **각 단계별 상세 내용**

#### **Step 1: 변수와 상수**
- **나쁜 예시**: 코드에 `86400`과 같은 의미를 알 수 없는 숫자를 직접 사용합니다. (매직 넘버)
- **좋은 예시**: `public static final int SECONDS_PER_DAY = 86400;` 와 같이 의미를 명확히 알 수 있는 상수로 정의합니다.
- **학습 포인트**: 매직 넘버는 가독성과 유지보수성을 크게 해칩니다. 상수를 사용하면 코드 자체가 문서화되어(Self-documenting) 의미를 명확히 하고, 변경 발생 시 수정 범위를 최소화할 수 있습니다.

#### **Step 2: Null 처리**
- **나쁜 예시**: 객체를 사용하기 전에 항상 `if (user != null)` 과 같은 코드를 반복적으로 작성합니다.
- **좋은 예시**: `Optional<User> user = findUser("test"); user.ifPresent(u -> ...);` 와 같이 `Optional`을 사용하여 Null로부터 안전하고 '값이 없을 수 있음'을 명시적으로 표현하는 코드를 작성합니다.
- **학습 포인트**: `Optional`은 `NullPointerException` (NPE)을 방지하고, 메소드의 반환 값이 없을 수 있음을 타입 시스템에 명시하여 개발자가 이를 처리하도록 강제합니다. `ifPresent`, `orElse`, `orElseThrow` 등의 API로 안전하고 간결한 처리가 가능합니다.

#### **Step 3: 문자열 처리**
- **나쁜 예시**: `for` 루프 안에서 `result += item;` 과 같이 `+` 연산자로 문자열을 더합니다.
- **좋은 예시**: `StringBuilder sb = new StringBuilder(); sb.append(item);` 와 같이 `StringBuilder`를 사용하여 루프 내에서 문자열을 효율적으로 조합합니다.
- **학습 포인트**: Java의 `String`은 불변(immutable) 객체이므로, `+` 연산은 매번 새로운 `String` 객체를 생성합니다. 반복문 안에서는 이로 인해 심각한 성능 저하와 메모리 낭비가 발생할 수 있습니다. `StringBuilder`는 가변(mutable) 객체로, 내부 버퍼를 직접 조작하여 문자열을 효율적으로 이어붙여 성능 문제를 해결합니다.

#### **Step 4: 컬렉션과 스트림**
- **나쁜 예시**: `for` 루프와 `if` 문을 사용하여 리스트에서 특정 조건의 요소만 필터링하고 가공합니다. (명령형 프로그래밍)
- **좋은 예시**: `list.stream().filter(...).map(...).collect(...)` 와 같이 `Stream API`를 사용하여 간결하고 가독성 높게 데이터를 처리합니다. (선언형 프로그래밍)
- **학습 포인트**: `Stream API`는 '무엇을' 할 것인지에 집중하는 선언형 코드를 가능하게 하여, 복잡한 컬렉션 처리 로직을 파이프라인 형태로 간결하게 표현합니다. 이는 코드의 가독성을 높이고, 내부적인 최적화 및 병렬 처리 가능성을 제공합니다.

#### **Step 5: 예외 처리**
- **나쁜 예시**: `try { ... } catch (Exception e) { ... }` 와 같이 모든 예외를 한 번에 처리합니다.
- **좋은 예시**: `try { ... } catch (FileNotFoundException e) { ... } catch (IOException e) { ... }` 와 같이 구체적인 예외를 명시하여 처리합니다.
- **학습 포인트**: 포괄적인 `Exception` 처리는 오류의 실제 원인을 숨기고 적절한 복구 로직 구현을 방해합니다. 구체적인 예외를 처리하면 코드 자체가 오류 상황을 설명하는 문서가 되며, 각 상황에 맞는 정교한 대응이 가능하여 프로그램의 안정성을 높입니다.

#### **Step 6: 객체 생성**
- **나쁜 예시**: `new User("name", "email", 30, null, null);` 과 같이 생성자의 파라미터 순서와 의미를 파악하기 어렵게 객체를 생성합니다. ('점층적 생성자' 안티패턴)
- **좋은 예시**: `User.builder().name("name").email("email").age(30).build();` 와 같이 빌더 패턴을 사용하여 명확하고 유연하게 객체를 생성합니다.
- **학습 포인트**: 파라미터가 많거나 선택적 파라미터가 있는 객체를 생성할 때, 빌더 패턴은 각 파라미터의 의미를 명확히 하고, 생성 과정의 유연성을 제공합니다. 이는 코드의 가독성을 높이고 잘못된 파라미터 순서로 인한 오류를 방지합니다.

#### **Step 7: 인터페이스와 구현체**
- **나쁜 예시**: `ArrayList<String> list = new ArrayList<>();` 와 같이 구체적인 구현 클래스 타입으로 변수를 선언합니다.
- **좋은 예시**: `List<String> list = new ArrayList<>();` 와 같이 인터페이스 타입으로 변수를 선언하여 유연성을 확보합니다.
- **학습 포인트**: '구현이 아닌 인터페이스에 프로그래밍하라'는 핵심 원칙입니다. 변수나 파라미터를 인터페이스 타입으로 선언하면, 코드가 특정 구현체에 종속되지 않고 더 추상적으로 동작하여 유연성과 확장성이 크게 향상됩니다. 이는 시스템의 결합도를 낮추고 변경에 유연하게 대응할 수 있도록 합니다.

---

### **생성된 Java 파일 목록**

`c:/Users/Nam/Documents/Cursor/Workspace/origin/learning-code/java` 경로에 다음 파일들이 생성되었습니다. 각 파일은 나쁜 예시와 좋은 예시 코드를 포함하고 있으며, 상세한 주석과 JavaDoc을 통해 각 패턴을 심층적으로 학습할 수 있도록 구성되었습니다.

```
learning-code/java/
├── Step1_VariablesAndConstants.java
├── Step2_NullHandling.java
├── Step3_StringManipulation.java
├── Step4_CollectionsAndStreams.java
├── Step5_ExceptionHandling.java
├── Step6_ObjectCreation.java
└── Step7_Interfaces.java
```

---

### **심화 학습 주제 (추가 제안)**

기본적인 실무 코드를 익히셨다면, 다음 주제들을 학습하여 더 깊이 있는 Java 개발자로 성장할 수 있습니다. 각 주제 역시 나쁜 예시와 좋은 예시를 비교하며 '언제, 왜, 어떻게' 사용해야 하는지에 대한 상세한 설명을 포함할 수 있습니다.

| 단계 | 주제 | 학습 목표 |
| :-- | :--- | :--- |
| **Step 8** | **동시성 처리 (Concurrency)** | `synchronized` 키워드의 한계를 이해하고, `java.util.concurrent` 패키지의 `ExecutorService`나 `Lock` 등을 사용한 현대적인 동시성 처리 방법을 학습합니다. `volatile`, `Atomic` 클래스, `CompletableFuture` 등도 다룰 수 있습니다. |
| **Step 9** | **제네릭 심화 (Advanced Generics)** | 단순한 컬렉션 타입을 넘어, 와일드카드(`? super T`, `? extends T`)를 사용한 유연한 메소드 설계, 제네릭 클래스/메소드 직접 구현, 타입 소거(Type Erasure)의 이해 등 제네릭의 고급 활용법을 익힙니다. |
| **Step 10**| **람다와 메소드 참조 (Lambdas & Method References)** | 익명 내부 클래스(Anonymous Inner Class)를 사용하는 기존 방식보다 람다 표현식과 메소드 참조가 어떻게 코드를 더 간결하고 함수형 프로그래밍 스타일로 만드는지 학습합니다. 함수형 인터페이스의 정의와 활용도 포함합니다. |
| **Step 11**| **새로운 `switch` 표현식 (Modern Switch - Java 14+)** | 기존의 `switch` 문법과 비교하여, Java 14부터 도입된 화살표(`->`)와 `yield`를 사용하는 새로운 `switch` 표현식의 장점(간결성, 안전성, 표현식으로서의 사용)을 이해하고 활용법을 배웁니다. |
| **Step 12**| **레코드 (Records - Java 16+)** | 불변(immutable) 데이터 객체를 만들기 위해 작성했던 상용구(boilerplate) 코드를 `record` 키워드를 통해 어떻게 간결하게 줄일 수 있는지 학습합니다. `equals()`, `hashCode()`, `toString()` 자동 생성의 이점을 이해합니다. |

이 주제들에 대한 학습 자료도 필요하시면 언제든지 요청해주세요!
