// Spring Batch Step 7: ErrorHandlingAndRestart.java
// ItemProcessor/Writer에서 발생하는 예외 처리 및 Job 재시작 전략을 학습합니다.
// 좋은 예시: 재시도, 스킵, 재시작 기능을 활용하여 견고한 배치 Job을 만듭니다.
// 나쁜 예시: 예외 발생 시 Job이 즉시 실패하고, 실패한 지점부터 재시작하기 어렵게 만듭니다.
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
public class Step7_ErrorHandlingAndRestart {

    private final JobBuilderFactory jobBuilderFactory;
    private final StepBuilderFactory stepBuilderFactory;

    public Step7_ErrorHandlingAndRestart(JobBuilderFactory jobBuilderFactory, StepBuilderFactory stepBuilderFactory) {
        this.jobBuilderFactory = jobBuilderFactory;
        this.stepBuilderFactory = stepBuilderFactory;
    }

    @Bean
    public ItemReader<String> faultTolerantItemReader() {
        List<String> data = Arrays.asList("item1", "fail_this", "item2", "fail_another", "item3");
        return new ListItemReader<>(data);
    }

    @Bean
    public ItemProcessor<String, String> faultTolerantItemProcessor() {
        return item -> {
            if (item.contains("fail")) {
                System.out.println("Processing failed for: " + item);
                throw new CustomProcessingException("Failed to process item: " + item);
            }
            return item.toUpperCase();
        };
    }

    @Bean
    public ItemWriter<String> faultTolerantItemWriter() {
        return items -> {
            for (String item : items) {
                System.out.println("Writing item: " + item);
            }
        };
    }

    @Bean
    public Step faultTolerantStep() {
        return stepBuilderFactory.get("faultTolerantStep")
                .<String, String>chunk(2)
                .reader(faultTolerantItemReader())
                .processor(faultTolerantItemProcessor())
                .writer(faultTolerantItemWriter())
                .faultTolerant() // 내결함성 활성화
                .skipLimit(10) // 스킵할 수 있는 최대 예외 수
                .skip(CustomProcessingException.class) // CustomProcessingException 발생 시 스킵
                .retryLimit(3) // 재시도 최대 횟수
                .retry(CustomProcessingException.class) // CustomProcessingException 발생 시 재시도
                .build();
    }

    @Bean
    public Job faultTolerantJob() {
        return jobBuilderFactory.get("faultTolerantJob")
                .start(faultTolerantStep())
                .build();
    }

    public static class CustomProcessingException extends Exception {
        public CustomProcessingException(String message) {
            super(message);
        }
    }
}
