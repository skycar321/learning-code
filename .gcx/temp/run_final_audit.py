import subprocess
import os

def run_audit():
    # Read contexts
    with open('.gcx/project_structure.txt', 'r', encoding='utf-8') as f:
        struct = f.read()
    with open('platform/backend/src/main.rs', 'r', encoding='utf-8') as f:
        main_rs = f.read()
    with open('platform/frontend/components/AppSidebar.tsx', 'r', encoding='utf-8') as f:
        sidebar = f.read()

    # 1. Claude Audit
    prompt_claude = f"""You are the Lead Architect (Opus).
Review the completed 'Platform Split' project.

**Context**:
- Goal: Split Monolithic Rust -> Rust JSON API (BE) + Next.js (FE).
- Current Structure:
{struct}

**Code (Backend - main.rs)**:
```rust
{main_rs}
```

**Verify**:
1. Is the directory structure correct (backend vs frontend)?
2. Does the Rust code serve JSON API?
3. Are the endpoints consistent?

**Output**: Short Audit Report (English Only)."""

    print("Invoking Claude...")
    try:
        proc_c = subprocess.Popen(
            ["claude", "-p", prompt_claude, "--model", "sonnet"], # Sonnet for speed
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, encoding='utf-8'
        )
        out_c, err_c = proc_c.communicate()
        
        with open('.gcx/final_audit_claude.md', 'w', encoding='utf-8') as f:
            if out_c: f.write(out_c)
            else: f.write(f"Error: {err_c}")
    except Exception as e:
        print(f"Claude Failed: {e}")

    # 2. Codex Audit
    prompt_codex = f"""You are the Code Auditor.
Review the Frontend implementation.

**Code (Frontend Sidebar)**:
```tsx
{sidebar}
```

**Verify**:
1. Does it correctly fetch from the API?
2. Is the recursive rendering logic sound?
3. Are there any infinite loops or memory leaks?

**Output**: Short Bug Report (English Only)."""

    print("Invoking Codex...")
    try:
        # Use shell=True for Codex command resolution on Windows
        proc_x = subprocess.Popen(
            f'codex exec -m "gpt-5.1-codex-max" "{prompt_codex}"',
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True
        )
        out_x, err_x = proc_x.communicate()
        
        # Decode safely
        try:
            res_x = out_x.decode('utf-8')
        except:
            res_x = out_x.decode('cp949', errors='replace')

        with open('.gcx/final_audit_codex.md', 'w', encoding='utf-8') as f:
            f.write(res_x)
            
    except Exception as e:
        print(f"Codex Failed: {e}")

if __name__ == "__main__":
    run_audit()
