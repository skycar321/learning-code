# PIP (Python Package Installer) Essential Commands

> **Python**의 표준 패키지 관리자입니다.

## 1. 패키지 설치
```bash
# 패키지 설치
pip install <package_name>

# 특정 버전 설치
pip install <package_name>==<version>

# 요구사항 파일(requirements.txt)로부터 일괄 설치
pip install -r requirements.txt

# 패키지 업그레이드
pip install --upgrade <package_name>
```

## 2. 패키지 정보 및 관리
```bash
# 설치된 패키지 목록 확인
pip list

# 패키지 상세 정보 확인
pip show <package_name>

# 패키지 제거
pip uninstall <package_name>
```

## 3. 가상환경과 함께 사용 (권장)
```bash
# 가상환경 생성
python -m venv .venv

# 가상환경 활성화 (Windows)
.venv\Scripts\activate

# 가상환경 활성화 (Mac/Linux)
source .venv/bin/activate

# 현재 환경의 패키지 목록을 파일로 저장
pip freeze > requirements.txt
```