// Spring Batch Step 9: PartitioningForParallelProcessing.java
// 대규모 데이터 처리를 위한 Partitioning 전략 구현을 학습합니다.
// 좋은 예시: Partitioning을 통해 Job을 여러 워커 스레드나 원격 서버에서 병렬로 실행하여 처리량을 극대화합니다.
// 나쁜 예시: 대용량 데이터를 단일 스레드에서 순차적으로 처리하여 처리 시간이 오래 걸리고 자원 활용이 비효율적입니다.
package com.example.springbatch;

import org.springframework.batch.core.Job;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.configuration.annotation.JobBuilderFactory;
import org.springframework.batch.core.configuration.annotation.StepBuilderFactory;
import org.springframework.batch.core.partition.PartitionHandler;
import org.springframework.batch.core.partition.support.TaskExecutorPartitionHandler;
import org.springframework.batch.core.step.tasklet.Tasklet;
import org.springframework.batch.repeat.RepeatStatus;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.task.SimpleAsyncTaskExecutor;
import org.springframework.core.task.TaskExecutor;

@Configuration
public class Step9_PartitioningForParallelProcessing {

    private final JobBuilderFactory jobBuilderFactory;
    private final StepBuilderFactory stepBuilderFactory;

    public Step9_PartitioningForParallelProcessing(JobBuilderFactory jobBuilderFactory, StepBuilderFactory stepBuilderFactory) {
        this.jobBuilderFactory = jobBuilderFactory;
        this.stepBuilderFactory = stepBuilderFactory;
    }

    // 마스터 Step이 워커 Step을 시작하고 결과를 집계합니다.
    @Bean
    public Step masterStep() {
        return stepBuilderFactory.get("masterStep")
                .partitioner("workerStep", new SimplePartitioner()) // SimplePartitioner는 파티션 키를 생성하는 간단한 예시
                .partitionHandler(partitionHandler())
                .build();
    }

    // 워커 Step: 실제 작업을 수행하는 Step
    @Bean
    public Step workerStep() {
        return stepBuilderFactory.get("workerStep")
                .tasklet(workerTasklet(null)) // 파티션 키는 실행 시점에 주입됩니다.
                .build();
    }

    @Bean
    public Tasklet workerTasklet(@org.springframework.beans.factory.annotation.Value("#{stepExecutionContext['name']}") String name) {
        return (contribution, chunkContext) -> {
            System.out.println("Processing worker step: " + name);
            // 실제 데이터 처리 로직 (ItemReader, ItemProcessor, ItemWriter 조합)
            return RepeatStatus.FINISHED;
        };
    }

    // 파티션 핸들러: 워커 Step을 실행할 TaskExecutor를 설정합니다.
    @Bean
    public PartitionHandler partitionHandler() {
        TaskExecutorPartitionHandler handler = new TaskExecutorPartitionHandler();
        handler.setGridSize(4); // 4개의 파티션으로 나눕니다.
        handler.setTaskExecutor(taskExecutor());
        handler.setStep(workerStep());
        return handler;
    }

    @Bean
    public TaskExecutor taskExecutor() {
        return new SimpleAsyncTaskExecutor("spring_batch_task_executor");
    }

    @Bean
    public Job partitionedJob() {
        return jobBuilderFactory.get("partitionedJob")
                .start(masterStep())
                .build();
    }
}
