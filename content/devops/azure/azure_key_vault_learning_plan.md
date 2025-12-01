# Azure Key Vault 및 환경 설정 학습 계획

## 개요 (Overview)
Azure Key Vault는 클라우드 애플리케이션 및 서비스에서 사용되는 암호화 키, 비밀(secrets), 인증서(certificates)를 안전하게 저장하고 관리하기 위한 Azure 서비스입니다. 이 학습 계획은 Key Vault의 기본 개념부터 실제 애플리케이션에 통합하고 관리하는 방법을 실무적으로 다루며, Azure 환경 설정 전반에 걸친 보안 모범 사례를 습득하는 것을 목표로 합니다.

## 학습 목표 (Learning Objectives)
*   Azure Key Vault의 중요성 및 핵심 기능 이해
*   Key Vault 생성, 키, 비밀, 인증서 관리
*   애플리케이션에서 Key Vault를 안전하게 사용하는 방법 학습
*   Azure 환경 보안 설정 및 관리 모범 사례 이해
*   Azure CLI/PowerShell을 이용한 자동화

## 학습 내용 (Learning Content)

### 1단계: 보안 및 Azure Key Vault 소개 (Security & Azure Key Vault Introduction)
*   클라우드 환경에서의 보안 중요성 (Importance of Security in Cloud)
*   자격 증명 및 비밀 관리의 도전 과제 (Challenges in Credential & Secret Management)
*   Azure Key Vault란 무엇인가? (What is Azure Key Vault?) - 핵심 기능 및 이점
*   Key Vault의 사용 시나리오 (Use Cases of Key Vault) - DB 연결 문자열, API 키, 인증서 등

### 2단계: Key Vault 생성 및 관리 (Key Vault Creation & Management)
*   Azure Portal을 통한 Key Vault 생성 (Creating Key Vault via Azure Portal)
*   Azure CLI/PowerShell을 통한 Key Vault 생성 (Creating Key Vault via Azure CLI/PowerShell)
*   키(Keys) 관리 (Managing Keys) - 생성, 가져오기, 버전 관리
*   비밀(Secrets) 관리 (Managing Secrets) - 생성, 업데이트, 삭제, 버전 관리
*   인증서(Certificates) 관리 (Managing Certificates) - 가져오기, 생성, 자동 갱신

### 3단계: 접근 정책 및 보안 (Access Policies & Security)
*   Key Vault 접근 정책 (Access Policies) 이해 및 구성
    *   사용자, 그룹, 서비스 주체(Service Principal) 권한 부여
*   관리 ID(Managed Identities)를 이용한 안전한 접근 (Secure Access using Managed Identities)
    *   시스템 할당 및 사용자 할당 관리 ID
*   네트워크 보안 (Network Security) - Private Endpoint, Virtual Network 서비스 엔드포인트
*   로깅 및 모니터링 (Logging & Monitoring) - Azure Monitor, Audit Logs

### 4단계: 애플리케이션 통합 (Application Integration)
*   Azure App Service/Functions에서 Key Vault 사용 (Using Key Vault in App Service/Functions)
*   Azure Kubernetes Service (AKS)에서 Key Vault 사용 (Using Key Vault in AKS) - CSI Driver
*   .NET, Java, Python 등 애플리케이션 코드에서 비밀/키 가져오기
*   CI/CD 파이프라인에서 Key Vault 사용 (Using Key Vault in CI/CD Pipelines) - Azure DevOps, GitHub Actions

### 5단계: Azure 환경 설정 및 모범 사례 (Azure Environment Setup & Best Practices)
*   Azure 리소스 그룹(Resource Groups)을 이용한 구성 관리
*   Azure Policy를 이용한 거버넌스 및 규정 준수 (Governance & Compliance with Azure Policy)
*   리소스 잠금(Resource Locks) 활용
*   Azure Active Directory (AAD) 통합 및 역할 기반 접근 제어 (RBAC)
*   환경별 구성 관리 (Configuration Management for Different Environments) - Dev, Test, Prod

## 예상 학습 시간 (Estimated Learning Time)
*   각 단계별 3-5시간 (총 15-25시간)

## 실습 과제 (Practical Exercises)
*   Key Vault를 생성하고 비밀(예: DB 연결 문자열)을 저장 (Create Key Vault & store a secret)
*   Azure App Service에 배포된 웹 애플리케이션에서 Key Vault의 비밀 사용 (Use a Key Vault secret in an Azure App Service web application)
*   관리 ID를 사용하여 VM에서 Key Vault에 접근 (Access Key Vault from a VM using Managed Identity)
*   Key Vault 접근 정책을 구성하고 테스트 (Configure & test Key Vault access policies)

## 참고 자료 (References)
*   Azure Key Vault 공식 문서 (Azure Key Vault Official Documentation)
*   Microsoft Learn - Azure 보안 및 Key Vault 관련 모듈 (Microsoft Learn - Azure Security & Key Vault Modules)
*   Azure Security Center 및 Azure Defender 자료 (Azure Security Center & Azure Defender resources)
