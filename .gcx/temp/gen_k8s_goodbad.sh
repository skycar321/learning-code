export NO_COLOR=1
PROMPT="You are a Senior DevOps Engineer.
Create a 'Good vs Bad' comparison YAML file named 'Step6_ResourceManagement_GoodBad.yaml'.

**Topic**: Kubernetes Resource Management & Probes.

**Requirements**:
1. **Output Language**: ENGLISH ONLY (Comments).
2. **Structure**:
   - YAML Separator `---
`. 
   - **Bad Deployment**: No resources, no probes, privileged security context, using 'latest' tag.
   - **Good Deployment**: Defined requests/limits (Guaranteed QoS), Liveness/Readiness probes, non-root user, fixed tag.
   - Detailed comments explaining the difference.
3. **Format**: Single YAML file with multiple documents.

**Reasoning Level**: High.

Generate the FULL YAML code to stdout."

codex exec -m "gpt-5.1-codex-max" "$PROMPT" > .gcx/k8s_goodbad_raw.yaml
