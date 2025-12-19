# Set code page to UTF-8
chcp.com 65001

# Run codex via Python wrapper (reusing the script, but environment is changed)
python .gcx/run_codex.py .gcx/test_output_chcp.md "Say 'Hello' in Korean and explain it briefly in Korean."
