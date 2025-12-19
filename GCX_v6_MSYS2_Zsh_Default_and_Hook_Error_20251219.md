# MSYS2 UCRT64 Zsh 기본 설정 및 Hook 오류 분석 (요약)

Date: 2025-12-19
Project: C:\Users\Nam\Documents\Cursor\Workspace\origin\learning-code

---

## 1) 결론 요약
- **MSYS2 UCRT64 zsh를 기본으로 설정하는 것만으로는 Hook 오류가 100% 해결된다고 보장할 수 없습니다.**
- 오류의 직접 원인은 `settings.json`의 Hook 명령에서 `$CLAUDE_PROJECT_DIR`가 **Windows에서 Bash 스타일로 확장되지 않아** 문자열 그대로 경로에 포함되는 문제입니다.
- 따라서 **근본 해결은 Hook command를 Windows 호환 방식으로 변경**하는 것입니다.

---

## 2) 문제 발생 오류
```
UserPromptSubmit operation blocked by hook:
  [python "$CLAUDE_PROJECT_DIR"/.claude/hooks/user_prompt.py]: python: can't open file 
  'C:\Users\Nam\Documents\Cursor\Workspace\origin\learning-code\$CLAUDE_PROJECT_DIR\.claude\hooks\user_prompt.py': [Errno 2] No such file or directory
```

### 원인
- `$CLAUDE_PROJECT_DIR`는 Bash 변수 표기인데, Windows에서 그대로 문자열로 전달되어 경로가 잘못됨.

---

## 3) 권장 해결책 (Hook command 교체)

### A) cmd 스타일
```
"command": "python \"%CLAUDE_PROJECT_DIR%/.claude/hooks/user_prompt.py\""
```

### B) PowerShell 스타일
```
"command": "python \"$env:CLAUDE_PROJECT_DIR\\.claude\\hooks\\user_prompt.py\""
```

### C) Shell-agnostic (가장 안전)
```
"command": "python -c \"import os,runpy,pathlib; root=os.environ.get('CLAUDE_PROJECT_DIR') or os.getcwd(); runpy.run_path(pathlib.Path(root)/'.claude'/'hooks'/'user_prompt.py')\""
```

### D) 작업 디렉터리가 항상 프로젝트 루트일 때
```
"command": "python .claude/hooks/user_prompt.py"
```

---

## 4) MSYS2 UCRT64 Zsh 기본 설정 스크립트

### 생성된 파일
- `scripts/set-msys2-zsh-default.ps1`
- `scripts/revert-msys2-zsh-default.ps1`

### 설정 스크립트 동작
- User 환경변수 설정: `SHELL`, `MSYSTEM=UCRT64`, `CHERE_INVOKING=1`
- User PATH에 `C:\msys64\usr\bin`, `C:\msys64\ucrt64\bin` 추가
- `.claude/settings.json`의 zsh 경로를 Windows 경로로 변경
- 백업 저장: `.gcx/state/msys2_shell_backup.json`

### 원복 스크립트 동작
- `.gcx/state/msys2_shell_backup.json`에 저장된 환경변수/설정 복원
- `.claude/settings.json` 백업 복원

### 실행 방법
```
# 적용
.\scripts\set-msys2-zsh-default.ps1

# 원복
.\scripts\revert-msys2-zsh-default.ps1
```

---

## 5) 추가 참고
- zsh 기본화는 **Hook 오류의 직접 원인을 제거하지 않음**
- 확실한 해결을 위해서는 **Hook command 수정이 우선**

End of document.
