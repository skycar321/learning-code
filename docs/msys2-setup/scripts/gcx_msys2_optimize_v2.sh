#!/usr/bin/env bash
set -euo pipefail

# GCX MSYS2 optimization orchestrator (non-WSL) - v2
# - Backs up key files to .gcx/state/msys2_backups
# - Applies MSYS2 fixes + VS Code drag-drop path fix
# - Optional installs only when missing

ROOT=""
find_root() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/.claude/settings.json" ]]; then
      ROOT="$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

is_wsl() {
  if [[ -n "${WSL_DISTRO_NAME-}" || -n "${WSL_INTEROP-}" ]]; then
    return 0
  fi
  if [[ -r /proc/version ]] && grep -qi microsoft /proc/version 2>/dev/null; then
    return 0
  fi
  return 1
}

if is_wsl; then
  echo "ERROR: Detected WSL. Run this script from MSYS2 (UCRT64), not WSL."
  echo "Tip: In MSYS2, Windows drives are mounted as /c/..., not /mnt/c/..."
  exit 1
fi

if ! find_root; then
  echo "Could not find repo root (missing .claude/settings.json)."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_BASE="$ROOT/.gcx/state/msys2_backups"
TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="$BACKUP_BASE/backup_$TS"
mkdir -p "$BACKUP_DIR"

MANIFEST="$BACKUP_DIR/backup_manifest.txt"
touch "$MANIFEST"

backup_file() {
  local src="$1"
  if [[ -f "$src" ]]; then
    cp -f "$src" "$BACKUP_DIR/$(basename "$src")"
    echo "$src" >> "$MANIFEST"
  fi
}

log() { echo "[GCX] $*"; }

run_script() {
  local path="$1"
  if [[ -f "$path" ]]; then
    log "Running: $(basename "$path")"
    bash "$path" </dev/null || true
  else
    log "Skip (missing): $path"
  fi
}

fix_vscode_dragdrop() {
  if [[ "${GCX_FIX_VSCODE_DROP:-1}" != "1" ]]; then
    log "Skip VS Code drag-drop fix (GCX_FIX_VSCODE_DROP=0)"
    return 0
  fi

  local py=""
  if command -v python >/dev/null 2>&1; then
    py="python"
  elif command -v python3 >/dev/null 2>&1; then
    py="python3"
  else
    log "python not found; skip VS Code drag-drop fix"
    return 0
  fi

  local win_user="${USERNAME:-${USER:-}}"
  if [[ -z "$win_user" ]]; then
    log "Could not determine Windows username; skip VS Code drag-drop fix"
    return 0
  fi

  local code_settings="/c/Users/$win_user/AppData/Roaming/Code/User/settings.json"
  local cursor_settings="/c/Users/$win_user/AppData/Roaming/Cursor/User/settings.json"

  local targets=()
  [[ -f "$code_settings" ]] && targets+=("$code_settings")
  [[ -f "$cursor_settings" ]] && targets+=("$cursor_settings")

  if [[ ${#targets[@]} -eq 0 ]]; then
    log "No VS Code/Cursor settings.json found; skip VS Code drag-drop fix"
    return 0
  fi

  for f in "${targets[@]}"; do
    local tag="settings"
    [[ "$f" == *"/Code/"* ]] && tag="vscode"
    [[ "$f" == *"/Cursor/"* ]] && tag="cursor"
    cp -f "$f" "$BACKUP_DIR/${tag}_settings.json.bak"
    log "Backup: $BACKUP_DIR/${tag}_settings.json.bak"

    "$py" - "$f" <<'PY'
import sys, pathlib, re

path = pathlib.Path(sys.argv[1])
text = path.read_text(encoding="utf-8")

def find_object_bounds(s, start):
    depth = 0
    in_str = False
    esc = False
    for i in range(start, len(s)):
        ch = s[i]
        if in_str:
            if esc:
                esc = False
            elif ch == "\\":
                esc = True
            elif ch == '"':
                in_str = False
            continue
        if ch == '"':
            in_str = True
            continue
        if ch == '{':
            depth += 1
        elif ch == '}':
            depth -= 1
            if depth == 0:
                return (start, i + 1)
    return None

def ensure_env_wslenv(block):
    m = re.search(r'\n([ \t]*)"env"\s*:\s*{', block)
    if not m:
        prop_m = re.search(r'\n([ \t]*)"[^"]+"\s*:', block)
        prop_indent = prop_m.group(1) if prop_m else "  "
        env_indent = prop_indent
        inner_indent = prop_indent + "  "
        env_block = f'\n{env_indent}"env": {{\n{inner_indent}"WSLENV": ""\n{env_indent}}}'
        before = block[:-1]
        j = len(before) - 1
        while j >= 0 and before[j].isspace():
            j -= 1
        if j >= 0 and before[j] not in '{,':
            before = before[:j+1] + "," + before[j+1:]
        return before + env_block + block[-1], True

    env_indent = m.group(1)
    env_obj_start = m.end() - 1
    bounds = find_object_bounds(block, env_obj_start)
    if not bounds:
        return block, False
    es, ee = bounds
    env_block = block[es:ee]
    if '"WSLENV"' in env_block:
        return block, False

    inner_m = re.search(r'\n([ \t]*)"[^"]+"\s*:', env_block)
    inner_indent = inner_m.group(1) if inner_m else (env_indent + "  ")
    env_inner = env_block[1:-1]
    j = len(env_inner) - 1
    while j >= 0 and env_inner[j].isspace():
        j -= 1
    if j >= 0 and env_inner[j] not in '{,':
        insert = "," + f'\n{inner_indent}"WSLENV": ""\n{env_indent}'
    else:
        insert = f'\n{inner_indent}"WSLENV": ""\n{env_indent}'
    env_inner_new = env_inner + insert
    env_block_new = "{" + env_inner_new + "}"
    return block[:es] + env_block_new + block[ee:], True

def update_profile(s, name):
    idx = s.find(f'"{name}"')
    if idx == -1:
        return s, False, f"{name}: not found"
    m = re.search(r'"' + re.escape(name) + r'"\s*:\s*{', s[idx:])
    if not m:
        return s, False, f"{name}: malformed"
    obj_start = idx + m.end() - 1
    bounds = find_object_bounds(s, obj_start)
    if not bounds:
        return s, False, f"{name}: no matching brace"
    start, end = bounds
    block = s[start:end]
    new_block, changed = ensure_env_wslenv(block)
    if not changed:
        return s, False, f"{name}: unchanged"
    return s[:start] + new_block + s[end:], True, f"{name}: updated"

changed = False
notes = []
for profile in ("MSYS2 UCRT64", "MSYS2 MINGW64"):
    text, ch, note = update_profile(text, profile)
    notes.append(note)
    changed = changed or ch

if changed:
    path.write_text(text, encoding="utf-8")

print(" / ".join(notes))
PY

    "$py" - "$f" <<'PY'
import sys, pathlib, re

path = pathlib.Path(sys.argv[1])
text = path.read_text(encoding="utf-8")

def find_object_bounds(s, start):
    depth = 0
    in_str = False
    esc = False
    for i in range(start, len(s)):
        ch = s[i]
        if in_str:
            if esc:
                esc = False
            elif ch == "\\":
                esc = True
            elif ch == '"':
                in_str = False
            continue
        if ch == '"':
            in_str = True
            continue
        if ch == '{':
            depth += 1
        elif ch == '}':
            depth -= 1
            if depth == 0:
                return (start, i + 1)
    return None

def set_simple_key(s, key, value):
    pattern = re.compile(r'^(?!\s*//)([ \t]*)"' + re.escape(key) + r'"\s*:\s*([^,\n]+)(,?)', re.M)
    m = pattern.search(s)
    if m:
        indent = m.group(1)
        comma = m.group(3)
        new = f'{indent}"{key}": {value}{comma}'
        return s[:m.start()] + new + s[m.end():], True

    obj_start = s.find('{')
    if obj_start == -1:
        return s, False
    bounds = find_object_bounds(s, obj_start)
    if not bounds:
        return s, False
    start, end = bounds
    block = s[start:end]

    m2 = re.search(r'\n([ \t]*)"', block)
    indent = m2.group(1) if m2 else "  "

    before = block[:-1]
    j = len(before) - 1
    while j >= 0 and before[j].isspace():
        j -= 1
    if j >= 0 and before[j] not in '{,':
        before = before[:j+1] + "," + before[j+1:]

    insert = f'\n{indent}"{key}": {value}\n'
    block_new = before + insert + block[-1]
    return s[:start] + block_new + s[end:], True

changed = False
notes = []
for key, value in (
    ("terminal.integrated.scrollbar.visible", "true"),
    ("terminal.integrated.scrollbar.style", "\"native\""),
):
    text, ch = set_simple_key(text, key, value)
    notes.append(f"{key}: {'updated' if ch else 'unchanged'}")
    changed = changed or ch

if changed:
    path.write_text(text, encoding="utf-8")

print(" / ".join(notes))
PY
  done

  log "VS Code drag-drop fix done (restart VS Code/Cursor)"
}

log "Backup directory: $BACKUP_DIR"

# Backups (best-effort)
backup_file "/etc/passwd"
backup_file "$HOME/.bashrc"
backup_file "$HOME/.zshrc"
backup_file "$HOME/.zprofile"
backup_file "$HOME/.zshenv"

# Ensure /etc/passwd exists (needed by fix_default_shell_v2.sh)
if [[ ! -f /etc/passwd ]]; then
  if command -v mkpasswd >/dev/null 2>&1; then
    log "Creating /etc/passwd with mkpasswd"
    if mkpasswd -l -c > /etc/passwd 2>/dev/null; then
      log "/etc/passwd created"
    else
      log "Failed to write /etc/passwd (permissions)"
    fi
  else
    log "mkpasswd not found; /etc/passwd will remain missing"
  fi
fi

# Optional installs (only if missing)
if [[ "${GCX_INCLUDE_INSTALL:-0}" == "1" ]]; then
  if ! command -v zsh >/dev/null 2>&1; then
    run_script "$SCRIPT_DIR/1_msys2_auto_install.sh"
  fi
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    run_script "$SCRIPT_DIR/2_install_ohmyzsh.sh"
  fi
  if ! command -v node >/dev/null 2>&1; then
    run_script "$SCRIPT_DIR/install_nodejs_npm.sh"
  fi
fi

# Non-install optimizations
run_script "$SCRIPT_DIR/fix_default_shell_v2.sh"
run_script "$SCRIPT_DIR/fix_zsh_setup.sh"
run_script "$SCRIPT_DIR/fix_zshrc_error.sh"
run_script "$SCRIPT_DIR/fix_windows_terminal_path.sh"
run_script "$SCRIPT_DIR/fix_claude_gemini_wrappers.sh"
if [[ "${GCX_FIX_CODEX_WRAPPER:-1}" == "1" ]]; then
  run_script "$SCRIPT_DIR/fix_codex_wrapper.sh"
fi
run_script "$SCRIPT_DIR/check_node_path.sh"
run_script "$SCRIPT_DIR/diagnose_terminal.sh"

# VS Code drag-drop path fix (WSL mis-detection)
fix_vscode_dragdrop

log "Done."
log "Backup: $BACKUP_DIR"
