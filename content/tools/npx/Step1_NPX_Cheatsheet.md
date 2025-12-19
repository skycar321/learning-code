# NPX (Node Package Runner) Cheatsheet

> npm 5.2.0부터 포함된 도구로, 패키지를 설치하지 않고 실행하거나 일회성으로 사용할 때 유용합니다.

## 1. 기본 실행 (설치 없이)
로컬이나 전역에 설치하지 않고 최신 버전을 다운로드하여 바로 실행합니다.

```bash
# create-react-app 실행 (가장 흔한 예시)
npx create-react-app my-app

# cowsay 실행 (재미있는 예시)
npx cowsay "Hello World"
```

## 2. 패키지 실행 제어
설치 여부나 버전을 세밀하게 제어할 수 있습니다.

```bash
# 로컬에 설치된 패키지가 없으면 실패하도록 설정 (의도치 않은 다운로드 방지)
npx --no-install <package_name>

# 이미 설치되어 있어도 무시하고 원격 버전 사용
npx --ignore-existing <package_name>

# 특정 버전 지정 실행
npx node@14 -v
npx uglify-js@3.1.0 main.js
```

## 3. GitHub Gist 실행
GitHub Gist에 있는 코드를 바로 실행할 수 있습니다. (보안 주의)

```bash
npx https://gist.github.com/zkat/4bc19503fe9e9309e2bfaa2c58074d32
```

## 4. 로컬 패키지 실행
`node_modules/.bin` 경로를 입력할 필요 없이 로컬에 설치된 바이너리를 실행합니다.

```bash
# 기존 방식: ./node_modules/.bin/mocha --version
npx mocha --version
```

## 5. 캐시 관리
NPX는 다운로드한 패키지를 임시 캐시에 저장합니다.

```bash
# 캐시 위치 확인 (OS별 상이)
npm config get cache

# 강제로 캐시 없이 실행 (항상 최신 버전)
npx <package_name>@latest
```
