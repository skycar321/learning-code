/**
 * Advanced Step 1: Spring Batch 멀티스레드 처리
 *
 * 이 파일은 Spring Batch에서 대용량 데이터를 효율적으로 처리하기 위한
 * 멀티스레드 Step 구성 방법을 학습합니다.
 *
 * 학습 목표:
 * 1. TaskExecutor를 활용한 멀티스레드 Step
 * 2. Partitioning을 활용한 병렬 처리
 * 3. 동시성 제어와 트랜잭션 관리
 * 4. 스레드 안전한 ItemReader 구현
 *
 * @author Learning Code Project
 * @since Spring Batch 5.x
 */

package com.example.batch.advanced;

import org.springframework.batch.core.*;
import org.springframework.batch.core.configuration.annotation.EnableBatchProcessing;
import org.springframework.batch.core.configuration.annotation.StepScope;
import org.springframework.batch.core.job.builder.JobBuilder;
import org.springframework.batch.core.partition.PartitionHandler;
import org.springframework.batch.core.partition.support.Partitioner;
import org.springframework.batch.core.partition.support.TaskExecutorPartitionHandler;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.batch.core.step.builder.StepBuilder;
import org.springframework.batch.item.*;
import org.springframework.batch.item.database.JdbcPagingItemReader;
import org.springframework.batch.item.database.Order;
import org.springframework.batch.item.database.builder.JdbcPagingItemReaderBuilder;
import org.springframework.batch.item.database.support.SqlPagingQueryProviderFactoryBean;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.task.TaskExecutor;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;
import org.springframework.transaction.PlatformTransactionManager;

import javax.sql.DataSource;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

@Configuration
@EnableBatchProcessing
public class Advanced_Step1_MultiThreadedStep {

    // ============================================================
    // 1. 나쁜 예시: 단일 스레드 배치 처리 (대용량 데이터에 부적합)
    // ============================================================

    /*
     * [나쁜 예시] 단일 스레드로 100만 건 처리
     *
     * 문제점:
     * 1. 처리 시간이 매우 오래 걸림
     * 2. CPU 코어를 충분히 활용하지 못함
     * 3. 확장성 없음
     *
     * @Bean
     * public Step singleThreadStep() {
     *     return new StepBuilder("singleThreadStep", jobRepository)
     *         .<Customer, Customer>chunk(1000, transactionManager)
     *         .reader(customerReader())
     *         .processor(customerProcessor())
     *         .writer(customerWriter())
     *         .build();
     * }
     */

    // ============================================================
    // 2. 좋은 예시: TaskExecutor를 사용한 멀티스레드 Step
    // ============================================================

    private final JobRepository jobRepository;
    private final PlatformTransactionManager transactionManager;
    private final DataSource dataSource;

    public Advanced_Step1_MultiThreadedStep(
            JobRepository jobRepository,
            PlatformTransactionManager transactionManager,
            DataSource dataSource) {
        this.jobRepository = jobRepository;
        this.transactionManager = transactionManager;
        this.dataSource = dataSource;
    }

    /**
     * 멀티스레드 Step용 TaskExecutor 설정
     *
     * 학습 포인트:
     * - corePoolSize: 기본 스레드 수 (CPU 코어 수 기준)
     * - maxPoolSize: 최대 스레드 수
     * - queueCapacity: 대기 큐 크기
     */
    @Bean
    public TaskExecutor batchTaskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(4);      // CPU 코어 수에 맞춤
        executor.setMaxPoolSize(8);       // 최대 스레드 수
        executor.setQueueCapacity(100);   // 대기 큐 크기
        executor.setThreadNamePrefix("batch-thread-");
        executor.setWaitForTasksToCompleteOnShutdown(true);
        executor.setAwaitTerminationSeconds(60);
        executor.initialize();
        return executor;
    }

    /**
     * [좋은 예시] 멀티스레드 Step 구성
     *
     * 주의사항:
     * - ItemReader는 반드시 스레드 안전해야 함
     * - throttleLimit으로 동시 스레드 수 제한 가능
     */
    @Bean
    public Step multiThreadedStep() {
        return new StepBuilder("multiThreadedStep", jobRepository)
                .<Customer, Customer>chunk(100, transactionManager)
                .reader(synchronizedCustomerReader()) // 스레드 안전한 Reader
                .processor(customerProcessor())
                .writer(customerWriter())
                .taskExecutor(batchTaskExecutor())   // 멀티스레드 실행
                .throttleLimit(4)                    // 최대 4개 스레드 동시 실행
                .build();
    }

    /**
     * 스레드 안전한 ItemReader
     *
     * 학습 포인트:
     * - JdbcPagingItemReader는 기본적으로 스레드 안전하지 않음
     * - SynchronizedItemStreamReader로 래핑하여 스레드 안전하게 만듦
     */
    @Bean
    public SynchronizedItemStreamReader<Customer> synchronizedCustomerReader() {
        SynchronizedItemStreamReader<Customer> synchronizedReader = new SynchronizedItemStreamReader<>();
        synchronizedReader.setDelegate(customerPagingReader());
        return synchronizedReader;
    }

    @Bean
    public JdbcPagingItemReader<Customer> customerPagingReader() {
        Map<String, Order> sortKeys = new HashMap<>();
        sortKeys.put("id", Order.ASCENDING);

        return new JdbcPagingItemReaderBuilder<Customer>()
                .name("customerPagingReader")
                .dataSource(dataSource)
                .selectClause("SELECT id, name, email, status")
                .fromClause("FROM customers")
                .whereClause("WHERE status = 'PENDING'")
                .sortKeys(sortKeys)
                .pageSize(100)
                .rowMapper(new BeanPropertyRowMapper<>(Customer.class))
                .build();
    }

    // ============================================================
    // 3. 좋은 예시: Partitioning을 사용한 병렬 처리
    // ============================================================

    /**
     * Partitioning Step 구성
     *
     * Partitioning vs Multi-threaded Step:
     * - Partitioning: 데이터를 논리적으로 분할하여 각 파티션을 독립적으로 처리
     * - Multi-threaded Step: 단일 Step 내에서 청크를 멀티스레드로 처리
     *
     * Partitioning 장점:
     * - 각 파티션이 독립적이므로 재시작 시 실패한 파티션만 재처리
     * - 더 세밀한 병렬 제어 가능
     */
    @Bean
    public Step masterStep() {
        return new StepBuilder("masterStep", jobRepository)
                .partitioner("slaveStep", rangePartitioner()) // 파티셔너 지정
                .partitionHandler(partitionHandler())         // 파티션 핸들러
                .build();
    }

    /**
     * 범위 기반 파티셔너
     *
     * 데이터를 ID 범위로 분할하여 각 파티션에 할당
     */
    @Bean
    public Partitioner rangePartitioner() {
        return gridSize -> {
            Map<String, ExecutionContext> partitions = new HashMap<>();

            int totalRecords = 1000000; // 전체 레코드 수
            int partitionSize = totalRecords / gridSize;

            for (int i = 0; i < gridSize; i++) {
                ExecutionContext context = new ExecutionContext();
                int startId = i * partitionSize + 1;
                int endId = (i + 1) * partitionSize;

                context.putInt("minId", startId);
                context.putInt("maxId", endId);
                context.putString("partitionName", "partition" + i);

                partitions.put("partition" + i, context);
            }

            return partitions;
        };
    }

    /**
     * 파티션 핸들러 설정
     */
    @Bean
    public PartitionHandler partitionHandler() {
        TaskExecutorPartitionHandler handler = new TaskExecutorPartitionHandler();
        handler.setTaskExecutor(batchTaskExecutor());
        handler.setStep(slaveStep());
        handler.setGridSize(4); // 4개의 파티션으로 분할
        return handler;
    }

    /**
     * 슬레이브 Step (각 파티션을 처리)
     */
    @Bean
    public Step slaveStep() {
        return new StepBuilder("slaveStep", jobRepository)
                .<Customer, Customer>chunk(100, transactionManager)
                .reader(partitionedCustomerReader(null, null))
                .processor(customerProcessor())
                .writer(customerWriter())
                .build();
    }

    /**
     * 파티션별 ItemReader
     *
     * @StepScope를 사용하여 각 파티션의 ExecutionContext에서 범위 값을 주입받음
     */
    @Bean
    @StepScope
    public JdbcPagingItemReader<Customer> partitionedCustomerReader(
            @Value("#{stepExecutionContext['minId']}") Integer minId,
            @Value("#{stepExecutionContext['maxId']}") Integer maxId) {

        Map<String, Order> sortKeys = new HashMap<>();
        sortKeys.put("id", Order.ASCENDING);

        return new JdbcPagingItemReaderBuilder<Customer>()
                .name("partitionedCustomerReader")
                .dataSource(dataSource)
                .selectClause("SELECT id, name, email, status")
                .fromClause("FROM customers")
                .whereClause("WHERE id >= :minId AND id <= :maxId")
                .sortKeys(sortKeys)
                .pageSize(100)
                .parameterValues(Map.of("minId", minId, "maxId", maxId))
                .rowMapper(new BeanPropertyRowMapper<>(Customer.class))
                .build();
    }

    // ============================================================
    // 4. 스레드 안전한 ItemProcessor/Writer
    // ============================================================

    /**
     * ItemProcessor (기본적으로 스레드 안전)
     *
     * 주의: 상태를 공유하지 않으면 스레드 안전
     */
    @Bean
    public ItemProcessor<Customer, Customer> customerProcessor() {
        return customer -> {
            // 처리 로직 (상태 없음 = 스레드 안전)
            customer.setStatus("PROCESSED");
            customer.setProcessedAt(System.currentTimeMillis());

            // 스레드 정보 로깅 (디버깅용)
            System.out.println(Thread.currentThread().getName()
                    + " processing: " + customer.getId());

            return customer;
        };
    }

    /**
     * 스레드 안전한 ItemWriter
     *
     * JdbcBatchItemWriter는 기본적으로 스레드 안전
     */
    @Bean
    public ItemWriter<Customer> customerWriter() {
        // AtomicInteger로 스레드 안전한 카운터 구현
        AtomicInteger processedCount = new AtomicInteger(0);

        return items -> {
            // 배치 처리 로직
            for (Customer customer : items) {
                // DB 저장 로직
                System.out.println(Thread.currentThread().getName()
                        + " writing: " + customer.getId());
            }

            int count = processedCount.addAndGet(items.size());
            System.out.println("Total processed: " + count);
        };
    }

    // ============================================================
    // 5. Job 구성
    // ============================================================

    @Bean
    public Job multiThreadedJob() {
        return new JobBuilder("multiThreadedJob", jobRepository)
                .start(multiThreadedStep())
                .build();
    }

    @Bean
    public Job partitionedJob() {
        return new JobBuilder("partitionedJob", jobRepository)
                .start(masterStep())
                .build();
    }

    // ============================================================
    // DTO 클래스
    // ============================================================

    public static class Customer {
        private Long id;
        private String name;
        private String email;
        private String status;
        private Long processedAt;

        // Getters and Setters
        public Long getId() { return id; }
        public void setId(Long id) { this.id = id; }
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
        public Long getProcessedAt() { return processedAt; }
        public void setProcessedAt(Long processedAt) { this.processedAt = processedAt; }
    }
}

// ============================================================
// SynchronizedItemStreamReader 클래스
// ============================================================

class SynchronizedItemStreamReader<T> implements ItemStreamReader<T> {

    private ItemStreamReader<T> delegate;

    public void setDelegate(ItemStreamReader<T> delegate) {
        this.delegate = delegate;
    }

    @Override
    public synchronized T read() throws Exception {
        return delegate.read();
    }

    @Override
    public void open(ExecutionContext executionContext) {
        delegate.open(executionContext);
    }

    @Override
    public void update(ExecutionContext executionContext) {
        delegate.update(executionContext);
    }

    @Override
    public void close() {
        delegate.close();
    }
}

/*
 * ============================================================
 * 학습 포인트 요약
 * ============================================================
 *
 * 1. 멀티스레드 Step vs Partitioning
 *    - 멀티스레드 Step: 단일 Step 내 청크를 병렬 처리
 *    - Partitioning: 데이터를 분할하여 독립적인 Step으로 처리
 *
 * 2. 스레드 안전성
 *    - ItemReader: 반드시 스레드 안전해야 함 (SynchronizedItemStreamReader 사용)
 *    - ItemProcessor: 상태가 없으면 기본적으로 스레드 안전
 *    - ItemWriter: JdbcBatchItemWriter는 스레드 안전
 *
 * 3. TaskExecutor 설정
 *    - corePoolSize: CPU 코어 수에 맞춤
 *    - throttleLimit: 동시 실행 스레드 수 제한
 *
 * 4. Partitioning 장점
 *    - 재시작 시 실패한 파티션만 재처리
 *    - 더 세밀한 병렬 제어
 *    - @StepScope로 파티션별 파라미터 주입
 *
 * 5. 주의사항
 *    - 공유 상태 사용 금지 (또는 AtomicXxx, ConcurrentXxx 사용)
 *    - 청크 크기와 스레드 수의 균형 조절
 *    - 데이터베이스 커넥션 풀 크기 고려
 *
 * 6. 성능 튜닝 팁
 *    - 청크 크기: 100~1000 권장 (메모리와 트랜잭션 오버헤드 균형)
 *    - 스레드 수: CPU 코어 수 * 1~2
 *    - 파티션 수: 데이터 분포에 따라 결정
 */
