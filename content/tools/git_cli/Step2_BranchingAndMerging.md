# Step2: 브랜치 & 병합

## 목표
- 브랜치 생성/이동/정리 방법을 익히고, merge·rebase 차이를 실습합니다.
- 단순 fast-forward 병합과 충돌 해결 흐름을 경험합니다.

## 0. 실습 리포지토리 초기화
```bash
mkdir git_branch_merge_project && cd git_branch_merge_project
git init
git config user.name  "Git Learner"
git config user.email "git.learner@example.com"
echo "Initial content" > main.txt
git add main.txt && git commit -m "feat: 초기 파일 추가"
git branch -M main
```

## 1. 브랜치 기본
- 목록 보기: `git branch`
- 생성: `git branch feature-a`
- 이동: `git switch feature-a` (또는 `git checkout feature-a`)
- 삭제: `git branch -d feature-a` (병합된 경우), 강제 `-D`

### 예시
```bash
git switch -c feature-a main
echo "Feature A content" > feature-a.txt
git add feature-a.txt && git commit -m "feat: Add feature A"

git switch main
echo "More main content" >> main.txt
git add main.txt && git commit -m "docs: Update main.txt"
```

## 2. 병합 (Merge)
### Fast-forward 또는 3-way
```bash
git switch main
git merge feature-a --no-edit   # 상황에 따라 FF 또는 3-way
git log --oneline --graph --all
```

### 충돌 해결 흐름
```bash
git switch -c feature-b main
echo "Feature B specific change" > common.txt
git add common.txt && git commit -m "feat: Add common.txt in feature-b"

git switch main
echo "Main specific change" > common.txt
git add common.txt && git commit -m "feat: Add common.txt in main"

git merge feature-b             # 충돌 발생
# common.txt에서 <<<<<<< ======= >>>>>>> 구간을 수동 해결
echo "Resolved content for common.txt from both branches" > common.txt
git add common.txt
git commit -m "fix: Resolve merge conflict in common.txt"
```

## 3. 리베이스 (Rebase)
### 기본 흐름
```bash
git switch -c feature-c main
echo "Feature C line 1" > feature-c.txt
git add feature-c.txt && git commit -m "feat: Add feature C line 1"
echo "Feature C line 2" >> feature-c.txt
git add feature-c.txt && git commit -m "feat: Add feature C line 2"

git switch main
echo "More main content for rebase" >> main.txt
git add main.txt && git commit -m "docs: Another update in main for rebase"

git switch feature-c
git rebase main
git log --oneline --graph --all
```

### Merge vs Rebase
- **Merge**: 기존 히스토리를 유지하며 병합 커밋이 추가됨.
- **Rebase**: 내 커밋을 새 베이스 위로 재배치해 히스토리를 일렬로 정리.
- 공개 브랜치에서는 rebase 강제푸시가 위험하므로 피하고, 개인 작업 브랜치에서 정리 용도로 사용.

## 4. 정리
```bash
cd ..
rm -rf git_branch_merge_project
```
