# Step1: Gradle 기본 개념 및 시작

이 디렉토리는 Gradle의 기본 개념과 프로젝트 설정 방법을 학습하기 위한 예제 코드입니다.

## 학습 목표

- Gradle 프로젝트의 기본 구조 이해
- `build.gradle` (Groovy DSL) 및 `settings.gradle` 파일의 역할 파악
- `plugins`, `group`, `version`, `repositories`, `dependencies` 블록 이해
- Gradle Wrapper의 중요성 파악

## 프로젝트 구조

```
gradle/Step1_GradleBasics/
├── build.gradle              # 프로젝트 빌드 로직 및 의존성 정의
├── settings.gradle           # 프로젝트 이름 및 멀티 프로젝트 구성 정의
└── src/
    ├── main/
    │   ├── java/
    │   │   └── com/
    │   │       └── example/
    │   │           └── App.java      # 메인 애플리케이션 소스 코드
    │   └── resources/
    └── test/
        ├── java/
        │   └── com/
        │       └── example/
        │           └── AppTest.java  # 테스트 소스 코드
        └── resources/
```

## 파일 설명

-   **`build.gradle`**:
    -   `plugins { id 'java' }`: 이 프로젝트가 Java 프로젝트임을 선언하고, Java 빌드에 필요한 태스크들을 추가합니다.
    -   `group 'com.example.gradle'`, `version '1.0-SNAPSHOT'`: 프로젝트의 그룹 ID와 버전을 정의합니다. 이는 빌드된 JAR 파일의 메타데이터에 사용됩니다.
    -   `repositories { mavenCentral() }`: 의존성을 다운로드할 저장소를 Maven Central로 설정합니다.
    -   `dependencies { testImplementation 'org.junit.jupiter:junit-jupiter-api:5.10.0' ... }`: 프로젝트의 의존성을 선언합니다. 여기서는 JUnit 5를 테스트용으로 추가했습니다.
    -   `test { useJUnitPlatform() }`: JUnit 5를 사용하여 테스트를 실행하도록 설정합니다.
    -   `java { toolchain { languageVersion = JavaLanguageVersion.of(17) } }`: Java 17을 사용하도록 설정합니다.

-   **`settings.gradle`**:
    -   `rootProject.name = 'step1-gradle-basics'`: 루트 프로젝트의 이름을 정의합니다. 단일 프로젝트에서는 이 이름이 빌드 폴더명 등에 사용됩니다. 멀티 프로젝트에서는 여기에 다른 서브 프로젝트들을 `include` 합니다.

-   **`src/main/java/com/example/App.java`**:
    ```java
    package com.example;

    public class App {
        public String getGreeting() {
            return "Hello World!";
        }

        public static void main(String[] args) {
            System.out.println(new App().getGreeting());
        }
    }
    ```

-   **`src/test/java/com/example/AppTest.java`**:
    ```java
    package com.example;

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

## 빌드 및 실행 방법

1.  **프로젝트 생성**:
    -   `gradle/Step1_GradleBasics` 디렉토리 내에 `src` 폴더를 위 구조에 맞게 생성합니다.
    -   `App.java` 및 `AppTest.java` 파일을 해당 경로에 생성하고 위 내용을 복사합니다.

2.  **Gradle Wrapper 생성 (선택 사항 - 일반적으로 프로젝트 생성 시 자동으로 생성됨)**:
    -   `Step1_GradleBasics` 디렉토리로 이동하여 `gradle wrapper --gradle-version 8.4` (원하는 Gradle 버전) 명령을 실행합니다.
    -   이 명령을 실행하면 `gradlew` (Windows: `gradlew.bat`) 스크립트와 `gradle/wrapper` 디렉토리가 생성됩니다.

3.  **애플리케이션 빌드**:
    -   `Step1_GradleBasics` 디렉토리에서 터미널을 엽니다.
    -   `./gradlew build` (Windows: `.\gradlew build`) 명령을 실행합니다.
    -   이 명령은 소스 코드 컴파일, 테스트 실행, JAR 파일 패키징 등 `java` 플러그인에 정의된 모든 빌드 단계를 수행합니다.

4.  **애플리케이션 실행**:
    -   빌드가 성공적으로 완료되면 `build/libs` 디렉토리 아래에 JAR 파일이 생성됩니다.
    -   `java -jar build/libs/step1-gradle-basics-1.0-SNAPSHOT.jar` 명령으로 실행합니다.
    -   (이 예시에는 Application 플러그인이 적용되지 않아 실행 가능한 JAR 파일은 아니지만, `main` 메서드가 있어 `java -jar`로 직접 실행 가능합니다.)

5.  **테스트 실행**:
    -   `./gradlew test` (Windows: `.\gradlew test`) 명령을 실행합니다.
    -   테스트 결과는 `build/reports/tests/test/index.html`에서 확인할 수 있습니다.

## 나쁜 예시와 좋은 예시 (개념)

`build.gradle` 파일 내의 주석을 참조하여, 각 설정 블록에서 나쁜 예시와 좋은 예시의 개념을 이해하고 모범 사례를 따르도록 노력하세요. Gradle은 유연하지만, 그만큼 잘못된 설정으로 인해 빌드 프로세스가 복잡해지거나 비효율적이 될 수 있습니다.
