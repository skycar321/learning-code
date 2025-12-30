#!/bin/bash

# Mock script to simulate 'java -jar spring-batch-app.jar'
# Usage: ./mock_java_runner.sh --job.name=jobName date=YYYYMMDD

echo "[JAVA-MOCK] Starting Java Virtual Machine..."
echo "[JAVA-MOCK] Arguments: $@"

JOB_NAME=""

# Parse arguments roughly
for arg in "$@"
do
    if [[ $arg == --job.name* ]]; then
        JOB_NAME="${arg#*=}"
    fi
done

echo "[SPRING-BATCH] Launching Job: $JOB_NAME"
sleep 3 # Simulate work

if [ "$JOB_NAME" == "apiCallJob" ]; then
    echo "[SPRING-BATCH] Executing API Calls..."
    echo "[SPRING-BATCH] 200 OK from External API"
elif [ "$JOB_NAME" == "uiAggregationJob" ]; then
    echo "[SPRING-BATCH] Aggregating Data for UI..."
    echo "[SPRING-BATCH] Dataset created successfully."
else
    echo "[SPRING-BATCH] Unknown Job Name: $JOB_NAME"
fi

echo "[SPRING-BATCH] Job Completed Successfully."
exit 0
