#!/bin/bash
export NO_COLOR=1
echo "Starting Claude Planning Phase..."
claude --model claude-3-haiku-20240307 --print "Role: Architect. Task: Define User Stories and minimal Architecture for a Python Factorial Calculator. Output: JSON format only with keys 'user_stories' and 'architecture'." > .gcx/01_planning/claude_plan.json
echo "Claude Planning Complete."