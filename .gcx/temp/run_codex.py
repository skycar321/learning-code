import subprocess
import sys
import os

def run_codex_safe(prompt, output_file, model="gpt-5.1-codex-max"):
    # Set environment variable to suppress color codes
    env = os.environ.copy()
    env["NO_COLOR"] = "1"

    print(f"Running Codex with model: {model}")
    print(f"Prompt: {prompt[:50]}...")
    
    try:
        # Construct command: echo "PROMPT" | codex exec -m MODEL
        # We pass prompt via stdin to avoid shell parsing issues
        process = subprocess.Popen(
            ["codex", "exec", "-m", model],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=env,
            shell=True # Required on Windows to find the codex command
        )
        
        # Send prompt to stdin (UTF-8 encoded)
        stdout_data, stderr_data = process.communicate(input=prompt.encode('utf-8'))
        
        # Decode stdout (Try UTF-8 first, then fallback)
        try:
            output_text = stdout_data.decode('utf-8')
        except UnicodeDecodeError:
            output_text = stdout_data.decode('cp949', errors='replace') # Fallback for Windows default

        # Write to file (Force UTF-8)
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(output_text)
            
        print(f"Successfully wrote output to {output_file}")
        
        # Print stderr if any (for debugging)
        if stderr_data:
            try:
                print("STDERR:", stderr_data.decode('utf-8', errors='replace'))
            except:
                print("STDERR: (Binary data)")

    except Exception as e:
        print(f"Error executing codex: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python run_codex.py <output_file> <prompt_string>")
        sys.exit(1)
        
    out_file = sys.argv[1]
    prompt_text = sys.argv[2]
    
    run_codex_safe(prompt_text, out_file)
