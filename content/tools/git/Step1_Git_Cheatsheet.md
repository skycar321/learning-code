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
