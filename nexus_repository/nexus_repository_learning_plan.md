# Nexus Repository 학습 계획

## 개요 (Overview)
Nexus Repository는 개발 및 배포 워크플로우에서 필요한 소프트웨어 컴포넌트(라이브러리, 의존성, 빌드 아티팩트 등)를 저장하고 관리하는 중앙화된 저장소 관리 도구입니다. Maven, Gradle, npm, Docker 등 다양한 패키지 포맷을 지원하며, 개발 생산성을 높이고 빌드 프로세스를 안정화하는 데 필수적인 역할을 합니다. 이 학습 계획은 Nexus Repository의 설치부터 저장소 구성, 보안 설정, 그리고 CI/CD 파이프라인 연동까지 실무에 필요한 지식을 습득하는 것을 목표로 합니다.

## 학습 목표 (Learning Objectives)
*   Nexus Repository의 역할 및 핵심 기능 이해
*   다양한 유형의 저장소(Proxy, Hosted, Group) 구성 및 관리
*   사용자 및 권한 관리를 통한 보안 강화
*   Maven, Gradle, npm 등 빌드 도구와 연동
*   CI/CD 파이프라인에서 아티팩트 관리 및 배포

## 학습 내용 (Learning Content)

### 1단계: Nexus Repository 소개 및 설치 (Introduction & Installation)
*   아티팩트 저장소의 필요성 (Need for Artifact Repositories)
*   Nexus Repository Manager 소개 (Introduction to Nexus Repository Manager) - 특징, 버전 (OSS vs Pro)
*   설치 방법 (Installation Methods) - Docker, Standalone
*   초기 설정 및 관리자 비밀번호 (Initial Setup & Admin Password)
*   Nexus UI 탐색 (Navigating the Nexus UI)

### 2단계: 저장소(Repositories) 구성 및 관리 (Configuring & Managing Repositories)
*   저장소 유형 이해 (Understanding Repository Types)
    *   **Proxy Repository (프록시 저장소):** 외부 중앙 저장소(Maven Central, npmjs.com) 캐싱
    *   **Hosted Repository (호스트 저장소):** 자체 개발 아티팩트 저장
    *   **Group Repository (그룹 저장소):** 여러 저장소를 하나의 URL로 묶음
*   Maven Repository 설정 (Maven Repository Setup)
*   npm Repository 설정 (npm Repository Setup)
*   Docker Registry 설정 (Docker Registry Setup)
*   기타 포맷 저장소 (Other Formats) - NuGet, PyPI, Rubygems 등

### 3단계: 사용자 및 권한 관리 (User & Role Management)
*   사용자(Users) 생성 및 관리 (Creating & Managing Users)
*   역할(Roles) 생성 및 권한 부여 (Creating Roles & Granting Privileges)
*   인증(Authentication) 및 인가(Authorization) 이해
*   외부 인증 시스템 연동 (Integrating External Authentication) - LDAP, SAML
*   보안 강화 모범 사례 (Security Best Practices)

### 4단계: 빌드 도구 연동 (Build Tool Integration)
*   **Maven 연동:** `settings.xml` 설정, `pom.xml` 배포 설정
*   **Gradle 연동:** `build.gradle` 설정
*   **npm 연동:** `.npmrc` 설정, `npm publish`
*   **Docker 연동:** Docker 로그인, 이미지 푸시/풀
*   아티팩트 배포 및 소비 (Deploying & Consuming Artifacts)

### 5단계: 유지보수 및 고급 기능 (Maintenance & Advanced Features)
*   스케줄된 태스크(Scheduled Tasks) 관리 (Managing Scheduled Tasks) - 캐시 정리, 인덱스 재빌드
*   스토리지 관리 (Storage Management) - Blob Store 설정
*   고가용성(High Availability) 및 백업/복구 (Backup & Restore) (Pro 버전 기능)
*   CI/CD 파이프라인 연동 (Integrating with CI/CD Pipelines) - Jenkins, GitLab CI, GitHub Actions
*   스크립팅(Scripting) - Groovy 스크립트를 이용한 자동화

## 예상 학습 시간 (Estimated Learning Time)
*   각 단계별 3-6시간 (총 15-30시간)

## 실습 과제 (Practical Exercises)
*   Docker를 이용하여 Nexus Repository Manager 설치 및 실행 (Install & run Nexus RM via Docker)
*   Maven Central을 프록시하는 저장소, 자체 아티팩트를 위한 호스트 저장소, 이 둘을 묶는 그룹 저장소 구성 (Configure Proxy, Hosted, and Group repositories)
*   사용자를 생성하고 특정 저장소에 대한 접근 권한 부여 (Create users & grant access to specific repositories)
*   Maven 프로젝트의 빌드 아티팩트를 호스트 저장소에 배포하고 그룹 저장소를 통해 소비 (Deploy & consume Maven artifacts via Nexus)
*   Docker 이미지를 Nexus Docker Registry에 푸시하고 풀 (Push & pull Docker images to Nexus Docker Registry)

## 참고 자료 (References)
*   Sonatype Nexus Repository 공식 문서 (Sonatype Nexus Repository Official Documentation)
*   Maven 및 Gradle 공식 문서 (Maven & Gradle Official Documentation)
*   Docker Registry 공식 문서 (Docker Registry Official Documentation)
