# Step3: Maven 빌드 라이프사이클 및 플러그인

이 디렉토리는 Maven의 빌드 라이프사이클, 단계(Phase), 목표(Goal)의 개념과
주요 빌드 플러그인 활용 방법을 학습하기 위한 예제 코드입니다.

## 학습 목표

-   Maven의 3가지 빌드 라이프사이클 (`clean`, `default`, `site`) 이해
-   `default` 라이프사이클의 주요 단계 (`validate`, `compile`, `test`, `package`, `install`, `deploy`) 파악
-   플러그인이 특정 단계(Phase)에 목표(Goal)를 바인딩하여 실행되는 방식 이해
-   `maven-compiler-plugin`, `maven-surefire-plugin`, `maven-failsafe-plugin`, `maven-jar-plugin` 등 주요 플러그인 설정 방법

## 프로젝트 구조

```
maven/Step3_BuildLifecycleAndPlugins/
├── pom.xml                   # 빌드 라이프사이클 및 플러그인 설정
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
        │               ├── AppTest.java          # 단위 테스트 소스 코드
        │               └── AppIntegrationTest.java # 통합 테스트 소스 코드
        └── resources/
```

## 파일 설명

-   **`pom.xml`**:
    -   **`properties`**: Java 컴파일러 버전(JDK 17) 및 JUnit 5 버전을 정의합니다.
    -   **`dependencies`**: JUnit 5 의존성을 `test` 스코프로 추가합니다.
    -   **`build`**: 빌드 플러그인 설정을 포함합니다.
        -   `maven-compiler-plugin`: Java 소스 코드를 컴파일하는 플러그인. `compile` 단계에 바인딩됩니다.
        -   `maven-surefire-plugin`: 단위 테스트를 실행하는 플러그인. `test` 단계에 바인딩되며, `-DskipTests` 옵션을 사용하면 이 플러그인이 실행되지 않습니다.
            -   `excludes` 및 `includes` 설정을 통해 단위 테스트만 실행하도록 구성합니다.
        -   `maven-failsafe-plugin`: 통합 테스트를 실행하는 플러그인. `integration-test` 및 `verify` 단계에 바인딩되며, 통합 테스트만 실행하도록 구성합니다.
            -   단위 테스트와 통합 테스트를 분리하여 관리하는 좋은 방법입니다.
        -   `maven-jar-plugin`: `package` 단계에 바인딩되어 실행 가능한 JAR 파일을 생성하고, 메인 클래스를 `com.example.maven.App`으로 지정합니다.

## 빌드 라이프사이클 및 명령어

`App.java`, `AppTest.java`, `AppIntegrationTest.java` 파일은 Step1 예제와 유사하게 구성할 수 있습니다. `AppIntegrationTest.java` 파일은 비어 있어도 무방합니다.

`maven/Step3_BuildLifecycleAndPlugins` 디렉토리에서 터미널을 엽니다.

1.  **클린 (Clean) 라이프사이클**:
    ```bash
    mvn clean
    ```
    -   `target` 디렉토리를 삭제합니다.

2.  **컴파일 (Compile) 단계**:
    ```bash
    mvn compile
    ```
    -   `validate` -> `compile` 단계까지 실행됩니다. `src/main/java`의 소스 코드가 컴파일되어 `target/classes` 디렉토리에 `.class` 파일이 생성됩니다.

3.  **테스트 (Test) 단계**:
    ```bash
    mvn test
    ```
    -   `validate` -> `compile` -> `test` 단계까지 실행됩니다. `src/test/java`의 단위 테스트 코드가 컴파일되고 `maven-surefire-plugin`에 의해 실행됩니다.

4.  **패키지 (Package) 단계**:
    ```bash
    mvn package
    ```
    -   `validate` -> ... -> `test` -> `package` 단계까지 실행됩니다. 컴파일 및 테스트가 완료된 후, `maven-jar-plugin`에 의해 `target` 디렉토리에 `step3-build-lifecycle-plugins-1.0-SNAPSHOT.jar` 파일이 생성됩니다.

5.  **설치 (Install) 단계**:
    ```bash
    mvn install
    ```
    -   `validate` -> ... -> `package` -> `install` 단계까지 실행됩니다. 패키징된 아티팩트가 로컬 Maven 저장소(`~/.m2/repository`)에 설치됩니다.

6.  **통합 테스트 실행**:
    -   통합 테스트는 일반적으로 `verify` 단계에서 실행됩니다.
    ```bash
    mvn verify
    ```
    -   `maven-failsafe-plugin`이 `integration-test` 단계를 실행하고 `verify` 단계에서 결과를 검증합니다.

## 나쁜 예시와 좋은 예시 (개념)

`pom.xml` 파일 내의 주석을 참조하여, Maven 빌드 라이프사이클 및 플러그인 사용 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 특히 단위 테스트와 통합 테스트를 별도의 플러그인(`maven-surefire-plugin`, `maven-failsafe-plugin`)으로 분리하여 실행하는 것은 테스트 전략을 효율적으로 관리하는 데 도움이 됩니다.
