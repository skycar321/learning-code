#!/bin/bash

# Git CLI 학습 계획 - 1단계: Git 기본 개념 및 설치
# 이 스크립트는 Git CLI의 기본 개념 및 설치, 그리고 초기 설정을 학습하기 위한
# 개념적인 명령어들을 포함하고 있습니다.
# 실제 Git 저장소를 생성하고 조작하며 Git의 기본 워크플로우를 이해하는 것을 목표로 합니다.

echo "--- 1단계: Git 기본 개념 및 설치 ---"

# -----------------------------------------------------------------------------
# 1. Git이란 무엇인가? (What is Git?) - 버전 관리의 중요성
# -----------------------------------------------------------------------------
echo "Git은 분산 버전 관리 시스템(DVCS)입니다."
echo "코드 변경 이력을 추적하고, 여러 개발자가 협업하며, 이전 버전으로 되돌리거나"
echo "다양한 버전(브랜치)을 관리하는 데 사용됩니다."
echo "나쁜 예시: 파일을 수정할 때마다 'mycode_v1.py', 'mycode_v2_final.py', 'mycode_v2_final_final.py' 처럼 저장하는 것."
echo "좋은 예시: Git을 사용하여 변경 이력을 명확하게 기록하고 관리하는 것."
echo ""

# -----------------------------------------------------------------------------
# 2. Git 설치 및 초기 설정 (Installation & Initial Setup)
# -----------------------------------------------------------------------------
echo "2.1. Git 설치 확인"
if command -v git &> /dev/null
then
    echo "Git이 이미 설치되어 있습니다: $(git --version)"
else
    echo "Git이 설치되어 있지 않습니다. 공식 웹사이트 또는 패키지 관리자를 통해 설치하세요."
    echo "예시: sudo apt-get install git (Ubuntu), brew install git (macOS)"
    exit 1 # Git이 없으면 나머지 스크립트 실행 불가
fi
echo ""

echo "2.2. Git 전역 사용자 정보 설정 (git config)"
# 모든 리포지토리에 적용되는 사용자 이름과 이메일 주소를 설정합니다.
# 커밋 시 이 정보가 기록됩니다.
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
echo "Git 사용자 이름과 이메일이 설정되었습니다."
echo "현재 설정 확인:"
git config --global user.name
git config --global user.email
echo ""

# -----------------------------------------------------------------------------
# 3. 기본 워크플로우 (Basic Workflow)
# -----------------------------------------------------------------------------

# 3.1. `git init`: 새 Git 리포지토리 초기화
# 현재 디렉토리를 Git 리포지토리로 만듭니다. `.git` 숨김 디렉토리가 생성됩니다.
echo "3.1. 새 Git 리포지토리 초기화"
mkdir my_git_project
cd my_git_project
git init
echo "'my_git_project' 디렉토리에 새 Git 리포지토리가 초기화되었습니다."
echo ""

# 3.2. `git status`: 작업 상태 확인
# 현재 작업 디렉토리, 스테이징 영역, 마지막 커밋 간의 차이를 보여줍니다.
echo "3.2. 현재 Git 상태 확인"
git status
echo ""

# 3.3. 파일 생성 및 `git add` (스테이징 영역 추가)
# Git은 파일을 Untracked (추적 안 함), Unmodified (수정 안 함), Modified (수정함), Staged (스테이징됨) 상태로 관리합니다.
echo "3.3. 새 파일 생성 및 스테이징"
echo "Hello Git!" > hello.txt
echo "This is my first Git repository." > readme.md
git status
echo "두 개의 Untracked 파일이 생성되었습니다."
echo ""

# `git add` 명령은 파일을 스테이징 영역에 추가합니다.
# 스테이징 영역은 다음 커밋에 포함될 변경 사항들을 모아두는 곳입니다.
git add hello.txt
git status
echo "'hello.txt' 파일이 스테이징되었습니다. 'readme.md'는 여전히 Untracked."
echo ""

git add readme.md
git status
echo "모든 변경 사항이 스테이징되었습니다."
echo ""

# 3.4. `git commit`: 변경 사항 기록
# 스테이징 영역에 있는 변경 사항들을 로컬 리포지토리에 영구적으로 기록합니다.
# `-m` 옵션으로 커밋 메시지를 직접 작성할 수 있습니다. (좋은 커밋 메시지는 중요!)
echo "3.4. 변경 사항 커밋"
git commit -m "feat: Initial commit with hello.txt and readme.md"
echo "첫 번째 커밋이 생성되었습니다."
git status
echo "작업 트리가 깨끗합니다."
echo ""

# 3.5. `git log`: 커밋 기록 확인
# 지금까지의 커밋 이력을 보여줍니다.
echo "3.5. 커밋 기록 확인"
git log --oneline --graph --all # 간결하고 시각적인 로그
echo ""

# 3.6. 파일 수정 및 `git add`, `git commit` 반복
echo "3.6. 파일 수정 및 두 번째 커밋"
echo "Add a new line." >> hello.txt
git status
echo "'hello.txt' 파일이 Modified 상태입니다."
echo ""

git add hello.txt
git status
echo "'hello.txt' 파일이 스테이징되었습니다."
echo ""

git commit -m "docs: Add new line to hello.txt"
echo "두 번째 커밋이 생성되었습니다."
echo ""
git log --oneline --graph --all
echo ""

# 3.7. `git restore` (Git 2.23+): 파일 변경 사항 되돌리기 (Unstaging/Discarding changes)
echo "3.7. 파일 변경 사항 되돌리기 (Unstaging 및 Discarding)"
echo "Temporary content" > temp.txt
git add temp.txt
git status
echo "'temp.txt'가 스테이징되었습니다."

# 스테이징된 파일을 Unstage (스테이징 해제)
git restore --staged temp.txt
git status
echo "'temp.txt'가 Unstage되었습니다."

# 수정된 파일의 변경 사항을 버리기 (마지막 커밋 상태로 되돌림)
echo "Discard this change" >> hello.txt
git status
echo "'hello.txt'가 Modified 상태입니다."
git restore hello.txt
git status
cat hello.txt # 변경 사항이 사라졌는지 확인
echo "'hello.txt'의 변경 사항이 버려졌습니다."
echo ""

echo "--- 1단계 학습 완료 ---"
cd .. # 원래 디렉토리로 돌아가기
rm -rf my_git_project # 생성된 프로젝트 디렉토리 삭제
echo "'my_git_project' 디렉토리가 삭제되었습니다."
