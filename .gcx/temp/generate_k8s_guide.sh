export NO_COLOR=1
CONTEXT=$(cat .gcx/k8s_errors_context.txt)

# Note: We escape backticks for the shell script string
PROMPT="You are a Senior DevOps Engineer. Create a file named 'content/devops/kubernetes/Troubleshooting_K8s_Top50.md'.

**Context**:
$CONTEXT

**Requirements**:
1. **Title**: 'Kubernetes Top 50 Troubleshooting Guide'
2. **Structure**: Group by Category (Pod, Node, Network, Storage, Security, Deployment).
3. **Content per Error**:
   - **Error Name** (e.g., CrashLoopBackOff)
   - **Symptoms**: What the user sees.
   - **Diagnosis**: Exact `kubectl` commands to run.
   - **Root Cause**: Why it happens.
   - **Solution**: Step-by-step fix.
   - **'Good vs Bad' Config**: Where applicable (e.g., showing a Bad LivenessProbe vs Good one).
4. **Tone**: Professional, Educational, 'No Fluff'.
5. **Language**: Korean (한국어) as per system default, but keep technical terms in English.

**Reasoning Level**: High (Please analyze deeply).

Generate the FULL Markdown content to stdout."

# Use 'codex exec'
codex exec -m "gpt-5.1-codex-max" "$PROMPT" > content/devops/kubernetes/Troubleshooting_K8s_Top50.md