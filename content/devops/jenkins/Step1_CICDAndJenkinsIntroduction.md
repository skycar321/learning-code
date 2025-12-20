# Jenkins 학습 계획 - 1단계: CI/CD 및 Jenkins 소개
# 이 파일은 Jenkins 학습 계획의 1단계인 'CI/CD 및 Jenkins 소개'를 위한
# 개념적인 설명입니다. CI/CD의 중요성과 Jenkins의 역할 및 아키텍처를
# 이해하는 데 중점을 둡니다.

## 개요 (Overview)
소프트웨어 개발 프로세스에서 코드 변경이 빈번하게 발생하고, 팀 규모가 커질수록
수동으로 빌드, 테스트, 배포하는 것은 비효율적이고 오류 발생 가능성이 높습니다.
CI/CD는 이러한 문제를 해결하고 소프트웨어의 품질과 배포 속도를 향상시키기 위한
핵심적인 방법론입니다.

## 학습 목표 (Learning Objectives)
*   CI/CD (지속적 통합/지속적 배포)의 개념과 이점 이해
*   Jenkins의 역사, 특징 및 아키텍처 파악
*   Jenkins와 다른 CI/CD 도구의 차이점 이해
*   Jenkins의 핵심 구성 요소 (Controller, Agent, Plugin) 식별

## 학습 내용 (Learning Content)

### 1. CI/CD란 무엇인가? (What is CI/CD?)
*   **CI (Continuous Integration, 지속적 통합)**:
    -   개발자들이 각자 작업한 코드를 정기적으로 (하루에 여러 번) 메인 브랜치에 통합(merge)하는 프로세스.
    -   통합될 때마다 자동화된 빌드 및 테스트를 수행하여 코드 충돌이나 버그를 조기에 발견.
    -   목표: 코드 통합 문제를 최소화하고, 항상 작동 가능한 소프트웨어 버전을 유지.
*   **CD (Continuous Delivery/Deployment, 지속적 배포/전달)**:
    -   **Continuous Delivery (지속적 전달)**: CI를 통해 검증된 코드를 수동 승인 후 언제든지 프로덕션 환경에 배포할 준비가 된 상태로 유지.
    -   **Continuous Deployment (지속적 배포)**: CI를 통해 검증된 코드를 아무런 수동 개입 없이 자동으로 프로덕션 환경에 배포.
    -   목표: 배포 프로세스를 자동화하여 소프트웨어를 빠르고 안정적으로 사용자에게 전달.

*   **CI/CD의 이점**:
    -   **오류 조기 발견**: 통합 및 테스트 자동화를 통해 버그를 빠르게 찾아 수정.
    -   **배포 속도 향상**: 수동 작업 제거, 자동화된 배포로 더 자주, 더 빠르게 배포.
    -   **코드 품질 향상**: 자동화된 테스트, 코드 분석 도구 통합.
    -   **안정성 증가**: 일관된 프로세스 적용으로 배포 실패율 감소.
    -   **개발자 생산성 증대**: 반복적인 수동 작업에서 해방.

### 2. Jenkins 소개 (Introduction to Jenkins)
*   **정의**: 가장 널리 사용되는 오픈소스 자동화 서버로, CI/CD 파이프라인 구축에 특화되어 있습니다.
    -   Java로 개발되었으며, 웹 기반 인터페이스를 제공.
    -   방대한 플러그인 생태계를 통해 다양한 도구 및 기술과 연동 가능.
*   **역사**: 2004년 Hudson 프로젝트로 시작하여 2011년 Jenkins로 포크(fork)됨.
*   **특징**:
    -   **확장성**: 수천 개의 플러그인을 통해 거의 모든 빌드, 테스트, 배포 기술과 통합 가능.
    -   **유연성**: Freestyle Job, Pipeline Script 등 다양한 방식으로 작업을 정의.
    -   **분산 빌드**: Controller-Agent 아키텍처를 통해 빌드 부하 분산.
    -   **커뮤니티**: 활발한 커뮤니티 지원과 방대한 문서.
*   **아키텍처**:
    -   **Jenkins Controller (Master)**: 중앙 서버로, 빌드 스케줄링, 플러그인 관리, UI 제공 등 Jenkins 시스템 전체를 제어합니다.
    -   **Jenkins Agent (Slave/Node)**: Controller의 지시를 받아 실제 빌드, 테스트 작업을 수행하는 서버 또는 컨테이너. Controller의 부하를 분산하고, 특정 환경(예: 특정 OS, 특정 JDK 버전)에서 빌드를 실행할 수 있게 합니다.
    -   **Plugin (플러그인)**: Jenkins의 핵심. Git, Maven, Docker, AWS 등 외부 도구와의 연동을 가능하게 하고, Jenkins의 기능을 확장합니다.

### 3. Jenkins와 다른 CI/CD 도구 비교 (Jenkins vs other CI/CD tools)
*   **Jenkins**:
    -   장점: 오픈소스(무료), 방대한 플러그인 생태계, 높은 커스터마이징 유연성, 온프레미스/클라우드 어디든 배포 가능.
    -   단점: 초기 설정 및 유지보수 노력이 필요, UI/UX가 다소 오래됨 (Blue Ocean 개선), 스케일링 복잡성.
*   **Cloud-Native CI/CD (GitHub Actions, GitLab CI, CircleCI, Travis CI, Azure DevOps Pipelines 등)**:
    -   장점: 클라우드 기반으로 관리 용이, 통합된 Git 플랫폼과의 연동, 간편한 설정, 확장성.
    -   단점: 비용 발생 가능, 커스터마이징 유연성이 Jenkins보다 낮을 수 있음, 특정 플랫폼 종속성.

*   **나쁜 예시**: Jenkins를 도입하면서 CI/CD 파이프라인을 구축하지 않고 수동으로 빌드/배포를 계속하는 것.
*   **좋은 예시**: Jenkins를 CI/CD의 핵심 도구로 활용하여 개발-테스트-배포 전 과정을 자동화하고, 개발자들이 코드 변경에만 집중할 수 있는 환경을 구축하는 것.

### 4. Jenkins의 핵심 구성 요소 (Key Components of Jenkins)
*   **Controller (Master)**: Jenkins의 중앙 허브.
    -   스케줄러, UI, API 제공.
    -   Job 설정, 플러그인 관리.
    -   Agent에 빌드 작업 할당.
*   **Agent (Slave/Node)**:
    -   Controller의 지시에 따라 실제 작업을 실행하는 워커 노드.
    -   다양한 OS, JDK 버전, 도구를 가진 Agent를 구성하여 빌드 환경을 분리.
    -   태그(Label)를 부여하여 특정 작업이 특정 Agent에서만 실행되도록 제어.
*   **Plugin (플러그인)**:
    -   Jenkins 생태계의 핵심. 기능을 확장하고 외부 시스템과 통합.
    -   Git, GitHub, Maven, Gradle, Docker, Slack, Jira 등 수많은 플러그인.
    -   Jenkins Web UI의 플러그인 관리자에서 쉽게 설치 및 업데이트 가능.

이러한 기본 개념들을 이해하는 것은 효과적인 Jenkins 파이프라인을 구축하고
운영하는 데 필수적입니다. 다음 단계에서는 Jenkins를 실제로 설치하고
기본 설정을 구성하는 방법을 학습합니다.
