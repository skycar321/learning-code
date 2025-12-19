# Claude Code & Gemini CLI MSYS2 수정 가이드

> 🔧 **MSYS2 환경에서 Claude Code와 Gemini CLI의 MODULE_NOT_FOUND 오류 해결**

최종 수정: 2025-12-19

---

## 📋 목차

- [문제 현상](#문제-현상)
- [근본 원인](#근본-원인)
- [해결 방법](#해결-방법)
- [검증](#검증)
- [기술 세부사항](#기술-세부사항)
- [참고사항](#참고사항)

---

## 🐛 문제 현상

MSYS2 UCRT64 환경(특히 zsh)에서 Claude Code나 Gemini CLI 실행 시 다음과 같은 오류 발생:

```bash
❯ claude --dangerously-skip-permissions
node:internal/modules/cjs/loader:1423
  throw err;
  ^

Error: Cannot find module 'C:\msys64\Users\Nam\AppData\Roaming\npm\node_modules\@anthropic-ai\claude-code\cli.js'
    at Module._resolveFilename (node:internal/modules/cjs/loader:1420:15)
    ...
  code: 'MODULE_NOT_FOUND',
  requireStack: []
}
```

```bash
❯ gemini --yolo -m=pro
Error: Cannot find module 'C:\msys64\Users\Nam\AppData\Roaming\npm\node_modules\@google\gemini-cli\dist\index.js'
    ...
  code: 'MODULE_NOT_FOUND',
  requireStack: []
}
```

### 주요 증상
- ❌ `claude` 또는 `gemini` 명령 실행 시 MODULE_NOT_FOUND 오류
- ❌ 경로가 `C:\msys64\Users\...`로 잘못 변환됨
- ❌ 실제 경로는 `C:\Users\...`인데 찾을 수 없음

---

## 🔍 근본 원인

### 1. npm wrapper 스크립트의 경로 변환 문제

npm이 자동 생성한 wrapper 스크립트(`/c/Users/Nam/AppData/Roaming/npm/claude`)는 `cygpath -w` 명령으로 경로를 Windows 스타일로 변환하려 시도합니다:

```bash
#!/bin/sh
basedir=$(dirname "$(echo "$0" | sed -e 's,\\,/,g')")

case `uname` in
    *CYGWIN*|*MINGW*|*MSYS*)
        if command -v cygpath > /dev/null 2>&1; then
            basedir=`cygpath -w "$basedir"`  # ← 문제 지점
        fi
    ;;
esac

exec node "$basedir/node_modules/@anthropic-ai/claude-code/cli.js" "$@"
```

### 2. 경로 변환의 오작동

MSYS2 환경에서 `cygpath -w`를 사용하면:
- 입력: `/c/Users/Nam/AppData/Roaming/npm`
- 출력: `C:\msys64\Users\Nam\AppData\Roaming\npm` ❌ (잘못된 경로)
- 기대값: `C:\Users\Nam\AppData\Roaming\npm` ✅

결과적으로 Node.js가 존재하지 않는 경로에서 모듈을 찾으려 시도하여 오류 발생.

### 3. 왜 codex는 작동했나?

이미 `codex` 명령어는 같은 문제를 겪어서 wrapper 스크립트가 수정되어 있었습니다:

```bash
❯ cat /c/Users/Nam/AppData/Roaming/npm/codex
#!/bin/sh
# Fixed wrapper for @openai/codex in MSYS2
# Directly use Windows paths to avoid cygpath issues

CODEX_JS="/c/Users/Nam/AppData/Roaming/npm/node_modules/@openai/codex/bin/codex.js"

if [ -f "$CODEX_JS" ]; then
    exec node "$CODEX_JS" "$@"
else
    echo "Error: codex.js not found at $CODEX_JS" >&2
    exit 1
fi
```

→ **codex와 동일한 방식으로 claude와 gemini도 수정하면 해결!**

---

## ✅ 해결 방법

### 방법 1: 자동 수정 스크립트 (권장) 🚀

```bash
# scripts/fix_claude_gemini_wrappers.sh 실행 (아래 스크립트 참조)
bash scripts/fix_claude_gemini_wrappers.sh
```

### 방법 2: 수동 수정

#### Step 1: 백업 생성

```bash
cp /c/Users/Nam/AppData/Roaming/npm/claude /c/Users/Nam/AppData/Roaming/npm/claude.backup
cp /c/Users/Nam/AppData/Roaming/npm/gemini /c/Users/Nam/AppData/Roaming/npm/gemini.backup
```

#### Step 2: claude wrapper 수정

```bash
cat > /c/Users/Nam/AppData/Roaming/npm/claude << 'EOF'
#!/bin/sh
# Fixed wrapper for @anthropic-ai/claude-code in MSYS2
# Directly use Windows paths to avoid cygpath issues

CLAUDE_JS="/c/Users/Nam/AppData/Roaming/npm/node_modules/@anthropic-ai/claude-code/cli.js"

if [ -f "$CLAUDE_JS" ]; then
    exec node "$CLAUDE_JS" "$@"
else
    echo "Error: cli.js not found at $CLAUDE_JS" >&2
    exit 1
fi
EOF
```

#### Step 3: gemini wrapper 수정

```bash
cat > /c/Users/Nam/AppData/Roaming/npm/gemini << 'EOF'
#!/bin/sh
# Fixed wrapper for @google/gemini-cli in MSYS2
# Directly use Windows paths to avoid cygpath issues

GEMINI_JS="/c/Users/Nam/AppData/Roaming/npm/node_modules/@google/gemini-cli/dist/index.js"

if [ -f "$GEMINI_JS" ]; then
    exec node "$GEMINI_JS" "$@"
else
    echo "Error: index.js not found at $GEMINI_JS" >&2
    exit 1
fi
EOF
```

#### Step 4: 실행 권한 부여

```bash
chmod +x /c/Users/Nam/AppData/Roaming/npm/claude
chmod +x /c/Users/Nam/AppData/Roaming/npm/gemini
```

---

## ✅ 검증

### 1. 버전 확인

```bash
claude --version
# 출력: 2.0.73 (Claude Code)

gemini --version
# 출력: 0.21.2
```

### 2. 도움말 확인

```bash
claude --help
# Usage: claude [options] [command] [prompt] ...

gemini --help
# Usage: gemini [options] [command] ...
```

### 3. 실제 사용

```bash
# Claude Code 실행
claude --dangerously-skip-permissions

# Gemini CLI 실행
gemini --yolo -m=pro
```

### 4. wrapper 스크립트 확인

```bash
cat /c/Users/Nam/AppData/Roaming/npm/claude
# "Fixed wrapper for @anthropic-ai/claude-code in MSYS2" 주석이 보여야 함

cat /c/Users/Nam/AppData/Roaming/npm/gemini
# "Fixed wrapper for @google/gemini-cli in MSYS2" 주석이 보여야 함
```

---

## 🔧 기술 세부사항

### 쉘 경로 우선순위

MSYS2 환경에서 명령어 실행 우선순위:
1. **함수 (function)** ← 가장 높음
2. 내장 명령어 (builtin)
3. 별칭 (alias)
4. **PATH의 실행 파일** ← npm wrapper는 여기

### Unix vs Windows 경로

| 형식 | 예시 | Node.js 해석 |
|------|------|--------------|
| Unix 스타일 | `/c/Users/Nam/...` | ✅ 정상 작동 |
| Windows 스타일 (올바름) | `C:\Users\Nam\...` | ✅ 정상 작동 |
| Windows 스타일 (오류) | `C:\msys64\Users\Nam\...` | ❌ 경로 없음 |

### cygpath 동작 방식

```bash
# MSYS2에서 cygpath -w의 문제
❯ cygpath -w "/c/Users/Nam/AppData/Roaming"
C:\msys64\Users\Nam\AppData\Roaming  # ❌ 잘못된 변환

# Node.js는 Unix 스타일 경로를 직접 이해 가능
❯ node "/c/Users/Nam/AppData/Roaming/npm/node_modules/@anthropic-ai/claude-code/cli.js" --version
2.0.73 (Claude Code)  # ✅ 정상 작동
```

### 해결 전략

**변환하지 말고 직접 사용**
- `cygpath -w`를 사용하지 않음
- Unix 스타일 경로(`/c/Users/...`)를 그대로 Node.js에 전달
- Node.js가 알아서 올바르게 해석

---

## 📚 참고사항

### npm 재설치 시 주의사항

npm 패키지를 재설치하면 wrapper 스크립트가 원래대로 돌아갑니다:

```bash
# Claude Code 재설치
npm install -g @anthropic-ai/claude-code

# Gemini CLI 재설치
npm install -g @google/gemini-cli
```

→ **재설치 후 다시 wrapper 수정 필요**

#### 빠른 복구 방법

```bash
# 백업에서 복원
cp /c/Users/Nam/AppData/Roaming/npm/claude.backup /c/Users/Nam/AppData/Roaming/npm/claude
cp /c/Users/Nam/AppData/Roaming/npm/gemini.backup /c/Users/Nam/AppData/Roaming/npm/gemini
```

또는 자동 수정 스크립트 재실행:
```bash
bash scripts/fix_claude_gemini_wrappers.sh
```

### 다른 npm 글로벌 패키지

같은 방법으로 다른 npm 글로벌 CLI 도구도 수정 가능:

```bash
# 예: TypeScript 컴파일러
cat > /c/Users/Nam/AppData/Roaming/npm/tsc << 'EOF'
#!/bin/sh
TSC_JS="/c/Users/Nam/AppData/Roaming/npm/node_modules/typescript/bin/tsc"
exec node "$TSC_JS" "$@"
EOF

chmod +x /c/Users/Nam/AppData/Roaming/npm/tsc
```

### 실패한 시도들 (참고용)

다음 방법들은 시도했지만 실패했습니다:

#### ❌ 시도 1: ~/.local/bin/ wrapper 생성
- 문제: PATH 우선순위 문제로 npm wrapper가 먼저 실행됨

#### ❌ 시도 2: ~/.zshrc에 alias 추가
- 문제: PATH의 실행 파일이 우선 실행됨

#### ❌ 시도 3: ~/.zshrc에 function 추가
- 문제: zsh가 함수를 제대로 로드하지 않음 (원인 불명)

#### ✅ 최종 해결: npm wrapper 직접 수정
- **근본 원인 해결**: wrapper 자체가 문제였으므로 wrapper를 수정

---

## 🚀 자동 수정 스크립트

`scripts/fix_claude_gemini_wrappers.sh`:

```bash
#!/bin/bash
# Fix Claude Code and Gemini CLI wrapper scripts for MSYS2

set -e

NPM_DIR="/c/Users/Nam/AppData/Roaming/npm"
CLAUDE_WRAPPER="$NPM_DIR/claude"
GEMINI_WRAPPER="$NPM_DIR/gemini"

echo "🔧 Fixing Claude Code and Gemini CLI wrappers for MSYS2..."

# Backup
if [ -f "$CLAUDE_WRAPPER" ]; then
    cp "$CLAUDE_WRAPPER" "$CLAUDE_WRAPPER.backup"
    echo "✓ Backed up claude wrapper"
fi

if [ -f "$GEMINI_WRAPPER" ]; then
    cp "$GEMINI_WRAPPER" "$GEMINI_WRAPPER.backup"
    echo "✓ Backed up gemini wrapper"
fi

# Fix claude
cat > "$CLAUDE_WRAPPER" << 'EOF'
#!/bin/sh
# Fixed wrapper for @anthropic-ai/claude-code in MSYS2
# Directly use Windows paths to avoid cygpath issues

CLAUDE_JS="/c/Users/Nam/AppData/Roaming/npm/node_modules/@anthropic-ai/claude-code/cli.js"

if [ -f "$CLAUDE_JS" ]; then
    exec node "$CLAUDE_JS" "$@"
else
    echo "Error: cli.js not found at $CLAUDE_JS" >&2
    exit 1
fi
EOF

chmod +x "$CLAUDE_WRAPPER"
echo "✓ Fixed claude wrapper"

# Fix gemini
cat > "$GEMINI_WRAPPER" << 'EOF'
#!/bin/sh
# Fixed wrapper for @google/gemini-cli in MSYS2
# Directly use Windows paths to avoid cygpath issues

GEMINI_JS="/c/Users/Nam/AppData/Roaming/npm/node_modules/@google/gemini-cli/dist/index.js"

if [ -f "$GEMINI_JS" ]; then
    exec node "$GEMINI_JS" "$@"
else
    echo "Error: index.js not found at $GEMINI_JS" >&2
    exit 1
fi
EOF

chmod +x "$GEMINI_WRAPPER"
echo "✓ Fixed gemini wrapper"

# Verify
echo ""
echo "✅ Verification:"
if claude --version > /dev/null 2>&1; then
    echo "✓ claude: $(claude --version)"
else
    echo "✗ claude: Failed"
fi

if gemini --version > /dev/null 2>&1; then
    echo "✓ gemini: $(gemini --version)"
else
    echo "✗ gemini: Failed"
fi

echo ""
echo "🎉 Done! You can now use 'claude' and 'gemini' commands."
```

---

## 📝 요약

| 항목 | 내용 |
|------|------|
| **문제** | MSYS2에서 claude/gemini 실행 시 MODULE_NOT_FOUND 오류 |
| **원인** | npm wrapper의 `cygpath -w` 경로 변환 오작동 |
| **해결** | wrapper를 codex 방식으로 수정 (Unix 경로 직접 사용) |
| **파일** | `/c/Users/Nam/AppData/Roaming/npm/claude`, `gemini` |
| **백업** | `.backup` 확장자로 자동 백업됨 |
| **재설치** | npm 재설치 시 다시 수정 필요 |

---

**Happy Coding! 🚀**
