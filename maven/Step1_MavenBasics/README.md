# Step1: Maven 기본 개념 및 시작

이 디렉토리는 Apache Maven의 기본 개념과 프로젝트 설정 방법을 학습하기 위한 예제 코드입니다.

## 학습 목표

-   Maven 프로젝트의 기본 구조 이해
-   `pom.xml` 파일의 주요 요소 (`groupId`, `artifactId`, `version`, `packaging`, `properties`, `dependencies`, `build`) 파악
-   Maven 빌드 라이프사이클의 기본 단계 이해
-   Maven 프로젝트 빌드 및 실행 방법

## 프로젝트 구조

```
maven/Step1_MavenBasics/
├── pom.xml                   # 프로젝트 객체 모델 (Project Object Model)
└── src/
    ├── main/
    │   ├── java/
    │   │   └── com/
    │   │       └── example/
    │   │           └── maven/
    │   │               └── App.java      # 메인 애플리케이션 소스 코드
    │   └── resources/
    └── test/
        ├── java/
        │   └── com/
        │       └── example/
        │           └── maven/
        │               └── AppTest.java  # 테스트 소스 코드
        └── resources/
```

## 파일 설명

-   **`pom.xml`**:
    -   **프로젝트 식별자**: `groupId`, `artifactId`, `version`, `packaging`을 정의합니다. `packaging`은 `jar`로 설정되어 실행 가능한 JAR 파일이 빌드됨을 나타냅니다.
    -   **`properties`**: Java 컴파일러 버전(JDK 17) 및 소스 인코딩(UTF-8), JUnit 5 버전을 정의합니다.
    -   **`dependencies`**: 프로젝트가 의존하는 외부 라이브러리를 선언합니다. 여기서는 JUnit 5를 테스트 스코프(`test`) 의존성으로 추가했습니다.
    -   **`build`**: 프로젝트 빌드 관련 설정을 정의합니다.
        -   `maven-compiler-plugin`: Java 소스 코드를 컴파일하는 플러그인.
        -   `maven-surefire-plugin`: 단위 테스트를 실행하는 플러그인.
        -   `maven-jar-plugin`: 실행 가능한 JAR 파일을 생성하고 `com.example.maven.App`을 메인 클래스로 지정합니다.

-   **`src/main/java/com/example/maven/App.java`**:
    ```java
    package com.example.maven;

    public class App {
        public String getGreeting() {
            return "Hello Maven!";
        }

        public static void main(String[] args) {
            System.out.println(new App().getGreeting());
        }
    }
    ```

-   **`src/test/java/com/example/maven/AppTest.java`**:
    ```java
    package com.example.maven;

    import org.junit.jupiter.api.Test;
    import static org.junit.jupiter.api.Assertions.assertEquals;

    class AppTest {
        @Test
        void appHasAGreeting() {
            App classUnderTest = new App();
            assertEquals("Hello Maven!", classUnderTest.getGreeting(), "app should have a greeting");
        }
    }
    ```

## 빌드 및 실행 방법

`maven/Step1_MavenBasics` 디렉토리로 이동하여 다음 명령어를 실행합니다.

1.  **프로젝트 생성**:
    -   `src` 폴더를 위 구조에 맞게 생성합니다.
    -   `App.java` 및 `AppTest.java` 파일을 해당 경로에 생성하고 위 내용을 복사합니다.

2.  **프로젝트 빌드**:
    ```bash
    mvn clean install
    ```
    -   `clean` 페이즈: `target` 디렉토리를 삭제합니다.
    -   `install` 페이즈: 컴파일, 테스트, 패키징 후 로컬 Maven 저장소(`~/.m2/repository`)에 아티팩트(`step1-maven-basics-1.0-SNAPSHOT.jar`)를 설치합니다.

3.  **애플리케이션 실행**:
    -   빌드가 성공적으로 완료되면 `target` 디렉토리 아래에 실행 가능한 JAR 파일이 생성됩니다.
    -   `java -jar target/step1-maven-basics-1.0-SNAPSHOT.jar` 명령으로 실행합니다.

4.  **테스트 실행**:
    -   `mvn test`
    -   테스트 결과는 `target/surefire-reports` 디렉토리에서 확인할 수 있습니다.

## 나쁜 예시와 좋은 예시 (개념)

`pom.xml` 파일 내의 주석을 참조하여, Maven 프로젝트 설정 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 특히 플러그인 버전과 Java 버전을 `properties` 블록에 명시하고, 플러그인 설정에 버전을 고정하는 것은 빌드의 재현성과 안정성을 위해 매우 중요합니다.
