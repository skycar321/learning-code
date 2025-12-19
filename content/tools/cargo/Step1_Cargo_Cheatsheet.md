# Cargo (Rust Package Manager)

> **Rust** 언어의 공식 패키지 관리자 및 빌드 시스템입니다.

## 1. 프로젝트 생성
```bash
# 바이너리(실행 파일) 프로젝트 생성
cargo new <project_name>

# 라이브러리 프로젝트 생성
cargo new --lib <project_name>

# 현재 디렉토리에 초기화
cargo init
```

## 2. 빌드 및 실행
```bash
# 디버그 모드로 빌드
cargo build

# 릴리즈 모드로 빌드 (최적화 포함)
cargo build --release

# 빌드 및 즉시 실행
cargo run

# 문법 오류 검사 (빌드보다 빠름)
cargo check
```

## 3. 의존성 관리
```bash
# 의존성 추가 (cargo-edit 필요, 또는 Cargo.toml 직접 수정)
cargo add <crate_name>

# 의존성 업데이트
cargo update

# 의존성 트리 확인
cargo tree
```

## 4. 테스트 및 문서
```bash
# 테스트 실행
cargo test

# 문서 생성 및 브라우저로 열기
cargo doc --open
```

## 5. 유용한 도구 (추가 설치)
```bash
# 코드 포맷터
cargo fmt

# 린터 (Linter)
cargo clippy
```