# MSYS2 Zsh Windows Env Sync Report

Date: 2025-12-19 23:34:01
Project: C:\Users\Nam\Documents\Cursor\Workspace\origin\learning-code

## Inventory Summary
- Total Windows env vars: 110
- Selected dev vars found: 
- Recommended-but-missing vars: 53
- Inventory file: .gcx\state\windows_env_inventory.json
- All vars list: .gcx\state\windows_env_all_vars.txt
- Allowlist file: C:\Users\Nam\Documents\Cursor\Workspace\origin\learning-code\.gcx\\state\dev_env_allowlist.txt

## Apply Results
- Env file exists: True (C:\msys64\home\Nam\.zshrc.d\windows_env.sh)
- .zshrc has source block: True (C:\msys64\home\Nam\.zshrc)

## Tests (zsh)
- GCX_WINDOWS_ENV_SYNC=1 (marker)
- PATH contains /c/Windows: 1

## Selected Vars (first 30)
(none)

## Recommended (missing) Vars (first 30)
ANDROID_HOME
ANDROID_SDK_ROOT
ANTHROPIC_API_KEY
AWS_DEFAULT_PROFILE
AWS_DEFAULT_REGION
AWS_PROFILE
AWS_REGION
AZURE_CONFIG_DIR
CARGO_HOME
CI
CLAUDE_API_KEY
CODEX_API_KEY
CONDA_DEFAULT_ENV
CONDA_PREFIX
DOCKER_CERT_PATH
DOCKER_HOST
DOCKER_TLS_VERIFY
DOTNET_CLI_HOME
DOTNET_ROOT
GEMINI_API_KEY
GOBIN
GOOGLE_APPLICATION_CREDENTIALS
GOOGLE_CLOUD_PROJECT
GOPATH
GOPRIVATE
GOPROXY
GOROOT
GRADLE_HOME
JAVA_HOME
JDK_HOME

## Notes
- Add extra env var names into the allowlist file and re-run apply.
- Restart MSYS2 zsh sessions after apply.

