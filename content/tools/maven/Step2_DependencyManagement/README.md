# Step2: Maven `pom.xml` 설정 및 의존성 관리

이 디렉토리는 Maven의 `pom.xml` 파일 설정과 의존성 관리 기법을 학습하기 위한 예제 코드입니다.

## 학습 목표

-   다양한 의존성 범위(scopes: `compile`, `test`, `provided`, `runtime`) 이해
-   의존성 충돌 해결 방법 (`<exclusions>`)
-   `dependencyManagement`를 이용한 의존성 버전 중앙 관리
-   `pluginManagement`를 이용한 플러그인 버전 중앙 관리

## 프로젝트 구조

```
maven/Step2_DependencyManagement/
├── pom.xml                   # 의존성 관리 설정
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
    -   **`properties`**: `junit.jupiter.version`, `spring.boot.version`, `log4j.version` 등 의존성 버전을 중앙에서 관리하기 위한 프로퍼티를 정의합니다.
    -   **`dependencies`**:
        -   `com.google.guava:guava`: `compile` 스코프의 예시 (기본값).
        -   `org.junit.jupiter:junit-jupiter-api`, `org.junit.jupiter:junit-jupiter-engine`, `org.mockito:mockito-core`: `test` 스코프의 예시. 테스트 시에만 필요합니다.
        -   `ch.qos.logback:logback-classic`: `runtime` 스코프의 예시. 런타임에만 필요합니다.
        -   `org.springframework.boot:spring-boot-starter-web`: Spring Boot 프로젝트에서 웹 기능을 제공하는 의존성입니다. `<exclusions>`를 사용하여 이 스타터에 포함된 특정 전이적(transitive) 의존성(`log4j-to-slf4j`)을 제외하는 방법을 보여줍니다. 이를 통해 의존성 충돌을 방지하거나 불필요한 라이브러리를 제외할 수 있습니다.
    -   **`dependencyManagement`**: 이 섹션 자체는 의존성을 추가하지 않습니다. 대신, 이 프로젝트 또는 하위 모듈에서 사용될 의존성의 `version`과 `scope`를 중앙에서 정의하여 의존성 버전을 일관되게 관리합니다. Spring Boot의 `spring-boot-dependencies` BOM(Bill of Materials)을 `import` 스코프로 가져와 여러 Spring 관련 라이브러리의 호환되는 버전을 한 번에 관리하는 좋은 예시입니다.
    -   **`pluginManagement`**: `dependencyManagement`와 유사하게, 빌드 플러그인의 버전을 중앙에서 관리합니다. `<build>` 섹션의 `<plugins>`에서 플러그인을 선언할 때 버전을 생략하면 여기서 정의된 버전이 적용됩니다.

## 빌드 및 실행 방법

`App.java` 및 `AppTest.java` 파일은 Step1 예제와 유사하게 구성할 수 있습니다.

1.  **프로젝트 준비**:
    -   `src` 폴더를 위 구조에 맞게 생성합니다.
    -   `App.java` (간단한 "Hello Maven!" 출력) 파일을 `src/main/java/com/example/maven/` 경로에 생성합니다.
    -   `AppTest.java` (간단한 테스트) 파일을 `src/test/java/com/example/maven/` 경로에 생성합니다.

2.  **의존성 트리 확인**:
    -   `maven/Step2_DependencyManagement` 디렉토리에서 터미널을 엽니다.
    -   `mvn dependency:tree` 명령을 실행하여 프로젝트의 의존성 트리를 확인합니다.
    -   `spring-boot-starter-web`에 대한 `<exclusions>` 설정이 Log4j 관련 의존성을 어떻게 제외하는지 확인합니다.
    -   `dependencyManagement`에 정의된 버전들이 어떻게 `dependencies` 블록에서 사용되는지도 확인합니다.

3.  **프로젝트 빌드**:
    ```bash
    mvn clean install
    ```
    -   컴파일, 테스트, 패키징이 수행됩니다. 의존성 스코프에 따라 필요한 라이브러리만 다운로드되고 빌드에 포함됩니다.

## 나쁜 예시와 좋은 예시 (개념)

`pom.xml` 파일 내의 주석을 참조하여, Maven 의존성 관리 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 특히 `dependencyManagement`와 `pluginManagement`를 사용하여 버전을 중앙에서 관리하고, 의존성 스코프를 정확히 지정하는 것은 대규모 프로젝트의 빌드 안정성과 재현성을 위해 매우 중요합니다.
