# Gradle 학습 계획

## 개요 (Overview)
Gradle은 Groovy 또는 Kotlin DSL을 기반으로 하는 오픈소스 빌드 자동화 도구입니다. 유연하고 강력한 빌드 시스템을 제공하여 Java, Android, Kotlin 등 다양한 프로젝트의 빌드, 테스트, 배포를 자동화합니다. Apache Maven의 선언적 모델과 Ant의 유연성을 결합한 하이브리드 접근 방식을 취하며, 대규모 프로젝트 및 멀티 프로젝트 빌드에 특히 강점을 보입니다. 이 학습 계획은 Gradle의 기본 개념부터 빌드 스크립트 작성, 의존성 관리, 플러그인 활용, 그리고 CI/CD 파이프라인 연동까지 실무에 필요한 지식을 습득하는 것을 목표로 합니다.

## 학습 목표 (Learning Objectives)
*   Gradle의 핵심 개념 및 동작 방식 이해
*   Groovy/Kotlin DSL을 사용하여 빌드 스크립트 작성
*   의존성 관리, 태스크(Task) 및 플러그인(Plugin) 활용
*   멀티 프로젝트 빌드 구성
*   Nexus 등 아티팩트 저장소와 연동 및 CI/CD 파이프라인 통합

## 학습 내용 (Learning Content)

### 1단계: Gradle 기본 개념 및 시작 (Gradle Basics & Getting Started)
*   빌드 자동화 도구의 진화 (Evolution of Build Automation Tools) - Ant, Maven, Gradle
*   Gradle 소개 (Introduction to Gradle) - 특징, 장점 (유연성, 성능)
*   Gradle 설치 및 환경 설정 (Installation & Setup)
*   Gradle 프로젝트 구조 (Standard Project Layout)
*   `build.gradle` 파일 이해 (Understanding `build.gradle`) - Groovy/Kotlin DSL
*   Gradle Wrapper (Gradle Wrapper) - 프로젝트별 Gradle 버전 관리

### 2단계: 빌드 스크립트 및 태스크 (Build Scripts & Tasks)
*   빌드 스크립트의 기본 요소 (Basic Elements of Build Scripts) - `plugins`, `repositories`, `dependencies`
*   태스크(Tasks) (Tasks) - Gradle 빌드의 기본 작업 단위
    *   사용자 정의 태스크 생성 (Creating Custom Tasks)
    *   태스크 의존성(Task Dependencies)
    *   DoLast, DoFirst 클로저
*   프로젝트(Project) 객체 이해 (Understanding Project Object)
*   프로퍼티(Properties) 관리 (Managing Properties)

### 3단계: 의존성 관리 및 플러그인 (Dependency Management & Plugins)
*   의존성 선언 (Declaring Dependencies) - `implementation`, `api`, `testImplementation`
*   의존성 버전 관리 (Dependency Version Management)
*   저장소(Repositories) 설정 (Configuring Repositories) - Maven Central, JCenter, Google Maven, `mavenLocal()`
*   플러그인(Plugins) (Plugins) - 빌드 기능 확장
    *   Java 플러그인, Application 플러그인, Kotlin 플러그인, Android 플러그인
    *   커스텀 플러그인 (Custom Plugins)
*   캐싱 (Caching) 및 증분 빌드 (Incremental Builds)

### 4단계: 멀티 프로젝트 빌드 및 고급 주제 (Multi-Project Builds & Advanced Topics)
*   멀티 프로젝트 빌드 (Multi-Project Builds) 구성 - `settings.gradle`
*   서브 프로젝트 간 의존성 관리 (Managing Dependencies between Subprojects)
*   테스트 (Testing) - JUnit, Kotest
*   프로파일(Profiles) / 환경별 설정 (Environment-Specific Configuration)
*   빌드 스캔 (Build Scans)
*   성능 최적화 (Performance Optimization) - 병렬 실행, 빌드 캐시

### 5단계: 배포 및 CI/CD 연동 (Deployment & CI/CD Integration)
*   아티팩트 생성 및 배포 (Creating & Deploying Artifacts) - JAR, WAR, AAR
*   아티팩트 저장소(Repository) 연동 (Integrating with Artifact Repositories) - Nexus, Artifactory
*   CI/CD 도구와 Gradle 연동 (Integrating with CI/CD Tools) - Jenkins, GitLab CI, GitHub Actions
*   자동화된 빌드 및 배포 파이프라인 구축
*   Gradle Daemon (Gradle Daemon) - 빌드 속도 향상

## 예상 학습 시간 (Estimated Learning Time)
*   각 단계별 3-6시간 (총 15-30시간)

## 실습 과제 (Practical Exercises)
*   Gradle로 간단한 Java/Kotlin 프로젝트 생성 및 빌드 (Create & build a simple Java/Kotlin project with Gradle)
*   외부 라이브러리 의존성 추가 및 관리 (Add & manage external library dependencies)
*   사용자 정의 태스크 생성 및 실행 (Create & execute custom tasks)
*   두 개 이상의 모듈을 포함하는 멀티 프로젝트 빌드 구성 (Configure a multi-project build)
*   Nexus 또는 유사 저장소에 아티팩트를 배포하고 소비 (Deploy & consume artifacts from Nexus/similar repository)

## 참고 자료 (References)
*   Gradle 공식 문서 (Gradle Official Documentation)
*   Building Android Apps with Gradle by Paul Deitel, Harvey Deitel
*   Gradle in Action by Benjamin Muschko
*   Kotlin DSL 가이드 (Kotlin DSL Guide)
