export NO_COLOR=1
PROMPT="You are a Senior Next.js Developer.
Create a client component `components/AppSidebar.tsx`.

**Functionality**:
1. Fetch tree data from `http://localhost:3000/api/tree` on mount (useEffect).
2. Render a **Recursive Tree View** for Categories > Subcategories > Files.
3. Clicking a file should navigate to `/view/category/subcategory/filename`.
4. Use Tailwind CSS for styling (Sidebar style, fixed width on left).
5. Handle loading and error states.

**Data Schema**:
```ts
type FileMeta = { name: string; title: string; path: string; };
type SubCategory = { name: string; files: FileMeta[]; };
type Category = { name: string; subcategories: SubCategory[]; };
```

**Output Language**: ENGLISH ONLY.
Generate the FULL React code."

codex exec -m "gpt-5.1-codex-max" "$PROMPT" > platform/frontend/components/AppSidebar.tsx
