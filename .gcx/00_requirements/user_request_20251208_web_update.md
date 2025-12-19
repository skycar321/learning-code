# User Request
**Date**: 2025-12-08
**Requester**: User
**Project**: Learning Platform (Web)

## Original Request
"'c:/Users/Nam/Documents/Cursor/Workspace/origin/learning-code/content/process/SoftwareDevelopmentLifecycle.md' 이쪽은 웹에서 안보여져서 웹에 보이도록 추가가 필요해 ."
"그외에도 디자인 개선을 진행해줘. extension으로 nanobanana를 추가했는데 활용할수있으면 활용해서 진행해줘 ."
"전체 진행간에 GCX프로토콜을 CLAUDE는 제외하고 진행해줘 ."

## Requirements
1.  **Content Visibility**: Make `content/process/SoftwareDevelopmentLifecycle.md` visible on the web platform.
    - Current logic likely only scans `content/frameworks`, `content/languages` etc.
    - Need to update parsing logic to include `content/process`.
2.  **Design Improvement**: Enhance the UI/UX of the web platform.
    - Use `nanobanana` (Image Generation) if applicable (e.g., generate thumbnails for categories or process steps).
    - Improve layout, typography, or color scheme.
3.  **Protocol**: Modified GCX (Gemini -> Codex -> Gemini). Skip Claude.

## Execution Plan
1.  **Analyze**: Check `web/scripts/generateLearningData.ts` and `web/lib/parsers/parseMarkdown.ts` to see how content is loaded.
2.  **Implement**:
    - Update script to scan `content/process`.
    - Update frontend components to render this new "Process" category.
    - Use `nanobanana` to generate a hero image or icons for the "Software Development Lifecycle" guide.
3.  **Verify**: Ensure the new content appears and looks good.
