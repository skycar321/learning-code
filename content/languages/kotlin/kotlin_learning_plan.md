# Kotlin 학습 계획

## 개요 (Overview)
Kotlin은 JetBrains에서 개발한 정적으로 타입이 지정된 프로그래밍 언어로, JVM(Java Virtual Machine)에서 실행되며 Java와 100% 호환됩니다. 간결하고 안전하며 현대적인 기능을 제공하여 Android 앱 개발, 서버 사이드 애플리케이션, 웹 프론트엔드(Kotlin/JS), 그리고 크로스 플랫폼 개발(Kotlin Multiplatform) 등 다양한 분야에서 빠르게 채택되고 있습니다. 이 학습 계획은 Kotlin의 기본 문법부터 객체 지향 프로그래밍, 함수형 프로그래밍, 그리고 실무에 필요한 고급 기능까지 다루는 것을 목표로 합니다.

## 학습 목표 (Learning Objectives)
*   Kotlin의 핵심 문법 및 특징 이해
*   Java 코드와의 상호 운용성 활용
*   객체 지향 및 함수형 프로그래밍 패러다임 적용
*   코루틴(Coroutines)을 이용한 비동기 프로그래밍 마스터
*   Android 앱 또는 서버 애플리케이션 개발 능력 습득

## 학습 내용 (Learning Content)

### 1단계: Kotlin 기본 문법 및 특징 (Kotlin Basics & Features)
*   Kotlin 소개 (Introduction to Kotlin) - 탄생 배경, 장점
*   환경 설정 (Environment Setup) - IntelliJ IDEA, Android Studio
*   변수 및 데이터 타입 (Variables & Data Types) - `val`, `var`, 타입 추론
*   널 안전성(Null Safety) (Null Safety) - `?`, `!!`, `?.`, `?:` 연산자
*   흐름 제어 (Control Flow) - `if`, `when`, `for`, `while`
*   함수(Functions) - 확장 함수(Extension Functions), 중위 함수(Infix Functions), 고차 함수(Higher-Order Functions)

### 2단계: 객체 지향 프로그래밍 (Object-Oriented Programming)
*   클래스(Classes) 및 객체(Objects) (Classes & Objects)
*   생성자(Constructors) (Constructors) - 주 생성자, 보조 생성자
*   상속(Inheritance) 및 인터페이스(Interfaces) (Inheritance & Interfaces)
*   데이터 클래스(Data Classes) (Data Classes) - 자동 생성되는 메서드
*   enum 클래스 (Enum Classes)
*   싱글톤 패턴(Singleton Pattern) - `object` 키워드

### 3단계: 함수형 프로그래밍 및 컬렉션 (Functional Programming & Collections)
*   람다식(Lambdas) (Lambdas) 및 익명 함수(Anonymous Functions)
*   고차 함수(Higher-Order Functions) (Higher-Order Functions)
*   컬렉션(Collections) (Collections) - `List`, `Set`, `Map`
*   컬렉션 연산 (Collection Operations) - `map`, `filter`, `forEach`, `reduce`
*   시퀀스(Sequences) (Sequences) - 지연 평가(Lazy Evaluation)

### 4단계: 비동기 프로그래밍 (Asynchronous Programming)
*   코루틴(Coroutines) 소개 (Introduction to Coroutines) - 비동기 처리의 새로운 접근
*   `launch`, `async` 빌더 (Coroutine Builders: `launch`, `async`)
*   `suspend` 함수 (Suspend Functions)
*   스코프(Scope) (Coroutine Scope) - GlobalScope, CoroutineScope
*   구조화된 동시성 (Structured Concurrency)
*   예외 처리 (Exception Handling) - `try-catch`, CoroutineExceptionHandler

### 5단계: Java 상호 운용성 및 고급 주제 (Java Interoperability & Advanced Topics)
*   Java 코드와 Kotlin 코드의 상호 운용 (Interoperability with Java Code)
*   어노테이션(Annotations) (Annotations)
*   리플렉션(Reflection) (Reflection)
*   제네릭(Generics) (Generics)
*   위임(Delegation) (Delegation)
*   DSL(Domain Specific Language) 구축 (Building DSLs)
*   코틀린 멀티플랫폼(Kotlin Multiplatform) 소개 (Introduction to Kotlin Multiplatform)

## 예상 학습 시간 (Estimated Learning Time)
*   각 단계별 3-6시간 (총 15-30시간)

## 실습 과제 (Practical Exercises)
*   Kotlin으로 간단한 콘솔 애플리케이션 작성 (Write a simple console application in Kotlin)
*   데이터 클래스를 이용한 데이터 모델링 및 컬렉션 처리 (Model data with data classes & process collections)
*   코루틴을 활용하여 비동기 작업 구현 (Implement asynchronous operations with Coroutines)
*   간단한 Android 앱 또는 서버 API (Spring Boot + Kotlin) 개발 (Develop a simple Android app or server API)
*   기존 Java 프로젝트에 Kotlin 코드 통합 (Integrate Kotlin code into an existing Java project)

## 참고 자료 (References)
*   Kotlin 공식 문서 (Kotlin Official Documentation)
*   Kotlin in Action by Dmitry Jemerov, Svetlana Isakova
*   Programming Kotlin by Venkat Subramaniam
*   Android Developers Kotlin 가이드
