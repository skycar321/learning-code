# Git CLI Cheatsheet

> 버전 관리를 위한 필수 Git 명령어 요약입니다. (튜토리얼이 아닌 빠른 참조용)

## 1. 설정 및 시작 (Setup)
```bash
# 사용자 이름/이메일 설정
git config --global user.name "My Name"
git config --global user.email "my@email.com"

# 현재 디렉토리를 Git 저장소로 초기화
git init

# 원격 저장소 복제
git clone <repo_url>
```

## 2. 작업 흐름 (Workflow)
```bash
# 변경 상태 확인 (필수)
git status

# 파일 스테이징 (준비 영역으로 이동)
git add .

# 커밋 (메시지와 함께 저장)
git commit -m "feat: add login page"

# 원격 저장소로 업로드
git push origin main
```

| 명령 | 예상 출력/효과 | 흔한 실수 |
| --- | --- | --- |
| `git status` | 변경 파일 목록, 브랜치, 추적 여부 표시 | 스테이징된 변경과 워킹트리 변경을 혼동 |
| `git add -p` | 변경을 덩어리(hunk) 단위로 선택 | 전체 `git add .`로 불필요한 파일까지 올리기 |
| `git commit -m "msg"` | 새 커밋 생성 | 메시지에 작업 맥락이 없거나 오타 |
| `git push origin main` | 원격 브랜치 업데이트 | 로컬이 뒤쳐진 상태에서 force push 시도 |

> TIP: 추가/삭제/수정된 파일만 올리고 싶을 때는 `git add -p`로 부분 스테이징을 습관화하세요.

## 4. 자주 쓰는 복구/확인
```bash
git log --oneline --graph --all   # 히스토리 트리 보기
git reflog                        # HEAD 이동 기록 (복구용)
git stash push -m "msg"           # 현재 변경 임시 보관
git restore <file>                # 워킹트리 변경 취소 (Git 2.23+)
```
| 명령 | 기대 출력/효과 | 흔한 실수 |
| --- | --- | --- |
| `git log --oneline` | 최근 커밋 요약 | 긴 로그에서 빠져나올 때 `q` 잊음 |
| `git reflog` | HEAD 이동 기록 표시 | reflog도 지워질 수 있음(보존기간 주의) |
| `git stash pop` | 스태시 적용+삭제 | 충돌 시 drop까지 동시에 일어남 주의 |
| `git restore <file>` | 워킹 변경 취소 | 스테이징 해제는 `--staged` 필요 |

## 3. 브랜치 관리 (Branching)
```bash
# 브랜치 목록 확인
git branch -a

# 새 브랜치 생성 및 이동
git switch -c feature/new-ui
# (구버전: git checkout -b feature/new-ui)

# 브랜치 병합 (현재 브랜치에 feature 병합)
git merge feature/new-ui
```

## 4. 되돌리기 (Undo & Reset)
```bash
# 마지막 커밋 메시지 수정
git commit --amend

# 작업 취소 (스테이징 취소, 파일 변경은 유지)
git reset HEAD~1

# 변경 사항 모두 폐기하고 특정 커밋으로 강제 이동 (주의!)
git reset --hard origin/main
```

## 5. 로그 확인
```bash
# 그래프 형태로 로그 보기
git log --oneline --graph --all
```
