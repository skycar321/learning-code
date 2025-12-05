# PIPX (Installable Python Apps)

> Python으로 작성된 CLI 도구를 시스템 전체에 격리된 환경으로 설치하고 실행합니다. 패키지 간 의존성 충돌을 방지합니다.

## 1. 설치
```bash
# pip를 통해 설치
pip install pipx
pipx ensurepath
```

## 2. 도구 설치 및 실행
```bash
# 도구 설치 (격리된 환경 생성)
pipx install <package_name>
# 예: pipx install black

# 설치된 도구 실행
black myfile.py
```

## 3. 도구 관리
```bash
# 설치된 도구 목록 확인
pipx list

# 도구 업그레이드
pipx upgrade <package_name>
pipx upgrade-all

# 도구 제거
pipx uninstall <package_name>
```

## 4. 일회성 실행 (설치 없이)
```bash
pipx run <package_name>
# 예: pipx run cowsay "Hello"
```