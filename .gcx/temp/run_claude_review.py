import subprocess
import sys

def run_review():
    try:
        with open('.gcx/prompt_review_rust.txt', 'r', encoding='utf-8') as f:
            prompt = f.read()
            
        with open('platform/src/main.rs', 'r', encoding='utf-8') as f:
            code = f.read()
            
        full_prompt = f"{prompt}\n\n**Code**:\n```rust\n{code}\n```"
        
        # Use shell=True for Windows
        process = subprocess.Popen(
            f'claude -p "{full_prompt}" --model sonnet',
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            shell=True, # Critical for Windows
            text=True,
            encoding='utf-8' # Force encoding
        )
        
        stdout, stderr = process.communicate()
        
        if stdout:
            with open('.gcx/review_rust_backend.json', 'w', encoding='utf-8') as f:
                f.write(stdout)
            print("Review saved.")
        else:
            print("No output.")
            print("Stderr:", stderr)

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    run_review()