export NO_COLOR=1
PROMPT="Say 'Hello' in Korean and explain it briefly in Korean."

# Method 1: Stdin to Codex (Bash)
echo "--- Method 1: Stdin ---" > .gcx/test_output_1.md
echo "$PROMPT" | codex exec -m "gpt-5.1-codex-mini" >> .gcx/test_output_1.md 2>&1

# Method 2: PowerShell Stdin + Encoding
echo "--- Method 2: PS Stdin ---" > .gcx/test_output_2.md
powershell.exe -Command "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; echo \"$PROMPT\" | codex exec -m 'gpt-5.1-codex-mini' | Out-File -Encoding UTF8 .gcx/test_output_2.md"
