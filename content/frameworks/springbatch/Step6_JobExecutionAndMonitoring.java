// Spring Batch Step 6: JobExecutionAndMonitoring.java
// JobLauncher, JobRepository, JobExplorer를 이용한 Job 실행 및 상태 관리를 학습합니다.
// 좋은 예시: Job의 실행을 프로그래밍적으로 제어하고, 실행 이력을 조회하여 모니터링합니다.
// 나쁜 예시: Job 실행을 수동으로만 의존하거나, 실행 중 문제 발생 시 이력을 추적하기 어렵게 만듭니다.
package com.example.springbatch;

import org.springframework.batch.core.Job;
import org.springframework.batch.core.JobParameters;
import org.springframework.batch.core.JobParametersBuilder;
import org.springframework.batch.core.explore.JobExplorer;
import org.springframework.batch.core.launch.JobLauncher;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;

@Configuration
@EnableScheduling // 스케줄링 기능을 활성화하여 Job을 주기적으로 실행할 수 있도록 합니다.
public class Step6_JobExecutionAndMonitoring {

    private final JobLauncher jobLauncher;
    private final JobExplorer jobExplorer;
    private final Job simpleJob; // Step1에서 정의한 Job을 주입받아 사용합니다.

    public Step6_JobExecutionAndMonitoring(JobLauncher jobLauncher, JobExplorer jobExplorer, Job simpleJob) {
        this.jobLauncher = jobLauncher;
        this.jobExplorer = jobExplorer;
        this.simpleJob = simpleJob;
    }

    // 매분 10초에 Job을 실행하는 예시 (스케줄링)
    @Scheduled(cron = "0 10 * * * ?")
    public void runSimpleJob() throws Exception {
        JobParameters jobParameters = new JobParametersBuilder()
                .addLong("time", System.currentTimeMillis()) // JobParameters를 고유하게 만들어 Job을 재실행 가능하게 합니다.
                .toJobParameters();
        jobLauncher.run(simpleJob, jobParameters);
        System.out.println("Job 'simpleJob' started.");
    }

    // Job 실행 이력을 조회하는 예시
    public void exploreJobExecutions() {
        System.out.println("Job 'simpleJob' is currently running: " + jobExplorer.findRunningJobExecutions("simpleJob").size());
        // findJobInstances, getJobExecutions 등 JobExplorer의 다양한 메서드를 활용하여 모니터링할 수 있습니다.
    }
}
