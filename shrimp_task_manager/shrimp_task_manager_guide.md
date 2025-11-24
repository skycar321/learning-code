# MCP Shrimp Task Manager 사용 가이드

## 1. MCP Shrimp Task Manager 소개

MCP Shrimp Task Manager는 AI 기반 개발을 위한 지능형 작업 관리 도구입니다. 복잡한 프로젝트를 관리하기 쉬운 작업으로 분해하고, 여러 세션에 걸쳐 컨텍스트를 유지하며, 개발 워크플로우 속도를 높여줍니다.

**주요 특징**:
*   **지속적인 메모리 (Persistent Memory)**: 작업과 진행 상황이 세션 간에 유지됩니다.
*   **구조화된 워크플로우 (Structured Workflows)**: 계획, 실행, 검증을 위한 가이드 프로세스를 제공합니다.
*   **스마트한 작업 분해 (Smart Decomposition)**: 복잡한 작업을 관리 가능한 작은 하위 작업으로 자동 분해합니다.
*   **컨텍스트 보존 (Context Preservation)**: 토큰 제한에도 불구하고 컨텍스트를 잃지 않습니다.

**MCP (Model Context Protocol)란?**
MCP는 AI 에이전트(예: Claude Code)가 작업 관리자와 상호 작용하는 프로토콜입니다. Shrimp Task Manager는 이러한 MCP 서버 역할을 수행합니다.

## 2. 시작하기 (Quick Start)

### 2.1. 전제 조건 (Prerequisites)

*   **Node.js**: 버전 18 이상 (Node.js 공식 웹사이트에서 설치)
*   **npm 또는 yarn**: Node.js 설치 시 함께 설치됩니다.
*   **MCP 호환 AI 클라이언트**: Claude Code, Cline (VS Code 확장), Claude Desktop 등 (Shrimp Task Manager와 연동하여 사용).

### 2.2. 설치 (Installation)

#### 2.2.1. Claude Code 설치 (권장)

Shrimp Task Manager를 사용하려면 MCP 호환 AI 클라이언트가 필요합니다. 여기서는 Claude Code 설치 방법을 안내합니다.

**Windows 11 (WSL2 사용)**:
1.  **WSL2 설치**: PowerShell을 관리자 권한으로 실행하여 다음 명령어를 입력합니다.
    ```bash
    wsl --install
    ```
2.  **Ubuntu/WSL 환경 진입**:
    ```bash
    wsl -d Ubuntu
    ```
3.  **Claude Code 전역 설치**:
    ```bash
    npm install -g @anthropic-ai/claude-code
    ```
4.  **Claude Code 시작**:
    ```bash
    claude
    ```

**macOS/Linux**:
1.  **Claude Code 전역 설치**:
    ```bash
    npm install -g @anthropic-ai/claude-code
    ```
2.  **Claude Code 시작**:
    ```bash
    claude
    ```

#### 2.2.2. Shrimp Task Manager 설치

사용자님께서 이미 `c:/Users/Nam/Documents/Cursor/Workspace/origin/learning-code/mcp_shrimp_task_manager` 경로에 Git 저장소를 클론해 놓으셨습니다. 다음 단계들을 수행해주세요.

1.  **클론된 디렉토리로 이동**:
    ```bash
    cd c:/Users/Nam/Documents/Cursor/Workspace/origin/learning-code/mcp_shrimp_task_manager
    ```
2.  **의존성 설치**:
    ```bash
    npm install
    ```
3.  **프로젝트 빌드**:
    ```bash
    npm run build
    ```

### 2.3. Claude Code 구성 (.mcp.json 파일)

Shrimp Task Manager를 MCP 서버로 사용하도록 AI 클라이언트(Claude Code)를 구성해야 합니다. 프로젝트 디렉토리 (또는 Claude Code가 실행될 경로)에 `.mcp.json` 파일을 생성합니다.

**예시 `.mcp.json` 파일 내용**:

```json
{
  "mcpServers": {
    "shrimp-task-manager": {
      "command": "node",
      "args": ["/path/to/mcp-shrimp-task-manager/dist/index.js"],
      "env": {
        "DATA_DIR": "/path/to/your/shrimp_data", # Shrimp Task Manager의 데이터 저장 경로 (필수)
        "TEMPLATES_USE": "en",                   # 프롬프트 템플릿 언어 (en, ko 등)
        "ENABLE_GUI": "false"                    # 웹 GUI 활성화 여부
      }
    }
  }
}
```
**참고**: `args` 내의 `/path/to/mcp-shrimp-task-manager/dist/index.js`와 `DATA_DIR` 내의 `/path/to/your/shrimp_data`는 실제 클론한 프로젝트의 경로로 **반드시 변경**해야 합니다.

예시 경로:
```json
{
  "mcpServers": {
    "shrimp-task-manager": {
      "command": "node",
      "args": ["c:/Users/Nam/Documents/Cursor/Workspace/origin/learning-code/mcp_shrimp_task_manager/dist/index.js"],
      "env": {
        "DATA_DIR": "c:/Users/Nam/Documents/Cursor/Workspace/origin/learning-code/shrimp_data", # 실제 데이터 저장 경로
        "TEMPLATES_USE": "en",
        "ENABLE_GUI": "false"
      }
    }
  }
}
```

이후 다음 명령어로 Claude Code를 커스텀 MCP 설정과 함께 시작합니다:
```bash
claude --dangerously-skip-permissions --mcp-config .mcp.json
```

## 3. Shrimp Task Manager UI 활용

Shrimp Task Manager는 두 가지 형태의 UI를 제공합니다.

### 3.1. 🖥️ Task Viewer (추천)

시각적인 작업 관리를 위한 모던 React 인터페이스입니다. 드래그 앤 드롭, 실시간 검색, 다중 프로필 지원 등의 기능을 제공합니다. 메인 Shrimp Task Manager 프로젝트와는 별도의 서브 프로젝트입니다.

**설치 및 실행**:
1.  **Task Viewer 디렉토리로 이동**:
    ```bash
    cd c:/Users/Nam/Documents/Cursor/Workspace/origin/learning-code/mcp_shrimp_task_manager/tools/task-viewer
    ```
2.  **의존성 설치**:
    ```bash
    npm install
    ```
3.  **프로젝트 실행**:
    ```bash
    npm run start:all
    ```
4.  **접속**: 웹 브라우저에서 `http://localhost:5173`으로 접속합니다.

### 3.2. 🌐 Web GUI (선택 사항)

간단한 작업 개요를 위한 경량 웹 인터페이스입니다. 메인 Shrimp Task Manager 애플리케이션에 내장되어 있습니다.

**활성화**:
`.mcp.json` 파일에 지정된 `DATA_DIR` 경로에 `.env` 파일을 생성하거나, Claude Code 실행 시 `env` 변수를 통해 설정합니다.
```bash
# .env 파일 예시
ENABLE_GUI=true
WEB_PORT=3000 # 사용자 정의 웹 포트
```
`.mcp.json`의 `env` 섹션에서 `ENABLE_GUI`를 `true`로 설정하여 활성화할 수도 있습니다.

## 4. Shrimp Task Manager 사용법

Shrimp Task Manager의 핵심은 AI 클라이언트(예: Claude Code)를 통해 명령어를 전달하는 것입니다.

### 4.1. 기본 명령어 (AI 클라이언트에 입력)

| 명령어                      | 설명                                         |
| :-------------------------- | :------------------------------------------- |
| `init project rules`        | 프로젝트 표준 및 규칙을 초기화합니다.        |
| `plan task [설명]`          | 작업 계획을 생성합니다.                      |
| `execute task [id]`         | 특정 ID의 작업을 실행합니다.                 |
| `continuous mode`           | 모든 작업을 순차적으로 실행합니다.           |
| `list tasks`                | 모든 작업을 나열합니다.                      |
| `research [주제]`           | 연구 모드로 진입하여 특정 주제를 탐색합니다. |
| `reflect task [id]`         | 작업 내용을 검토하고 개선합니다.             |

### 4.2. 사용자들이 많이 사용하는 법 (Best Practices for Good Results)

Shrimp Task Manager를 효과적으로 사용하기 위한 팁입니다.

*   **명확하고 구체적인 프롬프트**: AI 에이전트에게 작업을 지시할 때, 목표와 요구 사항을 최대한 명확하고 구체적으로 작성해야 합니다.
    *   예시: "사용자 인증 기능을 JWT로 추가해줘" (O) vs "인증 기능 만들어줘" (X)
*   **`init project rules`로 프로젝트 표준 설정**: 프로젝트 초기에 코딩 표준, 아키텍처 가이드라인 등을 정의하여 AI 에이전트가 일관된 결과물을 생성하도록 유도합니다.
*   **`plan task`를 통한 신중한 계획**: 복잡한 작업은 바로 `execute`하기보다 `plan task`를 통해 AI 에이전트가 먼저 계획을 수립하고 하위 작업을 분해하도록 하는 것이 좋습니다. 계획을 검토하고 필요한 경우 수정하여 더 나은 실행을 유도할 수 있습니다.
*   **`continuous mode`는 신중하게 사용**: 전체 워크플로우를 자동화할 때 유용하지만, 중요한 변경 사항이 있을 수 있으므로 주기적으로 진행 상황을 확인하고 검토해야 합니다.
*   **`Task Viewer`를 통한 시각적 관리**: 제공되는 `Task Viewer` UI를 활용하여 작업의 진행 상황, 의존성, 하위 작업 등을 한눈에 파악하고 시각적으로 관리하는 것이 효율적입니다.
*   **`DATA_DIR` 설정 관리**: `.mcp.json` 파일의 `DATA_DIR`은 Shrimp Task Manager가 작업 이력, 계획 등을 저장하는 매우 중요한 경로입니다. 이 경로를 신중하게 설정하고 백업하는 것이 중요합니다.
*   **Git과의 연동**: Shrimp Task Manager는 개발 워크플로우를 보조하는 도구이므로, AI 에이전트가 생성하거나 수정한 코드는 반드시 Git을 통해 버전 관리하고 코드 리뷰 과정을 거쳐야 합니다.

## 5. 추가 자료 및 문서

*   **[전체 문서](c:/Users/Nam/Documents/Cursor/Workspace/origin/learning-code/mcp_shrimp_task_manager/docs/README.md)**
*   **[에이전트 관리](c:/Users/Nam/Documents/Cursor/Workspace/origin/learning-code/mcp_shrimp_task_manager/docs/agents.md)**
*   **[Prompt 커스터마이징](c:/Users/Nam/Documents/Cursor/Workspace/origin/learning-code/mcp_shrimp_task_manager/docs/en/prompt-customization.md)**
*   **[API 레퍼런스](c:/Users/Nam/Documents/Cursor/Workspace/origin/learning-code/mcp_shrimp_task_manager/docs/api.md)**
*   **[Task Viewer 문서](c:/Users/Nam/Documents/Cursor/Workspace/origin/learning-code/mcp_shrimp_task_manager/tools/task-viewer/README.md)**

이 가이드를 통해 MCP Shrimp Task Manager를 효과적으로 활용하시어 AI 기반 개발 워크플로우를 한층 더 효율적으로 만드시길 바랍니다!
