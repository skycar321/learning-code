export NO_COLOR=1
PROMPT="Create a Next.js Page Component `app/view/[...slug]/page.tsx`.

**Functionality**:
1. Server Component (async).
2. Read `params.slug` and construct path string (join with '/').
3. Fetch `http://localhost:3000/api/content/{path}` (No-Cache).
4. Render the content.
   - If response contains `file_type: 'markdown'`, render using `react-markdown` (assume installed).
   - If `file_type: 'code'`, render in <pre><code>`.
5. Show Prev/Next navigation links if available.

**Output Language**: ENGLISH ONLY.
Generate the FULL TSX code."

codex exec -m "gpt-5.1-codex-max" "$PROMPT" > platform/frontend/app/view/[...slug]/page.tsx
