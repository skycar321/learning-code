export NO_COLOR=1
PROMPT="Update the provided HTML to include Mermaid.js support.
1. Add Mermaid.js CDN (ESM) version 10.x.
2. Add initialization script that runs `mermaid.run()` on load.
3. Ensure it works with the existing dark mode logic (initialize with correct theme).
4. Output the FULL HTML code in English ONLY.

Input HTML is standard Tailwind layout. Just show where to add mermaid scripts in <head> or <body>."

codex exec -m "gpt-5.1-codex-max" "$PROMPT" > .gcx/mermaid_impl.md
