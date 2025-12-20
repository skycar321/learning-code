#!/bin/bash

# Git CLI 학습 계획 - 4단계: Git 고급 기능 & 트러블슈팅 (UTF-8)
# 실무에서 자주 마주치는 상황을 짧은 스크립트로 연습합니다.

echo "--- 4단계: Git 고급 기능 & 문제 해결 ---"

# 0. 초기 Git 리포지토리 설정
rm -rf git_advanced_project
mkdir git_advanced_project
cd git_advanced_project
git init -q
git config user.name "Advanced Git User"
git config user.email "advanced.git.user@example.com"
echo "초기 Git 리포지토리 'git_advanced_project' 생성"

# 0-1. 기본 커밋 3개 생성
echo "Initial file content" > file1.txt
git add file1.txt
git commit -m "feat: Add initial file1.txt" -q
git branch -M main
echo "Second line for file1" >> file1.txt
git add file1.txt
git commit -m "docs: Update file1.txt with second line" -q
echo "Third line for file1" >> file1.txt
git add file1.txt
git commit -m "feat: Add third line to file1.txt" -q
echo "기본 3개 커밋 완료"
echo ""
git log --oneline --graph --all
echo ""

# -----------------------------------------------------------------------------
# 1. 커밋 되돌리기 (Undoing Changes)
# -----------------------------------------------------------------------------
echo "1.1. git revert <hash>: 특정 커밋을 되돌리는 새 커밋 생성"
LAST_COMMIT_HASH=$(git rev-parse --short HEAD)
git revert $LAST_COMMIT_HASH --no-edit -q
echo "마지막 커밋($LAST_COMMIT_HASH)을 revert 완료"
git log --oneline --graph --all
echo ""

echo "1.2. git reset <mode> <hash>: 커밋 히스토리 위치 이동"
SECOND_COMMIT_HASH=$(git log --oneline | grep "Update file1.txt" | head -n 1 | awk '{print $1}')
git reset --hard $SECOND_COMMIT_HASH >/dev/null
echo "git reset --hard $SECOND_COMMIT_HASH 실행 → 해당 시점으로 워킹트리/스테이징 초기화"
git log --oneline --graph --all
echo ""
cat file1.txt
echo ""

# -----------------------------------------------------------------------------
# 2. 커밋 가져오기 (Cherry-picking)
# -----------------------------------------------------------------------------
echo "2.1. git cherry-pick <hash>: 다른 브랜치의 커밋을 현재 브랜치에 적용"
git switch -c feature-cherry main >/dev/null
echo "New feature content" > feature.txt
git add feature.txt
git commit -m "feat: Add new feature in feature-cherry" -q
FEATURE_COMMIT_HASH=$(git rev-parse --short HEAD)
echo "feature-cherry 브랜치에서 커밋 생성: $FEATURE_COMMIT_HASH"
echo ""

git switch main >/dev/null
git cherry-pick $FEATURE_COMMIT_HASH >/dev/null
echo "main 브랜치에 cherry-pick 완료 → feature.txt 추가"
git log --oneline --graph --all
echo ""
cat feature.txt
echo ""

# -----------------------------------------------------------------------------
# 3. 변경사항 임시 저장 (Stashing) — 실무 필수 패턴
# -----------------------------------------------------------------------------
echo "3. 실무에서 자주 쓰는 git stash 활용법"

echo "3.1. 기본: 추적/비추적 파일을 함께 스태시 (--include-untracked)"
echo "작업 중 변경을 만들고 스태시로 보관"
echo "작업중 변경 A" >> file1.txt
echo "작업중 변경 B" >> file1.txt
echo "새로운 비추적 파일" > note_tmp.md
git add file1.txt
git status -s
git stash push --include-untracked -m "WIP: 파일 수정 + 새 비추적 파일" >/dev/null
echo "→ 최신 스태시로 보관 후 워킹트리 정리"
git status -s
git stash list
echo ""

echo "3.2. 스태시에 무엇이 있는지 확인 (git stash show -p)"
git stash show -p stash@{0}
echo ""

echo "3.3. 스태시 되돌리기: apply --index vs drop"
git stash apply --index stash@{0} >/dev/null
echo "→ 스테이징 상태까지 복원 (--index)"
git status -s
git stash drop stash@{0} >/dev/null
echo "→ 적용 후 스태시 삭제"
git status -s
echo ""

echo "3.4. 특정 파일만 스태시 (pathspec)"
echo "file1만 수정 후 스태시, file2는 계속 보존"
echo "file1에만 추가 변경" >> file1.txt
echo "file2는 계속 작업 중" > file2.txt
git status -s
git stash push -m "WIP: file1만 스태시" file1.txt >/dev/null
echo "→ file1 변경만 스태시됨, file2는 워킹트리에 남음"
git status -s
git stash pop >/dev/null
echo "→ 스태시 재적용 후 목록에서 제거"
git status -s
# 데모 정리
git checkout -- file1.txt
rm -f file2.txt
echo ""

echo "3.5. 빌드/로그/무시된 파일까지 함께 스태시 (--all)"
mkdir -p build logs
echo "임시 빌드 결과" > build/artifact.tmp
echo "디버그 로그" > logs/app.log
echo "민감값=secret" > .env.local
git status -s
git stash push --all -m "WIP: 빌드·로그·ignored 포함" >/dev/null
git stash list
echo ""

echo "3.6. 스태시에서 바로 브랜치 만들기 (git stash branch)"
git stash branch hotfix-from-stash stash@{0} >/dev/null
echo "→ hotfix-from-stash 브랜치에서 스태시 내용 복구 후 스태시 항목 제거"
git status -s
git switch main >/dev/null
git branch -D hotfix-from-stash >/dev/null
git stash clear >/dev/null
echo "스태시 목록 정리 완료"
git status -s
echo ""

# -----------------------------------------------------------------------------
# 4. 로그 기록 검색 (Searching History)
# -----------------------------------------------------------------------------
echo "4. git log 옵션 예시"
echo "-p 옵션으로 커밋 diff 확인:"
git log -1 -p
echo ""
echo "--grep으로 커밋 메시지 패턴 검색 (feat 포함):"
git log --oneline --grep="feat"
echo ""
echo "특정 파일(file1.txt)의 변경 이력:"
git log --oneline -- file1.txt
echo ""

# -----------------------------------------------------------------------------
# 5. Git 훅 (Git Hooks) 개념
# -----------------------------------------------------------------------------
echo "5. Git Hooks: 커밋/푸시 시점에 자동 스크립트 실행"
echo "위치: .git/hooks 디렉터리"
echo "예시: pre-commit 훅으로 린트/테스트 실행, 불필요한 커밋 방지"
echo "Tip: 팀에서는 husky(또는 core.hooksPath)로 공통 훅을 관리"
echo ""

# -----------------------------------------------------------------------------
# 6. .gitignore 구성
# -----------------------------------------------------------------------------
echo "6. .gitignore 기본 패턴 예시"
echo "/build, /dist, /target 등의 빌드 산출물"
echo "*.log, *.tmp 같은 로그/임시 파일"
echo ".env, *.pem 등 민감 정보"
echo ".idea/, .vscode/ 같은 IDE 설정"
echo ""

echo "--- 4단계 실습 종료 ---"
cd ..
rm -rf git_advanced_project
echo "'git_advanced_project' 정리 완료"
