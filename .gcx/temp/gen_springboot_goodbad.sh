export NO_COLOR=1
PROMPT="You are a Senior Java Spring Boot Developer.
Create a 'Good vs Bad' code comparison file named 'Step16_LayeredArchitecture_GoodBad.java'.

**Topic**: Layered Architecture vs Fat Controller Anti-Pattern.

**Requirements**:
1. **Output Language**: ENGLISH ONLY (Code comments and explanations).
2. **Structure**:
   - Class `BadController`: Shows business logic mixed in controller, direct DB calls, no DTOs.
   - Class `GoodController`: Shows clean API layer, delegating to Service.
   - Class `GoodService`: Shows business logic isolation.
   - Comments explaining WHY it is bad or good.
3. **Format**: Single Java file with multiple inner classes (static) for demonstration purposes.

**Reasoning Level**: High.

Generate the FULL Java code to stdout."

codex exec -m "gpt-5.1-codex-max" "$PROMPT" > .gcx/springboot_goodbad_raw.java
