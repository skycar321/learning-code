# Step4: 고급 Git & 트러블슈팅 (UTF-8)

## 목표
- 커밋 되돌리기, cherry-pick, stash/부분커밋 등 실무 잦은 시나리오를 한눈에 정리합니다.
- KakaoTalk 자료(스태시 & 부분커밋 가이드)를 통합해 웹에서 바로 읽을 수 있게 제공합니다.

---

## 0. 실습 환경 초기화 (옵션)
```bash
mkdir git_advanced_project && cd git_advanced_project
git init
git config user.name  "Advanced Git User"
git config user.email "advanced.git.user@example.com"
git branch -M main
```

기본 파일 생성 예시:
```bash
echo "Initial file content" > file1.txt
git add file1.txt && git commit -m "feat: Add initial file1.txt"
echo "Second line for file1" >> file1.txt
git add file1.txt && git commit -m "docs: Update file1.txt with second line"
echo "Third line for file1" >> file1.txt
git add file1.txt && git commit -m "feat: Add third line to file1.txt"
```

---

## 1. 커밋 되돌리기
### 1) `git revert <hash>`
- 기존 히스토리를 보존하면서 “반대 커밋”을 새로 만듭니다.
```bash
git revert <commit> --no-edit
```

### 2) `git reset <mode> <hash>`
- `--soft` : HEAD만 이동, 스테이징/워킹트리 보존  
- `--mixed`(기본) : 스테이징 초기화, 워킹트리 보존  
- `--hard` : 스테이징·워킹트리 모두 해당 시점으로 덮어쓰기
```bash
git reset --hard <commit>
```

---

## 2. Cherry-pick
다른 브랜치의 특정 커밋을 현재 브랜치에 적용.
```bash
git switch -c feature-cherry main
echo "New feature content" > feature.txt
git add feature.txt && git commit -m "feat: Add new feature in feature-cherry"

git switch main
git cherry-pick <위 커밋 해시>
```

---

## 3. Stash & 부분 커밋 실무 가이드

### 3-1. Stash 빠른 명령 모음
```bash
git stash                       # 기본 (추적 파일만)
git stash push -m "메시지"      # 메시지 포함
git stash push -u -m "추적+비추적"     # --include-untracked
git stash push --all -m "ignored까지"  # 빌드/로그 등 무시된 파일까지
git stash push -m "특정 파일만" config/app.js   # pathspec 지정
git stash list
git stash show -p stash@{0}     # 내용 확인
git stash apply stash@{0}       # 적용(보존)
git stash pop                   # 적용 후 제거
git stash drop stash@{1}        # 특정 항목 제거
git stash clear                 # 전체 제거
git stash branch hotfix stash@{0}  # 새 브랜치에서 복원하며 목록 제거
```

### 3-2. 스태시 활용 패턴
1) **추적+비추적 함께 저장**  
```bash
echo "작업중 변경" >> file1.txt
echo "메모" > note_tmp.md
git add file1.txt
git stash push --include-untracked -m "WIP: 파일 수정+메모"
git stash show -p stash@{0}
```

2) **스테이징 상태까지 복원**  
```bash
git stash apply --index stash@{0}
git stash drop stash@{0}
```

3) **특정 파일만 저장(pathspec)**  
```bash
echo "file1 전용 변경" >> file1.txt
echo "file2 계속 작업" > file2.txt
git stash push -m "WIP: file1만" file1.txt
git stash pop
```

4) **무시된 파일까지 포함**  
```bash
echo "빌드 산출물" > build/artifact.tmp
echo "로그" > logs/app.log
echo "SECRET=123" > .env.local
git stash push --all -m "WIP: 빌드·로그·ignored 포함"
```

5) **스태시에서 바로 브랜치 만들기**  
```bash
git stash branch hotfix-from-stash stash@{0}
```

### 3-3. 부분 커밋(git add -p) 핵심
- 커맨드라인에서 변경을 청크/줄 단위로 선택 스테이징.
- 프롬프트 선택지 요약:
  - `y` 적용, `n` 건너뜀, `s` 더 잘게 쪼갬, `e` 수동 편집, `q` 종료, `?` 도움말.
```bash
git add -p file.txt
```

### 3-4. 한 파일을 여러 브랜치로 나누어 커밋하기 (예시)
1. 모든 변경을 스태시에 보관  
```bash
git stash push -m "file.txt 3줄 작업"
```
2. 브랜치 `a`에서 1번 줄만 커밋  
```bash
git switch -c a
git stash apply        # pop 대신 apply로 보존
git add -p file.txt    # 1줄만 선택해 스테이징
git commit -m "첫째 줄"
git restore file.txt   # 나머지 줄 원상복구
```
3. 브랜치 `b`에서 2번 줄만 커밋 (필요하면 다시 stash apply)  
4. 브랜치 `c`에서 3번 줄만 커밋 (마지막에 stash pop)

### 3-5. IDE에서의 스태시 & 부분 스테이징 팁
- **VS Code**: Source Control 패널 → … 메뉴에서 Stash/Apply/Pop. 부분 스테이징은 Diff 뷰에서 원하는 줄 선택 후 `Stage Selected Ranges`.
- **IntelliJ/WebStorm**: Uncommitted Changes → Stash/Unstash. Diff 창에서 Chunk 단위 선택 또는 “Split Changes and Rollback”.
- **Eclipse/STS(EGit)**: Team → Stashes → Stash/Apply. Staging 뷰에서 “Stage Lines”로 부분 스테이징(기능 제한적).

---

## 4. 로그 검색 꿀팁
```bash
git log -1 -p                         # 직전 커밋 diff
git log --oneline --grep="feat"       # 메시지 패턴
git log --oneline -- file1.txt        # 특정 파일 이력
git log --author="이름" --since="2024-01-01"
git log -S"검색어"                    # 문자열이 추가/삭제된 커밋 (pickaxe)
```

---

## 5. Git Hooks 개념
- 위치: `.git/hooks`
- 예: `pre-commit` 훅에서 lint/test 실행해 불필요한 커밋 방지.
- 팀 공유 팁: husky 또는 `core.hooksPath`로 공통 훅 관리.

---

## 6. .gitignore 기본 패턴
- 빌드 산출물: `/build`, `/dist`, `/target`
- 로그/임시: `*.log`, `*.tmp`
- 민감 정보: `.env`, `*.pem`, `application-secret.properties`
- IDE 설정: `.idea/`, `.vscode/`

---

## 실습 정리 (옵션)
```bash
cd ..
rm -rf git_advanced_project
```
