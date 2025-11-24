# Git CLI 학습 계획

## 개요 (Overview)
Git 명령줄 인터페이스(CLI)는 버전 관리 시스템인 Git을 효과적으로 사용하기 위한 핵심 도구입니다. 이 학습 계획은 Git CLI의 기본 개념부터 고급 사용법까지 실무에 필요한 지식을 습득하는 것을 목표로 합니다.

## 학습 목표 (Learning Objectives)
*   Git의 기본 작동 원리 이해
*   커맨드 라인을 통해 Git 리포지토리 생성 및 관리
*   브랜치(Branch), 병합(Merge), 리베이스(Rebase) 등 협업 기능 숙달
*   Git 문제 해결 및 고급 기능 활용 능력 향상

## 학습 내용 (Learning Content)

### 1단계: Git 기본 개념 및 설치 (Git Basics & Installation)
*   Git이란 무엇인가? (What is Git?) - 버전 관리의 중요성
*   Git 설치 및 초기 설정 (Installation & Initial Setup)
    *   `git config` 명령어 활용 (Using `git config`)
*   기본 워크플로우 (Basic Workflow)
    *   `git init`, `git clone` (레포지토리 초기화 및 복제)
    *   `git status` (작업 상태 확인)
    *   `git add` (스테이징 영역 추가)
    *   `git commit` (변경 사항 기록)
    *   `git log` (커밋 기록 확인)

### 2단계: 브랜치 및 병합 (Branching & Merging)
*   브랜치 개념 이해 (Understanding Branches)
*   브랜치 생성, 전환, 삭제 (Creating, Switching, Deleting Branches)
    *   `git branch`, `git checkout`, `git switch`
*   브랜치 병합 (Merging Branches)
    *   `git merge` (fast-forward, 3-way merge)
    *   병합 충돌 해결 (Resolving merge conflicts)
*   리베이스 (Rebasing)
    *   `git rebase` (커밋 히스토리 정리)
    *   리베이스 vs 병합 (Rebase vs Merge)

### 3단계: 원격 저장소 (Remote Repositories)
*   원격 저장소 개념 (Understanding Remote Repositories)
*   원격 저장소 추가/제거 (Adding/Removing Remotes)
    *   `git remote`
*   원격 저장소와 동기화 (Syncing with Remote)
    *   `git fetch`, `git pull`, `git push`
*   Fork와 Pull Request 워크플로우 (Fork & Pull Request Workflow)

### 4단계: Git 고급 기능 및 문제 해결 (Advanced Git & Troubleshooting)
*   커밋 되돌리기 (Undoing Changes)
    *   `git revert`, `git reset` (soft, mixed, hard)
*   특정 커밋 가져오기 (Cherry-picking)
    *   `git cherry-pick`
*   변경 사항 임시 저장 (Stashing)
    *   `git stash`
*   로그 기록 검색 (Searching History)
    *   `git log` 옵션 활용
*   Git 후크 (Git Hooks) - 자동화 스크립트
*   gitignore 파일 설정 (Configuring .gitignore)

## 예상 학습 시간 (Estimated Learning Time)
*   각 단계별 2-4시간 (총 8-16시간)

## 실습 과제 (Practical Exercises)
*   개인 프로젝트에 Git 적용 (Applying Git to personal projects)
*   동료와 협업하며 브랜치 전략 연습 (Practicing branching strategies with peers)
*   오픈소스 프로젝트에 기여 (Contributing to open-source projects)

## 참고 자료 (References)
*   Pro Git 책 (Pro Git Book) - 온라인 버전
*   Git 공식 문서 (Git Official Documentation)
*   각종 Git 튜토리얼 및 강의 (Various Git tutorials and courses)
