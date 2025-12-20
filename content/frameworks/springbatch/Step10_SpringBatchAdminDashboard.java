// Spring Batch Step 10: SpringBatchAdminDashboard.java
// Spring Batch Admin 또는 커스텀 대시보드를 통한 Job 관리 및 모니터링을 학습합니다.
// 좋은 예시: Job 실행, 재시작, 중지, 상태 조회 등의 기능을 제공하는 대시보드를 구축하여 배치 운영을 효율화합니다.
// 나쁜 예시: Job 실행 및 관리를 커맨드라인이나 수동으로만 처리하여 운영에 비효율을 초래합니다.
package com.example.springbatch;

import org.springframework.batch.core.Job;
import org.springframework.batch.core.JobParameters;
import org.springframework.batch.core.JobParametersBuilder;
import org.springframework.batch.core.explore.JobExplorer;
import org.springframework.batch.core.launch.JobLauncher;
import org.springframework.batch.core.launch.JobOperator;
import org.springframework.context.annotation.Configuration;

import java.util.Properties;
import java.util.Set;

@Configuration
public class Step10_SpringBatchAdminDashboard {

    private final JobLauncher jobLauncher;
    private final JobExplorer jobExplorer;
    private final JobOperator jobOperator; // Job Operator를 통해 Job을 제어합니다.
    private final Job simpleJob; // Step1에서 정의한 Job을 주입받아 사용합니다.

    public Step10_SpringBatchAdminDashboard(JobLauncher jobLauncher, JobExplorer jobExplorer, JobOperator jobOperator, Job simpleJob) {
        this.jobLauncher = jobLauncher;
        this.jobExplorer = jobExplorer;
        this.jobOperator = jobOperator;
        this.simpleJob = simpleJob;
    }

    // Job을 수동으로 실행하는 메서드 (대시보드에서 호출될 수 있습니다)
    public void runJobManually() throws Exception {
        JobParameters jobParameters = new JobParametersBuilder()
                .addLong("time", System.currentTimeMillis())
                .toJobParameters();
        jobLauncher.run(simpleJob, jobParameters);
        System.out.println("Job 'simpleJob' manually started.");
    }

    // 실행 중인 Job들을 조회하는 메서드
    public void listRunningJobs() {
        Set<JobExecution> runningJobs = jobExplorer.findRunningJobExecutions("simpleJob");
        runningJobs.forEach(jobExecution ->
            System.out.println("Running Job ID: " + jobExecution.getId() + ", Status: " + jobExecution.getStatus())
        );
    }

    // Job을 중지하는 메서드 (JobOperator 사용)
    public void stopJob(long jobExecutionId) throws Exception {
        jobOperator.stop(jobExecutionId);
        System.out.println("Job execution " + jobExecutionId + " stopped.");
    }

    // Job을 재시작하는 메서드 (JobOperator 사용)
    public void restartJob(long jobExecutionId) throws Exception {
        jobOperator.restart(jobExecutionId);
        System.out.println("Job execution " + jobExecutionId + " restarted.");
    }

    // 실제 Spring Batch Admin은 별도의 WAR 파일이나 애플리케이션으로 배포됩니다.
    // 여기서는 Spring Batch Admin이 제공하는 기능들을 직접 코드로 구현하는 예시를 보여줍니다.
    // 이러한 메서드들은 웹 컨트롤러 등을 통해 UI와 연결될 수 있습니다.
}
