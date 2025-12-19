# User Request
**Date**: 2025-12-13
**Requester**: User
**Project**: learning-code (Kafka Content Addition)

## Original Request (Raw Text)
"gcx프로토콜 사용. 클로드코드는 opus모델사용. codex는 max 5.1 ehigh 사용 . 이프로젝트에 kafka도 학습내용에 추가하고싶어. 최대한 자세히 작성해줘다른것과 마찬가지로 좋은예 나쁜예도 같이 작성해줘"

## Clarified Requirements
1. **Target**: Add Apache Kafka to the `learning-code` repository.
2. **Structure**: Follow existing repository standards (Learning Plan `_learning_plan.md` + Detailed Steps).
3. **Content Depth**: "Maximum detail" (최대한 자세히) covering internals, usage, and operations.
4. **Key Feature**: Must include explicit "Good vs. Bad" (좋은 예 vs 나쁜 예) comparisons for code and configuration.
5. **Models**: 
   - Planning/Review: Claude 3 Opus
   - Technical/Audit: Codex Max 5.1 (Extra High)

## Functional Requirements
- **Directory**: `content/devops/kafka` (Proposed based on existing `devops` structure).
- **Core Topics**:
  - Introduction & Architecture (Brokers, Topics, Partitions, Replication).
  - Setup (Docker/KRaft).
  - Producers & Consumers (Semantics, Acks).
  - Internal Mechanics (Log Compaction, ISR).
  - Ecosystem (Connect, Streams).
- **Code Examples**: Real-world usage scenarios with "Bad Practice" vs "Good Practice" refactoring.

## Non-Functional Requirements
- **Language**: Korean (Overview/Comments), English (Code/Technical Terms).
- **Consistency**: Match the style of existing `airflow` or `postgresql` modules.

## Acceptance Criteria
- [ ] Directory `content/devops/kafka` created.
- [ ] `kafka_learning_plan.md` created with a comprehensive curriculum.
- [ ] At least 5 detailed step-files (Concepts, Setup, Basic API, Advanced Config, Tuning).
- [ ] Each step includes "Good vs Bad" examples.
- [ ] All artifacts verified by Claude Opus (Plan) and Codex Max 5.1 (Tech).
