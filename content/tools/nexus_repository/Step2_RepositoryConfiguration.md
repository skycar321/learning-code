# Nexus Repository 학습 계획 - 2단계: 저장소(Repositories) 구성 및 관리
# 이 파일은 Nexus Repository Manager에서 다양한 유형의 저장소(Proxy, Hosted, Group)를
# 구성하고 관리하는 방법을 학습하기 위한 개념적인 설명입니다.
#
# Nexus UI를 통해 이러한 저장소들을 직접 생성하고 설정하는 것이 핵심입니다.

## 개요 (Overview)
Nexus Repository Manager는 다양한 유형의 저장소를 제공하여, 외부 의존성 캐싱, 자체 개발 아티팩트 저장, 여러 저장소 통합 등 다양한 요구 사항을 충족시킬 수 있습니다. 각 저장소 유형의 역할과 올바른 구성 방법을 이해하는 것은 Nexus를 효율적으로 활용하는 데 중요합니다.

## 학습 목표 (Learning Objectives)
*   **Proxy Repository (프록시 저장소)**의 역할과 구성
*   **Hosted Repository (호스트 저장소)**의 역할과 구성
*   **Group Repository (그룹 저장소)**의 역할과 구성
*   Maven, npm, Docker 등 특정 패키지 포맷에 맞는 저장소 설정 방법 이해

## 학습 내용 (Learning Content)

### 1. 저장소 유형 이해 (Understanding Repository Types)

#### 1.1. Proxy Repository (프록시 저장소)
*   **역할**: 원격 저장소(예: Maven Central, npmjs.com, Docker Hub)의 콘텐츠를 로컬 Nexus에 캐싱합니다.
*   **동작 방식**:
    1.  클라이언트(Maven, npm, Docker)가 Nexus의 Proxy 저장소에 아티팩트를 요청합니다.
    2.  Nexus의 Proxy 저장소에 해당 아티팩트가 없으면, 원격 저장소에서 아티팩트를 가져와 캐싱한 후 클라이언트에 전달합니다.
    3.  이후 동일한 아티팩트 요청 시 캐시된 아티팩트를 즉시 제공하여 빌드 속도를 향상시키고 외부 네트워크 트래픽을 줄입니다.
*   **주요 설정**:
    -   **Remote URL**: 프록시할 원격 저장소의 URL.
    -   **Authentication**: 원격 저장소에 접근하기 위한 인증 정보 (필요시).
    -   **Blob Store**: 아티팩트를 저장할 디스크 위치.
*   **사용 시나리오**: Maven Central을 프록시하여 의존성 다운로드 속도 향상, Docker Hub를 프록시하여 이미지 풀 속도 향상.
*   **나쁜 예시**: Proxy 저장소 없이 각 개발 머신이나 CI/CD 환경에서 직접 외부 중앙 저장소에 접근하는 것.
    -   네트워크 지연 증가, 외부 저장소 장애 시 빌드 실패, 네트워크 트래픽 증가.

#### 1.2. Hosted Repository (호스트 저장소)
*   **역할**: 자체 개발한 아티팩트(라이브러리, 애플리케이션 JAR/WAR, Docker 이미지 등)를 저장하고 관리합니다.
*   **동작 방식**: 클라이언트가 Nexus의 Hosted 저장소에 아티팩트를 직접 배포(publish)하고 가져옵니다(consume).
*   **주요 설정**:
    -   **Deployment Policy**: 아티팩트 배포 정책 (Allow Redeploy, Read-only 등).
    -   **Blob Store**: 아티팩트를 저장할 디스크 위치.
*   **사용 시나리오**:
    -   **릴리즈(Release) 저장소**: 안정화된 버전의 아티팩트 (예: `my-lib-1.0.0.jar`) 저장.
    -   **스냅샷(Snapshot) 저장소**: 개발 중인 버전의 아티팩트 (예: `my-lib-1.0.0-SNAPSHOT.jar`) 저장.
    -   Docker Registry를 Hosted Repository로 구성하여 자체 Docker 이미지를 관리.
*   **나쁜 예시**: 자체 개발한 아티팩트를 Git에 직접 커밋하거나, 각 개발 머신에 수동으로 복사하여 배포하는 것.
    -   버전 관리의 어려움, 아티팩트 공유의 비효율성, 배포 오류 발생 가능성.

#### 1.3. Group Repository (그룹 저장소)
*   **역할**: 여러 Proxy 및 Hosted 저장소를 하나의 논리적인 URL로 묶어서 제공합니다.
*   **동작 방식**: 클라이언트가 Group 저장소에 아티팩트를 요청하면, Group 저장소는 포함된 저장소들을 정의된 순서(Routing Rule)대로 탐색하여 아티팩트를 제공합니다.
*   **주요 설정**:
    -   **Member Repositories**: 그룹에 포함할 Proxy 및 Hosted 저장소 목록.
*   **사용 시나리오**:
    -   개발자는 하나의 URL(Group 저장소 URL)만 설정하면 외부 의존성과 자체 개발 아티팩트를 모두 사용할 수 있어 편리합니다.
    -   Maven Central + 자체 Release + 자체 Snapshot을 하나의 Group 저장소로 묶어서 사용.
*   **나쁜 예시**: Group 저장소 없이 클라이언트가 여러 저장소 URL을 일일이 설정하여 사용하는 것.
    -   클라이언트 설정의 복잡성 증가, 저장소 관리의 어려움, 휴먼 에러 발생 가능성.

### 2. Maven Repository 설정 (Nexus UI를 통해)
*   **Nexus UI 접근**: `http://localhost:8081` (또는 설치된 Nexus URL)로 이동하여 `admin` 계정으로 로그인합니다.
*   **'Repositories' 메뉴 이동**: 좌측 메뉴에서 `Server` -> `Repositories`를 클릭합니다.
*   **저장소 생성**: `Create repository` 버튼을 클릭하여 원하는 유형의 저장소를 선택하고 구성합니다.
    -   **`maven-public` (Group)**: 기본적으로 `maven-releases`, `maven-snapshots`, `maven-central`을 포함하는 그룹 저장소로 존재합니다. 이를 사용하거나 새로 생성하여 Maven Central (Proxy), 자체 Hosted Release (Hosted), 자체 Hosted Snapshot (Hosted)을 추가합니다.
    -   **`maven-central` (Proxy)**: `maven2 (proxy)` 유형을 선택하고 Remote URL을 `https://repo.maven.apache.org/maven2/`로 설정합니다.
    -   **`maven-releases` (Hosted)**: `maven2 (hosted)` 유형을 선택하고 Deployment Policy를 `Allow Redeploy` 또는 `Disable Redeploy` (릴리즈 아티팩트의 불변성을 위해)로 설정합니다.
    -   **`maven-snapshots` (Hosted)**: `maven2 (hosted)` 유형을 선택하고 Deployment Policy를 `Allow Redeploy`로 설정합니다 (스냅샷은 자주 변경되므로).
*   **나쁜 예시**: Release 아티팩트용 Hosted 저장소에 `Allow Redeploy` 정책을 설정하는 것.
    -   배포된 릴리즈 아티팩트는 변경되지 않아야 버전 관리의 신뢰성을 유지할 수 있습니다. `Disable Redeploy`로 설정하여 변경을 막아야 합니다.

### 3. npm Repository 설정 (Nexus UI를 통해)
*   **`npm-proxy` (Proxy)**: `npm (proxy)` 유형을 선택하고 Remote URL을 `https://registry.npmjs.org/`로 설정합니다.
*   **`npm-hosted` (Hosted)**: `npm (hosted)` 유형을 선택하고 자체 npm 패키지를 저장합니다.
*   **`npm-group` (Group)**: `npm-proxy`와 `npm-hosted`를 포함하는 그룹 저장소를 생성합니다.

### 4. Docker Registry 설정 (Nexus UI를 통해)
*   **`docker-proxy` (Proxy)**: `docker (proxy)` 유형을 선택하고 Remote URL을 `https://registry-1.docker.io` (Docker Hub)로 설정합니다. Docker Hub에 인증이 필요한 경우 인증 정보를 설정해야 합니다.
*   **`docker-hosted` (Hosted)**: `docker (hosted)` 유형을 선택하고 자체 Docker 이미지를 저장합니다.
    -   **HTTP Port**: Docker 클라이언트가 접근할 포트를 지정합니다 (예: 8082).
    -   **Enable Docker V1 API**: 레거시 Docker 클라이언트 호환성을 위해 활성화할 수 있습니다.
*   **`docker-group` (Group)**: `docker-proxy`와 `docker-hosted`를 포함하는 그룹 저장소를 생성합니다.
*   **나쁜 예시**: Docker Hosted 저장소에 HTTP 포트를 설정하지 않고 HTTPS만 사용하도록 강제하는 것.
    -   개발 환경에서 `insecure-registries` 설정을 추가해야 하므로 클라이언트 설정이 복잡해집니다.
    -   프로덕션 환경에서는 반드시 HTTPS를 사용하고 유효한 SSL 인증서를 설정해야 합니다.

### 5. 기타 포맷 저장소
*   NuGet, PyPI, Rubygems 등 다양한 패키지 포맷에 대해서도 동일한 원리로 Proxy, Hosted, Group 저장소를 구성할 수 있습니다.

이러한 다양한 유형의 저장소를 올바르게 구성하고 관리하는 것은 Nexus Repository를 통한
아티팩트 관리 전략의 핵심입니다. 다음 단계에서는 사용자 및 권한 관리를 통해
Nexus의 보안을 강화하는 방법을 학습합니다.
