#!/bin/bash

# Git CLI 학습 계획 - 4단계: Git 고급 기능 및 문제 해결
# 이 스크립트는 Git의 고급 기능(커밋 되돌리기, 체리픽, 스태시 등)과
# 일반적인 문제 해결 방법을 학습하기 위한 명령어들을 포함하고 있습니다.
# Git을 보다 효율적으로 사용하고, 다양한 상황에서 발생하는 문제를 해결하는 능력을 향상시키는 것을 목표로 합니다.

echo "--- 4단계: Git 고급 기능 및 문제 해결 ---"

# 초기 Git 리포지토리 설정
mkdir git_advanced_project
cd git_advanced_project
git init > /dev/null
git config user.name "Advanced Git User"
git config user.email "advanced.git.user@example.com"

echo "초기 Git 리포지토리 'git_advanced_project' 설정 완료."

# 초기 커밋들
echo "Initial file content" > file1.txt
git add file1.txt
git commit -m "feat: Add initial file1.txt" > /dev/null
echo "Second line for file1" >> file1.txt
git add file1.txt
git commit -m "docs: Update file1.txt with second line" > /dev/null
echo "Third line for file1" >> file1.txt
git add file1.txt
git commit -m "feat: Add third line to file1.txt" > /dev/null
echo "초기 3개 커밋 생성 완료."
echo ""
git log --oneline --graph --all
echo ""

# -----------------------------------------------------------------------------
# 1. 커밋 되돌리기 (Undoing Changes)
# -----------------------------------------------------------------------------
echo "1.1. `git revert <commit-hash>`: 특정 커밋을 되돌리는 새로운 커밋 생성"
# 이 명령어는 특정 커밋의 변경 사항을 되돌리는 새로운 커밋을 생성합니다.
# 기존 커밋 히스토리를 변경하지 않으므로, 이미 원격에 푸시된 커밋을 되돌릴 때 안전합니다.
LAST_COMMIT_HASH=$(git log --oneline -n 1 | awk '{print $1}')
echo "마지막 커밋 ($LAST_COMMIT_HASH)의 변경 사항을 되돌립니다."
git revert $LAST_COMMIT_HASH --no-edit > /dev/null
echo "마지막 커밋을 되돌리는 새로운 커밋 생성 완료."
git log --oneline --graph --all
echo ""
cat file1.txt # 변경 사항이 되돌려졌는지 확인 (세 번째 줄 삭제)
echo ""

echo "1.2. `git reset <mode> <commit-hash>`: 커밋 히스토리를 변경"
# `git reset`은 커밋 히스토리를 재작성하므로, 이미 원격에 푸시된 커밋에는 사용하지 않는 것이 좋습니다.
# - `--soft`: 커밋만 되돌리고, 변경 사항은 스테이징 영역에 유지.
# - `--mixed` (기본값): 커밋을 되돌리고, 변경 사항은 작업 디렉토리에 유지 (unstaged).
# - `--hard`: 커밋을 되돌리고, 변경 사항을 완전히 버림. (가장 위험)
SECOND_COMMIT_HASH=$(git log --oneline | grep "Update file1.txt" | awk '{print $1}')
echo "세 번째 커밋을 되돌려 두 번째 커밋($SECOND_COMMIT_HASH) 상태로 `--hard` 리셋합니다."
git reset --hard $SECOND_COMMIT_HASH > /dev/null
echo "Git reset --hard 완료. 세 번째 커밋과 해당 변경 사항이 완전히 사라졌습니다."
git log --oneline --graph --all
echo ""
cat file1.txt # 두 번째 줄까지 남아있어야 함
echo ""

# -----------------------------------------------------------------------------
# 2. 특정 커밋 가져오기 (Cherry-picking)
# -----------------------------------------------------------------------------
echo "2.1. `git cherry-pick <commit-hash>`: 특정 브랜치의 커밋을 현재 브랜치로 가져오기"
# 다른 브랜치에 있는 특정 커밋의 변경 사항만 현재 브랜치로 가져올 때 사용합니다.
git switch -c feature-cherry main > /dev/null # main에서 새 브랜치 생성
echo "New feature content" > feature.txt
git add feature.txt
git commit -m "feat: Add new feature in feature-cherry" > /dev/null
FEATURE_COMMIT_HASH=$(git log --oneline -n 1 | awk '{print $1}')
echo "'feature-cherry' 브랜치에 새 기능 커밋($FEATURE_COMMIT_HASH) 생성."
echo ""

git switch main > /dev/null # main 브랜치로 전환
echo "main 브랜치에 'feature-cherry' 브랜치의 새 기능 커밋($FEATURE_COMMIT_HASH)을 체리픽합니다."
git cherry-pick $FEATURE_COMMIT_HASH > /dev/null
echo "체리픽 완료. 'main' 브랜치에 'feature.txt'가 추가되었습니다."
git log --oneline --graph --all
echo ""
cat feature.txt
echo ""

# -----------------------------------------------------------------------------
# 3. 변경 사항 임시 저장 (Stashing)
# -----------------------------------------------------------------------------
echo "3.1. `git stash`: 작업 중인 변경 사항을 임시 저장"
# 현재 작업 중인 내용을 커밋하기는 애매하지만, 다른 브랜치로 전환해야 할 때 유용합니다.
echo "Additional changes for file1" >> file1.txt
echo "New untracked file" > new_untracked_file.txt
git add file1.txt
echo "file1.txt는 스테이징, new_untracked_file.txt는 Untracked 상태."
git status
echo ""

git stash push -m "WIP: 작업 중이던 변경 사항 임시 저장" # `git stash save`는 구 버전
echo "현재 변경 사항을 스태시에 저장했습니다."
git status
echo "작업 디렉토리가 깨끗합니다."
echo ""

echo "3.2. `git stash list`: 스태시 목록 확인"
git stash list
echo ""

echo "3.3. `git stash pop` 또는 `git stash apply`: 스태시 적용"
# `pop`은 스태시를 적용하고 목록에서 제거합니다. `apply`는 적용만 하고 목록에 남깁니다.
git stash pop > /dev/null
echo "스태시를 적용하고 목록에서 제거했습니다."
git status
echo "이전 작업 내용이 복원되었습니다."
echo ""
cat file1.txt # 변경 사항이 다시 추가되었는지 확인
echo ""

# -----------------------------------------------------------------------------
# 4. 로그 기록 검색 (Searching History)
# -----------------------------------------------------------------------------
echo "4.1. `git log` 옵션 활용"
# - `-p`: 각 커밋의 변경 내용(diff)을 보여줍니다.
# - `--author="<name>"`: 특정 저자의 커밋만 필터링합니다.
# - `--grep="<pattern>"`: 커밋 메시지에서 특정 패턴을 검색합니다.
# - `--since="<date>"` / `--until="<date>"`: 특정 기간 내의 커밋만 보여줍니다.
# - `-S"<string>"`: 특정 문자열이 추가되거나 제거된 커밋을 찾습니다. (Pickaxe search)
echo "커밋 메시지에서 'feat'를 포함하는 커밋 찾기:"
git log --oneline --grep="feat"
echo ""

echo "파일1.txt의 변경 이력 확인:"
git log --oneline file1.txt
echo ""

# -----------------------------------------------------------------------------
# 5. Git 후크 (Git Hooks) - 자동화 스크립트 (개념)
# -----------------------------------------------------------------------------
echo "5. Git 후크 (Git Hooks) - 자동화 스크립트 (개념적 설명)"
echo "Git 후크는 Git 이벤트(커밋 전/후, 푸시 전/후 등)에 연결하여 특정 스크립트를 자동으로 실행할 수 있는 기능입니다."
echo "위치: `.git/hooks` 디렉토리"
echo "예시: `pre-commit` 후크를 사용하여 커밋 전에 코드 스타일 검사 또는 테스트 실행."
echo "나쁜 예시: 수동으로 모든 코드 검사나 테스트를 수행하여 휴먼 에러 발생 가능성을 높이는 것."
echo "좋은 예시: Git 후크를 통해 코드를 푸시하기 전에 자동화된 검사를 수행하여 코드 품질을 유지하는 것."
echo ""

# -----------------------------------------------------------------------------
# 6. .gitignore 파일 설정 (Configuring .gitignore)
# -----------------------------------------------------------------------------
echo "6. .gitignore 파일 설정 (개념적 설명)"
echo ".gitignore 파일은 Git이 추적하지 않아야 할 파일이나 디렉토리를 지정합니다."
echo "예시: 빌드 결과물 (`/build`, `/target`), 로그 파일 (`.log`), 민감한 설정 파일 (`.env`, `application-secret.properties`), IDE 설정 파일 (`.idea`, `.vscode`) 등"
echo "나쁜 예시: .gitignore를 사용하지 않아 불필요한 파일이나 민감한 정보가 리포지토리에 포함되는 것."
echo "좋은 예시: 프로젝트 시작 시 표준 .gitignore 파일을 구성하여 불필요한 파일을 Git 추적에서 제외하는 것."
echo ""
echo "--- 4단계 학습 완료 ---"
cd ..
rm -rf git_advanced_project
echo "'git_advanced_project' 디렉토리가 삭제되었습니다."
