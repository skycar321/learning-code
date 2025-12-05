# NPM (Node Package Manager) Essential Commands

> **Node.js**의 기본 패키지 관리자입니다.

## 1. 프로젝트 초기화
```bash
# 기본 설정으로 package.json 생성
npm init -y

# 사용자 질문과 함께 초기화
npm init
```

## 2. 패키지 설치
```bash
# 의존성(dependencies) 설치
npm install <package_name>
# 단축어
npm i <package_name>

# 개발 의존성(devDependencies) 설치 (테스트, 빌드 도구 등)
npm install <package_name> --save-dev
npm i -D <package_name>

# 전역(Global) 설치 (시스템 전체에서 사용)
npm install -g <package_name>

# 특정 버전 설치
npm i <package_name>@<version>
```

## 3. 패키지 관리
```bash
# 설치된 패키지 목록 확인
npm list --depth=0

# 오래된 패키지 확인
npm outdated

# 패키지 업데이트
npm update <package_name>

# 패키지 제거
npm uninstall <package_name>
```

## 4. 스크립트 실행
`package.json`의 `scripts` 섹션에 정의된 명령어를 실행합니다.
```bash
npm run <script_name>
# 예: npm run start, npm run build, npm run test
```

## 5. 캐시 및 문제 해결
```bash
# 캐시 삭제 (설치 문제 발생 시)
npm cache clean --force
```