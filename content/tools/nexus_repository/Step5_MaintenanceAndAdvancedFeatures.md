# Nexus Repository 학습 계획 - 5단계: 유지보수 및 고급 기능
# 이 파일은 Nexus Repository Manager의 운영, 유지보수, 보안 강화,
# 그리고 CI/CD 파이프라인과의 연동 및 스크립팅과 같은 고급 기능을 학습하기 위한 개념적인 설명입니다.
#
# Nexus Repository는 단순히 아티팩트를 저장하는 것을 넘어,
# 효율적인 관리와 자동화를 통해 개발 워크플로우를 최적화할 수 있습니다.

## 개요 (Overview)
Nexus Repository는 개발 프로세스에서 중요한 역할을 하므로, 항상 안정적이고 효율적으로
운영되어야 합니다. 이를 위해서는 정기적인 유지보수, 보안 강화, 그리고
CI/CD 파이프라인과의 긴밀한 연동이 필수적입니다.

## 학습 목표 (Learning Objectives)
*   스케줄된 태스크(Scheduled Tasks)를 이용한 Nexus 자동화
*   스토리지(Blob Store) 관리 및 백업/복구 전략 이해
*   CI/CD 파이프라인에서 Nexus를 활용한 아티팩트 관리 및 배포
*   Groovy 스크립트를 이용한 Nexus 자동화 개념
*   Nexus 보안 강화 및 모니터링 모범 사례

## 학습 내용 (Learning Content)

### 1. 스케줄된 태스크(Scheduled Tasks) 관리 (Nexus UI를 통해)
*   **목표**: 캐시 정리, 인덱스 재빌드 등 반복적인 관리 작업을 자동화하여 Nexus의 성능과 일관성을 유지합니다.
*   **Nexus UI 접근**: `http://localhost:8081`로 이동하여 `admin` 계정으로 로그인합니다.
*   **'Tasks' 메뉴 이동**: 좌측 메뉴에서 `System` -> `Tasks`를 클릭합니다.
*   **태스크 생성**: `Create task` 버튼을 클릭하여 새 스케줄된 태스크를 생성합니다.
    -   **Clean up unused manifests and images**: Docker 프록시 저장소의 사용되지 않는 이미지 및 매니페스트 정리.
    -   **Compact blob store**: 스토리지 공간 최적화.
    -   **Rebuild Maven indexes**: Maven 인덱스 재빌드 (의존성 검색 성능 향상).
    -   **Purge unmanaged old releases**: 특정 기간 이상 된 릴리즈 아티팩트 자동 삭제.
*   **실행 주기 설정**: `Run as user`, `Cron Expression` 등을 설정하여 태스크의 실행 주기와 권한을 정의합니다.
*   **나쁜 예시**: 스케줄된 태스크를 설정하지 않아 Nexus 디스크 공간이 부족해지거나,
    -   오래된 캐시가 쌓여 성능이 저하되는 것.
    -   정기적인 유지보수 작업 자동화는 Nexus 운영의 기본입니다.

### 2. 스토리지 관리 (Storage Management)
*   **Blob Store 설정**:
    -   Nexus는 아티팩트를 Blob Store에 저장합니다. 기본적으로 `default` Blob Store를 사용합니다.
    -   `Admin` -> `System` -> `Blob Stores` 메뉴에서 Blob Store를 관리할 수 있습니다.
    -   **유형**: File (기본값), S3 (S3 호환 스토리지 사용).
    -   **나쁜 예시**: Nexus 데이터를 로컬 디스크에만 저장하고, 스토리지를 이중화하지 않아 데이터 손실 위험을 감수하는 것.
    -   프로덕션 환경에서는 안정적인 스토리지(네트워크 스토리지, 클라우드 스토리지)에 Blob Store를 구성하고, S3와 같은 객체 스토리지 서비스를 활용하는 것이 좋습니다.

### 3. 고가용성(High Availability) 및 백업/복구 (Pro 버전 기능)
*   **고가용성 (HA)**: Nexus Pro 버전은 여러 Nexus 인스턴스를 클러스터로 구성하여 서비스 중단 없이 지속적인 운영을 가능하게 합니다.
*   **백업 및 복구**:
    -   Nexus OSS 버전도 `NEXUS_DATA_DIR` 디렉토리를 백업하는 방식으로 데이터를 복구할 수 있습니다.
    -   정기적인 백업 정책을 수립하고, 복구 절차를 테스트하는 것이 중요합니다.
*   **나쁜 예시**: 백업 전략 없이 Nexus Repository를 운영하여 데이터 손실 시 복구가 불가능한 상황을 만드는 것.

### 4. CI/CD 파이프라인 연동 (Integrating with CI/CD Pipelines)
*   **목표**: Jenkins, GitLab CI, GitHub Actions 등 CI/CD 도구에서 Nexus를 사용하여 아티팩트를 자동으로 배포하고 가져오도록 합니다.
*   **주요 연동 방식**:
    -   **Credentials**: CI/CD 도구의 Secret 관리 기능을 사용하여 Nexus 접근 인증 정보(사용자 이름, 비밀번호)를 안전하게 주입합니다.
    -   **`settings.xml` / `build.gradle` / `.npmrc`**: 빌드 도구별 설정 파일에 Nexus Repository URL을 명시합니다.
    -   **Build Scan / Publish**: 빌드 성공 시 아티팩트를 Nexus에 자동으로 배포하는 명령어를 CI/CD 스크립트에 포함합니다.
*   **나쁜 예시**: CI/CD 파이프라인에 Nexus 인증 정보를 하드코딩하거나, Nexus 연동 없이 빌드 프로세스를 수동으로 처리하는 것.

### 5. 스크립팅(Scripting) - Groovy 스크립트를 이용한 자동화 (개념)
*   **목표**: Nexus 내부 관리 및 아티팩트 조작과 같은 고급 작업을 Groovy 스크립트로 자동화합니다.
*   **Nexus UI 접근**: `Admin` -> `System` -> `Scripts` 메뉴에서 Groovy 스크립트를 관리하고 실행할 수 있습니다.
*   **활용 예시**:
    -   사용자 정의 저장소 생성 및 삭제.
    -   특정 조건에 맞는 아티팩트 검색 및 삭제.
    -   대량의 사용자 또는 권한 설정 변경.
*   **나쁜 예시**: 반복적이거나 복잡한 Nexus 관리 작업을 매번 UI에서 수동으로 처리하여 시간 낭비 및 휴먼 에러를 유발하는 것.
*   **좋은 예시**: Groovy 스크립트를 활용하여 Nexus 관리 작업을 자동화하고, 스크립트도 버전 관리하여 재현성을 확보하는 것.

## Nexus 보안 강화 및 모니터링 모범 사례 (개념)
*   **HTTPS 사용**: Nexus UI 및 아티팩트 다운로드/업로드 통신에 반드시 HTTPS를 적용합니다.
*   **네트워크 접근 제한**: 방화벽을 사용하여 Nexus 서버에 대한 접근을 내부 네트워크나 특정 IP 대역으로 제한합니다.
*   **정기적인 백업**: Nexus 데이터 디렉토리(`NEXUS_DATA_DIR`)를 정기적으로 백업하고, 백업본의 유효성을 검증합니다.
*   **로그 모니터링**: Nexus의 접근 로그, 시스템 로그, 감사 로그를 중앙 로깅 시스템(예: ELK Stack, Splunk)으로 수집하여 모니터링하고 비정상적인 활동을 감지합니다.
*   **최신 버전 유지**: Nexus Repository Manager를 항상 최신 상태로 유지하여 알려진 보안 취약점을 패치합니다.

이러한 유지보수 및 고급 기능들을 통해 Nexus Repository를 안정적이고 효율적이며 안전하게 운영할 수 있습니다.
Nexus는 단순히 아티팩트 저장소 이상의 역할을 수행하며, 개발팀의 생산성과 소프트웨어 품질에 큰 영향을 미칩니다.
