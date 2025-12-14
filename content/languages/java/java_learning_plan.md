# 실무 Java 코드 학습 계획
﻿
﻿안녕하세요! 미래의 멋진 Java 개발자 여러분!
﻿
﻿이 학습 계획은 여러분이 단순한 문법 지식을 넘어, 실제 프로젝트에서 마주하게 될 상황에 대비하여 견고하고 유지보수하기 쉬운 Java 코드를 구성하는 데 필요한 핵심 역량을 길러주기 위해 기획되었습니다. 각 단계에서 제시하는 '나쁜 예시'를 통해 흔히 저지르는 실수를 파악하고, '좋은 예시'를 통해 모범 사례와 그 배경에 있는 원칙을 깊이 있게 이해하는 것이 중요합니다.
﻿
﻿각 학습 주제는 상세한 설명과 코드 예시를 포함하며, '왜', '어떤 상황에서', '이 해당 패턴을 사용해야 하는지'를 깊이 있게 이해하는 학습이 되도록 합니다. 주도적인 학습을 위해 직접 예시 코드를 실행해보고, 나쁜 코드를 좋은 코드로 리팩토링하는 연습을 해볼 것을 강력히 추천합니다! 모든 학습 과정을 성공적으로 마치고 나면, 여러분은 자신감 넘치는 개발자로 성장해 있을 것입니다. 자, 그럼 시작해볼까요!
﻿
﻿---
﻿
﻿### **학습 로드맵**
﻿
﻿| 단계 | 주제 | 학습 목표 | 상태 |
﻿| :-- | :--- | :--- | :--- |
﻿| **Step 1** | **변수와 상수** | '마법의 숫자'를 지양하고 `final`을 사용한 상수의 중요성을 이해합니다. | 완료 |
﻿| **Step 2** | **Null 처리** | `if (obj != null)` 반복을 피하고, `Optional`을 사용해 안전하고 표현력 있는 코드를 작성하는 법을 배웁니다. | 완료 |
﻿| **Step 3** | **문자열 처리** | 반복문 안에서 `+` 연산자의 비효율성을 이해하고, `StringBuilder`를 사용하는 방법을 익힙니다. | 완료 |
﻿| **Step 4** | **컬렉션과 스트림** | Java 8의 `Stream API`를 사용한 함수형 데이터 처리 방식을 학습합니다. | 완료 |
﻿| **Step 5** | **예외 처리** | 구체적인 예외를 정의하고 처리하는 방법의 중요성을 이해합니다. | 완료 |
﻿| **Step 6** | **객체 생성** | 빌더 패턴(Builder Pattern)을 사용하여 명확하고 유연하게 객체를 생성하는 방법을 배웁니다. | 완료 |
﻿| **Step 7** | **인터페이스와 구현체** | 인터페이스 기반 프로그래밍의 유연성과 확장성을 학습합니다. | 완료 |
﻿| **Step 8** | **동시성 처리** | `java.util.concurrent` 패키지를 사용한 현대적인 동시성 처리 방법을 학습합니다. | 완료 |
﻿| **Step 9** | **제네릭 심화** | 와일드카드(`? super T`, `? extends T`) 등 제네릭의 고급 활용법을 익힙니다. | 완료 |
﻿| **Step 10**| **람다와 메소드 참조** | 람다 표현식과 메소드 참조로 간결하고 함수형 스타일의 코드를 작성하는 법을 학습합니다. | 완료 |
﻿| **Step 11**| **새로운 `switch` 표현식 (Java 14+)** | `->`와 `yield`를 사용하는 새로운 `switch` 표현식의 장점을 이해하고 활용법을 배웁니다. | 완료 |
﻿| **Step 12**| **레코드 (Records - Java 16+)** | `record` 키워드를 통해 불변 데이터 객체를 간결하게 생성하는 방법을 학습합니다. | 완료 |
﻿| **Step 13**| **가상 스레드 (Virtual Threads - Java 21+)** | `Thread-per-request` 모델의 한계를 이해하고, 가상 스레드로 높은 처리량의 동시성 코드를 작성하는 법을 배웁니다. | 진행중 |
﻿
﻿---
﻿
﻿### 빠른 실행 안내 (Step 1~3)
```bash
# JDK 17+ 권장, 파일마다 컴파일 후 실행
javac Step1_VariablesAndConstants.java && java Step1_VariablesAndConstants
javac Step2_NullHandling.java && java Step2_NullHandling
javac Step3_StringManipulation.java && java Step3_StringManipulation
```
> bad 예시는 주석을 풀어 실행하며 경고/예외를 직접 경험해보세요.

---

### **각 단계별 상세 내용 (예시)**
﻿
﻿#### **Step 1: 변수와 상수**
﻿- **나쁜 예시**: 코드에 `86400`과 같은 의미를 알 수 없는 숫자를 직접 사용합니다. (매직 넘버)
﻿- **좋은 예시**: `public static final int SECONDS_PER_DAY = 86400;` 와 같이 의미를 명확히 알 수 있는 상수로 정의합니다.
﻿- **학습 포인트**: 매직 넘버는 가독성과 유지보수성을 크게 해칩니다. 상수를 사용하면 코드 자체가 문서화되어(Self-documenting) 의미를 명확히 하고, 변경 발생 시 수정 범위를 최소화할 수 있습니다.
﻿
﻿#### **Step 13: 가상 스레드 (Virtual Threads)**
﻿- **나쁜 예시**: 기존 플랫폼 스레드를 스레드 풀과 함께 사용하여 요청마다 스레드를 할당하여, 많은 요청이 몰릴 경우 스레드 부족 및 높은 컨텍스트 스위칭 비용을 유발합니다.
﻿- **좋은 예시**: `Executors.newVirtualThreadPerTaskExecutor()`를 사용하여 각 작업을 가상 스레드에서 실행함으로써, 매우 높은 처리량과 간단한 코드를 유지합니다.
﻿- **학습 포인트**: Java 21에 도입된 가상 스레드는 경량의 사용자 수준 스레드로, 기존 플랫폼 스레드보다 생성 비용이 훨씬 저렴합니다. 이를 통해 '하나의 요청에 하나의 스레드'라는 직관적인 모델을 유지하면서도 수백만 개의 동시 작업을 효율적으로 처리할 수 있어, 고성능 서버 애플리케이션 개발이 용이해집니다.
﻿
﻿---
﻿
﻿### **생성될 Java 파일 목록**
﻿
﻿`c:/Users/Nam/Documents/Cursor/Workspace/origin/learning-code/java` 경로에 다음 파일들이 생성될 예정입니다. 각 파일은 나쁜 예시와 좋은 예시 코드를 포함하며, 상세한 주석과 JavaDoc을 통해 각 패턴을 심층적으로 학습할 수 있도록 구성될 것입니다.
﻿
﻿```
﻿learning-code/java/
﻿Step1_VariablesAndConstants.java
﻿Step2_NullHandling.java
﻿Step3_StringManipulation.java
﻿Step4_CollectionsAndStreams.java
﻿Step5_ExceptionHandling.java
﻿Step6_ObjectCreation.java
﻿Step7_Interfaces.java
﻿Step8_Concurrency.java
﻿Step9_AdvancedGenerics.java
﻿Step10_LambdasAndMethodReferences.java
﻿Step11_ModernSwitch.java
﻿Step12_Records.java
﻿Step13_VirtualThreads.java
﻿```
﻿
﻿---
﻿
﻿### **추가 학습 권장 사항**
﻿
﻿| 주제 | 설명 | 난이도 |
﻿|:-----|:-----|:------:|
﻿| **Spring Framework** | 엔터프라이즈 Java 애플리케이션 개발의 표준 프레임워크로, DI/IoC, AOP, Spring Boot 등을 학습합니다. | 중급 |
﻿| **JPA/Hibernate** | 객체-관계 매핑(ORM) 기술로, 데이터베이스 작업을 객체 지향적으로 처리하는 방법을 익힙니다. | 중급 |
﻿| **JUnit 5 & Mockito** | 단위 테스트와 모킹을 통한 테스트 주도 개발(TDD) 방법론을 학습합니다. | 중급 |
﻿| **GraalVM & Native Image** | GraalVM을 사용한 네이티브 이미지 컴파일로 빠른 시작 시간과 낮은 메모리 사용량을 달성합니다. | 고급 |
﻿| **Reactive Streams (Project Reactor)** | Non-blocking, 비동기 데이터 스트림 처리를 위한 리액티브 프로그래밍 라이브러리를 학습합니다. | 고급 |
﻿


