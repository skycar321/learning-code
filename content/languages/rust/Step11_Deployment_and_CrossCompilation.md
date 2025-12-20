# Rust 배포 및 크로스 컴파일 (Deployment & Cross Compilation) 가이드

**결론부터 말씀드리면: 네, 사실입니다.**

Rust는 Java(JVM 필요)나 Python(인터프리터 필요)과 달리, C/C++처럼 **기계어(Machine Code)로 컴파일되는 네이티브 언어**입니다. 따라서 Rust나 Cargo가 설치되어 있지 않은 서버라도, 해당 운영체제(OS)에 맞는 **실행 파일(바이너리)**만 복사하면 바로 실행할 수 있습니다.

이 문서는 Windows 개발 환경에서 리눅스(Linux) 서버로 배포하기 위한 **크로스 컴파일(Cross Compilation)** 방법과, 모든 의존성을 하나로 뭉치는 **정적 링크(Static Linking)** 기법을 상세히 다룹니다.

---

## 1. 기본 빌드 (Release Build)

개발할 때는 `cargo run`을 쓰지만, 배포할 때는 최적화된 실행 파일을 만들어야 합니다.

```bash
# 릴리즈 모드로 빌드 (최적화 활성화, 디버그 심볼 제거)
cargo build --release
```

*   **결과물**: `target/release/` 폴더에 실행 파일이 생성됩니다.
*   **문제점**: 현재 Windows에서 빌드하면 `.exe` 파일이 나옵니다. 이 파일은 리눅스 서버에서 실행되지 않습니다. (OS 아키텍처 불일치)

---

## 2. 크로스 컴파일 (Windows -> Linux)

Windows 컴퓨터에서 리눅스 서버용 실행 파일을 만드는 것을 **크로스 컴파일**이라고 합니다. Rust는 이를 위한 강력한 도구인 `cross`를 제공합니다.

### 방법 A: `cross` 도구 사용 (가장 추천)
Docker를 활용하여 복잡한 링커(Linker) 설정 없이 쉽게 다른 OS용 바이너리를 빌드해주는 도구입니다. (Docker 설치 필수)

1.  **cross 설치**:
    ```bash
    cargo install cross
    ```

2.  **리눅스용 빌드 (Glibc)**:
    대부분의 리눅스(Ubuntu, CentOS 등)에서 사용하는 표준 타겟입니다.
    ```bash
    cross build --target x86_64-unknown-linux-gnu --release
    ```

3.  **결과물 확인**:
    `target/x86_64-unknown-linux-gnu/release/` 폴더에 실행 파일이 생성됩니다. 이 파일을 서버로 복사(`scp`)해서 실행하면 됩니다.

---

## 3. 정적 링크 (Static Linking) - "진정한" 배포의 자유

위의 `gnu` 타겟은 서버에 있는 C 라이브러리(`glibc`) 버전에 의존합니다. 만약 서버가 아주 오래된 리눅스라면 버전 호환성 문제가 생길 수 있습니다.

이때 **MUSL** 타겟을 사용하면 C 라이브러리까지 바이너리 안에 다 포함시켜버립니다. 용량은 조금 커지지만, **어떤 리눅스 배포판이든 100% 실행 보장**됩니다. (Alpine Linux 등에서도 동작)

```bash
# MUSL 타겟으로 완벽한 정적 바이너리 빌드
cross build --target x86_64-unknown-linux-musl --release
```

*   이 파일은 의존성이 '0'입니다. 빈 깡통 서버에 던져놔도 돌아갑니다.

---

## 4. Docker Multi-stage Build (현대적 배포 방식)

크로스 컴파일이 번거롭다면, 아예 리눅스 환경인 Docker 안에서 빌드하고 실행 이미지를 만드는 것이 표준입니다.

`Dockerfile` 예시 (최적화된 버전):

```dockerfile
# 1단계: 빌드 (Builder Stage)
FROM rust:1.75 as builder
WORKDIR /app
COPY . .
# 정적 링크를 위해 musl 타겟 추가
RUN rustup target add x86_64-unknown-linux-musl
RUN cargo build --release --target x86_64-unknown-linux-musl

# 2단계: 실행 (Runtime Stage)
# 텅 빈 경량 이미지(Scratch) 사용 - 보안성 최고, 용량 최소
FROM scratch
COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/my_app /app
CMD ["/app"]
```

이 방식은 개발자 PC의 OS와 상관없이 항상 리눅스 바이너리를 생성합니다.

---

## 5. 요약 및 체크리스트

| 상황 | 추천 방법 | 명령어 |
| :--- | :--- | :--- |
| **같은 OS 배포** | 기본 빌드 | `cargo build --release` |
| **Win -> Linux (일반)** | Cross (GNU) | `cross build --target x86_64-unknown-linux-gnu --release` |
| **호환성 끝판왕** | Cross (MUSL) | `cross build --target x86_64-unknown-linux-musl --release` |
| **컨테이너 배포** | Docker | `docker build .` (Multi-stage 권장) |

### 배포 시 주의사항
1.  **OpenSSL 의존성**: Rust 웹 프레임워크(Axum, Actix)는 OpenSSL을 자주 쓰는데, 크로스 컴파일 시 가장 골치 아픈 부분입니다. `rustls` 기능을 켜서 OpenSSL 대신 Rust 순수 구현체를 쓰면 컴파일이 훨씬 쉬워집니다. (`Cargo.toml` 의존성 설정 확인)
2.  **환경 변수**: `.env` 파일은 컴파일에 포함되지 않습니다. 서버에서 실행할 때 환경 변수나 `.env` 파일을 따로 챙겨야 합니다.

---

## 6. 폐쇄망(Closed Network) 및 Nexus 연동 배포 전략

**시나리오**: 인터넷이 차단된 폐쇄망 환경의 **Rocky Linux 8.1** 서버에 배포해야 하며, 의존성 라이브러리(Crate)는 사내 **Nexus Repository**에서만 가져와야 합니다.

### 6.1. Nexus 저장소 설정 (Source Replacement)
Rust의 패키지 매니저인 Cargo가 `crates.io` 대신 사내 Nexus를 바라보도록 설정해야 합니다.
프로젝트 루트 또는 사용자 홈 디렉토리의 `.cargo/config.toml` 파일을 생성/수정합니다.

**파일 경로**: `my_project/.cargo/config.toml`

```toml
# 기본 crates.io 소스를 'nexus'라는 이름의 소스로 교체
[source.crates-io]
replace-with = 'nexus'

# Nexus 저장소 상세 정보 정의
[source.nexus]
# Nexus의 Cargo 호스팅 레지스트리 주소 (반드시 'git'이 아닌 'sparse' 또는 'registry' 방식 확인 필요)
# 보통 Nexus는 crates.io의 프록시(Proxy) 역할을 합니다.
registry = "http://nexus.internal.company.com/repository/cargo-group/"

# 인증이 필요한 경우 (선택 사항)
[registries.nexus]
index = "http://nexus.internal.company.com/repository/cargo-group/index"
```

만약 Nexus에 인증이 필요하다면 다음 명령어로 토큰을 저장합니다:
```bash
cargo login --registry nexus [YOUR_AUTH_TOKEN]
```

### 6.2. Rocky Linux 8.1 호환성 확보 전략
Rocky Linux 8.1은 `glibc 2.28` 버전을 사용합니다.
만약 최신 Ubuntu 등에서 `gnu` 타겟으로 빌드하면, 바이너리가 더 높은 버전의 `glibc`(예: 2.35)를 요구하여 **"version 'GLIBC_2.35' not found"** 에러가 발생할 수 있습니다.

이를 해결하는 가장 확실한 방법은 **MUSL(정적 링크)** 타겟을 사용하는 것입니다.

#### 방법 1: 개발 PC에서 `cross`로 MUSL 빌드 (추천)
Nexus 설정을 마친 개발 PC(인터넷/사내망 연결)에서 다음 명령어로 빌드합니다.

```bash
# Nexus에서 의존성을 받아와서, 리눅스용 정적 바이너리 생성
cross build --target x86_64-unknown-linux-musl --release
```
생성된 파일(`target/x86_64-unknown-linux-musl/release/my_app`)은 `glibc` 버전을 타지 않으므로 Rocky 8.1에서도 100% 동작합니다.

#### 방법 2: Rocky 8 컨테이너에서 빌드
만약 반드시 동적 링크(`gnu`)를 써야 한다면, 빌드 환경을 타겟 서버와 맞춰야 합니다.

**Dockerfile (Rocky 8 기반 빌더)**
```dockerfile
FROM rockylinux:8
# Rust 설치 (curl이 안된다면 오프라인 설치 파일 필요)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# 소스 복사
WORKDIR /app
COPY . .

# Nexus 설정 파일도 같이 복사되었는지 확인 (.cargo/config.toml)
# 빌드 수행
RUN cargo build --release
```

### 6.3. 최종 배포 프로세스 (요약)

1.  **설정**: 개발 PC의 `.cargo/config.toml`에 사내 **Nexus 주소** 등록.
2.  **빌드**: `cross build --target x86_64-unknown-linux-musl --release` 실행.
3.  **전송**: 생성된 **단일 바이너리 파일**만 보안 USB나 망연계 솔루션을 통해 폐쇄망의 Rocky 8.1 서버로 복사.
4.  **실행**: 서버에는 Rust 설치 불필요. 권한 주고 실행만 하면 끝.
    ```bash
    chmod +x ./my_app
    ./my_app
    ```