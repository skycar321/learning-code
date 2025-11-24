# Step5: Maven CI/CD 연동 및 문제 해결

이 디렉토리는 Maven을 CI/CD(Continuous Integration/Continuous Delivery) 파이프라인에 연동하고,
빌드 문제 발생 시 효과적으로 해결하는 방법을 학습하기 위한 예제 코드입니다.

## 학습 목표

-   Maven Wrapper를 이용한 빌드 환경 일관성 확보
-   CI/CD 도구(Jenkins, GitLab CI, GitHub Actions 등)와 Maven 연동 전략 이해
-   `mvn` 명령어 옵션을 이용한 빌드 문제 진단 (`-X`, `-B`, `-U`)
-   의존성 트리 분석을 통한 충돌 해결

## 프로젝트 구조

```
maven/Step5_CICDIntegrationAndTroubleshooting/
├── pom.xml                   # Maven Wrapper 플러그인 설정
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/
│   │   │       └── example/
│   │   │           └── maven/
│   │   │               └── App.java      # 메인 애플리케이션 소스 코드
│   │   └── resources/
│   └── test/
│       ├── java/
│       │   └── com/
│       │       └── example/
│       │           └── maven/
│       │               └── AppTest.java  # 테스트 소스 코드
│       └── resources/
├── .mvn/                     # Maven Wrapper 관련 파일 (mvnw 명령 실행 후 생성)
│   └── wrapper/
│       ├── maven-wrapper.jar
│       └── maven-wrapper.properties
├── mvnw                      # Maven Wrapper 쉘 스크립트 (Linux/macOS)
├── mvnw.cmd                  # Maven Wrapper 배치 파일 (Windows)
└── README.md
```

## 파일 설명

-   **`pom.xml`**:
    -   **`maven-wrapper-plugin`**: `generate-resources` 페이즈에 바인딩되어 Wrapper를 생성하는 `wrapper` 목표(goal)를 실행합니다. `mavenVersion`을 통해 사용할 Maven 버전을 명시적으로 지정하여 빌드 환경의 일관성을 보장합니다.

## 빌드 및 실행 방법

`App.java` 및 `AppTest.java` 파일은 Step1 예제와 유사하게 구성할 수 있습니다.

`maven/Step5_CICDIntegrationAndTroubleshooting` 디렉토리에서 터미널을 엽니다.

1.  **Maven Wrapper 생성**:
    ```bash
    mvn wrapper:wrapper -Dmaven.wrapper.version=3.2.0
    ```
    -   `pom.xml`에 `maven-wrapper-plugin`이 정의되어 있으므로, `mvn clean install`과 같은 빌드 명령을 실행해도 Wrapper가 자동으로 생성됩니다.
    -   이 명령을 실행하면 `.mvn/wrapper` 디렉토리와 `mvnw`, `mvnw.cmd` 스크립트가 생성됩니다.

2.  **Wrapper를 이용한 빌드**:
    ```bash
    ./mvnw clean install
    # (Windows) .\mvnw.cmd clean install
    ```
    -   이 명령은 로컬에 Maven이 설치되어 있지 않거나, 프로젝트에 명시된 특정 버전의 Maven을 사용하고자 할 때 매우 유용합니다. CI/CD 환경에서는 항상 Wrapper 스크립트를 사용하는 것이 좋습니다.

3.  **CI/CD 파이프라인 연동 (개념)**:
    -   Jenkins, GitLab CI, GitHub Actions 등 CI/CD 도구에서 빌드 스텝에 `bash ./mvnw clean install` (또는 `.\mvnw.cmd clean install`) 명령을 추가하여 Maven 빌드를 실행합니다.
    -   `settings.xml` 파일에 원격 저장소 인증 정보가 필요한 경우, CI/CD 도구의 Secret 관리 기능을 사용하여 안전하게 주입해야 합니다.
        -   예: GitHub Actions에서 `secrets.MAVEN_USERNAME`, `secrets.MAVEN_PASSWORD` 사용.

## 문제 해결 (Troubleshooting)

Maven 빌드 실패 시 유용한 명령어 옵션:

1.  **디버그 모드 (`-X`)**:
    ```bash
    ./mvnw clean install -X
    ```
    -   빌드의 모든 단계에 대한 상세한 로그를 출력합니다. 플러그인 실행 순서, 의존성 결정 과정 등을 자세히 확인할 수 있어 문제의 원인을 파악하는 데 매우 유용합니다.

2.  **배치 모드 (`-B`)**:
    ```bash
    ./mvnw clean install -B
    ```
    -   비대화형 모드로 빌드를 실행합니다. CI/CD 환경에서 자동화된 빌드를 실행할 때 사용됩니다. 사용자 입력 없이 빌드가 진행됩니다.

3.  **의존성 강제 업데이트 (`-U`)**:
    ```bash
    ./mvnw clean install -U
    ```
    -   모든 의존성을 강제로 업데이트하여 다운로드합니다. 로컬 저장소의 캐시된 의존성에 문제가 있거나, 최신 SNAPSHOT 버전을 사용해야 할 때 유용합니다.

4.  **의존성 트리 확인 (`dependency:tree`)**:
    ```bash
    ./mvnw dependency:tree
    ```
    -   프로젝트의 모든 의존성 목록을 트리 형태로 보여줍니다. 의존성 충돌이나 불필요한 의존성을 파악하는 데 매우 중요합니다.

5.  **오프라인 모드 (`-o`)**:
    ```bash
    ./mvnw clean install -o
    ```
    -   외부 저장소에 접속하지 않고 로컬 저장소의 의존성만 사용하여 빌드를 시도합니다. 네트워크 문제나 오프라인 환경에서 테스트 빌드를 할 때 유용합니다.

## 나쁜 예시와 좋은 예시 (개념)

`pom.xml` 파일 내의 주석을 참조하여, CI/CD 연동 및 문제 해결 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 특히 Maven Wrapper를 사용하여 빌드 환경의 일관성을 유지하고, 상세 로그를 통해 문제를 진단하는 습관을 들이는 것이 중요합니다.
