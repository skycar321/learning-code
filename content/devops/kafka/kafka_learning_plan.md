# Apache Kafka Learning Plan

Apache Kafka는 고성능 데이터 파이프라인, 스트리밍 분석, 데이터 통합 및 미션 크리티컬 애플리케이션을 위한 분산 이벤트 스트리밍 플랫폼입니다. 이 학습 계획은 Kafka의 내부 구조부터 운영 모범 사례까지 심도 있게 다룹니다.

## 🎯 학습 목표
- Kafka의 로그 기반 아키텍처와 Zero-copy 메커니즘 이해
- 신뢰성 있는 데이터 전송을 위한 Producer/Consumer 튜닝 (`acks`, `retries` 등)
- Consumer Group의 동작 원리와 리밸런싱 대응
- 프로덕션 레벨의 토픽 설계 및 운영 노하우 습득

## 📚 커리큘럼

### [Step 1] 핵심 아키텍처와 원리 (Core Concepts)
- **파일명**: `Step1_CoreConcepts_Architecture.md`
- **내용**:
    - Event Streaming이란?
    - Broker, Topic, Partition, Segment, Offset의 관계
    - Kafka가 빠른 이유 (Sequential I/O, Zero-copy, Page Cache)
    - **[심화]** Replication Protocol과 ISR (In-Sync Replicas)

### [Step 2] 환경 구성 (Setup & CLI)
- **파일명**: `Step2_EnvironmentSetup.md` / `docker-compose.yaml`
- **내용**:
    - KRaft 모드(ZooKeeper-less) 기반 클러스터 구축
    - Kafka CLI 도구 마스터하기 (`kafka-topics`, `kafka-console-producer` 등)
    - **[Good vs Bad]** 로컬 개발 환경 vs 프로덕션 배포 설정 비교

### [Step 3] Producer: 신뢰성 있는 데이터 전송
- **파일명**: `Step3_Producer_Reliability.md`
- **내용**:
    - Message Delivery Semantics (At-most, At-least, Exactly-once)
    - 주요 파라미터: `acks`, `retries`, `batch.size`, `linger.ms`, `enable.idempotence`
    - **[Good vs Bad]** Fire-and-forget vs Async Callback vs Sync Send

### [Step 4] Consumer: 확장성과 그룹 관리
- **파일명**: `Step4_Consumer_Scalability.md`
- **내용**:
    - Consumer Group과 Partition Assignment Strategy
    - Offset Commit 전략 (Auto vs Manual)
    - Rebalancing 이슈와 Static Membership
    - **[Good vs Bad]** Blocking I/O 처리에 따른 리밸런싱 폭풍 방지

### [Step 5] 토픽 설계와 운영 최적화
- **파일명**: `Step5_Topic_Configuration_Optimization.md`
- **내용**:
    - Partition 개수 산정 공식
    - Log Retention Policy (Delete vs Compact)
    - OS 튜닝 포인트 (File Descriptors, Socket Buffers)
    - **[Good vs Bad]** "More Partitions"의 함정

---

## 💡 권장 학습 방법
1. **이론 선행**: Kafka는 아키텍처를 모르면 설정값을 제대로 튜닝할 수 없습니다. Step 1을 정독하세요.
2. **실습 병행**: 제공된 `docker-compose.yaml`을 사용해 로컬에 클러스터를 띄우고 CLI로 직접 메시지를 주고받아 보세요.
3. **코드 분석**: Good vs Bad 예제를 통해 왜 특정 패턴이 안티패턴인지 이해하는 것이 중요합니다.
