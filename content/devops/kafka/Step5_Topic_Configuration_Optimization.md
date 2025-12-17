# Step 5: 토픽 설계와 운영 최적화 (Optimization)

토픽을 생성한 후에 설정을 바꾸는 것은 매우 어렵거나 불가능할 수 있습니다(특히 파티션 수 감소). 초기 설계가 시스템의 수명을 결정합니다.

## 1. Partition 개수 산정 공식

파티션은 무조건 많다고 좋지 않습니다.

### ❌ Bad Practice: 무지성 파티션 증설
"일단 100개 뚫어놓자."
- **문제점 1**: 브로커가 관리해야 할 파일 핸들(File Descriptor) 폭증.
- **문제점 2**: 장애 발생 시 복구 시간(Mean Time To Recover) 증가. 컨트롤러가 수천 개의 리더를 다시 선출해야 함.
- **문제점 3**: 엔드투엔드 레이턴시 증가 (Replication 오버헤드).

### ✅ Good Practice: 계산된 증설
1. 목표 처리량(Throughput) 측정 (예: 100 MB/s).
2. Consumer 1개가 처리 가능한 속도 측정 (예: 20 MB/s).
3. 필요 파티션 수 = `100 / 20` = 5개.
4. 여유분을 둬서 **6개**로 설정.

---

## 2. Log Retention & Compaction

데이터를 언제까지 보관할 것인가?

### `delete` 정책 (기본값)
- `retention.ms`: 시간 기반 삭제 (기본 7일).
- `retention.bytes`: 용량 기반 삭제.
- 주로 로그, 이벤트 스트림 등 **이력 데이터**에 사용.

### `compact` 정책 (Log Compaction)
- 키(Key)별로 **최신 값(Last Value)**만 남기고 과거 데이터는 삭제.
- 예: "사용자 ID 100의 주소 변경". 주소가 10번 바뀌어도 현재 주소만 알면 된다면 Compaction 사용.
- **KSQL, Kafka Streams의 Table, CDC(Change Data Capture)**에서 필수적으로 사용됨.

---

## 3. OS Level Tuning (Linux)

Kafka 성능을 쥐어짜려면 OS 설정이 필요합니다.

1.  **File Descriptors**: Kafka는 많은 파일을 엽니다.
    - `ulimit -n 100000` 이상 권장.
2.  **Swapping**: Kafka는 힙 메모리보다 OS Page Cache를 쓰므로, 스왑이 발생하면 성능이 급락합니다.
    - `vm.swappiness = 1` (최소화).
3.  **Filesystem**: XFS 또는 Ext4 권장. (XFS가 대용량 처리에 조금 더 유리하다는 벤치마크 존재).

