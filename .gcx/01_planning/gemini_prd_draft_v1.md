# Kafka Content PRD (Learning Plan)

**Version**: 1.0
**Status**: Draft
**Author**: Gemini (Drafting for Claude Opus Review)

## 1. Project Overview
Create a comprehensive, deep-dive learning module for **Apache Kafka** within the `content/devops/kafka` directory. The focus is on backend engineers and DevOps professionals who need to understand not just the "how" but the "why" and "best practices."

## 2. Curriculum Structure (User Stories)

### Module 1: Core Concepts & Architecture
- **Story**: As a learner, I want to understand the log-structured design of Kafka so that I know why it's fast.
- **Content**: Topics, Partitions, Segments, Brokers, Zookeeper vs KRaft.
- **Good vs Bad**: 
  - *Bad*: Treating Kafka like a traditional message queue (RabbitMQ).
  - *Good*: Designing around events and log retention.

### Module 2: Installation & Operations
- **Story**: As a developer, I want to set up a local cluster using Docker Compose so I can practice.
- **Content**: `docker-compose.yml`, Kafka CLI tools (`kafka-topics`, `kafka-console-producer`).
- **Good vs Bad**:
  - *Bad*: Hardcoding listeners to `localhost` in production.
  - *Good*: Understanding `ADVERTISED_LISTENERS` and internal/external networks.

### Module 3: Producer API & Reliability
- **Story**: As a backend engineer, I want to send data safely without losing messages.
- **Content**: `acks` (0, 1, all), `retries`, `idempotence`, `batch.size`, `linger.ms`.
- **Good vs Bad**:
  - *Bad*: Sending messages synchronously in a loop (High latency).
  - *Good*: Asynchronous sending with callbacks and proper error handling.

### Module 4: Consumer API & Groups
- **Story**: As a backend engineer, I want to process messages in parallel and handle failures.
- **Content**: Consumer Groups, Rebalancing, Auto-commit vs Manual commit, Heartbeats.
- **Good vs Bad**:
  - *Bad*: Processing heavy logic inside the poll loop causing timeouts (Rebalance storm).
  - *Good*: Decoupling processing or tuning `max.poll.interval.ms`.

### Module 5: Topics & Partitions Design
- **Story**: As an architect, I want to determine the right number of partitions.
- **Content**: Ordering guarantees, parallelism limits, retention policies.
- **Good vs Bad**:
  - *Bad*: Creating 1000 partitions for a low-throughput topic.
  - *Good*: Sizing based on throughput and consumer count.

## 3. Technical Constraints
- **Format**: Markdown (`.md`) and Code (`.java`, `.yaml`, `.py`).
- **Language**: Explanations in Korean, Code in English.
- **Comparison Format**:
  ```java
  // ❌ Bad Practice
  // Explanation...
  code...

  // ✅ Good Practice
  // Explanation...
  code...
  ```

## 4. Success Metrics
- User understands `acks=all` vs `acks=1`.
- User can debug a "Consumer Group Rebalance" issue.
- User can configure a robust `producer.properties`.