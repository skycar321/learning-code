# Nexus Repository 학습 계획 - 3단계: 사용자 및 권한 관리
# 이 파일은 Nexus Repository Manager에서 사용자(Users) 및 역할(Roles)을 관리하여
# 저장소에 대한 접근을 제어하고 보안을 강화하는 방법을 학습하기 위한 개념적인 설명입니다.
#
# Nexus UI를 통해 사용자 계정을 생성하고, 역할을 정의하며, 권한을 부여하는 것이 핵심입니다.

## 개요 (Overview)
Nexus Repository는 중요한 개발 아티팩트를 저장하므로, 누가 어떤 아티팩트에 접근하고
배포할 수 있는지에 대한 명확한 권한 관리가 필수적입니다. 역할 기반 접근 제어(RBAC)를 통해
보안 정책을 효과적으로 구현할 수 있습니다.

## 학습 목표 (Learning Objectives)
*   사용자 생성 및 관리
*   역할(Roles) 정의 및 역할에 권한(Privileges) 부여
*   인증(Authentication) 및 인가(Authorization) 메커니즘 이해
*   외부 인증 시스템(LDAP, SAML) 연동 개념
*   Nexus 보안 강화 모범 사례 이해

## 학습 내용 (Learning Content)

### 1. 사용자(Users) 생성 및 관리 (Nexus UI를 통해)
*   **Nexus UI 접근**: `http://localhost:8081`로 이동하여 `admin` 계정으로 로그인합니다.
*   **'Users' 메뉴 이동**: 좌측 메뉴에서 `Security` -> `Users`를 클릭합니다.
*   **사용자 생성**: `Create local user` 버튼을 클릭하여 새 사용자 계정을 생성합니다.
    -   `ID`: 사용자 로그인 ID.
    -   `First Name`, `Last Name`, `Email`: 사용자 정보.
    -   `Password`: 비밀번호 (초기 로그인 시 변경 강제).
    -   `Status`: `Active` (기본값).
    -   `Roles`: 사용자에게 부여할 역할(기본 역할은 `nx-anonymous`, `nx-admin` 등이 있습니다).
*   **나쁜 예시**: 모든 개발자에게 `admin` 역할을 부여하는 것.
    -   `최소 권한 원칙(Principle of Least Privilege)`에 위배되며, 보안 사고 발생 시 심각한 문제를 야기할 수 있습니다.
*   **좋은 예시**: 각 사용자의 직무와 역할에 필요한 최소한의 권한만 부여합니다.

### 2. 역할(Roles) 생성 및 권한(Privileges) 부여 (Nexus UI를 통해)
*   **Nexus의 권한 모델**:
    -   **Privilege (권한)**: Nexus에서 수행할 수 있는 가장 세분화된 작업 단위 (예: `nx-repository-view-*-*-read`, `nx-repository-view-*-*-add`).
    -   **Role (역할)**: 여러 Privileges를 묶어 놓은 집합. 사용자에게 Role을 부여합니다.
*   **'Privileges' 메뉴 이동**: `Security` -> `Privileges`를 클릭하여 사용 가능한 모든 권한 목록을 확인합니다.
*   **'Roles' 메뉴 이동**: `Security` -> `Roles`를 클릭합니다.
*   **역할 생성**: `Create role` 버튼을 클릭하여 `Nexus role`을 선택하고 새 역할을 생성합니다.
    -   `Role ID`, `Role Name`, `Description`: 역할 정보.
    -   `Privileges`: 이 역할에 부여할 개별 권한을 추가합니다.
        -   예: `nx-repository-view-maven2-hosted-my-release-read` (내 릴리즈 저장소 읽기)
        -   예: `nx-repository-view-maven2-hosted-my-snapshot-add` (내 스냅샷 저장소에 배포)
    -   `Roles`: 다른 역할을 포함하여 계층적인 역할 구조를 만들 수 있습니다. (예: `developer` 역할에 `reader` 역할을 포함)
*   **나쁜 예시**: 특정 저장소에 대한 접근 권한 없이 광범위한 권한(예: `nx-all`)을 포함하는 역할을 생성하는 것.
    -   보안 범위를 좁히지 못하고, 의도치 않은 접근을 허용할 수 있습니다.
*   **좋은 예시**: 저장소별로 읽기/쓰기 권한을 명확히 분리하고, 필요한 역할(예: `maven-developer`, `npm-publisher`)을 생성하여 최소한의 권한만 부여합니다.

### 3. 인증(Authentication) 및 인가(Authorization) 이해
*   **인증 (Authentication)**: 사용자가 "누구인지" 확인하는 과정 (로그인).
    -   Nexus는 기본적으로 로컬 사용자 데이터베이스를 사용합니다.
*   **인가 (Authorization)**: 인증된 사용자가 "무엇을 할 수 있는지" 확인하는 과정 (권한 체크).
    -   Nexus는 Role-based Access Control을 통해 인가를 수행합니다.
*   **나쁜 예시**: 인증되지 않은 사용자에게 `anonymous` 접근 권한을 과도하게 부여하여
    -   외부에서 모든 아티팩트를 열람할 수 있도록 설정하는 것.
    -   `Security` -> `Anonymous Access` 메뉴에서 `Allow anonymous access`를 비활성화하는 것을 고려합니다. (물론 공개된 아티팩트의 경우 활성화할 수도 있습니다.)

### 4. 외부 인증 시스템 연동 (Integrating External Authentication) (개념)
*   **목표**: 기존 조직의 사용자 관리 시스템(LDAP, SAML, OAuth2 등)과 Nexus를 연동하여 사용자 관리를 통합합니다.
*   **설정**: `Security` -> `Realms` 메뉴에서 활성화할 Realm을 선택하고 설정합니다.
    -   `LDAP Realm`: Active Directory 또는 OpenLDAP과 같은 LDAP 서버와 연동.
*   **모범 사례**: 대규모 조직에서는 사용자 관리를 중앙 집중화하기 위해 외부 인증 시스템과 Nexus를 연동하는 것이 일반적입니다.
*   **나쁜 예시**: 로컬 Nexus 사용자 계정을 수백 개씩 수동으로 관리하여 유지보수 부담을 늘리는 것.

### 5. Nexus 보안 강화 모범 사례 (Security Best Practices)
*   **기본 `admin` 비밀번호 변경**: 초기 설치 후 반드시 `admin` 계정의 비밀번호를 변경합니다.
*   **HTTPS 사용**: Nexus UI 및 아티팩트 통신에 HTTPS를 적용하여 데이터 암호화를 보장합니다. (SSL 인증서 설정)
*   **네트워크 접근 제한**: 방화벽을 사용하여 Nexus 서버에 대한 접근을 특정 IP 대역이나 내부 네트워크로 제한합니다.
*   **정기적인 백업**: `JENKINS_HOME`과 유사하게 `NEXUS_DATA_DIR`을 정기적으로 백업합니다.
*   **최신 버전 유지**: Nexus Repository Manager를 최신 버전으로 업데이트하여 보안 취약점을 패치합니다.
*   **로그 모니터링**: Nexus의 접근 로그 및 에러 로그를 주기적으로 확인하여 비정상적인 활동을 감지합니다.

이러한 사용자 및 권한 관리, 보안 강화 모범 사례들을 통해 Nexus Repository를 안전하고 효율적으로 운영할 수 있습니다.
다음 단계에서는 다양한 빌드 도구와 Nexus를 연동하는 방법을 학습합니다.
