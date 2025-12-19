#!/bin/bash
export NO_COLOR=1
echo "Starting Codex Test Generation..."
codex -m gpt-5.1-codex-mini --reasoning medium -p "Context: $(cat .gcx/01_planning/claude_plan.json). Task: Generate a comprehensive 'tests/test_factorial.py' using 'unittest'. Include cases for valid input, negative input, and non-integer input. Output: Python code only." > .gcx/02_implementation/tests/codex_test_generation.md
echo "Codex Task Complete."
