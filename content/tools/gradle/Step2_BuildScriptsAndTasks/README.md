# Step2: Gradle 빌드 스크립트 및 태스크

이 디렉토리는 Gradle의 빌드 스크립트 작성 및 태스크(Task) 관리 방법을 학습하기 위한 예제 코드입니다.

## 학습 목표

- 사용자 정의 태스크 생성 방법 이해
- 태스크 의존성 설정 (`dependsOn`)
- `doLast`, `doFirst` 클로저의 활용
- `GreetingTask`와 같은 사용자 정의 태스크 클래스 구현

## 프로젝트 구조 (개념)

이 예제는 주로 `build.gradle` 파일에 집중하며, 실제 애플리케이션 코드는 `Step1`과 유사하거나 생략될 수 있습니다. 중요한 것은 태스크 정의와 실행입니다.

```
gradle/Step2_BuildScriptsAndTasks/
├── build.gradle              # 빌드 로직 및 사용자 정의 태스크 정의
├── settings.gradle           # (선택 사항) 단일 프로젝트에서는 간단히 루트 프로젝트 이름 정의
└── (src 디렉토리는 태스크 학습을 위해 생략 가능하나, 필요시 Step1과 유사하게 구성)
```

## 파일 설명

-   **`build.gradle`**:
    -   `plugins { id 'java' }`: Java 빌드 기능을 사용하기 위해 `java` 플러그인을 적용합니다.
    -   **사용자 정의 태스크 `hello`**: `doLast` 클로저를 사용하여 간단한 메시지를 출력하는 태스크입니다.
    -   **사용자 정의 태스크 `greet` (Task 클래스 활용)**:
        -   `tasks.register('greet', GreetingTask) { ... }`: `GreetingTask` 클래스를 기반으로 `greet`라는 태스크를 등록합니다.
        -   `GreetingTask` 클래스는 `DefaultTask`를 상속받아 `message` 프로퍼티와 `greetAction()` 메서드를 가집니다. `@TaskAction` 어노테이션이 `greetAction()`에 붙어 있어 태스크 실행 시 이 메서드가 호출됩니다.
    -   **태스크 의존성 `prepareEnvironment`, `runApplication`**:
        -   `prepareEnvironment` 태스크는 환경 준비 로직을 시뮬레이션합니다.
        -   `runApplication` 태스크는 `hello`와 `prepareEnvironment` 태스크가 먼저 성공적으로 완료된 후에 실행되도록 `dependsOn`으로 의존성을 설정합니다.
    -   **`doLast` 및 `doFirst` 클로저 `dataProcessing`**:
        -   `dataProcessing` 태스크는 `doFirst`로 전처리 로직을, `doLast`로 후처리 로직을 정의하는 방법을 보여줍니다. 여러 `doLast` 클로저도 사용할 수 있습니다.

## 빌드 및 실행 방법

`gradle/Step2_BuildScriptsAndTasks` 디렉토리로 이동하여 다음 명령어를 실행합니다.

1.  **모든 태스크 목록 확인**:
    ```bash
    ./gradlew tasks --all
    # (Windows) .\gradlew tasks --all
    ```
    -   `hello`, `greet`, `prepareEnvironment`, `runApplication`, `dataProcessing` 등 정의된 태스크들을 확인할 수 있습니다.
    -   `greet` 태스크에 설정된 `description`과 `group`도 함께 표시됩니다.

2.  **`hello` 태스크 실행**:
    ```bash
    ./gradlew hello
    ```
    -   "Hello from Gradle Custom Task!" 메시지가 출력됩니다.

3.  **`greet` 태스크 실행**:
    ```bash
    ./gradlew greet
    ```
    -   "GreetingTask: 안녕, Gradle!" 메시지가 출력됩니다.

4.  **`runApplication` 태스크 실행 (태스크 의존성 확인)**:
    ```bash
    ./gradlew runApplication
    ```
    -   콘솔에 `hello` 태스크의 메시지 ("Hello from Gradle Custom Task!"), `prepareEnvironment` 태스크의 메시지 ("환경 준비 중..."), 그리고 `runApplication` 태스크의 메시지 ("애플리케이션 실행 중...")가 순서대로 출력되는 것을 확인할 수 있습니다. `dependsOn` 설정 덕분에 순서가 보장됩니다.

5.  **`dataProcessing` 태스크 실행**:
    ```bash
    ./gradlew dataProcessing
    ```
    -   `doFirst`로 정의된 "데이터 전처리 시작..." 메시지가 먼저, 그 다음 `doLast`로 정의된 "데이터 후처리 완료." 및 "결과 보고서 생성." 메시지가 순서대로 출력됩니다.

## 나쁜 예시와 좋은 예시 (개념)

`build.gradle` 파일 내의 주석을 참조하여, 태스크 정의 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 특히 태스크의 액션은 `doLast` 또는 `doFirst` 클로저 내에 정의하여 불필요한 실행을 방지하는 것이 중요합니다.
