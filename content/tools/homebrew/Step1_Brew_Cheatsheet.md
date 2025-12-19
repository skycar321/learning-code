# Homebrew (The Missing Package Manager for macOS/Linux)

> macOS와 Linux에서 소프트웨어 설치를 단순화하는 패키지 관리자입니다.

## 1. 패키지(Formula) 관리
CLI 도구나 라이브러리를 설치합니다.

```bash
# 패키지 검색
brew search <package_name>

# 패키지 설치
brew install <package_name>

# 패키지 정보 확인
brew info <package_name>

# 패키지 업그레이드
brew upgrade <package_name>

# 패키지 삭제
brew uninstall <package_name>
```

## 2. 애플리케이션(Cask) 관리 (macOS only)
GUI 애플리케이션(Chrome, VS Code 등)을 설치합니다.

```bash
# 앱 설치
brew install --cask <app_name>
# 예: brew install --cask google-chrome

# 앱 삭제
brew uninstall --cask <app_name>
```

## 3. 시스템 관리
```bash
# Homebrew 자체 및 패키지 정의 업데이트
brew update

# 전체 패키지 업그레이드
brew upgrade

# 오래된 파일 및 캐시 정리
brew cleanup

# 시스템 상태 진단
brew doctor
```

## 4. 서비스 관리 (Background Services)
데이터베이스 등을 백그라운드에서 실행할 때 유용합니다.
```bash
# 서비스 목록 확인
brew services list

# 서비스 시작/중단
brew services start <service_name>
brew services stop <service_name>
```