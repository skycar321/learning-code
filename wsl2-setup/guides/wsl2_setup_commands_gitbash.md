# Git Bash 설정 가이드 (Windows Terminal)

## 문제 1: 한글 파일명 깨짐 현상

### 증상
```bash
$ ls -lrt
'□'$'\231\224''면 캡□□'$'\230'' 2025-12-17 153638.png'
```

한글 파일명이 `□□□`이나 이스케이프 문자로 표시됨

### 원인
- Git의 `core.quotepath` 설정이 true (기본값)
- Bash의 locale이 UTF-8로 설정되지 않음

### 해결 방법

#### Step 1: Git 설정 변경
```bash
# 비ASCII 문자를 이스케이프하지 않고 원본 그대로 표시
git config --global core.quotepath false
```

#### Step 2: Bash UTF-8 Locale 설정
```bash
# .bashrc에 UTF-8 locale 추가
cat >> ~/.bashrc << 'EOF'

# UTF-8 설정 (한글 지원)
export LANG=ko_KR.UTF-8
export LC_ALL=ko_KR.UTF-8
EOF

# 설정 적용
source ~/.bashrc
```

#### Step 3: 결과 확인
```bash
$ ls -lrt
화면 캡처 2025-12-17 153638.png  # 한글 정상 표시 ✓
```

---

## 문제 2: 백스페이스 키 누를 때 화면 깜박임

### 증상
- Git Bash에서 백스페이스 키를 누르면 화면이 깜박임
- 시스템 벨(Bell) 사운드의 시각적 피드백

### 원인
- Readline의 기본 bell-style 설정이 `visible` 또는 `audible`로 되어 있음
- Windows Terminal에서 벨 알림을 화면 깜박임으로 표시

### 해결 방법

#### Step 1: .inputrc 파일 생성/수정
```bash
# 시스템 벨 비활성화
cat >> ~/.inputrc << 'EOF'
# 시스템 벨 비활성화 (백스페이스 깜박임 방지)
set bell-style none
EOF
```

#### Step 2: 설정 즉시 적용
```bash
# 현재 세션에 바로 적용 (터미널 재시작 불필요)
bind -f ~/.inputrc
```

#### Step 3: Windows Terminal 설정 (선택사항)

Windows Terminal 프로필에서도 벨 알림 비활성화:

1. `Ctrl + ,` (설정 열기)
2. Git Bash 프로필 선택
3. **고급** 탭 클릭
4. **벨 알림 스타일**: `없음` 선택
5. **저장**

---

## 전체 설정 일괄 실행

두 가지 문제를 한 번에 해결:

```bash
# 1. Git 한글 설정
git config --global core.quotepath false

# 2. Bash UTF-8 locale 설정
cat >> ~/.bashrc << 'EOF'

# UTF-8 설정 (한글 지원)
export LANG=ko_KR.UTF-8
export LC_ALL=ko_KR.UTF-8
EOF

# 3. 백스페이스 깜박임 방지
cat >> ~/.inputrc << 'EOF'
# 시스템 벨 비활성화 (백스페이스 깜박임 방지)
set bell-style none
EOF

# 4. 설정 적용
source ~/.bashrc
bind -f ~/.inputrc

# 5. 확인
echo "✅ Git Bash 설정 완료!"
echo "한글 파일명 테스트:"
ls -lrt | head -5
```

---

## 추가 팁

### MesloLGS NF 폰트 적용 (PowerLevel10k 아이콘 표시)

Git Bash에서도 아이콘이 보이도록 Nerd Font 설정:

1. **MesloLGS NF 폰트 설치** (WSL 가이드 참조)
2. Windows Terminal 설정 → Git Bash 프로필
3. **모양** → **글꼴**: `MesloLGS NF` 선택
4. **크기**: 11 또는 12
5. **저장**

### Git Bash 프롬프트 커스터마이징

`~/.bashrc`에 추가:

```bash
# Git 브랜치 표시
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# 프롬프트 설정
export PS1="\[\033[32m\]\u@\h\[\033[00m\]:\[\033[34m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\]\$ "
```

적용:
```bash
source ~/.bashrc
```

---

## 문제 해결

### 설정이 적용되지 않을 때

```bash
# .bashrc 확인
cat ~/.bashrc | tail -10

# .inputrc 확인
cat ~/.inputrc

# Git config 확인
git config --global core.quotepath

# 터미널 재시작
exit
# Git Bash 다시 열기
```

### Windows Terminal에서 Git Bash 탭이 없을 때

**프로필 수동 추가:**

1. `Ctrl + Shift + ,` (JSON 설정 열기)
2. `profiles.list` 배열에 추가:

```json
{
    "commandline": "C:\\Program Files\\Git\\bin\\bash.exe",
    "guid": "{00000000-0000-0000-0000-000000012345}",
    "hidden": false,
    "name": "Git Bash",
    "icon": "C:\\Program Files\\Git\\mingw64\\share\\git\\git-for-windows.ico",
    "startingDirectory": "%USERPROFILE%",
    "colorScheme": "One Half Dark",
    "font": {
        "face": "MesloLGS NF",
        "size": 11
    }
}
```

---

**작성:** 2025-12-17 19:03 KST
**대상:** Windows Terminal + Git Bash 사용자
**관련 파일:** `~/.bashrc`, `~/.inputrc`, Git global config
