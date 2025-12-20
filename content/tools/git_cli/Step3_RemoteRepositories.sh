#!/bin/bash

# Git CLI 학습 계획 - 3단계: 원격 저장소 (Remote Repositories)
# 이 스크립트는 원격 Git 저장소의 개념, 추가/제거, 그리고 로컬 저장소와 원격 저장소 간의
# 동기화 (`git fetch`, `git pull`, `git push`) 방법을 학습하기 위한 명령어들을 포함하고 있습니다.
# GitHub, GitLab, Bitbucket 등과 같은 원격 저장소 서비스와의 협업 및 코드 공유에 필수적인 지식입니다.

echo "--- 3단계: 원격 저장소 ---"

# 초기 Git 리포지토리 설정
mkdir git_remote_project
cd git_remote_project
git init > /dev/null
git config user.name "Remote Learner"
git config user.email "remote.learner@example.com"

echo "초기 Git 리포지토리 'git_remote_project' 설정 완료."

# 첫 번째 커밋
echo "Initial content for remote" > remote_file.txt
git add remote_file.txt
git commit -m "feat: Initial commit for remote" > /dev/null
echo "첫 번째 커밋 (main 브랜치) 생성 완료."
echo ""

# -----------------------------------------------------------------------------
# 1. 원격 저장소 개념 (Understanding Remote Repositories)
# -----------------------------------------------------------------------------
echo "원격 저장소는 인터넷이나 네트워크를 통해 접근할 수 있는 Git 저장소입니다."
echo "주로 코드 공유, 협업, 백업 목적으로 사용됩니다."
echo "가장 대표적인 원격 저장소 호스팅 서비스는 GitHub, GitLab, Bitbucket 등이 있습니다."
echo "나쁜 예시: 코드를 로컬 PC에만 보관하고 백업이나 협업 없이 개발하는 것."
echo "좋은 예시: 원격 저장소를 활용하여 코드를 안전하게 백업하고 여러 개발자와 협업하는 것."
echo ""

# -----------------------------------------------------------------------------
# 2. 원격 저장소 추가/제거 (Adding/Removing Remotes)
# -----------------------------------------------------------------------------

echo "2.1. `git remote add <name> <url>`: 원격 저장소 추가"
# 'origin'은 Git에서 관례적으로 사용되는 기본 원격 저장소 이름입니다.
# 실제 GitHub/GitLab URL을 대체하여 사용하세요.
# 예시: git remote add origin https://github.com/your-username/your-repo.git
# 학습 목적으로는 실제 원격 저장소가 없으므로 가상의 URL을 사용합니다.
# 주의: 이 예시 스크립트는 실제 원격 저장소에 접근하지 않습니다.

# 나쁜 예시: 이미 존재하는 'origin' 원격 저장소에 다른 이름으로 추가하거나,
# 원격 저장소 URL을 잘못 입력하여 연결이 되지 않는 것.
# - 'git remote set-url origin <new-url>'을 사용하여 URL을 변경할 수 있습니다.

# 실제 GitHub에 리포지토리를 만들고 다음 명령어를 실행한다고 가정
# git remote add origin https://github.com/your-username/git_remote_project.git
echo "가상의 원격 저장소 'origin'이 추가되었습니다."
echo ""

echo "2.2. `git remote -v`: 원격 저장소 목록 확인"
# `-v` 옵션은 원격 저장소의 URL도 함께 보여줍니다.
git remote -v
echo ""

# 2.3. `git remote rename <old-name> <new-name>`: 원격 저장소 이름 변경
# git remote rename origin upstream # 예시
# echo "원격 저장소 'origin'의 이름을 'upstream'으로 변경했습니다."
# git remote -v
# echo ""

# 2.4. `git remote remove <name>`: 원격 저장소 제거
# git remote remove origin # 예시
# echo "원격 저장소 'origin'을 제거했습니다."
# git remote -v
# echo ""

echo "----------------------------------------------------------------------------"
echo "위 `git remote add/rename/remove` 명령어는 실제 원격 저장소가 없으므로"
echo "실제로 실행되지는 않거나 오류가 발생할 수 있습니다. 학습용으로 개념을 이해하세요."
echo "----------------------------------------------------------------------------"
echo ""

# -----------------------------------------------------------------------------
# 3. 원격 저장소와 동기화 (Syncing with Remote)
# -----------------------------------------------------------------------------

# 3.1. `git fetch <remote>`: 원격 저장소의 최신 변경 사항을 가져오기 (로컬에는 반영 안 함)
# 원격 저장소의 변경 사항(커밋, 브랜치)을 로컬로 가져오지만, 현재 작업 브랜치에는 적용하지 않습니다.
# `git status`는 여전히 'Your branch is up to date with 'origin/main'.' 등으로 표시될 수 있습니다.
# 나쁜 예시: `git fetch` 없이 `git pull`만 계속 사용하여 원격 변경 사항을 정확히 이해하지 못하는 것.
# - `git fetch`는 먼저 원격 변경 사항을 확인하고 필요한 경우에만 `git merge`나 `git rebase`를 사용하는 좋은 습관입니다.
echo "3.1. `git fetch origin` (가상): 원격 저장소의 최신 변경 사항 가져오기 (현재 브랜치에는 미적용)"
# git fetch origin
echo "원격 저장소 'origin'의 변경 사항을 가져왔다고 가정합니다."
echo ""

echo "3.2. `git pull <remote> <branch>`: 원격 저장소의 변경 사항을 가져와 현재 브랜치에 병합 (fetch + merge)"
# `git pull`은 `git fetch`와 `git merge`를 합친 명령어입니다.
# `origin` 원격 저장소의 `main` 브랜치 변경 사항을 가져와 로컬 `main` 브랜치에 병합합니다.
# 나쁜 예시: `git pull`을 너무 자주 사용하여 로컬 작업이 불안정해지거나 원치 않는 충돌을 자주 겪는 것.
# - 변경 사항을 푸시하기 전에 한 번 `git pull` 하는 것이 일반적입니다.
echo "3.2. `git pull origin main` (가상): 원격 저장소의 변경 사항을 가져와 현재 브랜치에 병합"
# git pull origin main
echo "원격 저장소 'origin/main'의 변경 사항을 로컬 'main' 브랜치에 병합했다고 가정합니다."
echo ""

echo "3.3. `git push <remote> <branch>`: 로컬 변경 사항을 원격 저장소로 업로드"
# 로컬 저장소의 변경 사항(커밋)을 원격 저장소로 전송합니다.
# `git push origin main`은 로컬의 `main` 브랜치 변경 사항을 `origin` 원격의 `main` 브랜치로 푸시합니다.
# 나쁜 예시: `git pull` 없이 `git push`를 먼저 시도하여 원격 저장소의 최신 변경 사항을 덮어쓰려 하거나,
# 다른 사람의 작업을 강제로 덮어쓰기 위해 `git push --force`를 사용하는 것.
# - `git push --force`는 특별한 경우를 제외하고는 사용을 지양해야 합니다.
echo "3.3. `git push origin main` (가상): 로컬 변경 사항을 원격 저장소로 업로드"
# git push origin main
echo "로컬 'main' 브랜치의 변경 사항을 원격 'origin/main'으로 푸시했다고 가정합니다."
echo ""

# -----------------------------------------------------------------------------
# 4. Fork와 Pull Request 워크플로우 (Fork & Pull Request Workflow) (개념)
# -----------------------------------------------------------------------------
echo "4. Fork와 Pull Request 워크플로우 (개념적 설명)"
echo "Fork: 다른 사람의 공개 리포지토리를 내 계정으로 복사하는 것입니다."
echo " - 이 복사본을 내 마음대로 수정하고 관리할 수 있습니다."
echo "Pull Request (PR): Fork한 리포지토리에서 변경한 내용을 원본 리포지토리에 반영해달라고 요청하는 것입니다."
echo " - PR을 통해 코드 리뷰를 받고, 원본 프로젝트에 기여할 수 있습니다."
echo " - 오픈소스 프로젝트 참여 시 일반적인 워크플로우입니다."
echo ""

echo "--- 3단계 학습 완료 ---"
cd ..
rm -rf git_remote_project
echo "'git_remote_project' 디렉토리가 삭제되었습니다."
