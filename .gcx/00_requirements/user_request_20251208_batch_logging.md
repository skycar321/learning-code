# User Request
**Date**: 2025-12-08
**Requester**: User
**Topic**: Logging for Batch Jobs & ETL Tools (Spring Batch, StreamSets)

## Original Request
"스케줄에 의해 사용되는 스프링배치나 스트림셋 의 경우에도 로그 남길수가있을까?"

## Core Questions
1.  **Spring Batch**: How to log access/execution details for scheduled jobs? (User context is usually `SYSTEM` or `SCHEDULER`).
2.  **StreamSets (ETL)**: How to secure/log pipeline executions?
3.  **Consistency**: Does the "Access Log" requirement apply to background jobs? (Yes, if they touch PII).

## Constraints
- Consult **ONLY** with Codex (gpt-5.1-codex-max, extra_high reasoning).
- Focus on **"What Developer needs to do"**.

## Execution Plan
1.  **Spring Batch Logging**:
    - JobExecutionListener / StepExecutionListener.
    - Logging "Who" triggered it (if manual) or "System" (if scheduled).
    - Logging "What" data was processed (summary, not PII).
2.  **StreamSets Logging**:
    - Audit logs within StreamSets Data Collector (SDC).
    - Pipeline events (Start/Stop/Error).
