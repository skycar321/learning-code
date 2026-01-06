import sys
import time
import random

def process_data():
    print("[INFO] Starting Python Data Processing...")
    print("[INFO] Reading data from StreamSets output...")
    time.sleep(2)  # Simulate processing time
    
    # Simulate random failure (optional, currently commented out)
    # if random.choice([True, False]):
    #     print("[ERROR] Data corruption detected!")
    #     sys.exit(1)
        
    print("[INFO] 1st Phase Processing Complete.")
    print("[INFO] Data saved to /data/processed/phase1_output.csv")

if __name__ == "__main__":
    process_data()
