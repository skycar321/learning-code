#!/bin/bash

# Git CLI 학습 계획 - 2단계: 브랜치 및 병합
# 이 스크립트는 Git의 핵심 기능인 브랜치(Branch), 병합(Merge), 리베이스(Rebase)를
# 학습하기 위한 개념적인 명령어들을 포함하고 있습니다.
# 여러 개발자가 협업하거나 새로운 기능을 개발할 때 효과적으로 코드를 관리하는 방법을 배웁니다.

echo "--- 2단계: 브랜치 및 병합 ---"

# 초기 Git 리포지토리 설정
mkdir git_branch_merge_project
cd git_branch_merge_project
git init > /dev/null
git config user.name "Git Learner"
git config user.email "git.learner@example.com"

echo "초기 Git 리포지토리 'git_branch_merge_project' 설정 완료."

# 첫 번째 커밋
echo "Initial content" > main.txt
git add main.txt
git commit -m "feat: 초기 파일 추가" > /dev/null
echo "첫 번째 커밋 (main 브랜치) 생성 완료."
echo ""

# -----------------------------------------------------------------------------
# 1. 브랜치 개념 이해 (Understanding Branches)
# -----------------------------------------------------------------------------
echo "Git 브랜치는 독립적으로 작업을 진행할 수 있는 코드 라인입니다."
echo "각 브랜치는 프로젝트의 전체 복사본처럼 동작하며, 다른 브랜치에 영향을 주지 않고"
echo "새로운 기능 개발이나 버그 수정을 할 수 있게 해줍니다."
echo "나쁜 예시: 모든 개발자가 하나의 main 브랜치에서 직접 작업하여 코드 충돌 위험을 높이는 것."
echo "좋은 예시: 각 기능 또는 작업별로 새로운 브랜치를 생성하여 개발하고, 완료 후 main 브랜치에 병합하는 것."
echo ""

# -----------------------------------------------------------------------------
# 2. 브랜치 생성, 전환, 삭제 (Creating, Switching, Deleting Branches)
# -----------------------------------------------------------------------------

echo "2.1. `git branch`: 브랜치 목록 확인"
git branch
echo "현재 'main' 브랜치만 존재합니다."
echo ""

echo "2.2. `git branch <new-branch-name>`: 새 브랜치 생성"
git branch feature-a
echo "'feature-a' 브랜치 생성 완료."
git branch
echo ""

echo "2.3. `git checkout <branch-name>` 또는 `git switch <branch-name>`: 브랜치 전환"
# `git checkout`은 브랜치 전환 외에 파일 복원 등 다양한 용도로 사용됩니다.
# Git 2.23부터는 브랜치 전환 전용으로 `git switch`가 도입되었습니다.
git switch feature-a
echo "'feature-a' 브랜치로 전환 완료."
echo ""

# feature-a 브랜치에서 작업 수행
echo "Feature A content" > feature-a.txt
git add feature-a.txt
git commit -m "feat: Add feature A" > /dev/null
echo "'feature-a' 브랜치에 커밋 생성 완료."
echo ""

# 다시 main 브랜치로 전환
git switch main
echo "'main' 브랜치로 전환 완료."
echo ""

# main 브랜치에서 다른 작업 수행
echo "More main content" >> main.txt
git add main.txt
git commit -m "docs: Update main.txt" > /dev/null
echo "'main' 브랜치에 다른 커밋 생성 완료."
echo ""

echo "2.4. `git branch -d <branch-name>`: 브랜치 삭제"
# 병합된 브랜치만 삭제할 수 있습니다. (-D는 강제 삭제)
# git branch -d feature-a # 아직 병합되지 않아 실패할 것입니다.
echo ""

# -----------------------------------------------------------------------------
# 3. 브랜치 병합 (Merging Branches)
# -----------------------------------------------------------------------------

echo "3.1. `git merge <branch-name>`: 브랜치 병합 (Fast-forward 또는 3-way)"
# main 브랜치에서 feature-a 브랜치를 병합합니다.
echo "3.1. 'feature-a' 브랜치를 'main'으로 병합 시도..."
git merge feature-a --no-edit # --no-edit는 커밋 메시지 편집기를 열지 않습니다.
echo "'feature-a' 브랜치가 'main'으로 병합되었습니다 (Fast-forward 또는 3-way)."
git log --oneline --graph --all
echo ""

echo "3.2. 병합 충돌 해결 (Resolving merge conflicts)"
# 의도적으로 충돌을 발생시켜 해결 과정을 시뮬레이션합니다.
git switch -c feature-b main # main에서 feature-b 브랜치 생성 및 전환
echo "Feature B specific change" > common.txt
git add common.txt
git commit -m "feat: Add common.txt in feature-b" > /dev/null
echo "'feature-b' 브랜치에 'common.txt' 추가."
echo ""

git switch main # main 브랜치로 전환
echo "Main specific change" > common.txt # main 브랜치에서도 동일 파일 수정
git add common.txt
git commit -m "feat: Add common.txt in main" > /dev/null
echo "'main' 브랜치에 'common.txt' 추가."
echo ""

echo "이제 'main' 브랜치에서 'feature-b' 브랜치를 병합하면 충돌이 발생할 것입니다."
git merge feature-b
echo "!!! 병합 충돌 발생 !!!"
echo "common.txt 파일을 열어보면 충돌 마커(<<<<<<<, =======, >>>>>>>)가 보일 것입니다."
echo "예시 충돌 내용 (common.txt):"
cat common.txt
echo ""

echo "수동으로 충돌을 해결합니다 (예: 두 내용을 모두 포함하거나 하나만 선택)."
echo "Resolved content for common.txt from both branches" > common.txt
git add common.txt # 충돌 해결 후 파일을 스테이징합니다.
git commit -m "fix: Resolve merge conflict in common.txt" > /dev/null
echo "병합 충돌 해결 및 커밋 완료."
echo ""
git log --oneline --graph --all
echo ""

# -----------------------------------------------------------------------------
# 4. 리베이스 (Rebasing)
# -----------------------------------------------------------------------------
echo "4.1. `git rebase <base-branch>`: 커밋 히스토리 정리"
# 리베이스는 한 브랜치의 변경 사항을 다른 브랜치 위에 '재배치'하는 작업입니다.
# 커밋 히스토리가 선형적으로 깔끔하게 유지되는 장점이 있습니다.
git switch -c feature-c main # main에서 feature-c 브랜치 생성 및 전환
echo "Feature C line 1" > feature-c.txt
git add feature-c.txt
git commit -m "feat: Add feature C line 1" > /dev/null
echo "Feature C line 2" >> feature-c.txt
git add feature-c.txt
git commit -m "feat: Add feature C line 2" > /dev/null
echo "'feature-c' 브랜치에 두 개의 커밋 생성."
echo ""

git switch main
echo "More main content for rebase" >> main.txt
git add main.txt
git commit -m "docs: Another update in main for rebase" > /dev/null
echo "'main' 브랜치에 추가 커밋 생성."
echo ""

echo "이제 'feature-c' 브랜치를 'main' 브랜치 위에 리베이스합니다."
echo "'feature-c'의 커밋들이 'main'의 최신 커밋 뒤에 다시 적용될 것입니다."
git switch feature-c
git rebase main # feature-c의 base를 main으로 변경
echo "리베이스 완료."
echo ""
git log --oneline --graph --all
echo ""

echo "4.2. 리베이스 vs 병합 (Rebase vs Merge)"
echo "Merge: 히스토리가 유지되지만 병합 커밋(merge commit)이 생성되어 복잡해질 수 있습니다."
echo "Rebase: 히스토리가 선형적으로 깔끔하게 유지되지만, 커밋 히스토리가 변경됩니다."
echo "주의: 이미 공개된(푸시된) 브랜치에 리베이스하는 것은 피해야 합니다. 히스토리가 변경되어 다른 사람들의 작업에 영향을 줄 수 있습니다."
echo ""

echo "--- 2단계 학습 완료 ---"
cd ..
rm -rf git_branch_merge_project
echo "'git_branch_merge_project' 디렉토리가 삭제되었습니다."
