# Cargo는 Rust의 패키지·빌드·테스트 관리 도구입니다.  
# Cargo 명령어 가이드 (platform 프로젝트)

> 실행 위치: 항상 `platform` 폴더에서 실행  
> 예: `cd C:\Users\Nam\Desktop\Workspace\learning-code\platform`

## 사전 준비 (Windows)
- Rust 도구 경로 추가: `$env:PATH="$env:USERPROFILE\.cargo\bin;$env:PATH"`
- MSVC 링크 도구 사용: `"%ProgramFiles%\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat" -arch=amd64` 실행 후 같은 셸에서 Cargo 명령을 실행.
- (최초 1회) Windows SDK가 필요합니다. 이미 `10.0.26100` 버전이 설치되어 있다면 추가 작업은 없습니다.

## 주요 명령어
- `cargo build`  
  프로젝트를 컴파일만 합니다. 릴리즈 최적화가 필요하면 `cargo build --release`.

- `cargo run`  
  서버를 실행합니다. 기본 포트는 `3000`이며, 콘텐츠 루트는 `../content`. 다른 경로를 쓰려면 `CONTENT_ROOT="경로"` 환경변수를 지정하세요.  
  예: `CONTENT_ROOT="C:/Users/Nam/Desktop/Workspace/learning-code/content" cargo run`

- `cargo test`  
  단위 테스트(현재 2개)를 실행합니다. VS 개발자 명령 프롬프트를 켠 후 `cargo test` 실행.

- `cargo fmt`  
  러스트 코드 자동 정렬. 실행 전 한 번 `rustup component add rustfmt` 필요.

- `cargo clippy`  
  정적 분석 경고 확인. 필요 시 `rustup component add clippy` 후 `cargo clippy`.

- `cargo clean`  
  `target` 빌드 산출물을 삭제해 공간을 확보합니다.

## 자주 쓰는 실행 예시
```powershell
# 1) VS 개발 환경 + PATH 설정
"$Env:ProgramFiles\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat" -arch=amd64
$env:PATH="$env:USERPROFILE\.cargo\bin;$env:PATH"

# 2) 프로젝트 디렉터리 이동
cd C:\Users\Nam\Desktop\Workspace\learning-code\platform

# 3) 테스트 실행
cargo test

# 4) 서버 실행 (콘텐츠 루트 명시)
CONTENT_ROOT="C:/Users/Nam/Desktop/Workspace/learning-code/content" cargo run
```
