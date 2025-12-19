export NO_COLOR=1
# Read the inventory file
INVENTORY=$(cat .gcx/file_inventory.txt)

# Prompt for Claude
PROMPT="You are the Lead Curriculum Architect for the 'learning-code' project.
I need you to analyze the existing file structure and identify critical content gaps based on the user's request for 'Advanced Topics', 'Good vs Bad Examples', and 'Troubleshooting'.

Here is the file inventory of the current repository:
$INVENTORY

**Your Task:**
1. **Analyze Progression**: Check if each major technology (Databases, DevOps, Frameworks, Languages, Tools) has a clear path from Beginner to Advanced.
2. **Identify Gaps**:
   - Which topics are missing 'Advanced' sections?
   - Which topics are missing 'Good vs Bad' code examples? (Most seem to be missing this explicit distinction).
   - Which topics lack a dedicated 'Troubleshooting' guide?
3. **Generate Action Plan**:
   - List the Top 10 'Advanced' topics that need to be created immediately.
   - List the Top 10 'Troubleshooting' guides (Top 50-100 errors style) to be created.
   - List the Top 10 'Good vs Bad' comparative documents to be created.

**Output Format**: Markdown. Use headers. Be specific with filenames."

# Execute Claude
claude -p "$PROMPT" --model sonnet > .gcx/01_planning/gap_analysis.md