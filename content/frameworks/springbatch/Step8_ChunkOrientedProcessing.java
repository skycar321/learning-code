// Spring Batch Step 8: ChunkOrientedProcessing.java
// Chunk 단위 처리의 장점 및 동작 방식 심화 학습합니다.
// 좋은 예시: 대량의 데이터를 청크 단위로 처리하여 메모리 사용량을 최적화하고 트랜잭션 효율성을 높입니다.
// 나쁜 예시: 청크 단위 처리의 이점을 이해하지 못하고 모든 데이터를 한 번에 처리하여 성능 저하 및 메모리 문제를 야기합니다.
package com.example.springbatch;

import org.springframework.batch.core.Job;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.configuration.annotation.JobBuilderFactory;
import org.springframework.batch.core.configuration.annotation.StepBuilderFactory;
import org.springframework.batch.item.ItemProcessor;
import org.springframework.batch.item.ItemReader;
import org.springframework.batch.item.ItemWriter;
import org.springframework.batch.item.support.ListItemReader;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Arrays;
import java.util.List;

@Configuration
public class Step8_ChunkOrientedProcessing {

    private final JobBuilderFactory jobBuilderFactory;
    private final StepBuilderFactory stepBuilderFactory;

    public Step8_ChunkOrientedProcessing(JobBuilderFactory jobBuilderFactory, StepBuilderFactory stepBuilderFactory) {
        this.jobBuilderFactory = jobBuilderFactory;
        this.stepBuilderFactory = stepBuilderFactory;
    }

    @Bean
    public ItemReader<Integer> chunkItemReader() {
        List<Integer> data = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
        return new ListItemReader<>(data);
    }

    @Bean
    public ItemProcessor<Integer, Integer> chunkItemProcessor() {
        return item -> {
            System.out.println("Processing item: " + item);
            return item * 2;
        };
    }

    @Bean
    public ItemWriter<Integer> chunkItemWriter() {
        return items -> {
            System.out.println("Writing chunk: " + items);
            // 실제 환경에서는 DB에 저장하거나 파일에 쓰는 등의 작업을 수행합니다.
        };
    }

    @Bean
    public Step chunkProcessingStep() {
        return stepBuilderFactory.get("chunkProcessingStep")
                .<Integer, Integer>chunk(3) // 3개 단위로 묶어서 처리합니다.
                .reader(chunkItemReader())
                .processor(chunkItemProcessor())
                .writer(chunkItemWriter())
                .build();
    }

    @Bean
    public Job chunkProcessingJob() {
        return jobBuilderFactory.get("chunkProcessingJob")
                .start(chunkProcessingStep())
                .build();
    }
}
