# Step 1: Kafka 핵심 아키텍처와 원리 (Core Concepts & Architecture)

Kafka를 단순한 메시지 큐(Message Queue)로 이해하면 프로덕션 운영 중 발생하는 수많은 성능 이슈와 데이터 유실 사고를 막을 수 없습니다. Kafka는 **분산 커밋 로그(Distributed Commit Log)** 시스템입니다.

## 1. Kafka의 계층 구조 (The Hierarchy)

Kafka의 데이터 저장 구조는 물리적/논리적으로 명확한 계층을 가집니다.

### 1.1 Broker (Server)
- Kafka 프로세스가 실행되는 서버(노드)입니다.
- **Controller Broker**: 클러스터 멤버십 관리, 파티션 리더 선출 등을 담당합니다. (구버전은 ZooKeeper 의존, 최신버전은 KRaft 내부 합의 알고리즘 사용)

### 1.2 Topic (Logical Category)
- 데이터가 저장되는 논리적인 이름(폴더 개념)입니다. (예: `payment-events`, `user-logs`)
- DB의 `Table`과 유사합니다.

### 1.3 Partition (Scalability Unit)
- 하나의 Topic은 여러 개의 **Partition**으로 쪼개져 분산 저장됩니다.
- **병렬 처리(Parallelism)의 단위**입니다. 파티션이 3개면, 최대 3개의 Consumer가 동시에 붙어서 처리할 수 있습니다.
- **순서 보장(Ordering)**은 오직 **Partition 내부에서만** 유효합니다. (전체 Topic 기준 아님)

### 1.4 Segment (Physical File)
- Partition은 디스크에 하나의 거대한 파일로 저장되지 않습니다. 관리 용이성을 위해 **Segment**라는 단위로 잘려서 저장됩니다.
- `*.log`: 실제 메시지가 저장되는 데이터 파일
- `*.index`: 오프셋(Offset)을 물리적 바이트 위치로 매핑하는 인덱스
- `*.timeindex`: 타임스탬프를 오프셋으로 매핑하는 인덱스

---

## 2. Kafka가 빠른 이유 (Performance Secrets)

Kafka는 JVM 위에서 돌아가지만, C++ 애플리케이션에 버금가는 처리량을 보여줍니다. 그 비결은 3가지입니다.

### 2.1 Sequential I/O (순차 입출력)
- **설명**: 디스크(HDD/SSD)는 랜덤 액세스(Random Access)보다 순차 쓰기(Sequential Write)가 압도적으로 빠릅니다.
- **원리**: Kafka는 데이터를 수정하거나 삭제하지 않고, 오직 **끝에 추가(Append-only)**만 합니다. 이로 인해 디스크 헤드 이동(Seek time)을 최소화합니다.

### 2.2 Page Cache (OS 레벨 캐싱)
- **설명**: Kafka는 힙(Heap) 메모리에 데이터를 캐싱하지 않고, **OS의 페이지 캐시(Page Cache)**를 적극 활용합니다.
- **장점**: JVM GC(Garbage Collection) 오버헤드가 없으며, 프로세스가 재시작되어도 OS 캐시는 살아있어 웜업(Warm-up) 시간이 단축됩니다.

### 2.3 Zero-Copy
- **설명**: 데이터를 디스크에서 네트워크로 보낼 때, CPU를 거치지 않고 다이렉트로 전송합니다.
- **전통적 방식**: Disk -> OS Cache -> App Buffer -> Socket Buffer -> NIC (복사 4회, 컨텍스트 스위칭 4회)
- **Zero-Copy (sendfile)**: Disk -> OS Cache -> NIC (복사 2회, 컨텍스트 스위칭 2회)

---

## 3. 심화: Replication Protocol & ISR

데이터 유실 없는 시스템을 구축하려면 이 개념이 필수입니다.

### 3.1 Leader & Follower
- 모든 읽기/쓰기는 **Leader Partition**에서만 일어납니다. (Kafka 2.4+ 부터 Follower Fetching이 가능하지만 기본은 Leader)
- **Follower**는 Leader의 데이터를 끊임없이 복제(Fetch)해가는 수동적인 존재입니다.

### 3.2 ISR (In-Sync Replicas)
- Leader와 "동기화(Sync)가 잘 맞고 있는" 복제본들의 그룹입니다.
- **Leader**: ISR 목록을 관리합니다. Follower가 너무 느리거나 응답이 없으면 ISR에서 추방(Kick out)합니다.
- **High Watermark**: ISR의 모든 멤버가 복제를 완료한 오프셋 지점입니다. Consumer는 이 지점까지만 읽을 수 있습니다.

### 🔍 Good vs Bad Architecture

#### ❌ Bad Practice: 과도한 파티션 (Too Many Partitions)
```text
상황: 처리량을 높이겠다며 작은 토픽에도 파티션을 100개씩 생성함.
결과:
1. File Descriptor 고갈 (파티션당 파일 3개 오픈).
2. Broker 장애 시 Leader Election 시간 급증 (수천 개 파티션 리더 선출하느라 서비스 중단 길어짐).
3. 클라이언트 메모리 사용량 증가.
```

#### ✅ Good Practice: 적절한 파티션 산정
```text
공식: Max(Target Throughput / Producer Throughput, Target Throughput / Consumer Throughput)
전략: 작게 시작해서(예: 3~6개) 모니터링하며 늘려나간다. (줄이는 건 불가능하므로!)
```

---

## 4. 요약 (Summary)
1. Kafka는 **Append-only Log** 구조로 디스크의 **Sequential I/O** 성능을 극대화한다.
2. 데이터를 메모리에 복사하지 않고 **Zero-copy**를 통해 네트워크로 쏜다.
3. 데이터의 신뢰성은 **Replication**과 **ISR** 메커니즘으로 보장한다.
