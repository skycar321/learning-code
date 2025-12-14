# Git CLI 학습 로드맵 (웹 뷰 친화형)

*폴더*: `content/tools/git_cli/` — 각 Step은 바로 클릭해 웹에서 읽을 수 있는 마크다운으로 제공됩니다.  
*대상*: 처음 Git을 접하는 사람 → 협업/실무 문제 해결까지 단계별 완주를 목표로 합니다.

## 진행 순서 & 링크
1. **기본 개념·설치** — [Step1_GitBasicsAndInstallation.md](Step1_GitBasicsAndInstallation.md)  
   - Git이 왜 필요한지, 초기 설정과 첫 커밋까지 “Hello Git” 워크플로우.
2. **브랜치 & 병합** — [Step2_BranchingAndMerging.md](Step2_BranchingAndMerging.md)  
   - 브랜치 생성/이동/삭제, fast-forward/3-way merge, 충돌 해결, rebase vs merge 비교.
3. **원격 저장소** — [Step3_RemoteRepositories.md](Step3_RemoteRepositories.md)  
   - remote 추가/변경/삭제, fetch·pull·push 차이, Fork & PR 개념.
4. **고급 & 트러블슈팅** — [Step4_AdvancedGitAndTroubleshooting.md](Step4_AdvancedGitAndTroubleshooting.md)  
   - revert/reset/cherry-pick, stash 심화(부분 스테이징 포함), 로그 검색, hooks, .gitignore 패턴.
5. **실무 시나리오 모음** — [Step5_Git_Practical_Scenarios.md](Step5_Git_Practical_Scenarios.md)  
   - push 거절, 충돌 처리, 대규모 리팩터링, 히스토리 정리 등 문제 상황별 처방전.

## 추천 학습 흐름
- **입문(1→3)**: 로컬 기본 → 브랜치 → 원격 협업까지 익힌 뒤,
- **실무(4→5)**: 문제 복구/스태시/부분 커밋, 그리고 자주 겪는 트러블을 케이스별로 연습.

## 사용 팁
- 각 Step의 코드 블록은 그대로 복사·실행 가능하도록 순서를 적었습니다.
- 데모용 리포지토리는 스크립트 끝에서 자동 정리되지만, 필요 시 `rm -rf` 부분을 주석 처리해 결과물을 남겨둘 수 있습니다.
- IDE 사용자라면 Step4의 “IDE 팁”과 Step5의 “GUI/CLI 비교”를 참고하세요.

## 업데이트 이력 (요약)
- 2025-12-15: Step1~4 마크다운 추가, 스태시·부분커밋 가이드 통합, 학습 로드맵 링크화, Step5 사용자 친화 리팩터링.
