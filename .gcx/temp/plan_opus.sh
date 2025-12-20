export NO_COLOR=1
PROMPT="You are the Lead Curriculum Architect (Model: Opus).
We have successfully created Top 50 Troubleshooting guides for Kubernetes, Spring Boot, and React.

Now we need to create **'Good vs Bad' Code Examples** to deepen the learning experience.
Please analyze the following technologies and propose 3 specific 'Good vs Bad' file topics for each:

1. **Spring Boot**: Focus on Architecture, DI, and Exception Handling.
2. **React**: Focus on Hooks (useEffect), Props Drilling, and Rendering Optimization.
3. **Kubernetes**: Focus on Deployment YAMLs (Resources, Probes, Security).

**Output Format**: Markdown list with filenames and brief description of what the 'Good' and 'Bad' examples will show.
**Language**: English (for encoding safety)."

# Invoking Claude Opus
claude -p "$PROMPT" --model opus > .gcx/01_planning/good_vs_bad_plan.md
