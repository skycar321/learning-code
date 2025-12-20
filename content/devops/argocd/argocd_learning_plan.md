# ArgoCD 학습 계획

## 개요 (Overview)
ArgoCD는 Kubernetes를 위한 선언적(declarative) GitOps 지속적 배포(CD) 도구입니다. 이 학습 계획은 ArgoCD의 기본 개념부터 실제 애플리케이션 배포 및 관리까지 실무적인 지식을 습득하고, GitOps 워크플로우를 이해하는 것을 목표로 합니다.

## 학습 목표 (Learning Objectives)
*   GitOps 원칙 및 ArgoCD의 역할 이해
*   ArgoCD 설치 및 기본 구성
*   Git 저장소를 통해 Kubernetes 애플리케이션 배포 및 동기화
*   ArgoCD의 고급 기능 (예: 헬름 차트, Kustomize) 활용
*   ArgoCD를 이용한 애플리케이션 관리 및 모니터링

## 학습 내용 (Learning Content)

### 1단계: GitOps 및 ArgoCD 기본 (GitOps & ArgoCD Basics)
*   GitOps란 무엇인가? (What is GitOps?) - 핵심 원칙과 장점
*   ArgoCD 소개 (Introduction to ArgoCD) - 특징 및 아키텍처
*   ArgoCD vs 다른 CD 도구 (ArgoCD vs other CD tools)
*   기본 용어 이해 (Understanding Key Terminologies) - Application, Project, Sync, Health, Status

### 2단계: ArgoCD 설치 및 초기 설정 (ArgoCD Installation & Initial Setup)
*   Kubernetes 환경 준비 (Preparing Kubernetes Environment)
*   ArgoCD 설치 방법 (Installation Methods) - YAML Manifests, Helm
*   ArgoCD CLI 설치 및 사용 (Installing & Using ArgoCD CLI)
*   ArgoCD UI 접근 및 초기 로그인 (Accessing UI & Initial Login)
*   클러스터 등록 (Registering Clusters)

### 3단계: 애플리케이션 배포 및 관리 (Application Deployment & Management)
*   ArgoCD 애플리케이션 생성 (Creating ArgoCD Applications)
    *   Git Repository 연결 (Connecting Git Repositories)
    *   Application Manifest 작성 (Writing Application Manifests)
*   애플리케이션 동기화 (Application Synchronization)
    *   수동(Manual) 및 자동(Automatic) 동기화
    *   Sync 정책 (Sync Policies) - Pruning, Self-Heal, Auto-prune
*   애플리케이션 상태 및 헬스 체크 (Application Status & Health Checks)
*   리소스 관리 (Resource Management) - Rollback, Suspend, Terminate

### 4단계: GitOps 워크플로우 및 고급 기능 (GitOps Workflow & Advanced Features)
*   선언적 배포 워크플로우 (Declarative Deployment Workflow)
*   Config Management Plugins (CMP)
    *   Helm 차트 배포 (Deploying Helm Charts)
    *   Kustomize 사용 (Using Kustomize)
    *   Jsonnet 사용 (Using Jsonnet)
*   ArgoCD 프로젝트 (ArgoCD Projects) - RBAC 및 리소스 격리
*   환경별 배포 전략 (Deployment Strategies for Environments) - Development, Staging, Production
*   PreSync, Sync, PostSync 훅 (PreSync, Sync, PostSync Hooks)

### 5단계: 모니터링 및 운영 (Monitoring & Operations)
*   ArgoCD 이벤트 및 알림 (ArgoCD Events & Notifications) - Slack, Email 연동
*   로그 및 감사 (Logs & Auditing)
*   문제 해결 (Troubleshooting) - 동기화 오류, 리소스 문제
*   ArgoCD HA (High Availability) 구성
*   보안 고려 사항 (Security Considerations)

## 예상 학습 시간 (Estimated Learning Time)
*   각 단계별 3-5시간 (총 15-25시간)

## 실습 과제 (Practical Exercises)
*   간단한 웹 애플리케이션을 Git 저장소에 구성하고 ArgoCD로 배포 (Deploy a simple web app to Kubernetes via ArgoCD & Git)
*   Helm 차트를 사용하여 ArgoCD 애플리케이션 생성 (Create an ArgoCD application using Helm charts)
*   배포 실패 시 롤백 연습 (Practice rollback on deployment failure)
*   여러 환경(dev, prod)에 대한 GitOps 워크플로우 구현 (Implement GitOps workflow for multiple environments)

## 참고 자료 (References)
*   ArgoCD 공식 문서 (ArgoCD Official Documentation)
*   GitOps: The Right Way to Do Cloud Native by Stefan Krantz
*   Kubernetes 및 Helm 관련 자료 (Kubernetes and Helm related resources)
