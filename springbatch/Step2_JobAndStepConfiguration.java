// Spring Batch Step 2: JobAndStepConfiguration.java
// Job 및 Step을 구성하는 방법을 학습합니다. `JobBuilderFactory`와 `StepBuilderFactory`를 이용한 Job과 Step 정의.
// 좋은 예시: Job과 Step을 명확하게 정의하고, 각 Step의 역할을 분리합니다.
// 나쁜 예시: 모든 배치 로직을 하나의 Job과 Step에 몰아넣어 가독성 및 유지보수성을 떨어뜨립니다.
package com.example.springbatch;

import org.springframework.batch.core.Job;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.configuration.annotation.JobBuilderFactory;
import org.springframework.batch.core.configuration.annotation.StepBuilderFactory;
import org.springframework.batch.repeat.RepeatStatus;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class Step2_JobAndStepConfiguration {

    private final JobBuilderFactory jobBuilderFactory;
    private final StepBuilderFactory stepBuilderFactory;

    public Step2_JobAndStepConfiguration(JobBuilderFactory jobBuilderFactory, StepBuilderFactory stepBuilderFactory) {
        this.jobBuilderFactory = jobBuilderFactory;
        this.stepBuilderFactory = stepBuilderFactory;
    }

    // 첫 번째 Step 정의
    @Bean
    public Step firstStep() {
        return stepBuilderFactory.get("firstStep")
                .tasklet((contribution, chunkContext) -> {
                    System.out.println(">>> This is first Step");
                    return RepeatStatus.FINISHED;
                })
                .build();
    }

    // 두 번째 Step 정의
    @Bean
    public Step secondStep() {
        return stepBuilderFactory.get("secondStep")
                .tasklet((contribution, chunkContext) -> {
                    System.out.println(">>> This is second Step");
                    return RepeatStatus.FINISHED;
                })
                .build();
    }

    // 두 개의 Step을 포함하는 Job 정의
    @Bean
    public Job twoStepJob() {
        return jobBuilderFactory.get("twoStepJob")
                .start(firstStep())
                .next(secondStep()) // firstStep 다음에 secondStep 실행
                .build();
    }
}
