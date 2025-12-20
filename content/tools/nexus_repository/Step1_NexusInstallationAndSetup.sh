#!/bin/bash

# Nexus Repository 학습 계획 - 1단계: Nexus Repository 소개 및 설치
# 이 스크립트는 Docker를 사용하여 Nexus Repository Manager (OSS 버전)를 설치하고,
# 초기 설정 및 Nexus UI 접근 방법을 학습하기 위한 개념적인 명령어들을 포함하고 있습니다.
#
# Nexus Repository는 개발 아티팩트(라이브러리, 빌드 결과물 등)를 중앙에서 관리하여
# 개발 프로세스의 효율성과 안정성을 높이는 데 필수적인 도구입니다.

echo "--- 1단계: Nexus Repository 소개 및 설치 ---"

# -----------------------------------------------------------------------------
# 1. 아티팩트 저장소의 필요성 (개념)
# - 외부 의존성(Maven Central, npmjs.com 등)을 캐싱하여 빌드 속도를 향상시킵니다.
# - 자체 개발한 아티팩트를 관리하고 공유하는 중앙 저장소 역할을 합니다.
# - CI/CD 파이프라인에서 빌드된 아티팩트의 배포 대상으로 사용됩니다.
# - 보안 및 거버넌스: 외부 네트워크 접근을 최소화하고, 승인된 아티팩트만 사용하도록 강제합니다.
# -----------------------------------------------------------------------------
echo "1. 아티팩트 저장소의 필요성 (개념적 설명)"
echo "  - 빌드 속도 향상, 아티팩트 관리, 보안 강화 등의 이유로 아티팩트 저장소가 필요합니다."
echo "나쁜 예시: 아티팩트 저장소 없이 외부 중앙 저장소에만 의존하거나,
  자체 개발한 라이브러리를 Git에 직접 커밋하는 것."
echo "  - 빌드 속도 저하, 네트워크 문제 시 빌드 실패, 버전 관리의 어려움 등의 문제가 발생합니다."
echo ""

# -----------------------------------------------------------------------------
# 2. Nexus Repository Manager 소개 (개념)
# - Sonatype에서 개발한 범용 아티팩트 저장소 관리 솔루션.
# - Maven, npm, Docker, PyPI, NuGet 등 다양한 패키지 포맷 지원.
# - 버전: Nexus Repository OSS (오픈소스 무료), Nexus Repository Pro (유료 엔터프라이즈 기능)
# -----------------------------------------------------------------------------
echo "2. Nexus Repository Manager 소개 (개념적 설명)"
echo "  - 다양한 패키지 포맷을 지원하는 강력한 아티팩트 관리 도구입니다."
echo ""

# -----------------------------------------------------------------------------
# 3. 설치 방법 (Docker 이용)
# - Docker가 설치되어 있어야 합니다.
# - Nexus 공식 Docker 이미지를 사용합니다.
# - 영구적인 데이터 저장을 위해 Docker Volume을 마운트합니다.
# -----------------------------------------------------------------------------

NEXUS_DATA_DIR="$(pwd)/nexus-data" # Nexus 데이터가 저장될 로컬 디렉토리
NEXUS_CONTAINER_NAME="my-nexus"
NEXUS_PORT="8081"                  # Nexus 웹 UI 포트 (기본값)
NEXUS_IMAGE="sonatype/nexus3"      # Nexus Repository Manager 3 이미지

echo "3.1. Nexus 데이터 저장을 위한 로컬 디렉토리 생성: $NEXUS_DATA_DIR"
mkdir -p "$NEXUS_DATA_DIR"
# Nexus 컨테이너는 내부적으로 'nexus' 사용자로 실행됩니다.
# 이 사용자가 마운트된 볼륨에 쓰기 권한이 있어야 하므로,
# 권한을 200:200 (nexus:nexus)으로 설정하는 것이 일반적입니다.
# 하지만 도커를 사용하는 경우, 컨테이너가 시작될 때 자동으로 권한을 조정하는 경우도 많습니다.
# 만약 권한 문제가 발생하면 `sudo chown -R 200:200 "$NEXUS_DATA_DIR"`를 시도해보세요.

echo "3.2. Docker를 사용하여 Nexus Repository Manager 컨테이너 실행"
# 나쁜 예시: `-v` 옵션 없이 Nexus 컨테이너를 실행하여 모든 데이터가 컨테이너 재시작 시 사라지게 하는 것.
# - 아티팩트 저장소는 영구적인 데이터 저장이 필수적이므로 반드시 볼륨을 마운트해야 합니다.
docker run -d --name "$NEXUS_CONTAINER_NAME" \
    -p "$NEXUS_PORT":"$NEXUS_PORT" \
    -v "$NEXUS_DATA_DIR":/nexus-data \
    "$NEXUS_IMAGE"

if [ $? -eq 0 ]; then
    echo "Nexus 컨테이너 '$NEXUS_CONTAINER_NAME'가 백그라운드에서 시작되었습니다."
echo "Nexus 웹 UI는 http://localhost:$NEXUS_PORT 에서 접근 가능합니다."
echo ""
else
    echo "Nexus 컨테이너 시작 실패."
    exit 1
fi

echo "Nexus가 완전히 시작될 때까지 잠시 기다립니다 (약 1분-2분)..."
sleep 120 # Nexus가 완전히 시작될 때까지 충분한 시간 대기

# -----------------------------------------------------------------------------
# 4. 초기 설정 및 관리자 비밀번호
# - Nexus UI에 처음 접근할 때 필요한 초기 관리자 비밀번호를 가져옵니다.
# -----------------------------------------------------------------------------
echo "4.1. 초기 관리자 비밀번호 확인"
# Nexus 3의 경우, 초기 비밀번호는 `/nexus-data/admin.password` 파일에 저장됩니다.
NEXUS_INITIAL_ADMIN_PASSWORD=$(docker exec "$NEXUS_CONTAINER_NAME" cat /nexus-data/admin.password)

if [ -n "$NEXUS_INITIAL_ADMIN_PASSWORD" ]; then
    echo "----------------------------------------------------------------------"
echo "초기 관리자 사용자명: admin"
echo "초기 관리자 비밀번호: $NEXUS_INITIAL_ADMIN_PASSWORD"
echo "이 비밀번호를 사용하여 http://localhost:$NEXUS_PORT 에서 Nexus에 로그인하세요."
echo "로그인 후 새 비밀번호로 변경해야 합니다."
echo "----------------------------------------------------------------------"
echo ""
else
    echo "초기 관리자 비밀번호를 가져오지 못했습니다. Nexus 컨테이너 로그를 확인하세요."
    docker logs "$NEXUS_CONTAINER_NAME" | tail -n 50 # 최근 로그 50줄 출력
fi

# -----------------------------------------------------------------------------
# 5. Nexus UI 탐색 (개념)
# - 로그인 후 'admin' 계정으로 Nexus UI에 접근합니다.
# - 'Repositories' 메뉴에서 기본으로 제공되는 저장소들을 확인합니다 (maven-central, maven-releases 등).
# - 'Security' -> 'Users' 메뉴에서 사용자 및 역할 관리를 수행합니다.
# -----------------------------------------------------------------------------
echo "5. Nexus UI 탐색 (개념적 설명)"
echo "  - 로그인 후 UI를 탐색하며 저장소 목록, 사용자 관리 등을 확인합니다."
echo ""

echo "--- 1단계 학습 완료 ---"

# Nexus 컨테이너 중지 및 삭제 (선택 사항: 학습 완료 후 환경 정리)
# echo "Nexus 컨테이너 '$NEXUS_CONTAINER_NAME' 중지 및 삭제 (5초 후)..."
# sleep 5
# docker stop "$NEXUS_CONTAINER_NAME" > /dev/null
# docker rm "$NEXUS_CONTAINER_NAME" > /dev/null
# echo "Nexus 컨테이너 삭제 완료."
# echo "Nexus 데이터 디렉토리 '$NEXUS_DATA_DIR' 삭제 (5초 후)..."
# sleep 5
# rm -rf "$NEXUS_DATA_DIR"
# echo "Nexus 데이터 디렉토리 삭제 완료."
