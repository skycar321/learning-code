# Kafka Content PRD (Final)

**Version**: 1.0
**Approved By**: Claude 3 Opus
**Status**: Finalized

## Directory Structure
`content/devops/kafka/`

## Content Plan

### 1. `kafka_learning_plan.md`
- Master roadmap document.
- Links to all steps.
- Prerequisite knowledge (Network, Docker).

### 2. `Step1_CoreConcepts_Architecture.md`
- **Topics**: Logs, Segments, Indexing (.index, .timeindex), Zero-copy.
- **Visuals**: Diagram descriptions of Broker/Topic/Partition hierarchy.
- **Why**: Understand hardware efficiency.

### 3. `Step2_EnvironmentSetup.yaml` (plus MD guide)
- **Topics**: KRaft mode setup (No Zookeeper), Docker Compose.
- **Tools**: Redpanda Console or AKHQ for UI visualization.
- **Good/Bad**: Usage of `latest` tags vs specific versions.

### 4. `Step3_Producer_Reliability.md` (with Java code snippets)
- **Topics**: Message delivery semantics (At-most-once, At-least-once, Exactly-once).
- **Config**: `enable.idempotence`, `transactional.id`.
- **Code**: 
  - Bad: `producer.send(record)` (Fire and forget).
  - Good: `producer.send(record, callback)` + Error handling.

### 5. `Step4_Consumer_Scalability.md` (with Java code snippets)
- **Topics**: Consumer Groups, Lag monitoring, Offset commit strategies.
- **Code**:
  - Bad: `enable.auto.commit=true` in critical financial transactions.
  - Good: Manual commit control with `commitSync` vs `commitAsync`.

### 6. `Step5_Topic_Configuration_Optimization.md`
- **Topics**: Retention policies (delete vs compact), Partition sizing.
- **Good/Bad**: Impact of too many partitions on recovery time.

### 7. `Step6_Security_And_Production_Checklist.md`
- **Topics**: SASL/SCRAM, mTLS overview, OS Tuning (ulimit, pagecache).

## Verification Strategy (Codex)
- Validate Docker Compose syntax.
- Verify Java code snippets compile (conceptually).
- Ensure configuration keys exist in Kafka 3.x.