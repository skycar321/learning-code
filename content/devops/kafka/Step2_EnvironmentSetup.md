# Step 2: 환경 구성 및 기본 CLI (Setup & CLI)

가장 최신 트렌드인 **KRaft (ZooKeeper-less)** 모드를 사용하여 로컬 실습 환경을 구축합니다.

## 1. Docker Compose Setup

`docker-compose.yaml` 파일을 생성하여 실행합니다.

```yaml
# ❌ Bad Practice: 버전 태그 없이 'latest' 사용
# image: bitnami/kafka:latest
# 이유: 운영 환경과 로컬 환경의 버전 불일치로 인한 디버깅 지옥 발생 가능

# ✅ Good Practice: 명시적인 버전 사용 & KRaft 설정
services:
  kafka:
    image: bitnami/kafka:3.7.0
    container_name: kafka-learning
    ports:
      - "9092:9092"
    environment:
      # KRaft settings
      - KAFKA_CFG_NODE_ID=0
      - KAFKA_CFG_PROCESS_ROLES=controller,broker
      - KAFKA_CFG_CONTROLLER_QUORUM_VOTERS=0@kafka:9093
      # Listeners
      - KAFKA_CFG_LISTENERS=PLAINTEXT://:9092,CONTROLLER://:9093
      - KAFKA_CFG_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092
      - KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT
      - KAFKA_CFG_CONTROLLER_LISTENER_NAMES=CONTROLLER
    volumes:
      - kafka_data:/bitnami/kafka

  # UI 도구 (선택사항) - Kafka 내부를 눈으로 보기 위함
  kafka-ui:
    image: provectuslabs/kafka-ui:latest
    ports:
      - "8080:8080"
    environment:
      - KAFKA_CLUSTERS_0_NAME=local
      - KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS=kafka:9092

volumes:
  kafka_data:
```

### 실행
```bash
docker-compose up -d
```
이제 `localhost:8080`에 접속하면 Kafka UI를 볼 수 있습니다.

---

## 2. Essential CLI Commands

GUI가 있어도 장애 상황이나 자동화를 위해 CLI는 필수입니다. 컨테이너 내부로 진입하거나 로컬에 설치된 Kafka 바이너리를 사용하세요.

### 2.1 Topic 생성 (Create)
```bash
# ❌ Bad Practice: 옵션 없이 생성 (Default 설정 사용)
# kafka-topics.sh --create --topic my-topic --bootstrap-server localhost:9092
# 결과: 파티션 1개, 복제본 1개로 생성되어 성능/안정성 모두 잃음.

# ✅ Good Practice: 명시적 설정
kafka-topics.sh --create \
    --topic payment-events \
    --bootstrap-server localhost:9092 \
    --partitions 3 \
    --replication-factor 1
```
*(참고: 로컬 단일 브로커라 replication-factor는 1로 설정. 실제 운영에선 최소 3 권장)*

### 2.2 Topic 목록 및 상세 조회 (Describe)
```bash
kafka-topics.sh --describe --topic payment-events --bootstrap-server localhost:9092
```
**출력 해석**:
- `Leader: 0`: 0번 브로커가 리더임.
- `ISR: 0`: 현재 동기화된 복제본이 0번 브로커뿐임.

### 2.3 Console Producer (메시지 보내기)
```bash
kafka-console-producer.sh --topic payment-events --bootstrap-server localhost:9092
>user_id:1001,amount:5000
>user_id:1002,amount:1200
```

### 2.4 Console Consumer (메시지 읽기)
```bash
# --from-beginning: 토픽의 처음부터 다 읽어옴 (안 쓰면 실행 시점 이후 메시지만 수신)
kafka-console-consumer.sh \
    --topic payment-events \
    --bootstrap-server localhost:9092 \
    --from-beginning \
    --group my-learning-group
```

---

## 3. Listeners 이해하기 (가장 많이 겪는 에러)

Kafka 접속 실패의 90%는 `ADVERTISED_LISTENERS` 설정 오류입니다.

### 🔍 Good vs Bad Configuration

#### ❌ Bad Config: 내부/외부 구분 없음
```properties
listeners=PLAINTEXT://0.0.0.0:9092
advertised.listeners=PLAINTEXT://kafka:9092
```
**문제점**: Docker 내부 통신은 되지만, 호스트(내 노트북)나 외부 클라이언트에서는 `kafka:9092`라는 도메인을 찾을 수 없어 접속 불가.

#### ✅ Good Config: 트래픽 분리
```properties
# 내부(Docker 간) 통신용
listeners=INTERNAL://0.0.0.0:9093,EXTERNAL://0.0.0.0:9092
# 클라이언트에게 알려주는 주소 (Advertised)
advertised.listeners=INTERNAL://kafka:9093,EXTERNAL://localhost:9092
listener.security.protocol.map=INTERNAL:PLAINTEXT,EXTERNAL:PLAINTEXT
inter.broker.listener.name=INTERNAL
```
**설명**:
- Kafka 내부는 `kafka:9093`으로 통신.
- 외부(내 PC)는 `localhost:9092`로 접속하도록 안내.

```