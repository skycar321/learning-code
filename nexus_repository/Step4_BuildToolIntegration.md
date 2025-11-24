# Nexus Repository 학습 계획 - 4단계: 빌드 도구 연동
# 이 파일은 Nexus Repository Manager와 다양한 빌드 도구(Maven, Gradle, npm, Docker)를
# 연동하는 방법을 학습하기 위한 개념적인 설명 및 코드 스니펫 예시입니다.
#
# 빌드 도구와 Nexus를 연동함으로써 외부 의존성을 캐싱하고, 자체 개발 아티팩트를 배포하며,
# 일관된 빌드 환경을 구축할 수 있습니다.

## 개요 (Overview)
개발 워크플로우에서 빌드 도구는 외부 라이브러리를 가져오고(consume), 프로젝트를 빌드하며,
결과물(아티팩트)을 배포(publish)하는 핵심적인 역할을 합니다. Nexus Repository와 이러한
빌드 도구를 연동하는 것은 CI/CD 파이프라인의 핵심 구성 요소입니다.

## 학습 목표 (Learning Objectives)
*   **Maven:** `settings.xml`과 `pom.xml`을 이용한 Nexus 연동
*   **Gradle:** `build.gradle`을 이용한 Nexus 연동
*   **npm:** `.npmrc` 파일을 이용한 Nexus 연동
*   **Docker:** Docker 클라이언트를 이용한 Nexus Docker Registry 연동
*   빌드 도구별 아티팩트 배포 및 소비 방법 이해

## 학습 내용 (Learning Content)

### 1. Maven 연동

#### 1.1. `settings.xml` 설정 (로컬 Maven 환경)
*   **목표**: Maven이 Nexus Repository Manager에서 아티팩트를 가져오고(consume), 배포할 수 있도록 설정합니다.
*   **경로**: `~/.m2/settings.xml` (사용자별) 또는 `$M2_HOME/conf/settings.xml` (전역)
*   **주요 설정**:
    -   `<servers>`: Nexus에 배포할 때 사용될 인증 정보(사용자 이름, 비밀번호)를 정의합니다. `id`는 `pom.xml`의 `distributionManagement` 섹션에 정의된 `repository` 또는 `snapshotRepository`의 `id`와 일치해야 합니다.
    -   `<mirrors>`: 모든 의존성 요청을 Nexus의 Group Repository로 리다이렉션하여, 모든 아티팩트가 Nexus를 통해 가져와지도록 합니다.
    -   `<profiles>`: 환경별 설정을 정의하고, `<activeProfiles>`를 통해 특정 프로파일을 기본적으로 활성화합니다.
*   **코드 스니펫 (`~/.m2/settings.xml` 예시)**:
    ```xml
    <settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd">

      <servers>
        <!-- Nexus Release Repository에 배포할 때 사용될 인증 정보 -->
        <server>
          <id>nexus-releases</id>
          <username>deployment</username>
          <password>deployment_password</password> <!-- CI/CD에서는 환경 변수 또는 Secret 사용 -->
        </server>
        <!-- Nexus Snapshot Repository에 배포할 때 사용될 인증 정보 -->
        <server>
          <id>nexus-snapshots</id>
          <username>deployment</username>
          <password>deployment_password</password>
        </server>
        <!-- Nexus Hosted npm Repository에 배포할 때 사용될 인증 정보 -->
        <server>
          <id>nexus-npm-hosted</id>
          <username>deployment</username>
          <password>deployment_password</password>
        </server>
      </servers>

      <mirrors>
        <!-- 모든 Maven 요청을 Nexus Group Repository로 리다이렉션 -->
        <mirror>
          <id>nexus-group</id>
          <mirrorOf>*</mirrorOf>
          <url>http://localhost:8081/repository/maven-group/</url>
        </mirror>
      </mirrors>

      <profiles>
        <profile>
          <id>nexus</id>
          <repositories>
            <repository>
              <id>nexus-group</id>
              <url>http://localhost:8081/repository/maven-group/</url>
              <releases><enabled>true</enabled></releases>
              <snapshots><enabled>true</enabled></snapshots>
            </repository>
          </repositories>
          <pluginRepositories>
            <pluginRepository>
              <id>nexus-group</id>
              <url>http://localhost:8081/repository/maven-group/</url>
              <releases><enabled>true</enabled></releases>
              <snapshots><enabled>true</enabled></snapshots>
            </pluginRepository>
          </pluginRepositories>
        </profile>
      </profiles>

      <activeProfiles>
        <!-- 'nexus' 프로파일을 항상 활성화 -->
        <activeProfile>nexus</activeProfile>
      </activeProfiles>

    </settings>
    ```
*   **나쁜 예시**: `settings.xml`에 인증 정보를 하드코딩하여 Git에 커밋하는 것.
    -   보안에 매우 취약하며, 민감 정보가 노출됩니다. CI/CD 환경에서는 Secret 기능을 사용하고, 로컬에서는 `~/.m2/settings.xml` 파일에만 저장해야 합니다.

#### 1.2. `pom.xml` 배포 설정 (Maven 프로젝트)
*   **목표**: `mvn deploy` 명령을 통해 빌드된 아티팩트를 Nexus Hosted Repository에 배포하도록 `pom.xml`을 설정합니다.
*   **주요 설정**:
    -   `<distributionManagement>`: 배포될 아티팩트의 대상 저장소를 정의합니다.
        -   `<repository>`: 릴리즈 아티팩트의 대상. `id`는 `settings.xml`의 `server` `id`와 일치해야 합니다.
        -   `<snapshotRepository>`: 스냅샷 아티팩트의 대상. `id`는 `settings.xml`의 `server` `id`와 일치해야 합니다.
*   **코드 스니펫 (`pom.xml` 예시)**:
    ```xml
    <project>
        <!-- ... (기존 pom.xml 내용) ... -->
        <modelVersion>4.0.0</modelVersion>
        <groupId>com.example</groupId>
        <artifactId>my-maven-app</artifactId>
        <version>1.0.0-SNAPSHOT</version> <!-- SNAPSHOT 버전 또는 1.0.0과 같은 릴리즈 버전 -->

        <distributionManagement>
            <repository>
                <id>nexus-releases</id> <!-- settings.xml의 server ID와 일치 -->
                <name>Nexus Releases</name>
                <url>http://localhost:8081/repository/maven-releases/</url>
            </repository>
            <snapshotRepository>
                <id>nexus-snapshots</id> <!-- settings.xml의 server ID와 일치 -->
                <name>Nexus Snapshots</name>
                <url>http://localhost:8081/repository/maven-snapshots/</url>
            </snapshotRepository>
        </distributionManagement>

        <!-- ... (빌드 플러그인 등) ... -->
    </project>
    ```
*   **배포**:
    -   릴리즈 버전 아티팩트 배포: `mvn clean deploy` (버전이 SNAPSHOT이 아니면 `repository`에 배포)
    -   스냅샷 버전 아티팩트 배포: `mvn clean deploy` (버전이 SNAPSHOT이면 `snapshotRepository`에 배포)

### 2. Gradle 연동

#### 2.1. `build.gradle` 설정 (Gradle 프로젝트)
*   **목표**: Gradle 프로젝트가 Nexus Repository Manager에서 의존성을 가져오고 배포할 수 있도록 설정합니다.
*   **주요 설정**:
    -   `plugins { id 'maven-publish' }`: 아티팩트 게시를 위한 플러그인 적용.
    -   `repositories`: Nexus의 Group Repository URL을 설정합니다.
    -   `publishing`: 게시할 아티팩트와 대상 저장소를 정의합니다.
*   **코드 스니펫 (`build.gradle` 예시)**:
    ```groovy
    plugins {
        id 'java'
        id 'maven-publish' // Maven 저장소에 게시하기 위한 플러그인
    }

    group 'com.example'
    version '1.0.0-SNAPSHOT' // SNAPSHOT 또는 릴리즈 버전

    repositories {
        // 모든 의존성을 Nexus Group Repository에서 가져오도록 설정
        maven {
            url 'http://localhost:8081/repository/maven-group/'
            // 나쁜 예시: `http://` 대신 `https://`를 사용해야 하는데 SSL 인증서 문제가 발생해도
            // - 무시하고 진행하는 설정 (allowInsecureProtocol)을 사용하는 것.
            // - 보안 위험이 있으므로 항상 유효한 SSL 인증서를 사용해야 합니다.
            allowInsecureProtocol = true // 개발/테스트용 (프로덕션에서는 비활성화)
        }
        mavenCentral() // Nexus가 다운되면 Fallback으로 사용할 수 있도록 추가
    }

    dependencies {
        // ... (의존성 정의) ...
    }

    publishing {
        publications {
            mavenJava(MavenPublication) {
                from components.java
                groupId = project.group
                artifactId = project.name
                version = project.version
            }
        }
        repositories {
            maven {
                name = "NexusReleases"
                url = uri('http://localhost:8081/repository/maven-releases/') // 릴리즈 저장소
                credentials {
                    username = System.getenv("NEXUS_USERNAME") ?: project.properties['nexusUsername']
                    password = System.getenv("NEXUS_PASSWORD") ?: project.properties['nexusPassword']
                }
            }
            maven {
                name = "NexusSnapshots"
                url = uri('http://localhost:8081/repository/maven-snapshots/') // 스냅샷 저장소
                credentials {
                    username = System.getenv("NEXUS_USERNAME") ?: project.properties['nexusUsername']
                    password = System.getenv("NEXUS_PASSWORD") ?: project.properties['nexusPassword']
                }
            }
        }
    }
    ```
*   **배포**:
    -   `./gradlew publish` (또는 `gradlew publish` for Windows) 명령으로 아티팩트를 배포합니다.

### 3. npm 연동

#### 3.1. `.npmrc` 설정 (npm 프로젝트)
*   **목표**: npm 클라이언트가 Nexus npm Hosted Repository에 패키지를 배포하고 가져올 수 있도록 설정합니다.
*   **경로**: `~/.npmrc` (사용자별) 또는 프로젝트 루트의 `.npmrc`
*   **주요 설정**:
    -   `registry`: 모든 npm 요청을 Nexus npm Group Repository로 리다이렉션합니다.
    -   `always-auth`: 항상 인증을 요구하도록 설정.
    -   `_authToken`: Nexus에 로그인한 사용자의 인증 토큰.
*   **코드 스니펫 (`.npmrc` 예시)**:
    ```
    # 모든 npm 요청을 Nexus Group으로 리다이렉션
    registry=http://localhost:8081/repository/npm-group/

    # 자체 개발 패키지 배포 시 사용될 Hosted Repository
    # @scope는 배포할 패키지의 scope (예: @my-org/my-package)
    @my-org:registry=http://localhost:8081/repository/npm-hosted/

    # 항상 인증 필요
    always-auth=true

    # 인증 토큰 (Nexus UI에서 'admin' -> 'User Tokens'에서 생성)
    # 실제 CI/CD에서는 환경 변수 또는 Secret 사용
    //localhost:8081/repository/npm-hosted/:_authToken=npm-deploy-token
    ```
*   **인증 토큰 발급**: Nexus UI에서 `admin` 계정으로 로그인 후, 우측 상단 사용자 아이콘 클릭 -> `User tokens` -> `Create token`을 통해 발급받습니다.

#### 3.2. npm 패키지 배포 및 소비
*   **배포**:
    -   `npm publish --registry http://localhost:8081/repository/npm-hosted/`
    -   `.npmrc`에 설정된 `registry`를 사용하거나 `--registry` 옵션으로 명시합니다.
*   **소비**:
    -   `npm install <package-name>` (Nexus Group Repository를 통해 가져옴)

### 4. Docker 연동

#### 4.1. Docker 클라이언트 로그인
*   **목표**: Docker 클라이언트가 Nexus Docker Hosted Repository에 이미지를 푸시하고 풀할 수 있도록 로그인합니다.
*   **명령어**:
    ```bash
    docker login http://localhost:8081 # Nexus Docker Hosted Repository URL
    # Username: deployment
    # Password: deployment_password
    ```
*   **나쁜 예시**: `docker login -u user -p password`와 같이 비밀번호를 명령줄에 직접 입력하는 것.
    -   쉘 히스토리에 비밀번호가 남을 수 있어 보안에 취약합니다.
    -   비밀번호를 파일로 읽어오거나 CI/CD 환경에서는 Secret 기능을 사용해야 합니다.

#### 4.2. Docker 이미지 푸시 및 풀
*   **푸시**:
    -   `docker tag my-image:latest http://localhost:8081/docker-hosted/my-image:1.0`
    -   `docker push http://localhost:8081/docker-hosted/my-image:1.0`
*   **풀**:
    -   `docker pull http://localhost:8081/docker-hosted/my-image:1.0`
*   **나쁜 예시**: Docker Hosted Repository에 HTTPS를 적용하지 않고 `insecure-registries` 설정을 남용하는 것.
    -   개발/테스트 환경에서는 편리하지만, 프로덕션 환경에서는 반드시 HTTPS와 유효한 SSL 인증서를 사용해야 합니다.

## 실습 가이드 (Practical Guide)
1.  `Step1_NexusInstallationAndSetup.sh`를 통해 Nexus를 설치 및 실행합니다.
2.  Nexus UI에서 `Step2_RepositoryConfiguration.md`를 참고하여 Maven Group/Hosted/Proxy 저장소를 구성합니다.
3.  `Step3_UserAndRoleManagement.md`를 참고하여 `deployment` 사용자를 생성하고 Maven Hosted Repository에 배포 권한을 부여합니다.
4.  이 문서의 Maven 섹션을 참고하여 `settings.xml`과 `pom.xml`을 구성하고 `mvn deploy`를 실행하여 아티팩트를 배포합니다.
5.  Nexus UI에서 배포된 아티팩트를 확인하고, `settings.xml`의 `mirrors` 설정을 확인하여 의존성 소비가 Nexus를 통해 이루어지는지 확인합니다.

## 나쁜 예시와 좋은 예시 (개념)
`pom.xml`, `build.gradle`, `.npmrc` 파일 내의 주석을 참조하여, 빌드 도구 연동 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 특히 민감한 인증 정보는 항상 안전하게 관리하고, 빌드 환경의 일관성을 유지하는 것이 중요합니다.
