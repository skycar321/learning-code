# zsh 단축키 및 사용법 완벽 가이드

> MSYS2 + zsh + oh-my-zsh 환경에서 생산성을 높이는 단축키 모음

## 📋 목차

1. [zsh-autosuggestions 사용법](#zsh-autosuggestions-사용법)
2. [명령어 히스토리 탐색](#명령어-히스토리-탐색)
3. [편집 단축키](#편집-단축키)
4. [디렉토리 이동](#디렉토리-이동)
5. [Git Aliases](#git-aliases)
6. [유용한 플러그인 기능](#유용한-플러그인-기능)

---

## 🎯 zsh-autosuggestions 사용법

### 기본 개념

**흐릿하게 보이는 명령어**는 과거에 실행했던 명령어를 자동으로 제안하는 기능입니다.

```bash
$ git st█                          # 여기서 타이핑 중...
$ git status --short               # 흐릿하게 제안됨 (회색 텍스트)
```

### 자동완성 단축키

| 키 | 기능 | 설명 |
|---|------|------|
| `→` | **전체 수락** | 제안된 명령어 전체를 한번에 수락 |
| `End` | **전체 수락** | 제안된 명령어 전체를 한번에 수락 |
| `Ctrl + →` | **부분 수락** | 한 단어씩만 수락 (띄어쓰기 기준) |
| `Esc` 또는 타이핑 계속 | **제안 거부** | 제안 무시하고 새로운 명령어 입력 |

### 실전 예시

```bash
# 예시 1: 긴 명령어 재사용
$ npm install --save-dev typescript ts-node @types/node█
→ (오른쪽 화살표) → 전체 명령어 수락!

# 예시 2: 한 단어씩 수락
$ git commit -m "feat: add login feature"█
# 'git'만 필요하면 Ctrl+→
$ git█                             # 여기서 멈춤
# 'commit'도 필요하면 Ctrl+→ 한번 더
$ git commit█                      # 여기서 멈춤
```

### 설정 커스터마이징

```bash
# ~/.zshrc에 추가 가능한 설정

# 제안 색상 변경 (기본: 회색)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# 제안 전략 변경 (기본: history)
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# 버퍼 최대 길이 설정
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
```

---

## 📜 명령어 히스토리 탐색

### 기본 히스토리 탐색

| 키 | 기능 |
|---|------|
| `↑` | 이전 명령어 |
| `↓` | 다음 명령어 |
| `Ctrl + R` | **히스토리 검색** (가장 유용!) |
| `Ctrl + S` | 앞으로 검색 |
| `history` | 전체 히스토리 출력 |
| `!!` | 직전 명령어 실행 |
| `!$` | 직전 명령어의 마지막 인자 |

### 히스토리 검색 (Ctrl+R) 사용법

```bash
# Ctrl+R 누르면 검색 모드 진입
(reverse-i-search)`git': git push origin main

# 계속 타이핑하면 필터링됨
(reverse-i-search)`git com': git commit -m "feat: add feature"

# Enter: 실행
# Esc: 취소
# Ctrl+R 반복: 이전 매치로 이동
```

### 히스토리 재사용 트릭

```bash
# 직전 명령어 재실행
$ !!

# 직전 명령어의 마지막 인자 재사용
$ mkdir /path/to/long/directory
$ cd !$                            # cd /path/to/long/directory

# 직전 명령어의 첫 인자 재사용
$ echo hello world
$ echo !^                          # echo hello

# N번째 이전 명령어 실행
$ !-2                              # 2번째 이전 명령어 실행

# 특정 명령어로 시작하는 최근 명령어
$ !git                             # git으로 시작하는 최근 명령어
```

---

## ✏️ 편집 단축키

### 커서 이동

| 키 | 기능 |
|---|------|
| `Ctrl + A` | **줄 맨 앞으로** |
| `Ctrl + E` | **줄 맨 뒤로** |
| `Ctrl + ←` | 이전 단어로 |
| `Ctrl + →` | 다음 단어로 |
| `Alt + B` | 이전 단어로 (백워드) |
| `Alt + F` | 다음 단어로 (포워드) |

### 삭제 및 편집

| 키 | 기능 |
|---|------|
| `Ctrl + U` | **커서부터 줄 맨 앞까지 삭제** |
| `Ctrl + K` | **커서부터 줄 맨 뒤까지 삭제** |
| `Ctrl + W` | 이전 단어 삭제 |
| `Alt + D` | 다음 단어 삭제 |
| `Ctrl + Y` | 마지막 삭제 내용 붙여넣기 |
| `Ctrl + L` | 화면 클리어 (clear 명령어와 동일) |

### 실전 팁

```bash
# 긴 명령어 수정 시 유용
$ sudo apt install package-name --some-very-long-option█
# 처음부터 다시 입력하고 싶다면
Ctrl + U → 전체 삭제!

# 명령어 중간 수정
$ git commit -m "typo message"█
Ctrl + ← Ctrl + ← Ctrl + W  # "message" 삭제
# 결과: git commit -m "typo█
```

---

## 📂 디렉토리 이동

### zsh 내장 기능

| 명령어 | 기능 |
|--------|------|
| `cd -` | **이전 디렉토리로 돌아가기** (매우 유용!) |
| `cd` 또는 `cd ~` | 홈 디렉토리로 |
| `..` | 상위 디렉토리 (alias 설정 시) |
| `...` | 상위의 상위 디렉토리 |
| `....` | 상위의 상위의 상위 디렉토리 |

### 디렉토리 스택 사용

```bash
# 디렉토리 푸시
$ pushd /some/path                 # 현재 디렉토리를 스택에 저장하고 이동

# 디렉토리 팝
$ popd                             # 스택에서 꺼내서 해당 디렉토리로 이동

# 스택 목록 보기
$ dirs -v
0  /current/path
1  /previous/path
2  /another/path

# 스택의 N번째로 이동
$ cd ~2                            # 스택의 2번째 디렉토리로
```

### 자주 쓰는 Aliases (자동 설치 포함)

```bash
# ~/.zshrc에 이미 포함됨
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias home='cd ~'
alias downloads='cd ~/Downloads'
alias desktop='cd ~/Desktop'
alias proj='cd ~/projects'          # 프로젝트 디렉토리 (수정 가능)
```

---

## 🐙 Git Aliases

### oh-my-zsh git 플러그인 기본 제공

| Alias | 실제 명령어 | 설명 |
|-------|-------------|------|
| `gs` | `git status` | 상태 확인 |
| `ga` | `git add` | 파일 추가 |
| `gaa` | `git add --all` | 모든 파일 추가 |
| `gc` | `git commit -m` | 커밋 |
| `gc!` | `git commit --amend` | 커밋 수정 |
| `gp` | `git push` | 푸시 |
| `gpl` | `git pull` | 풀 |
| `gl` | `git log --oneline --graph` | 로그 (그래프) |
| `gd` | `git diff` | 변경 사항 확인 |
| `gco` | `git checkout` | 브랜치 변경 |
| `gcb` | `git checkout -b` | 새 브랜치 생성 후 변경 |
| `gb` | `git branch` | 브랜치 목록 |
| `gba` | `git branch -a` | 모든 브랜치 (원격 포함) |
| `gbd` | `git branch -d` | 브랜치 삭제 |
| `gm` | `git merge` | 병합 |
| `grb` | `git rebase` | 리베이스 |
| `gst` | `git stash` | 임시 저장 |
| `gstp` | `git stash pop` | 임시 저장 복원 |

### 전체 목록 확인

```bash
# git 플러그인의 모든 alias 확인
alias | grep git

# 또는 oh-my-zsh 공식 문서
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git
```

---

## 🎨 유용한 플러그인 기능

### 1. zsh-syntax-highlighting

타이핑하는 순간 **실시간으로 문법 검사**:

```bash
# 초록색: 올바른 명령어
$ git status                       # 초록색

# 빨간색: 잘못된 명령어
$ giit status                      # 빨간색 (오타)

# 파란색: 파일/디렉토리 존재
$ cat existing-file.txt            # 파란색

# 회색: 파일/디렉토리 없음
$ cat nonexistent.txt              # 회색 또는 빨간색
```

### 2. colored-man-pages

`man` 페이지를 컬러로 표시:

```bash
$ man git                          # 컬러풀한 매뉴얼 페이지!
```

### 3. command-not-found

명령어가 없을 때 **설치 방법 제안**:

```bash
$ htop
zsh: command not found: htop

# 플러그인이 제안:
The command 'htop' could not be found.
Install it with: pacman -S htop
```

### 4. Tab 자동완성 (기본 zsh 기능)

```bash
# 파일명 자동완성
$ cat README.md          # TAB → cat README.md

# 명령어 옵션 자동완성
$ git co                 # TAB → 'commit', 'checkout' 등 제안

# 경로 자동완성
$ cd /c/Users/           # TAB → 사용자 목록 표시
```

---

## 🔥 고급 기능

### 1. 글로벌 Aliases

```bash
# ~/.zshrc에 추가
alias -g G='| grep'
alias -g L='| less'
alias -g H='| head'
alias -g T='| tail'
alias -g N='> /dev/null 2>&1'

# 사용 예시
$ ps aux G node                    # ps aux | grep node
$ cat long-file.txt L              # cat long-file.txt | less
$ npm install N                    # npm install > /dev/null 2>&1
```

### 2. Suffix Aliases

```bash
# 파일 확장자별로 자동 실행 프로그램 지정
alias -s md=vim
alias -s txt=cat
alias -s json=jq

# 사용 예시
$ README.md                        # vim README.md 실행
$ data.json                        # jq data.json 실행
```

### 3. 함수 정의

```bash
# ~/.zshrc에 추가

# 디렉토리 생성 후 바로 이동
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# 파일 내용 검색
findtext() {
  grep -rnw . -e "$1"
}

# 프로세스 검색 및 종료
pskill() {
  ps aux | grep "$1" | awk '{print $2}' | xargs kill -9
}

# JSON 포맷팅
jsonformat() {
  if [ -n "$1" ]; then
    jq . "$1"
  else
    jq .
  fi
}
```

---

## 🎓 학습 팁

### 단축키 연습

1. **Ctrl+R** - 히스토리 검색 (가장 중요!)
2. **Ctrl+A / Ctrl+E** - 줄 맨 앞/뒤로 이동
3. **Ctrl+U / Ctrl+K** - 줄 삭제
4. **→ (오른쪽 화살표)** - autosuggestion 수락
5. **cd -** - 이전 디렉토리로 돌아가기

### 설정 파일 위치

```bash
# zsh 설정 파일
~/.zshrc

# oh-my-zsh 설정
~/.oh-my-zsh/

# Powerlevel10k 설정
~/.p10k.zsh
```

### 설정 다시 로드

```bash
# .zshrc 수정 후 바로 적용
$ source ~/.zshrc

# 또는
$ exec zsh                         # zsh 재시작
```

---

## 📚 참고 자료

- [zsh-autosuggestions GitHub](https://github.com/zsh-users/zsh-autosuggestions)
- [oh-my-zsh Git Plugin](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git)
- [zsh 공식 문서](https://zsh.sourceforge.io/Doc/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)

---

**작성일**: 2025-12-18
**작성자**: Nam
**버전**: 1.0

---

**Happy Coding! 🚀**
