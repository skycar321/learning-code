export NO_COLOR=1
CODE=$(cat platform/src/main.rs)
PROMPT_BASE=$(cat .gcx/prompt_review_rust.txt)

FULL_PROMPT="$PROMPT_BASE

**Code to Review**:
```rust
$CODE
```"

claude -p "$FULL_PROMPT" --model opus > .gcx/review_rust_backend.json
