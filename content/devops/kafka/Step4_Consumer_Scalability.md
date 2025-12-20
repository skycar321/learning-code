# Step 4: Consumer - 그룹 관리와 성능 (Scalability)

Consumer의 핵심은 **Consumer Group**을 통한 병렬 처리와 **Offset Management**입니다.

## 1. Consumer Group & Rebalancing

- **Consumer Group**: 하나의 토픽을 여러 컨슈머가 나눠서 처리하기 위한 논리적 그룹입니다. `group.id`로 식별합니다.
- **Partition Assignment**: 파티션은 그룹 내의 컨슈머에게 1:1 또는 N:1로 할당됩니다. **컨슈머가 파티션보다 많으면, 남는 컨슈머는 놉니다(Idle).**
- **Rebalancing**: 컨슈머가 죽거나 새로 들어오면 파티션 소유권을 다시 분배하는 과정입니다. 리밸런싱 중에는 메시지 처리가 일시 중단됩니다(Stop-the-world).

---

## 2. Code: Good vs Bad Examples (Java)

### ❌ Bad Practice: 과도한 처리 & 자동 커밋

```java
Properties props = new Properties();
props.put("group.id", "payment-group");
props.put("enable.auto.commit", "true"); // 기본값 사용
props.put("auto.commit.interval.ms", "1000");

Consumer<String, String> consumer = new KafkaConsumer<>(props);
consumer.subscribe(Collections.singletonList("payment-topic"));

while (true) {
    // 1. Poll을 해옴
    ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));
    
    for (ConsumerRecord<String, String> record : records) {
        // Bad: 여기서 무거운 작업을 동기로 수행 (예: 외부 API 호출 3초 소요)
        // 100개 레코드 * 3초 = 300초 소요.
        // max.poll.interval.ms 기본값(5분)을 초과할 수 있음 -> 강제 리밸런싱 발생
        processHeavyTask(record); 
    }
    // Auto Commit은 poll() 호출 시점에 이전 배치의 오프셋을 커밋함.
    // 만약 processHeavyTask 도중 에러나서 죽으면, 일부는 처리됐는데 커밋은 안 됨 -> 중복 처리 발생
}
```

### ✅ Good Practice: Manual Commit & Flow Control

```java
Properties props = new Properties();
props.put("group.id", "payment-group");
// 수동 커밋 사용
props.put("enable.auto.commit", "false");
// 한 번에 가져올 최대 개수 제한 (처리 시간 조절)
props.put("max.poll.records", "50");

Consumer<String, String> consumer = new KafkaConsumer<>(props);
consumer.subscribe(Collections.singletonList("payment-topic"));

try {
    while (true) {
        ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));
        
        if (records.isEmpty()) continue;

        try {
            for (ConsumerRecord<String, String> record : records) {
                processHeavyTask(record);
            }
            
            // 처리가 다 끝난 후 동기 커밋 (가장 안전)
            // 비동기 커밋(commitAsync)은 속도는 빠르지만 실패 시 재시도가 안 됨(순서 꼬임 방지)
            consumer.commitSync(); 
            
        } catch (Exception e) {
            // 에러 핸들링: DB 롤백 등 수행
            // 커밋을 안 했으므로, 재시작 시 다시 처리됨 (At-least-once)
            log.error("Error processing records", e);
        }
    }
} finally {
    consumer.close();
}
```

---

## 3. 리밸런싱 폭풍(Rebalance Storm) 피하기

Consumer가 이유 없이 그룹에서 튕겨나간다면 아래 설정을 확인하세요.

1.  **`session.timeout.ms` (Default: 45s)**
    - 컨슈머가 이 시간 동안 Heartbeat를 안 보내면 죽은 것으로 간주.
    - 너무 짧으면 네트워크 일시 지연에도 리밸런싱 발생.
2.  **`max.poll.interval.ms` (Default: 5m)**
    - `poll()`과 `poll()` 사이의 최대 시간.
    - 데이터 처리가 이 시간보다 오래 걸리면 컨슈머가 멈춘(Hung) 것으로 간주하여 강제 퇴출.
    - **해결책**: `max.poll.records`를 줄이거나, 처리 로직을 별도 스레드풀로 위임(단, Offset 관리가 복잡해짐).
