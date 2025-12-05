# UV (Ultra-Fast Python Package Installer)

> **Rust**로 작성된 엄청나게 빠른 Python 패키지 관리자입니다. `pip`를 대체할 수 있습니다.

## 1. 설치 및 업데이트
```bash
# 설치 (Windows/Mac/Linux 공통 스크립트)
curl -LsSf https://astral.sh/uv/install.sh | sh

# UV 자체 업데이트
uv self update
```

## 2. 가상환경 관리 (venv 대체)
```bash
# 가상환경 생성 (매우 빠름)
uv venv

# 가상환경 활성화
# (Windows) .venv\Scripts\activate
# (Linux/Mac) source .venv/bin/activate
```

## 3. 패키지 관리 (pip 대체)
`uv pip` 명령어를 사용하여 `pip`와 호환되는 인터페이스를 제공합니다.

```bash
# 패키지 설치
uv pip install <package_name>

# requirements.txt로 설치
uv pip install -r requirements.txt

# 패키지 제거
uv pip uninstall <package_name>

# 설치된 패키지 목록 동기화 (requirements.txt와 정확히 일치시킴)
uv pip sync requirements.txt
```

## 4. 도구 실행 (pipx 대체)
설치하지 않고 도구를 일회성으로 실행할 때 유용합니다.
```bash
uvx <tool_name>
# 예: uvx ruff check .
```