# Jenkins 학습 계획

## 개요 (Overview)
Jenkins는 가장 널리 사용되는 오픈소스 자동화 서버 중 하나로, 지속적 통합(CI) 및 지속적 배포(CD) 파이프라인을 구축하는 데 핵심적인 역할을 합니다. 이 학습 계획은 Jenkins의 설치부터 파이프라인 구성, 플러그인 활용, 그리고 실제 프로젝트에 적용하는 방법까지 다루어, 개발 및 배포 프로세스를 자동화하는 역량을 키우는 것을 목표로 합니다.

## 학습 목표 (Learning Objectives)
*   CI/CD 개념 및 Jenkins의 역할 이해
*   Jenkins 설치 및 초기 설정
*   Jenkins Job 및 Pipeline 생성 및 관리
*   주요 플러그인 활용 능력 습득
*   Jenkins를 이용한 빌드, 테스트, 배포 자동화

## 학습 내용 (Learning Content)

### 1단계: CI/CD 및 Jenkins 소개 (CI/CD & Jenkins Introduction)
*   CI/CD란 무엇인가? (What is CI/CD?) - 개념, 이점
*   Jenkins 소개 (Introduction to Jenkins) - 역사, 특징, 아키텍처
*   Jenkins와 다른 CI/CD 도구 비교 (Jenkins vs other CI/CD tools)
*   Jenkins의 핵심 구성 요소 (Key Components of Jenkins) - Controller, Agent, Plugin

### 2단계: Jenkins 설치 및 기본 설정 (Jenkins Installation & Basic Configuration)
*   Jenkins 설치 방법 (Installation Methods) - Docker, OS Package, War file
*   초기 설정 및 관리자 비밀번호 (Initial Setup & Admin Password)
*   플러그인 관리 (Plugin Management) - 필수 플러그인 설치
*   글로벌 도구 설정 (Global Tool Configuration) - JDK, Maven, Git 등
*   사용자 및 권한 관리 (User & Permission Management) - Role-based Access Control

### 3단계: Jenkins Job 구성 (Configuring Jenkins Jobs)
*   Freestyle Project (프리스타일 프로젝트) - 기본 Job 구성
    *   소스 코드 관리 (Source Code Management) - Git 연동
    *   빌드 트리거 (Build Triggers) - SCM polling, Webhook
    *   빌드 환경 (Build Environment)
    *   빌드 스텝 (Build Steps) - Shell Script, Maven, Gradle
    *   빌드 후 조치 (Post-build Actions)
*   Pipeline Project (파이프라인 프로젝트) - 코드로서의 파이프라인
    *   Declarative Pipeline vs Scripted Pipeline
    *   Jenkinsfile 작성 (Writing Jenkinsfile)
    *   Stage, Step, Agent, Post 섹션 이해
    *   환경 변수 (Environment Variables) 및 매개변수화 (Parameterization)

### 4단계: 고급 Jenkins 기능 및 플러그인 활용 (Advanced Jenkins & Plugin Usage)
*   공유 라이브러리 (Shared Libraries) - 파이프라인 재사용성 증대
*   Credential Management (자격 증명 관리) - Secret Text, SSH Username with private key
*   Slave/Agent 관리 (Managing Agents) - 분산 빌드 환경 구축
*   주요 플러그인 활용 (Utilizing Key Plugins)
    *   Blue Ocean (파이프라인 시각화)
    *   Email Extension (빌드 결과 알림)
    *   Jira, Slack 연동 플러그인
    *   SonarQube Scanner (코드 품질 분석)

### 5단계: Jenkins 운영 및 모니터링 (Jenkins Operations & Monitoring)
*   빌드 이력 관리 (Build History Management)
*   Jenkins 백업 및 복원 (Backup & Restore)
*   Jenkins 시스템 모니터링 (Monitoring Jenkins System) - 로그, 메트릭스
*   문제 해결 및 최적화 (Troubleshooting & Optimization)
*   Jenkins 보안 강화 (Enhancing Jenkins Security)

## 예상 학습 시간 (Estimated Learning Time)
*   각 단계별 3-6시간 (총 15-30시간)

## 실습 과제 (Practical Exercises)
*   간단한 Java/Node.js 프로젝트에 대한 CI 파이프라인 구축 (Build a CI pipeline for a simple project)
*   Docker 이미지를 빌드하고 레지스트리에 푸시하는 파이프라인 작성 (Create a pipeline to build and push Docker images)
*   Git Webhook을 이용한 자동 빌드 트리거 설정 (Configure auto build triggers using Git Webhooks)
*   스테이징 환경으로 자동 배포하는 CD 파이프라인 구현 (Implement a CD pipeline for automated deployment to a staging environment)

## 참고 자료 (References)
*   Jenkins 공식 문서 (Jenkins Official Documentation)
*   Jenkins: The Definitive Guide (O'Reilly)
*   CI/CD with Jenkins by M. W. S. Wijenayake
*   온라인 Jenkins 튜토리얼 및 강의 (Online Jenkins tutorials and courses)
