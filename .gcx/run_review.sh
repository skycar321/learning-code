#!/bin/bash
export NO_COLOR=1
export TERM=dumb
codex exec -m gpt-5.1-codex-max "Audit factorial.py" > .gcx/review/codex_bash.md
claude --model haiku -p "Review .gcx/02_implementation/factorial.py. 간단한 한글 피드백." --add-dir .gcx > .gcx/review/claude_bash.md
