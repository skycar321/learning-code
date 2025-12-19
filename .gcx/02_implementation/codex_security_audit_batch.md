# Codex Security Audit Report

**Topic**: Batch & ETL Logging (Spring Batch, StreamSets)
**Model**: gpt-5.1-codex-max
**Reasoning Effort**: extra_high

## 1. 결론: 네, 반드시 남겨야 합니다. (구현 방법은 다름)

스케줄러(배치)나 ETL 도구(스트림셋)는 "사람"이 직접 클릭하지 않을 뿐, **"시스템 계정"이 대량의 데이터를 조회하고 조작**하는 행위입니다. 오히려 사람이 한 건씩 조회하는 것보다 **대량의 개인정보**를 다루므로 보안 감사(Audit)의 핵심 대상입니다.

---

## 2. Spring Batch (개발자 영역)

웹(API)과 달리 HTTP 요청이 없으므로 `Interceptor`는 동작하지 않습니다. 대신 **Listener**를 사용해야 합니다.

### A. 구현 포인트 (JobExecutionListener)
배치 작업의 시작과 끝에 로그를 남기는 리스너를 등록합니다.

```java
@Component
public class JobLoggingListener implements JobExecutionListener {

    private static final Logger log = LoggerFactory.getLogger("BATCH_AUDIT_LOG");

    @Override
    public void beforeJob(JobExecution jobExecution) {
        // 접속자ID: 스케줄러에 의해 실행되므로 "SYSTEM" 또는 "SCHEDULER"로 고정
        // 수행업무: Job 이름 (예: "휴면계정전환_Job")
        log.info("Type=BATCH_START, JobName={}, User=SYSTEM, Time={}", 
                 jobExecution.getJobInstance().getJobName(), LocalDateTime.now());
    }

    @Override
    public void afterJob(JobExecution jobExecution) {
        // 결과: 성공/실패 여부, 처리 건수 (매우 중요)
        // 처리 건수를 남겨야 "어? 평소엔 100건인데 왜 오늘 100만 건을 조회했지?" 같은 이상 징후 탐지 가능
        long readCount = jobExecution.getStepExecutions().stream().mapToLong(StepExecution::getReadCount).sum();
        long writeCount = jobExecution.getStepExecutions().stream().mapToLong(StepExecution::getWriteCount).sum();
        
        log.info("Type=BATCH_END, JobName={}, User=SYSTEM, Status={}, Read={}, Write={}", 
                 jobExecution.getJobInstance().getJobName(), 
                 jobExecution.getStatus(),
                 readCount, writeCount);
    }
}
```

### B. 주의사항 (개인정보)
*   **ItemProcessor** 단계에서 개별 데이터를 처리할 때, 절대 `log.info("처리 중인 고객: {}", customer.toString());` 처럼 남기면 안 됩니다. (대량 개인정보 유출)
*   오류가 난 특정 건의 식별값(ID) 정도만 에러 로그에 남기는 것이 정석입니다.

---

## 3. StreamSets (인프라/도구 설정 영역)

StreamSets(SDC)와 같은 ETL 도구는 코드를 짜는 게 아니라 설정을 통해 로그를 남깁니다.

### A. Audit Log 활성화
StreamSets는 자체적으로 **Audit Log** 기능을 제공합니다.
*   `sdc.properties` 또는 설정 메뉴에서 Audit 기능을 켭니다.
*   **누가**: 파이프라인을 누가 시작/정지했는지 (admin, user 등)
*   **무엇을**: 어떤 파이프라인 설정이 변경되었는지

### B. 데이터 처리 기록 (Pipeline Events)
파이프라인 실행 자체(몇 건 처리했나)에 대한 기록은 **Event Framework**를 사용합니다.
*   파이프라인 설정에서 `Lifecycle Events`를 활성화합니다.
*   파이프라인 시작/종료 시 이벤트를 발생시켜 별도의 목적지(로컬 파일, Kafka, DB)로 로그를 쏘도록 구성합니다.
*   이렇게 생성된 로그 파일을 인프라 팀이 수집해 가면 됩니다.

---

## 4. 요약 (Action Item)

1.  **Spring Batch**: 개발자가 `JobExecutionListener`를 구현하여 **[Job이름, 시작/종료시간, 처리건수, 성공여부]**를 로그 파일에 남기도록 코드 추가.
2.  **StreamSets**: 운영자가 설정에서 **Audit Log** 및 **Pipeline Event**를 활성화하여 로그 파일이 생성되도록 설정.
3.  **공통**: 이렇게 생성된 로그 파일들은 앞서 논의한 대로 **인프라 팀이 수집 -> 해시 생성 -> WORM 보관** 프로세스를 타야 합니다.
