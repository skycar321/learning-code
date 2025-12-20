# Step1: Git 기본 개념 및 설치

## 목표
- Git이 무엇이며 왜 필요한지 이해하고, 로컬에서 바로 실행할 수 있는 최소 워크플로우를 익힙니다.
- Git이 설치되어 있는지 확인하고 전역 사용자 정보를 설정합니다.

## 1. 준비 및 설치 확인
```bash
git --version               # 설치 여부 확인
git config --global user.name  "Your Name"
git config --global user.email "your.email@example.com"
git config --global user.name   # 설정 확인
git config --global user.email
```

## 2. 로컬 저장소 생성과 첫 커밋
```bash
mkdir my_git_project && cd my_git_project
git init

echo "Hello Git!" > hello.txt
echo "This is my first Git repository." > readme.md
git status                         # Untracked 두 개 확인

git add hello.txt readme.md        # 스테이징
git commit -m "feat: Initial commit with hello.txt and readme.md"
git status                         # 깨끗한 상태
git log --oneline --graph --all    # 히스토리 확인
```

## 3. 변경 → 스테이징 → 커밋 반복
```bash
echo "Add a new line." >> hello.txt
git status
git add hello.txt
git commit -m "docs: Add new line to hello.txt"
git log --oneline --graph --all
```

## 4. 변경 되돌리기 (Git 2.23+)
- 특정 파일 스테이징 해제: `git restore --staged <file>`
- 워킹트리 변경 취소(커밋 전): `git restore <file>`
```bash
echo "Temporary content" > temp.txt
git add temp.txt
git restore --staged temp.txt      # 스테이징 취소

echo "Discard this change" >> hello.txt
git restore hello.txt              # 워킹트리 변경 취소
```

## 5. 정리
```bash
cd ..
rm -rf my_git_project
```

## 핵심 명령어 메모
- 상태: `git status`
- 스테이징/언스테이징: `git add <file>`, `git restore --staged <file>`
- 커밋: `git commit -m "<msg>"`
- 로그: `git log --oneline --graph --all`
- 워킹트리 되돌리기: `git restore <file>`
