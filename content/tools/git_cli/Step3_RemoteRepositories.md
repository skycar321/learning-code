# Step3: 원격 저장소

## 목표
- 원격(remote)의 개념을 이해하고 추가/변경/삭제 명령을 익힙니다.
- fetch·pull·push 차이를 실습하고, Fork & PR 워크플로우 개념을 정리합니다.

## 0. 실습 리포지토리 초기화
```bash
mkdir git_remote_project && cd git_remote_project
git init
git config user.name  "Remote Learner"
git config user.email "remote.learner@example.com"
echo "Initial content for remote" > remote_file.txt
git add remote_file.txt && git commit -m "feat: Initial commit for remote"
git branch -M main
```

## 1. 원격 저장소 개념
- 네트워크를 통해 접근하는 Git 저장소 (GitHub, GitLab, Bitbucket 등).
- 코드 공유, 협업, 백업 목적에 필수.

## 2. 원격 추가/조회/변경/삭제
```bash
git remote add origin https://github.com/your-username/your-repo.git  # 추가
git remote -v                                                          # 조회
git remote set-url origin <new-url>                                    # URL 변경
git remote rename origin upstream                                      # 이름 변경 (예시)
git remote remove origin                                               # 삭제 (예시)
```

> `origin`은 관례적 기본 이름일 뿐, 의미에 맞게 변경 가능.

## 3. 동기화 명령어
- **fetch**: 원격 변경 이력만 가져옴, 워킹트리/스테이징은 그대로.
  ```bash
  git fetch origin
  ```
- **pull**: `fetch + merge`(기본) 또는 `fetch + rebase`(`--rebase`).
  ```bash
  git pull origin main
  ```
- **push**: 로컬 커밋을 원격 브랜치로 전송.
  ```bash
  git push origin main
  # 이미 원격이 앞서 있으면 pull 후 push. --force는 공동 브랜치에서 지양.
  ```

## 4. Fork & Pull Request 워크플로우 (개념)
- **Fork**: 다른 사람의 공개 리포를 내 계정에 복사해 독립적으로 작업.
- **PR**: 내 포크/브랜치에서 만든 변경을 원본 리포에 병합해 달라고 요청.
- 리뷰·CI를 거쳐 승인되면 원본에 병합된다.

## 5. 정리
```bash
cd ..
rm -rf git_remote_project
```
