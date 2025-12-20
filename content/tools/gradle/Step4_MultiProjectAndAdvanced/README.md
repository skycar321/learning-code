# Step4: Gradle 멀티 프로젝트 빌드 및 고급 주제

이 디렉토리는 Gradle을 이용한 멀티 프로젝트 빌드 구성 및 고급 주제를 학습하기 위한 예제 코드입니다.

## 학습 목표

-   `settings.gradle`을 이용한 멀티 프로젝트 구조 정의
-   루트 `build.gradle`에서 서브 프로젝트에 공통 설정 적용 (`allprojects`, `subprojects`)
-   `project(':subproject-name')` 문법을 이용한 서브 프로젝트 간 의존성 관리
-   `java-library` 플러그인을 이용한 라이브러리 프로젝트 생성

## 프로젝트 구조

```
gradle/Step4_MultiProjectAndAdvanced/
├── settings.gradle           # 루트 프로젝트 설정, 서브 프로젝트 정의
├── build.gradle              # 루트 프로젝트의 공통 설정
├── app/                      # 서브 프로젝트 1 (실행 가능한 애플리케이션)
│   ├── build.gradle
│   └── src/
│       └── main/
│           └── java/
│               └── com/
│                   └── example/
│                       └── app/
│                           └── App.java      # 메인 애플리케이션 소스 코드
├── library/                  # 서브 프로젝트 2 (재사용 가능한 라이브러리)
│   ├── build.gradle
│   └── src/
│       └── main/
│           └── java/
│               └── com/
│                   └── example/
│                       └── lib/
│                           └── Greeter.java  # 라이브러리 소스 코드
└── README.md
```

## 파일 설명

-   **`settings.gradle`**:
    -   `rootProject.name = 'multi-project-example'`: 멀티 프로젝트의 루트 이름을 정의합니다.
    -   `include 'app', 'library'`: `app`과 `library`라는 두 개의 서브 프로젝트를 빌드에 포함시킵니다. Gradle은 이 이름과 동일한 디렉토리를 찾아 서브 프로젝트로 인식합니다.

-   **루트 `build.gradle`**:
    -   `allprojects { ... }`: 루트 프로젝트를 포함한 모든 프로젝트에 공통적으로 `group`, `version`, `repositories`를 설정합니다.
    -   `subprojects { ... }`: 루트 프로젝트를 제외한 모든 서브 프로젝트에 `java` 플러그인, `java` 컴파일러 버전, `dependencies`, `test` 설정을 공통으로 적용합니다. 이렇게 함으로써 각 서브 프로젝트의 `build.gradle` 파일에서 중복되는 설정을 줄일 수 있습니다.

-   **`app/build.gradle`**:
    -   `plugins { id 'application' }`: `app` 프로젝트가 실행 가능한 애플리케이션임을 명시합니다.
    -   `application { mainClass = 'com.example.app.App' }`: 애플리케이션의 메인 클래스를 지정합니다.
    -   `dependencies { implementation project(':library') }`: `app` 프로젝트가 `library` 서브 프로젝트에 의존함을 선언합니다. 이를 통해 `app`에서 `library`의 코드를 사용할 수 있습니다.
    -   `implementation 'com.google.guava:guava:32.1.3-jre'`: `app` 프로젝트에만 필요한 외부 의존성을 추가합니다.

-   **`app/src/main/java/com/example/app/App.java`**:
    -   `com.example.lib.Greeter` 클래스를 사용하여 `library` 프로젝트의 기능을 호출합니다.

-   **`library/build.gradle`**:
    -   `plugins { id 'java-library' }`: 이 프로젝트가 다른 프로젝트에서 사용될 라이브러리임을 명시합니다. (`api` 및 `implementation` 구성 사용 가능)
    -   `dependencies { implementation 'org.apache.commons:commons-lang3:3.12.0' }`: `library` 프로젝트에만 필요한 외부 의존성을 추가합니다. 이 의존성은 `library` 내부에서만 사용되고, `library`를 의존하는 `app` 프로젝트에는 전이되지 않습니다 (기본 `implementation` 스코프).

-   **`library/src/main/java/com/example/lib/Greeter.java`**:
    -   간단한 `getGreeting()` 메서드를 제공하는 클래스입니다. `StringUtils`와 같은 `commons-lang3` 라이브러리의 기능을 사용합니다.

## 빌드 및 실행 방법

`gradle/Step4_MultiProjectAndAdvanced` 디렉토리 (루트 프로젝트)로 이동하여 다음 명령어를 실행합니다.

1.  **전체 프로젝트 빌드**:
    ```bash
    ./gradlew build
    # (Windows) .\gradlew build
    ```
    -   이 명령은 `app`과 `library`를 포함한 모든 서브 프로젝트를 빌드합니다. `app` 프로젝트가 `library` 프로젝트보다 먼저 빌드되어야 하는 의존성을 Gradle이 자동으로 처리합니다.

2.  **특정 서브 프로젝트 빌드**:
    ```bash
    ./gradlew :app:build
    ./gradlew :library:build
    ```
    -   콜론(`:`)을 사용하여 서브 프로젝트를 지정합니다.

3.  **`app` 프로젝트 실행**:
    ```bash
    ./gradlew :app:run
    ```
    -   `app` 프로젝트의 `main` 메서드가 실행되고, `library` 프로젝트의 `Greeter` 클래스로부터 받은 메시지가 출력됩니다.

4.  **모든 태스크 목록 확인**:
    ```bash
    ./gradlew tasks --all
    ```
    -   루트 프로젝트의 태스크와 `:app:`, `:library:` 접두사가 붙은 서브 프로젝트의 태스크들을 모두 확인할 수 있습니다.

## 나쁜 예시와 좋은 예시 (개념)

`build.gradle` 파일 내의 주석을 참조하여, 멀티 프로젝트 구성 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 특히 서브 프로젝트 간의 의존성 관리와 공통 설정의 중앙 집중화는 대규모 프로젝트의 빌드 효율성과 유지보수성을 결정하는 중요한 요소입니다.
