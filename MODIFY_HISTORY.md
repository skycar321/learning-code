# 코드 수정 이력

## [2025-11-29 14:51:51 KST] Git Ignore 패턴 추가 - 개발 도구 디렉토리

**Type**: 설정변경

**Affected Files**:
- `.gitignore`

**Changes**:
- `.claude/` 디렉토리를 gitignore에 추가 (Claude Code 개인 설정)
- `mcp_*/` 패턴을 gitignore에 추가 (MCP 관련 디렉토리 전체)

**Reason**:
- `.claude/` 디렉토리는 개인별 개발 환경 설정으로 버전 관리 대상이 아님
- `mcp_shrimp_task_manager/` 등 MCP 관련 디렉토리는 로컬 도구 설정으로 프로젝트 레포지토리에 포함할 필요가 없음
- Untracked files 목록을 정리하여 Git 상태를 깔끔하게 유지

**AI Collaborator**:
- 없음 (Claude 단독 작업)

**Related Issue/Request**:
사용자 요청: "불필요한 파일들을 git ignore 에 등록해줘"

---
