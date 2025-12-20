# Step3: Gradle 의존성 관리 및 플러그인

이 디렉토리는 Gradle을 이용한 의존성 관리 및 다양한 플러그인 활용 방법을 학습하기 위한 예제 코드입니다.

## 학습 목표

-   `plugins` 블록을 이용한 플러그인 선언 및 버전 관리
-   `repositories` 블록을 이용한 의존성 저장소 설정
-   `dependencies` 블록의 다양한 의존성 구성(`implementation`, `api`, `compileOnly`, `testImplementation`, `annotationProcessor`) 이해
-   `application` 플러그인을 활용한 실행 가능한 JAR 파일 빌드 및 실행
-   `ext` 블록을 이용한 의존성 버전 관리 개념

## 프로젝트 구조 (개념)

이 예제는 주로 `build.gradle` 파일에 집중하며, `App.java` 및 `AppTest.java` 파일은 Step1과 동일하게 구성할 수 있습니다.

```
gradle/Step3_DependencyManagementAndPlugins/
├── build.gradle              # 빌드 로직, 의존성 및 플러그인 정의
├── settings.gradle           # (선택 사항) 단일 프로젝트에서는 간단히 루트 프로젝트 이름 정의
└── src/
    └── main/
        └── java/
            └── com/
                └── example/
                    └── gradle/
                        └── deps/
                            └── App.java  # 메인 애플리케이션 소스 코드
    └── test/
        └── java/
            └── com/
                └── example/
                    └── gradle/
                        └── deps/
                            └── AppTest.java # 테스트 소스 코드
```

## 파일 설명

-   **`build.gradle`**:
    -   **`plugins`**: `java`와 `application` 플러그인을 적용하여 Java 프로젝트를 빌드하고 실행 가능한 애플리케이션으로 만들 수 있도록 합니다. Spring Boot 플러그인 등 다른 플러그인 사용 예시가 주석 처리되어 있습니다.
    -   **`group`, `version`**: 프로젝트 메타데이터를 정의합니다.
    -   **`repositories`**: `mavenCentral()`, `google()` 등 의존성을 가져올 저장소를 설정합니다.
    -   **`dependencies`**:
        -   `implementation 'com.google.guava:guava:32.1.3-jre'`: `Guava` 라이브러리를 `implementation` 구성으로 추가합니다.
        -   `compileOnly 'org.projectlombok:lombok:1.18.30'`, `annotationProcessor 'org.projectlombok:lombok:1.18.30'`: `Lombok`을 컴파일 시에만 사용하고, 어노테이션 프로세서를 지정합니다.
        -   `testImplementation`, `testRuntimeOnly`: JUnit 5를 테스트 스코프 의존성으로 추가합니다.
        -   `ext` 블록을 사용하여 의존성 버전을 중앙에서 관리하는 예시를 보여줍니다.
    -   **`application`**: `mainClass`를 `com.example.gradle.deps.App`으로 지정하여 `run` 태스크 및 실행 가능한 JAR 파일의 메인 클래스를 설정합니다.
    -   **`java`**: Java 17을 사용하도록 툴체인을 설정합니다.
    -   **`test`**: JUnit Platform을 사용하여 테스트를 실행하도록 설정합니다.

## 빌드 및 실행 방법

이 예제를 실행하려면 `App.java` 및 `AppTest.java` 파일이 필요합니다. `Step1` 예제의 코드를 약간 수정하여 이 디렉토리에 맞게 사용할 수 있습니다.

1.  **프로젝트 준비**:
    -   `gradle/Step3_DependencyManagementAndPlugins` 디렉토리 내에 `src` 폴더를 위 구조에 맞게 생성합니다.
    -   `App.java` 파일 (간단한 "Hello World!" 출력)을 `src/main/java/com/example/gradle/deps/` 경로에 생성합니다. (Lombok 사용 예시를 위해 Lombok 어노테이션을 추가할 수도 있습니다.)
    -   `AppTest.java` 파일 (간단한 테스트)을 `src/test/java/com/example/gradle/deps/` 경로에 생성합니다.

    **`App.java` 예시 (Lombok 사용 예시 포함)**:
    ```java
    package com.example.gradle.deps;

    import lombok.Data; // Lombok 어노테이션

    @Data // Getter, Setter, toString, equals, hashCode 등을 자동으로 생성
    public class App {
        private String greeting = "Hello World!";

        public static void main(String[] args) {
            App app = new App();
            System.out.println(app.getGreeting());
            // Guava 라이브러리 사용 예시 (컴파일 후 실행 시 확인 가능)
            // System.out.println(com.google.common.base.Strings.repeat("Guava! ", 3));
        }
    }
    ```

    **`AppTest.java` 예시**:
    ```java
    package com.example.gradle.deps;

    import org.junit.jupiter.api.Test;
    import static org.junit.jupiter.api.Assertions.assertEquals;

    class AppTest {
        @Test
        void appHasAGreeting() {
            App classUnderTest = new App();
            assertEquals("Hello World!", classUnderTest.getGreeting(), "app should have a greeting");
        }
    }
    ```

2.  **의존성 설치 및 빌드**:
    -   `gradle/Step3_DependencyManagementAndPlugins` 디렉토리에서 터미널을 엽니다.
    -   `./gradlew build` (Windows: `.\gradlew build`) 명령을 실행합니다.
    -   Gradle이 `mavenCentral()`에서 `Guava`, `Lombok`, `JUnit 5` 등의 의존성을 다운로드하고, 컴파일, 테스트, JAR 파일 패키징을 수행합니다.

3.  **애플리케이션 실행**:
    -   `./gradlew run` 명령을 실행합니다. `application` 플러그인 덕분에 이 명령으로 `mainClass`에 지정된 `App.java`의 `main` 메서드가 실행됩니다.
    -   또는 `build/libs` 디렉토리 아래에 생성된 JAR 파일을 `java -jar build/libs/step3-dependency-management-and-plugins-1.0-SNAPSHOT.jar` 명령으로 실행합니다. (이 경우 `mainClass`가 포함된 실행 가능한 JAR이 생성됩니다.)

## 나쁜 예시와 좋은 예시 (개념)

`build.gradle` 파일 내의 주석을 참조하여, 의존성 관리 및 플러그인 사용 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 특히 의존성 구성의 선택은 빌드 성능과 애플리케이션 번들 크기, 그리고 모듈 간의 캡슐화에 중요한 영향을 미칩니다.
