# MSYS2에서 Node.js와 npm 설치 가이드

## 문제 상황
```bash
npm install -g @openai/codex
zsh: command not found: npm
```

MSYS2 환경에서 Node.js와 npm이 설치되지 않아 발생하는 오류입니다.

---

## 해결 방법

### 방법 1: MSYS2 패키지 매니저로 설치 (권장)

#### 1-1. UCRT64 환경용 Node.js 설치
```bash
# UCRT64 터미널에서 실행
# Node.js 패키지에 npm이 이미 포함되어 있습니다
pacman -S mingw-w64-ucrt-x86_64-nodejs
```

#### 1-2. MINGW64 환경용 Node.js 설치
```bash
# MINGW64 터미널에서 실행
# Node.js 패키지에 npm이 이미 포함되어 있습니다
pacman -S mingw-w64-x86_64-nodejs
```

> **참고**: MSYS2의 Node.js 패키지는 npm을 번들로 포함하므로 별도로 설치할 필요가 없습니다.

#### 1-3. 설치 확인
```bash
node --version
npm --version
```

#### 1-4. 전역 패키지 설치 경로 설정
```bash
# npm 전역 패키지 디렉토리 설정
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'

# PATH에 추가 (zshrc 또는 bashrc에 추가)
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc
source ~/.zshrc
```

#### 1-5. 이제 Codex 설치 가능
```bash
npm install -g @openai/codex
```

---

### 방법 2: Windows용 Node.js 공식 설치 (대안)

#### 2-1. Node.js 공식 사이트에서 다운로드
- URL: https://nodejs.org/
- LTS 버전 다운로드 및 설치

#### 2-2. Windows PATH 자동 추가 확인
설치 중 "Add to PATH" 옵션 체크

#### 2-3. MSYS2 터미널 재시작 후 확인
```bash
node --version
npm --version
```

---

## 자동 설치 스크립트 사용

### 스크립트 실행
```bash
# UCRT64 터미널에서
cd ~/Desktop/Workspace/learning-code/docs/msys2-setup/scripts
./install_nodejs_npm.sh
```

---

## 트러블슈팅

### 문제 1: PATH에 npm이 없음
**증상:**
```bash
which npm
# 아무것도 출력되지 않음
```

**해결:**
```bash
# MSYS2 패키지 재설치
pacman -S --force mingw-w64-ucrt-x86_64-nodejs

# 터미널 재시작
exec zsh
```

### 문제 2: npm 권한 오류
**증상:**
```bash
npm install -g @openai/codex
# EACCES: permission denied
```

**해결:**
```bash
# 전역 패키지 디렉토리를 홈 디렉토리로 변경
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc
source ~/.zshrc

# 다시 설치
npm install -g @openai/codex
```

### 문제 3: 패키지 설치 후 명령어 못 찾음
**증상:**
```bash
npm install -g @openai/codex
# 설치 성공했으나
codex
# zsh: command not found: codex
```

**해결:**
```bash
# npm 전역 bin 경로 확인
npm config get prefix
# 출력: ~/.npm-global (또는 /usr/local)

# PATH 확인
echo $PATH | grep npm

# PATH에 없다면 추가
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc
source ~/.zshrc
```

### 문제 4: MSYS2와 Windows Node.js 충돌
**증상:**
```bash
which node
# /c/Program Files/nodejs/node (Windows 버전)
# MSYS2 버전을 사용하고 싶음
```

**해결 방법 1: MSYS2 Node.js를 우선 사용 (권장)**
```bash
# .zshrc에서 MSYS2 경로를 Windows 경로보다 앞에 배치
# ~/.zshrc 편집
export PATH="/ucrt64/bin:$PATH"  # MSYS2 우선

# 또는 더 명확하게
export PATH="/$MSYSTEM/bin:$PATH"

# 적용
source ~/.zshrc

# 확인
which node
# 출력: /ucrt64/bin/node (MSYS2 버전)
```

**해결 방법 2: Windows Node.js만 사용**
```bash
# MSYS2 Node.js 설치 건너뛰기
# Windows의 npm을 MSYS2에서 그대로 사용
# 이미 설치된 경우 충돌 없음

# 확인
which node
# 출력: /c/Program Files/nodejs/node (Windows 버전)
```

**해결 방법 3: 프로젝트별로 선택**
```bash
# Windows Node.js와 MSYS2 Node.js 병행 사용
# .zshrc에 함수 추가

# Windows Node.js 사용
use-windows-node() {
    export PATH="/c/Program Files/nodejs:$PATH"
}

# MSYS2 Node.js 사용
use-msys2-node() {
    export PATH="/ucrt64/bin:$PATH"
}

# 사용법
use-windows-node  # Windows 버전으로 전환
use-msys2-node    # MSYS2 버전으로 전환
```

**권장 사항:**
- **MSYS2 환경에서 개발**: MSYS2 Node.js 사용 (경로 충돌 없음)
- **Windows 환경에서 개발**: Windows Node.js 사용 (이미 설치된 경우)
- **혼합 사용**: 함수를 만들어 필요 시 전환

---

## 추천 설정

### package.json 스크립트 예시
MSYS2 환경에서 프로젝트를 관리할 경우:

```json
{
  "scripts": {
    "dev": "node server.js",
    "build": "npm run clean && npm run compile",
    "clean": "rm -rf dist",
    "test": "jest"
  }
}
```

### npm 캐시 경로 설정
```bash
# Windows 파일시스템과 충돌 방지
npm config set cache ~/.npm-cache
```

---

## 설치 확인 체크리스트

- [ ] Node.js 설치 확인: `node --version`
- [ ] npm 설치 확인: `npm --version`
- [ ] npm 전역 경로 설정: `npm config get prefix`
- [ ] PATH 설정 확인: `echo $PATH | grep npm`
- [ ] 테스트 패키지 설치: `npm install -g @openai/codex`
- [ ] 설치된 패키지 실행 확인: `codex --version`

---

## 참고 자료

- **MSYS2 공식 패키지 검색**: https://packages.msys2.org/package/mingw-w64-ucrt-x86_64-nodejs
- **Node.js 공식 사이트**: https://nodejs.org/
- **npm 공식 문서**: https://docs.npmjs.com/

---

## 관련 파일
- **자동 설치 스크립트**: `scripts/install_nodejs_npm.sh`
- **MSYS2 기본 설정**: `guides/msys2_setup_guide.md`
