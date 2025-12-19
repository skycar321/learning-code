export NO_COLOR=1
# Test Script for Windows Encoding
# Goal: Verify if we can capture Korean output from Codex correctly.

PROMPT="Say 'Hello' in Korean (An-nyeong-ha-se-yo) and explain it briefly in Korean."

# Method 1: Direct Bash Redirection (Has failed before)
echo "--- Method 1: Bash Direct ---" > .gcx/test_encoding_1.md
codex exec -m "gpt-5.1-codex-mini" "$PROMPT" >> .gcx/test_encoding_1.md 2>&1

# Method 2: PowerShell with Encoding enforcement (Invoked via Bash)
echo "--- Method 2: PowerShell Wrap ---" > .gcx/test_encoding_2.md
powershell.exe -Command "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; codex exec -m 'gpt-5.1-codex-mini' '$PROMPT' | Out-File -Encoding UTF8 .gcx/test_encoding_2.md"
