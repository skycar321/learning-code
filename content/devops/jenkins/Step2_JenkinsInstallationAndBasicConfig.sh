#!/bin/bash

# Jenkins 학습 계획 - 2단계: Jenkins 설치 및 기본 설정
# 이 스크립트는 Docker를 사용하여 Jenkins Controller를 설치하고,
# 초기 관리자 비밀번호를 확인하며, 플러그인 관리 및 글로벌 도구 설정에 대한
# 개념적인 명령어들을 포함하고 있습니다.
#
# Docker를 이용한 Jenkins 설치는 환경 구성의 간편함과 이식성을 제공합니다.

echo "--- 2단계: Jenkins 설치 및 기본 설정 ---"

# -----------------------------------------------------------------------------
# 1. Jenkins 설치 방법 (Docker 이용)
# - Docker가 설치되어 있어야 합니다.
# - Jenkins 공식 Docker 이미지를 사용합니다.
# - 영구적인 데이터 저장을 위해 Docker Volume을 마운트합니다.
# -----------------------------------------------------------------------------

JENKINS_HOME_DIR="$(pwd)/jenkins_home" # Jenkins 데이터가 저장될 로컬 디렉토리
JENKINS_IMAGE="jenkins/jenkins:lts"    # Jenkins LTS (Long Term Support) 이미지 사용
JENKINS_CONTAINER_NAME="my-jenkins-controller"
JENKINS_PORT="8080"                    # Jenkins 웹 UI 포트
JENKINS_AGENT_PORT="50000"             # Jenkins 에이전트 통신 포트

echo "1.1. Jenkins 데이터 저장을 위한 로컬 디렉토리 생성: $JENKINS_HOME_DIR"
mkdir -p "$JENKINS_HOME_DIR"
chmod 777 "$JENKINS_HOME_DIR" # Jenkins 컨테이너의 jenkins 유저가 접근할 수 있도록 권한 설정 (Docker 환경에 따라 다를 수 있음)

echo "1.2. Docker를 사용하여 Jenkins Controller 컨테이너 실행"
# 나쁜 예시: `-v` 옵션 없이 Jenkins 컨테이너를 실행하여 모든 데이터가 컨테이너 재시작 시 사라지게 하는 것.
# - Jenkins 설정, Job 데이터, 플러그인 등이 유실되어 재설정해야 하는 문제가 발생합니다.
# 좋은 예시: Docker Volume을 사용하여 Jenkins 데이터를 호스트 머신에 영구적으로 저장하는 것.
docker run -d --name "$JENKINS_CONTAINER_NAME" \
    -p "$JENKINS_PORT":"$JENKINS_PORT" \
    -p "$JENKINS_AGENT_PORT":"$JENKINS_AGENT_PORT" \
    -v "$JENKINS_HOME_DIR":/var/jenkins_home \
    -v /var/run/docker.sock:/var/run/docker.sock \
    "$JENKINS_IMAGE"

if [ $? -eq 0 ]; then
    echo "Jenkins 컨테이너 '$JENKINS_CONTAINER_NAME'가 백그라운드에서 시작되었습니다."
    echo "Jenkins 웹 UI는 http://localhost:$JENKINS_PORT 에서 접근 가능합니다."
    echo ""
else
    echo "Jenkins 컨테이너 시작 실패."
    exit 1
fi

echo "컨테이너가 완전히 시작될 때까지 잠시 기다립니다 (약 30초-1분)..."
sleep 60 # Jenkins가 완전히 시작될 때까지 충분한 시간 대기

# -----------------------------------------------------------------------------
# 2. 초기 설정 및 관리자 비밀번호 확인
# - Jenkins 웹 UI에 처음 접근할 때 필요한 초기 관리자 비밀번호를 가져옵니다.
# -----------------------------------------------------------------------------
echo "2.1. 초기 관리자 비밀번호 확인"
JENKINS_INITIAL_ADMIN_PASSWORD=$(docker exec "$JENKINS_CONTAINER_NAME" cat /var/jenkins_home/secrets/initialAdminPassword)

if [ -n "$JENKINS_INITIAL_ADMIN_PASSWORD" ]; then
    echo "----------------------------------------------------------------------"
    echo "초기 관리자 비밀번호: $JENKINS_INITIAL_ADMIN_PASSWORD"
    echo "이 비밀번호를 사용하여 http://localhost:$JENKINS_PORT 에서 Jenkins에 로그인하세요."
    echo "----------------------------------------------------------------------"
    echo "플러그인 설치 (Install suggested plugins 선택) 후 새 관리자 계정 생성 과정을 진행하세요."
    echo ""
else
    echo "초기 관리자 비밀번호를 가져오지 못했습니다. 로그를 확인하세요."
fi

# -----------------------------------------------------------------------------
# 3. 플러그인 관리 (Plugin Management) (개념)
# - Jenkins UI에서 'Jenkins 관리' -> '플러그인 관리' 메뉴를 통해 플러그인을 설치, 업데이트, 제거합니다.
# - CI/CD 파이프라인에 필요한 플러그인(예: Git, Maven, Docker, Pipeline, Blue Ocean, Slack)을 설치합니다.
# -----------------------------------------------------------------------------
echo "3. 플러그인 관리 (Jenkins UI를 통해 수행)"
echo "Jenkins 로그인 후 'Jenkins 관리' -> '플러그인 관리'에서 필요한 플러그인을 설치하세요."
echo "주요 플러그인 예시: Git, Maven Integration, Pipeline, Blue Ocean, Docker, Slack Notification"
echo ""

# -----------------------------------------------------------------------------
# 4. 글로벌 도구 설정 (Global Tool Configuration) (개념)
# - Jenkins UI에서 'Jenkins 관리' -> 'Global Tool Configuration' 메뉴를 통해
#   JDK, Maven, Git, Gradle 등 빌드에 필요한 도구들의 경로를 설정합니다.
# -----------------------------------------------------------------------------
echo "4. 글로벌 도구 설정 (Jenkins UI를 통해 수행)"
echo "Jenkins 로그인 후 'Jenkins 관리' -> 'Global Tool Configuration'에서"
echo "JDK, Git, Maven, Gradle 등 빌드에 필요한 도구들을 설정하세요."
echo "특히 'Add JDK', 'Add Git', 'Add Maven' 등을 클릭하여 설치 경로 또는 자동 설치를 구성합니다."
echo ""

# -----------------------------------------------------------------------------
# 5. 사용자 및 권한 관리 (User & Permission Management) (개념)
# - Jenkins UI에서 'Jenkins 관리' -> '사용자 관리' 및 '권한 설정' 메뉴를 통해
#   사용자 계정을 생성하고, 역할 기반 권한 관리(Role-based Access Control, RBAC)를 설정합니다.
# - 보안 강화를 위해 꼭 필요한 최소한의 권한만 부여해야 합니다.
# -----------------------------------------------------------------------------
echo "5. 사용자 및 권한 관리 (Jenkins UI를 통해 수행)"
echo "Jenkins 로그인 후 'Jenkins 관리' -> '사용자 관리'에서 신규 사용자를 생성하고,"
echo "'Configure Global Security'에서 'Matrix-based security' 또는 'Role-Based Strategy' 플러그인을 사용하여"
echo "세부적인 권한을 설정하세요."
echo ""

echo "--- 2단계 학습 완료 ---"

# Jenkins 컨테이너 중지 및 삭제 (선택 사항: 학습 완료 후 환경 정리)
# echo "Jenkins 컨테이너 '$JENKINS_CONTAINER_NAME' 중지 및 삭제 (5초 후)..."
# sleep 5
# docker stop "$JENKINS_CONTAINER_NAME" > /dev/null
# docker rm "$JENKINS_CONTAINER_NAME" > /dev/null
# echo "Jenkins 컨테이너 삭제 완료."
# echo "Jenkins 데이터 디렉토리 '$JENKINS_HOME_DIR' 삭제 (5초 후)..."
# sleep 5
# rm -rf "$JENKINS_HOME_DIR"
# echo "Jenkins 데이터 디렉토리 삭제 완료."
