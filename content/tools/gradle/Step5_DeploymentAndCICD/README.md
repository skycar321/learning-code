# Step5: Gradle 배포 및 CI/CD 연동

이 디렉토리는 Gradle을 이용한 아티팩트 배포 및 CI/CD(Continuous Integration/Continuous Delivery) 파이프라인 연동 방법을 학습하기 위한 예제 코드입니다.

## 학습 목표

-   `maven-publish` 플러그인을 이용한 아티팩트 게시
-   아티팩트 저장소(Nexus, Artifactory) 설정 및 인증
-   `signing` 플러그인을 이용한 아티팩트 서명 (선택 사항)
-   CI/CD 도구(`Jenkins`, `GitLab CI`, `GitHub Actions` 등)와 Gradle 연동 개념
-   `Gradle Daemon`의 역할과 빌드 속도 향상

## 프로젝트 구조 (개념)

이 예제는 `build.gradle` 파일에 주로 집중하며, 실제 애플리케이션 코드는 `Step1`과 유사하게 구성하거나 생략될 수 있습니다.

```
gradle/Step5_DeploymentAndCICD/
├── build.gradle              # 배포 및 CI/CD 관련 설정 정의
├── settings.gradle           # (선택 사항)
└── src/
    └── main/
        └── java/
            └── com/
                └── example/
                    └── gradle/
                        └── deploy/
                            └── App.java  # 메인 애플리케이션 소스 코드 (선택 사항)
```

## 파일 설명

-   **`build.gradle`**:
    -   **`plugins`**: `java`, `maven-publish`, `signing`, `application` 플러그인을 적용합니다.
    -   **`group`, `version`**: 배포될 아티팩트의 메타데이터를 정의합니다. 버전은 배포를 위해 `1.0.0`과 같은 안정적인 번호를 사용합니다.
    -   **`repositories`**: `mavenCentral()`을 설정합니다.
    -   **`dependencies`**: `Guava` 및 `JUnit 5`와 같은 의존성을 선언합니다.
    -   **`java { withSourcesJar(); withJavadocJar(); }`**: 소스 코드와 Javadoc을 포함하는 JAR 파일을 생성하도록 설정합니다. 이는 공개 저장소에 배포할 때 유용합니다.
    -   **`application { mainClass = 'com.example.gradle.deploy.App' }`**: `application` 플러그인의 메인 클래스를 지정합니다.
    -   **`publishing` 블록**:
        -   `publications`: `mavenJava`라는 이름으로 `MavenPublication`을 정의하고, `from components.java`를 통해 빌드된 JAR, Sources JAR, Javadoc JAR을 게시하도록 합니다. `pom` 블록을 통해 생성될 POM 파일에 프로젝트 정보를 상세히 추가할 수 있습니다.
        -   `repositories`: `MyRemoteRepository`라는 이름의 원격 Maven 저장소(예: Nexus)를 설정합니다. **인증 정보는 `build.gradle`에 하드코딩하지 않고 환경 변수나 `gradle.properties`를 통해 가져오는 안전한 방식을 사용합니다.**
    -   **`signing` 블록 (주석 처리)**: `signing` 플러그인을 사용하여 아티팩트에 GPG 서명을 추가하는 방법을 보여줍니다. 보안 강화를 위해 사용됩니다.
    -   **`ciBuild`, `ciPublish` 태스크**: CI/CD 파이프라인에서 Gradle을 사용하는 개념을 보여주기 위한 사용자 정의 태스크입니다. `clean`, `build`, `test`, `publish`와 같은 기본 Gradle 태스크들을 조합하여 파이프라인의 단계를 정의할 수 있습니다.

## 빌드 및 실행 방법

이 예제를 실행하려면 `App.java` 파일이 필요합니다. `Step1` 또는 `Step3` 예제의 코드를 약간 수정하여 이 디렉토리의 `src/main/java/com/example/gradle/deploy/` 경로에 맞게 사용할 수 있습니다.

**`App.java` 예시:**
```java
package com.example.gradle.deploy;

public class App {
    public static void main(String[] args) {
        System.out.println("Hello from Deployment Application!");
    }
}
```

`gradle/Step5_DeploymentAndCICD` 디렉토리 (루트 프로젝트)로 이동하여 다음 명령어를 실행합니다.

1.  **애플리케이션 빌드**:
    ```bash
    ./gradlew build
    ```
    -   컴파일, 테스트, JAR 파일 패키징, Sources JAR, Javadoc JAR 생성을 수행합니다.

2.  **아티팩트 게시 (로컬 Maven 저장소)**:
    ```bash
    ./gradlew publishToMavenLocal
    ```
    -   `maven-publish` 플러그인에 의해 제공되는 태스크입니다. 아티팩트가 로컬 Maven 저장소(일반적으로 `~/.m2/repository`)에 게시됩니다.

3.  **아티팩트 게시 (원격 저장소 - 개념)**:
    -   실제 Nexus나 Artifactory와 같은 원격 저장소가 설정되어 있고, 인증 정보(환경 변수 또는 `gradle.properties`)가 올바르게 설정된 경우에만 실행 가능합니다.
    -   `./gradlew publish`
    -   이 명령은 `publishing` 블록에 정의된 모든 publication을 모든 repository에 게시합니다.
    -   특정 publication만 게시: `./gradlew publishMavenJavaPublicationToMyRemoteRepository` (MyRemoteRepository는 `build.gradle`에서 설정한 `name`)

4.  **CI/CD 빌드 태스크 실행**:
    ```bash
    ./gradlew ciBuild
    ```
    -   `clean`, `build`, `test` 태스크를 순서대로 실행합니다.

## 나쁜 예시와 좋은 예시 (개념)

`build.gradle` 파일 내의 주석을 참조하여, 배포 및 CI/CD 연동 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 특히 보안에 민감한 정보(인증 토큰, 비밀번호)는 절대 코드에 하드코딩하지 말고, 환경 변수나 CI/CD Secret 기능을 활용하는 것이 매우 중요합니다.
