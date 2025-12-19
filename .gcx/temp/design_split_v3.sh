export NO_COLOR=1
PROMPT=$(cat .gcx/prompt_opus.txt)
claude -p "$PROMPT" --model sonnet > .gcx/01_planning/TRD_Platform_Split.md
