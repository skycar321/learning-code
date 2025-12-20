# Step 11: Docker 트러블슈팅 가이드 (Troubleshooting Guide)

Docker 사용 시 자주 마주치는 오류 Top 50을 정리했습니다. 오류 메시지(Error Message)를 검색(`Ctrl+F`)하여 원인과 해결책을 빠르게 찾으세요.

## 1. Daemon & Installation Errors (데몬 및 설치)

### 1-1. `Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?`
- **원인**: Docker 데몬이 실행 중이지 않거나 중단됨.
- **해결**:
  - Linux: `sudo systemctl start docker`
  - macOS/Windows: Docker Desktop 앱 실행.

### 1-2. `permission denied while trying to connect to the Docker daemon socket`
- **원인**: 현재 사용자가 `docker` 그룹에 속하지 않아 소켓 접근 권한 없음.
- **해결**:
  ```bash
  sudo usermod -aG docker $USER
  # 가장 확실한 적용 방법: 로그아웃 후 다시 로그인
  # 임시 적용: newgrp docker
  ```
- **Bad**: 매번 `sudo docker ...` 사용 (보안상 비권장).

### 3-3. `pip install` fails with connection timeout
- **원인**: 사내 방화벽, 느린 네트워크, 또는 PyPI 서버 지연.
- **해결**:
  - 타임아웃 시간 늘리기: `RUN pip install --default-timeout=100 ...`
  - 신뢰할 수 있는 호스트 추가 (보안 주의): `RUN pip install --trusted-host pypi.org ...`
  - 프록시 설정: `ENV http_proxy` 사용.

### 3-4. `toomanyrequests: You have reached your pull rate limit`
- **원인**: Docker Hub 익명 사용자 요청 제한 초과.
- **해결**: `docker login` 으로 로그인.

### 3-5. `authentication required` (Build time)
- **원인**: 프라이빗 베이스 이미지를 가져오는데 인증 정보 누락.
- **해결**: `docker login` 후 빌드.

### 3-6. `no space left on device` (Build time)
- **원인**: 빌드 중 임시 레이어 생성 공간 부족.
- **해결**: `docker system prune -a`.

### 3-7. `failed to compute cache key: "/app/node_modules" not found`
- **원인**: 멀티 스테이지 빌드에서 `COPY --from=builder` 경로 오타.
- **해결**: 이전 스테이지의 경로 확인.

### 3-8. `The command '/bin/sh -c ...' returned a non-zero code: 127`
- **원인**: 명령어를 찾을 수 없음 (Command not found).
- **해결**: 해당 바이너리가 설치되었는지, `PATH`에 있는지 확인.

### 3-9. `returned a non-zero code: 2` (Python Syntax Error)
- **원인**: Python 2 vs 3 문법 차이 또는 스크립트 에러.
- **해결**: 스크립트 로컬 테스트 수행.

### 3-10. `debconf: unable to initialize frontend: Dialog`
- **원인**: `apt-get` 실행 시 인터랙티브 모드 진입 시도.
- **해결**: `ARG DEBIAN_FRONTEND=noninteractive` 추가.

---

## 4. Networking Errors (네트워크)

### 4-1. `connection refused` (Between Containers)
- **원인**: 대상 컨테이너가 실행 중이지 않거나, 해당 포트로 리슨하지 않음. `localhost`로 접속 시도.
- **해결**: `localhost` 대신 **서비스 이름(Service Name)** 사용 (Docker DNS). 애플리케이션이 `0.0.0.0`으로 바인딩하는지 확인.

### 4-2. `Temporary failure in name resolution`
- **원인**: 컨테이너 내부 DNS 설정 오류.
- **해결**: `docker run --dns 8.8.8.8 ...` 또는 호스트의 `/etc/resolv.conf` 확인.

### 4-3. `bind: address already in use`
- **원인**: 호스트의 해당 포트를 다른 프로세스가 사용 중.
- **해결**: `netstat -nlp | grep <port>` 로 확인 후 프로세스 종료 또는 매핑 포트 변경 (`-p 8081:80`).

### 4-4. `network not found`
- **원인**: 지정된 네트워크가 존재하지 않음.
- **해결**: `docker network create <name>` 또는 `docker-compose up` (자동 생성).

### 4-5. `Host is unreachable`
- **원인**: 컨테이너에서 외부(인터넷) 또는 호스트 네트워크로 라우팅 실패.
- **해결**: 방화벽(UFW/Firewalld) 설정 확인. Docker 데몬의 `bip` 충돌 확인.

### 4-6. `Access to port 80 is not allowed` (Non-root)
- **원인**: 1024번 이하 포트는 루트 권한 필요.
- **해결**: 1024번 이상 포트(8080 등) 사용.

### 4-7. Docker container cannot ping host
- **원인**: 컨테이너 격리로 인해 호스트 IP 접근 불가.
- **해결**: `host.docker.internal` DNS 사용 (Mac/Windows). Linux는 `--add-host` 옵션 사용.

### 4-8. `endpoint with name ... already exists in network`
- **원인**: 컨테이너가 비정상 종료되면서 네트워크 엔드포인트가 정리되지 않음.
- **해결**: `docker network disconnect -f <network> <container>` 또는 네트워크 재생성.

### 4-9. `failed to publish ports: ... iptables: No chain/target/match by that name`
- **원인**: iptables 초기화됨.
- **해결**: Docker 데몬 재시작.

### 4-10. Slow network performance inside container
- **원인**: MTU(Maximum Transmission Unit) 불일치.
- **해결**: Docker 네트워크의 MTU를 호스트와 일치시킴 (`com.docker.network.driver.mtu`).

---

## 5. Volumes & Storage Errors (볼륨 및 스토리지)

### 5-1. `permission denied` (Mounted Volume)
- **원인**: 호스트 디렉토리의 소유자(UID)와 컨테이너 내부 프로세스 실행자(UID) 불일치.
- **해결**: `chown -R 1000:1000 ./data` (호스트) 또는 `user: "${UID}:${GID}"` (Compose).

### 5-2. `device or resource busy`
- **원인**: 컨테이너가 사용 중인 파일을 호스트나 다른 프로세스가 삭제/수정하려고 함.
- **해결**: 컨테이너 종료 후 작업.

### 5-3. `no space left on device` (Overlay2)
- **원인**: Docker Root Dir(`/var/lib/docker`) 용량 부족.
- **해결**: `docker system prune` 또는 디스크 증설.

### 5-4. `Filesystem is read-only`
- **원인**: 컨테이너가 `read_only: true`로 설정되었거나, 볼륨이 `:ro`로 마운트됨.
- **해결**: 설정 변경.

### 5-5. `invalid mount config for type "bind": bind source path does not exist`
- **원인**: 호스트 경로가 존재하지 않음.
- **해결**: 미리 디렉토리 생성 (`mkdir`).

### 5-6. Changes in container not reflected on host (or vice versa)
- **원인**: Docker Desktop(Mac/Win)의 파일 싱크 지연 또는 볼륨 마운트 설정 오류.
- **해결**: Named Volume 대신 Bind Mount 사용 확인.

### 5-7. `tar: ...: Cannot open: Permission denied` (During Copy)
- **원인**: `docker cp` 시 대상 경로 권한 부족.
- **해결**: 대상 경로 권한 확인.

### 5-8. `volume is in use`
- **원인**: 볼륨을 제거하려는데 다른 컨테이너가 사용 중.
- **해결**: `docker ps -a`로 멈춘 컨테이너 확인 후 삭제.

### 5-9. `inode exhaustion`
- **원인**: 용량은 남았으나 파일 개수가 너무 많음.
- **해결**: `df -i` 확인. 불필요한 작은 파일들 삭제.

### 5-10. `OverlayFS: missing 'lowerdir'`
- **원인**: 파일시스템 손상.
- **해결**: `/var/lib/docker` 초기화 (주의: 모든 데이터 삭제됨).

---

## 6. Docker Compose Errors (도커 컴포즈)

### 6-1. `yaml: line X: mapping values are not allowed in this context`
- **원인**: 들여쓰기(Indentation) 오류. 탭(Tab) 사용 금지.
- **해결**: 스페이스 2칸으로 들여쓰기 교정. IDE의 YAML Validator 사용.

### 6-2. `Service '...' depends on service '...' which is undefined`
- **원인**: `depends_on`에 적은 서비스 이름 오타.
- **해결**: 서비스 이름 확인.

### 6-3. `Variable ${VAR} is not set. Defaulting to a blank string.`
- **원인**: `.env` 파일이 없거나 변수 누락.
- **해결**: `.env` 파일 위치 확인 또는 `export VAR=...`.

### 6-4. `Version in "./docker-compose.yml" is unsupported`
- **원인**: Docker Compose 버전이 너무 낮음.
- **해결**: Docker Compose 업그레이드 또는 YAML `version` 낮춤.

### 6-5. `container name "..." is already in use`
- **원인**: `container_name` 속성을 썼는데 스케일링(Scale) 하려고 함. 고정 이름은 1개만 존재 가능.
- **해결**: `container_name` 제거.

---

## 🔍 Good vs Bad Troubleshooting Habits

### ❌ Bad Practice
- 오류 메시지를 읽지 않고 무조건 `rm -rf` 하고 다시 빌드한다.
- 권한 문제가 생기면 무조건 `chmod 777`을 하거나 `privileged` 모드를 켠다.
- 컨테이너가 죽으면 `restart: always`로 덮어두고 원인을 찾지 않는다.

### ✅ Good Practice
- `docker logs <id>`와 `docker inspect <id>`를 먼저 확인한다.
- `docker exec -it <id> /bin/bash`로 들어가서 네트워크/파일 상태를 직접 본다.
- 최소 권한 원칙(Least Privilege)을 지키며 해결책을 찾는다.
