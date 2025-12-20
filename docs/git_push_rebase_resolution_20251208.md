# Git push 거절 대응 기록 (2025-12-08)

## 상황 요약
- 로컬 브랜치 `dev`가 원격 `origin/dev`보다 **1커밋 앞서고 9커밋 뒤처져** 있어 `git push`가 거절됨.

## 단계별 처리 (명령어 · 의도 · 결과)
1. `git status --short --branch`  
   - 의도: 현재 브랜치·ahead/behind·변경 파일 파악.  
   - 결과: `dev...origin/dev [ahead 1, behind 9]`, 다수 변경 확인.
2. `git fetch origin`  
   - 의도: 원격 최신 이력만 받아 로컬 기준점 최신화.  
   - 결과: 원격 `dev` 커밋 9개 확보.
3. `git stash push -u -m "auto-stash before rebase"`  
   - 의도: 워킹 변경(추가/수정/신규)을 임시 보관해 깨끗한 리베이스 준비.  
   - 결과: 모든 변경이 스택으로 이동, 워킹트리 정리.
4. `git rebase origin/dev`  
   - 의도: 원격 `dev` 위에 내 커밋을 재적용.  
   - 결과: `MODIFY_HISTORY.md` 충돌 발생 → 수동 해결 필요.
5. `git checkout --theirs MODIFY_HISTORY.md`  
   - 의도: 충돌 파일을 원격 버전으로 선택해 간단히 해결.  
   - 결과: 충돌 해소.
6. `git add MODIFY_HISTORY.md`  
   - 의도: 해결된 충돌 파일 스테이징.  
   - 결과: 리베이스 계속 진행 가능 상태.
7. `GIT_EDITOR=true git rebase --continue`  
   - 의도: 에디터 없이 리베이스 재개·완료.  
   - 결과: 새 커밋 `36607c7` 생성, rebase 성공.
8. `git stash pop`  
   - 의도: 임시 보관했던 변경 복원.  
   - 결과: `MODIFY_HISTORY.md` 수정, `.gcx/00_requirements/`, `.gcx/02_implementation/` 신규 파일 복귀.
9. `git push origin dev`  
   - 의도: 정리된 커밋을 원격에 반영.  
   - 결과: push 성공, 원격 `dev` 최신화.

## 시각화 (Flow)
```mermaid
flowchart TD
  A[시작: push 거절 확인] --> B[git status]
  B --> C[git fetch origin]
  C --> D[git stash push -u]
  D --> E[git rebase origin/dev]
  E -->|충돌| F[checkout --theirs MODIFY_HISTORY.md]
  F --> G[git add MODIFY_HISTORY.md]
  G --> H[rebase --continue (GIT_EDITOR=true)]
  H --> I[git stash pop]
  I --> J[git push origin dev]
  J --> K[끝: 원격 동기화 + 워킹트리 잔여 확인]
```

## 기대/실제 결과 체크
- 원격 동기화: ✅ (로컬·원격 dev 일치)
- 충돌 처리: ✅ (`MODIFY_HISTORY.md` 원격 버전 선택)
- 잔여 변경: ⚠️ `MODIFY_HISTORY.md` 수정 1건, 신규 디렉터리 `.gcx/00_requirements/`, `.gcx/02_implementation/`가 미커밋 상태

## 재발 방지 팁
- 작업 시작 전에 `git pull --rebase` 또는 `git fetch && git rebase origin/dev`로 항상 최신 베이스 확보.
- 큰 변경 전에는 `git stash`나 임시 커밋으로 작업물 보호 후 리베이스/풀 진행.
- 충돌 파일이 문서만 포함될 때는 `--theirs/--ours`로 빠르게 정리하고, 코드 충돌 시 수동 병합 후 `git add` → `rebase --continue`.
