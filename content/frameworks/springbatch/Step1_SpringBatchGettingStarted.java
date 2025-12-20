// Spring Batch Step 1: SpringBatchGettingStarted.java
// Spring Batch의 기본 개념 (Job, Step, ItemReader, ItemProcessor, ItemWriter)을 이해합니다.
// 좋은 예시: Spring Batch의 핵심 개념을 활용하여 모듈화되고 견고한 배치 아키텍처를 구성합니다.
// 나쁜 예시: 모든 배치 로직을 단일 스크립트나 서비스에서 직접 구현하여 재사용성, 확장성이 떨어집니다.
package com.example.springbatch;

import org.springframework.batch.core.Job;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.configuration.annotation.EnableBatchProcessing;
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
@EnableBatchProcessing
public class Step1_SpringBatchGettingStarted {

    private final JobBuilderFactory jobBuilderFactory;
    private final StepBuilderFactory stepBuilderFactory;

    public Step1_SpringBatchGettingStarted(JobBuilderFactory jobBuilderFactory, StepBuilderFactory stepBuilderFactory) {
        this.jobBuilderFactory = jobBuilderFactory;
        this.stepBuilderFactory = stepBuilderFactory;
    }

    // ItemReader: 데이터를 읽어오는 역할
    @Bean
    public ItemReader<String> listItemReader() {
        List<String> data = Arrays.asList("item1", "item2", "item3", "item4", "item5");
        return new ListItemReader<>(data);
    }

    // ItemProcessor: 읽어온 데이터를 가공하는 역할
    @Bean
    public ItemProcessor<String, String> itemProcessor() {
        return item -> item.toUpperCase(); // 간단하게 대문자로 변환
    }

    // ItemWriter: 가공된 데이터를 쓰는 역할
    @Bean
    public ItemWriter<String> itemWriter() {
        return items -> {
            for (String item : items) {
                System.out.println("Writing item: " + item);
            }
        };
    }

    // Step: ItemReader, ItemProcessor, ItemWriter를 묶어 실제 작업을 정의
    @Bean
    public Step processStep() {
        return stepBuilderFactory.get("processStep")
                .<String, String>chunk(3) // 3개 단위로 묶어서 처리
                .reader(listItemReader())
                .processor(itemProcessor())
                .writer(itemWriter())
                .build();
    }

    // Job: 하나 이상의 Step을 포함하는 배치 작업의 최상위 단위
    @Bean
    public Job simpleJob() {
        return jobBuilderFactory.get("simpleJob")
                .start(processStep())
                .build();
    }
}
