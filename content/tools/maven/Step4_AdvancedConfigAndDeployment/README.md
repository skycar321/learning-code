# Step4: Maven 고급 설정 및 배포

이 디렉토리는 Maven의 고급 설정 및 아티팩트 배포 방법을 학습하기 위한 예제 코드입니다.

## 학습 목표

-   `profiles`를 이용한 환경별 빌드 설정 관리
-   `resources` 블록의 `filtering` 기능을 이용한 리소스 파일의 변수 치환
-   SNAPSHOT 버전과 RELEASE 버전의 차이 이해
-   `distributionManagement`를 이용한 원격 저장소 배포 설정
-   `settings.xml` 파일의 역할 이해

## 프로젝트 구조

```
maven/Step4_AdvancedConfigAndDeployment/
├── pom.xml                   # 고급 설정 및 배포 설정
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/
│   │   │       └── example/
│   │   │           └── maven/
│   │   │               └── App.java      # 메인 애플리케이션 소스 코드
│   │   └── resources/
│   │       └── application.properties    # 필터링될 리소스 파일
│   └── test/
│       ├── java/
│       │   └── com/
│       │       └── example/
│       │           └── maven/
│       │               └── AppTest.java  # 테스트 소스 코드
│       └── resources/
├── settings.xml (개념)       # 로컬 Maven 환경 설정 (원격 저장소 인증 정보 포함)
└── README.md
```

## 파일 설명

-   **`pom.xml`**:
    -   **`version`**: `1.0-SNAPSHOT`으로 설정되어 있어 개발 중인 버전을 나타냅니다. Maven은 `SNAPSHOT` 버전을 원격 저장소에 배포할 때 항상 최신 버전을 가져오려 합니다. 릴리즈 버전(`1.0.0` 등)은 한 번 배포되면 변경되지 않습니다.
    -   **`properties`**: `build.profile`, `db.url`, `api.endpoint` 등의 프로퍼티를 정의하고, `resources` 블록의 `filtering` 기능을 통해 `src/main/resources/application.properties` 파일 내의 플레이스홀더를 치환합니다.
    -   **`resources`**: `filtering`을 `true`로 설정하여 `src/main/resources` 디렉토리의 리소스 파일에 대해 프로퍼티 치환을 활성화합니다.
    -   **`profiles`**:
        -   `dev` 프로파일: `activeByDefault`가 `true`로 설정되어 기본적으로 활성화됩니다. 개발 환경에 맞는 `db.url`과 `api.endpoint`를 설정하고 `exec-maven-plugin`을 통해 애플리케이션 실행 태스크를 정의합니다.
        -   `prod` 프로파일: 운영 환경에 맞는 `db.url`과 `api.endpoint`를 설정하고, `maven-surefire-plugin` 설정을 통해 통합 테스트를 제외합니다. `-Pprod` 옵션으로 활성화됩니다.
    -   **`distributionManagement`**: 빌드된 아티팩트(JAR)를 원격 Maven 저장소(`repository`, `snapshotRepository`)에 배포하는 방법을 정의합니다. 이 섹션의 `id`는 `settings.xml` 파일의 `<servers>` 섹션에 정의된 ID와 일치해야 합니다.

-   **`settings.xml` (개념)**:
    -   이 파일은 Maven 설치 디렉토리의 `conf/` 또는 사용자 홈 디렉토리의 `.m2/` 폴더에 위치하며, 로컬 Maven 환경 설정을 정의합니다.
    -   `<servers>` 섹션에 `pom.xml`의 `distributionManagement`에 정의된 `id`와 동일한 ID로 원격 저장소의 인증 정보(사용자 이름, 비밀번호)를 설정합니다. **이 파일은 민감한 정보를 포함하므로 Git에 커밋하지 않아야 합니다.**
    -   `<profiles>` 및 `<activeProfiles>`를 통해 특정 프로파일을 기본적으로 활성화할 수도 있습니다.

-   **`src/main/resources/application.properties`**:
    ```properties
    # application.properties
    app.profile=${build.profile}
    app.db.url=${db.url}
    app.api.endpoint=${api.endpoint}
    ```

## 빌드 및 실행 방법

`App.java` 및 `AppTest.java` 파일은 Step1 예제와 유사하게 구성할 수 있습니다. `application.properties` 파일을 위 내용으로 `src/main/resources` 경로에 생성합니다.

`maven/Step4_AdvancedConfigAndDeployment` 디렉토리에서 터미널을 엽니다.

1.  **개발(dev) 프로파일로 빌드 및 실행 (기본 동작)**:
    ```bash
    mvn clean package exec:exec
    ```
    -   `package` 단계에서 `application.properties` 파일의 플레이스홀더가 `dev` 프로파일의 값으로 치환됩니다.
    -   `exec:exec` 목표는 `dev` 프로파일에 정의된 `exec-maven-plugin`을 실행하여 JAR 파일을 실행합니다.
    -   콘솔에 "Profile: dev", "DB URL: jdbc:h2:mem:testdb" 등의 메시지가 출력되는 것을 확인할 수 있습니다.

2.  **운영(prod) 프로파일로 빌드**:
    ```bash
    mvn clean package -Pprod
    ```
    -   `-Pprod` 옵션으로 `prod` 프로파일을 활성화합니다.
    -   `application.properties` 파일의 플레이스홀더가 `prod` 프로파일의 값으로 치환됩니다.
    -   `mvn package` 실행 후 `target/classes/application.properties` 파일을 열어 치환된 값을 직접 확인할 수 있습니다.

3.  **릴리즈 버전 배포 (개념)**:
    -   `pom.xml`의 `<version>`을 `1.0-SNAPSHOT`에서 `1.0.0`과 같은 릴리즈 버전으로 변경합니다.
    -   `mvn clean deploy` 명령을 실행합니다.
    -   Maven은 `pom.xml`의 `distributionManagement`에 정의된 `repository` (`id='central'`)로 아티팩트(`step4-advanced-config-deployment-1.0.0.jar`)를 배포하려 할 것입니다.
    -   **이 명령은 실제 원격 저장소에 접근하므로, `settings.xml`에 올바른 인증 정보가 설정되어 있지 않으면 실패합니다.**

## 나쁜 예시와 좋은 예시 (개념)

`pom.xml` 파일 내의 주석을 참조하여, Maven 고급 설정 및 배포 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 특히 `profiles`를 통한 환경별 설정 관리와 `distributionManagement`를 통한 자동화된 배포는 CI/CD 환경에서 프로젝트를 효율적으로 운영하는 데 필수적입니다. `settings.xml`을 통한 인증 정보 관리는 보안상 매우 중요합니다.
