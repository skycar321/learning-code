# Maven 학습 계획

## 개요 (Overview)
Apache Maven은 Java 프로젝트의 빌드 자동화 및 프로젝트 관리를 위한 강력한 도구입니다. 프로젝트 객체 모델(Project Object Model, POM)을 기반으로 표준화된 디렉토리 구조, 의존성 관리, 빌드 라이프사이클 등을 제공하여 개발 프로세스를 단순화하고 생산성을 향상시킵니다. 이 학습 계획은 Maven의 기본 개념부터 `pom.xml` 설정, 플러그인 활용, 빌드 라이프사이클 관리, 그리고 CI/CD 파이프라인 연동까지 실무에 필요한 지식을 습득하는 것을 목표로 합니다.

## 학습 목표 (Learning Objectives)
*   Maven의 핵심 개념 및 프로젝트 구조 이해
*   `pom.xml`을 이용한 의존성 및 빌드 설정
*   빌드 라이프사이클, 단계(Phase), 목표(Goal) 활용
*   플러그인을 사용하여 빌드 기능 확장
*   Nexus 등 아티팩트 저장소와 연동 및 CI/CD 파이프라인 통합

## 학습 내용 (Learning Content)

### 1단계: Maven 기본 개념 및 시작 (Maven Basics & Getting Started)
*   빌드 자동화 도구의 필요성 (Need for Build Automation Tools)
*   Maven 소개 (Introduction to Maven) - 역사, 특징, 철학
*   Maven 설치 및 환경 설정 (Installation & Setup) - `M2_HOME`, `PATH`
*   Maven 프로젝트 구조 (Standard Directory Layout)
*   `pom.xml` 파일 이해 (Understanding `pom.xml`) - 프로젝트 객체 모델

### 2단계: `pom.xml` 설정 및 의존성 관리 (`pom.xml` & Dependency Management)
*   기본 요소 (`groupId`, `artifactId`, `version`, `packaging`)
*   의존성 선언 (Declaring Dependencies) - `<dependencies>`, `<dependency>`
*   의존성 범위 (Dependency Scopes) - `compile`, `test`, `provided`, `runtime`, `system`, `import`
*   의존성 충돌 해결 (Resolving Dependency Conflicts)
*   부모 `pom` (Parent `pom`) 및 상속 (Inheritance)
*   `dependencyManagement` 및 `pluginManagement`

### 3단계: 빌드 라이프사이클 및 플러그인 (Build Lifecycle & Plugins)
*   빌드 라이프사이클 (Build Lifecycle) - `clean`, `default`, `site`
*   빌드 단계(Phases) (Build Phases) - `validate`, `compile`, `test`, `package`, `install`, `deploy`
*   빌드 목표(Goals) (Build Goals) - 플러그인과 연동
*   주요 플러그인 활용 (Utilizing Key Plugins)
    *   `maven-compiler-plugin`, `maven-surefire-plugin` (테스트)
    *   `maven-jar-plugin`, `maven-war-plugin` (패키징)
    *   `maven-install-plugin`, `maven-deploy-plugin` (설치 및 배포)
*   사용자 정의 플러그인 (Custom Plugins)

### 4단계: 고급 설정 및 배포 (Advanced Configuration & Deployment)
*   프로파일(Profiles) (Profiles) - 환경별 설정 관리
*   필터링(Filtering) (Filtering) - 리소스 파일의 변수 치환
*   스냅샷(SNAPSHOT) 버전 및 릴리즈(RELEASE) 버전 (SNAPSHOT vs RELEASE Versions)
*   로컬 저장소 (Local Repository) - `~/.m2/repository`
*   원격 저장소 (Remote Repositories) - Maven Central, Nexus, Artifactory
    *   `settings.xml` 설정 (Configuring `settings.xml`)
*   배포 (Deployment) - `maven deploy`

### 5단계: CI/CD 연동 및 문제 해결 (CI/CD Integration & Troubleshooting)
*   Jenkins, GitLab CI, GitHub Actions 등 CI/CD 도구와 Maven 연동
*   자동화된 빌드 및 배포 파이프라인 구축
*   Maven Wrapper (Maven Wrapper) - 프로젝트별 Maven 버전 관리
*   문제 해결 (Troubleshooting) - 빌드 실패 원인 분석, 의존성 트리 확인
    *   `mvn clean install -X` (디버그 모드)
*   멀티 모듈 프로젝트 (Multi-module Projects)

## 예상 학습 시간 (Estimated Learning Time)
*   각 단계별 3-6시간 (총 15-30시간)

## 실습 과제 (Practical Exercises)
*   Maven으로 간단한 Java 프로젝트 생성 및 빌드 (Create & build a simple Java project with Maven)
*   외부 라이브러리 의존성 추가 및 관리 (Add & manage external library dependencies)
*   `maven-jar-plugin`을 이용하여 실행 가능한 JAR 파일 생성 (Create an executable JAR with `maven-jar-plugin`)
*   `settings.xml`을 설정하여 로컬 Nexus Repository와 연동 (Integrate with local Nexus Repository via `settings.xml`)
*   CI/CD 환경에서 Maven 빌드 및 배포 파이프라인 구축 (Set up Maven build & deploy pipeline in CI/CD)

## 참고 자료 (References)
*   Apache Maven 공식 문서 (Apache Maven Official Documentation)
*   Maven: The Definitive Guide (O'Reilly)
*   Better Builds with Maven by John Smart
