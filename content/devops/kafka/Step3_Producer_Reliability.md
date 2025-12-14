# Step 3: Producer - 데이터 유실 없는 전송 (Reliability)

Kafka Producer는 단순히 메시지를 `send()` 하는 것이 전부가 아닙니다. "얼마나 확실하게 보낼 것인가"에 따라 처리량(Throughput)과 신뢰성(Reliability)의 트레이드오프가 발생합니다.

## 1. Message Delivery Semantics

- **At-most-once**: 메시지가 유실될 수 있지만 중복은 없음. (Fire and forget)
- **At-least-once**: 메시지 유실은 없지만 중복 발생 가능. (기본값)
- **Exactly-once**: 유실도 없고 중복도 없음. (Idempotence + Transaction)

## 2. 핵심 설정 (Configuration)

### `acks` (Acknowledgments)
- `acks=0`: 브로커 응답을 기다리지 않음. 가장 빠르지만 데이터 유실 위험 큼.
- `acks=1`: Leader가 기록하면 성공으로 간주. Leader 장애 시 유실 가능. (Default ~v2.x)
- `acks=all` (또는 `-1`): 모든 ISR(In-Sync Replicas)이 기록해야 성공. 가장 느리지만 가장 안전. (Default v3.x+)

### `enable.idempotence`
- `true`로 설정 시, Producer가 메시지에 Sequence Number를 붙여서 보냅니다.
- 브로커는 중복된 번호가 오면 저장하지 않고 Ack만 보냅니다. (중복 제거)
- Kafka 3.x부터는 기본값이 `true`입니다.

---

## 3. Code: Good vs Bad Examples (Java)

### ❌ Bad Practice: Fire-and-Forget (동기식 전송)

```java
Properties props = new Properties();
props.put("bootstrap.servers", "localhost:9092");
props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");

Producer<String, String> producer = new KafkaProducer<>(props);

for (int i = 0; i < 100; i++) {
    // Bad 1: Future.get()을 호출하여 건건이 블로킹됨. 처리량 최악.
    // Bad 2: 에러 발생 시 재시도 로직이 미비하거나 Loop가 멈춤.
    try {
        producer.send(new ProducerRecord<>("my-topic", "value-" + i)).get();
    } catch (Exception e) {
        e.printStackTrace();
    }
}
producer.close();
```

### ✅ Good Practice: Asynchronous with Callback

```java
Properties props = new Properties();
props.put("bootstrap.servers", "localhost:9092");
// 신뢰성 설정
props.put("acks", "all");
props.put("enable.idempotence", "true"); 
// 성능 튜닝
props.put("batch.size", 16384); // 16KB 배칭
props.put("linger.ms", 5);      // 5ms 정도는 기다렸다가 배칭해서 보냄

Producer<String, String> producer = new KafkaProducer<>(props);

for (int i = 0; i < 100; i++) {
    ProducerRecord<String, String> record = new ProducerRecord<>("my-topic", "key", "value-" + i);
    
    // 비동기 전송 + 콜백
    producer.send(record, (metadata, exception) -> {
        if (exception == null) {
            // 성공
            System.out.printf("Success: Partition=%d, Offset=%d\n", 
                metadata.partition(), metadata.offset());
        } else {
            // 실패 (여기서 재시도 로직을 타거나, DLQ(Dead Letter Queue)로 전송)
            System.err.println("Error sending message: " + exception.getMessage());
            // 실제 운영에선 log.error("...", exception) 사용
        }
    });
}
// 애플리케이션 종료 시 반드시 close() 호출하여 버퍼에 남은 메시지 전송(flush)
producer.close();
```

---

## 4. Tip: `linger.ms`의 마법
Producer는 `batch.size`가 찰 때까지 기다리거나 `linger.ms` 시간이 지날 때까지 기다립니다.
- **기본값 (0ms)**: 데이터가 들어오자마자 보냄. 레이턴시는 낮지만 I/O 오버헤드 큼.
- **튜닝 (5~100ms)**: 약간의 지연을 허용하는 대신, 한 번에 묶어서 보내므로 **처리량(Throughput)이 급격히 상승**합니다.

```