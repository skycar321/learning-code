export NO_COLOR=1
PROMPT="You are a Senior React Developer.
Create a 'Good vs Bad' code comparison file named 'Step11_UseEffect_GoodBad.jsx'.

**Topic**: useEffect Anti-Patterns (Infinite Loop, Stale Closure, Memory Leak).

**Requirements**:
1. **Output Language**: ENGLISH ONLY (Code comments and explanations).
2. **Structure**:
   - Component `BadUseEffect`: Shows infinite loop (setting state in effect without proper deps), missing cleanup.
   - Component `GoodUseEffect`: Shows correct dependency array, cleanup function, and AbortController usage.
   - Comments explaining WHY it causes bugs or performance issues.
3. **Format**: Single JSX file exporting multiple components.

**Reasoning Level**: High.

Generate the FULL JSX code to stdout."

codex exec -m "gpt-5.1-codex-max" "$PROMPT" > .gcx/react_goodbad_raw.jsx
