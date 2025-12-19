# GCX MSYS2 All-in-One Apply Report

Date: 2025-12-19 23:43:33
Project: C:\Users\Nam\Documents\Cursor\Workspace\origin\learning-code

## Combined Scripts
- Apply (PS): docs/msys2-setup/scripts/gcx_apply_all.ps1
- Revert (PS): docs/msys2-setup/scripts/gcx_revert_all.ps1
- Apply (Bash): docs/msys2-setup/scripts/gcx_apply_all.sh
- Revert (Bash): docs/msys2-setup/scripts/gcx_revert_all.sh
- MSYS2 optimize: docs/msys2-setup/scripts/gcx_msys2_optimize.sh
- MSYS2 revert: docs/msys2-setup/scripts/gcx_msys2_optimize_revert.sh

## Windows -> MSYS2 Env Sync
- Inventory file: .gcx\state\windows_env_inventory.json
- All vars list: .gcx\state\windows_env_all_vars.txt
- Allowlist file: C:\Users\Nam\Documents\Cursor\Workspace\origin\learning-code\.gcx\\state\dev_env_allowlist.txt
- Total Windows env vars: 110
- Selected dev vars found: 
- Recommended-but-missing vars: 53

## MSYS2 Zsh Env File
- Env file exists: True (C:\msys64\home\Nam\.zshrc.d\windows_env.sh)
- .zshrc has source block: False (C:\msys64\home\Nam\.zshrc)

## MSYS2 Backups
- Latest backup: C:\Users\Nam\Documents\Cursor\Workspace\origin\learning-code\.gcx\state\msys2_backups\backup_20251219_234253

## Tests (zsh)
GCX_WINDOWS_ENV_SYNC= PATH_HAS_WIN=1

## Notes / Issues
- fix_default_shell.sh output showed /etc/passwd missing during run.
- diagnose_terminal.sh encountered a syntax error around line 86 (script encoding issue).

## How to Revert
- Run: docs/msys2-setup/scripts/gcx_revert_all.ps1
  or: docs/msys2-setup/scripts/gcx_revert_all.sh

