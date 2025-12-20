export NO_COLOR=1
CONTEXT=$(cat .gcx/springboot_errors_context.txt)

PROMPT="You are a Senior Java Spring Boot Developer.
Create a Markdown content for 'Spring Boot Top 50 Troubleshooting Guide'.

**Context**:
$CONTEXT

**Requirements**:
1. **Output Language**: ENGLISH ONLY (To avoid encoding issues).
2. **Structure**: Categories (Startup, Config, Web, Data, Security).
3. **Content**:
   - Error Name
   - Symptoms
   - Root Cause
   - Solution (Code snippet or Config change)
4. **Volume**: Cover at least 30-40 common errors based on context and your knowledge.

**Reasoning Level**: High.

Generate the FULL Markdown content to stdout."

codex exec -m "gpt-5.1-codex-max" "$PROMPT"
