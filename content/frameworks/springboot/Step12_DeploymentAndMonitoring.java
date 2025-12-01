// Step12_DeploymentAndMonitoring.java
// Spring Boot 애플리케이션 운영 환경 배포 및 모니터링 학습을 위한 코드 예시입니다.
// 이 파일은 Spring Boot Actuator, 프로파일(Profiles), 로깅(Logging) 설정을 사용하여
// 애플리케이션을 효율적으로 배포하고 모니터링하는 방법을 보여줍니다.
//
// 안정적인 서비스 운영을 위해서는 배포 전략 수립, 실시간 상태 모니터링,
// 문제 발생 시 빠른 진단 및 대응이 필수적입니다.

package com.example.deploymentmonitoring;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Profile;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.PostConstruct;

// -----------------------------------------------------------------------------
// 학습 포인트 1: Spring Boot Actuator 활용
// - 애플리케이션의 운영 정보를 제공하는 엔드포인트(Endpoints)를 제공합니다.
// - 헬스 체크, 메트릭, 환경 정보, 로거 레벨 변경 등 다양한 기능을 지원합니다.
// - 의존성: `spring-boot-starter-actuator`
// - 설정: `application.properties` 또는 `application.yml`에서 노출할 엔드포인트를 지정.
//   - `management.endpoints.web.exposure.include=*`: 모든 엔드포인트 노출 (개발 환경 권장)
//   - `management.endpoints.web.exposure.exclude=heapdump,threaddump`: 특정 엔드포인트 제외
//   - `management.endpoint.health.show-details=always`: 헬스 엔드포인트 상세 정보 항상 표시
// -----------------------------------------------------------------------------
@RestController
class MonitoringController {

    private static final Logger logger = LoggerFactory.getLogger(MonitoringController.class);

    @GetMapping("/hello")
    public String hello() {
        logger.info("Hello endpoint 호출됨.");
        return "Hello from Spring Boot Application!";
    }

    @GetMapping("/metrics/custom")
    public String customMetric() {
        // Actuator의 MeterRegistry를 사용하여 사용자 정의 메트릭을 발행할 수 있습니다.
        // 예를 들어, 카운터, 게이지, 타이머 등을 사용하여 비즈니스 로직의 성능을 측정합니다.
        // MeterRegistry meterRegistry = new SimpleMeterRegistry(); // 실제로는 Spring이 주입해줍니다.
        // meterRegistry.counter("my_custom_counter").increment();
        logger.info("사용자 정의 메트릭 엔드포인트 호출됨.");
        return "Custom metric endpoint called. Check /actuator/metrics for 'my_custom_counter'.";
    }

    // 나쁜 예시: 민감한 운영 정보를 노출하는 엔드포인트를 무분별하게 외부에 노출
    // - `management.endpoints.web.exposure.include=*` 설정 후,
    //   `management.endpoints.web.base-path=/` 로 설정하여 모든 Actuator 엔드포인트를
    //   애플리케이션의 루트 경로에 노출하는 것은 보안상 매우 위험합니다.
    // - 항상 `/actuator`와 같은 별도의 경로 아래에 노출하고, 인증/인가를 통해 접근을 제한해야 합니다.
}

// -----------------------------------------------------------------------------
// 학습 포인트 2: Spring Profiles 활용
// - 개발(dev), 테스트(test), 운영(prod) 등 다양한 환경에 따라 설정을 다르게 적용합니다.
// - `application-{profile}.properties` 또는 `application-{profile}.yml` 파일을 사용합니다.
// - 활성화 방법: `spring.profiles.active=dev` (application.properties),
//   또는 JVM 옵션 `-Dspring.profiles.active=dev`, 환경 변수 `SPRING_PROFILES_ACTIVE=dev`
// -----------------------------------------------------------------------------
@Component
@Profile("dev") // 'dev' 프로파일이 활성화될 때만 이 빈이 로드됩니다.
class DevEnvironmentConfig {
    @PostConstruct
    public void init() {
        System.out.println("개발(dev) 환경 설정이 로드되었습니다.");
        logger.warn("개발 환경에서는 특정 기능을 활성화하거나, 테스트 데이터를 로드할 수 있습니다.");
    }
}

@Component
@Profile("prod") // 'prod' 프로파일이 활성화될 때만 이 빈이 로드됩니다.
class ProdEnvironmentConfig {
    @PostConstruct
    public void init() {
        System.out.println("운영(prod) 환경 설정이 로드되었습니다.");
        logger.error("운영 환경에서는 보안, 성능, 안정성에 중점을 둔 설정을 사용해야 합니다.");
    }
}

// -----------------------------------------------------------------------------
// 학습 포인트 3: 로깅 (Logging) 설정
// - Spring Boot는 기본적으로 SLF4J와 Logback을 사용합니다.
// - `application.properties` 또는 `application.yml`에서 로깅 레벨, 출력 위치 등을 설정합니다.
// - 로깅 레벨: TRACE, DEBUG, INFO, WARN, ERROR
// -----------------------------------------------------------------------------
@Service
class LoggingService {
    private static final Logger serviceLogger = LoggerFactory.getLogger(LoggingService.class);

    public void performSomeOperation() {
        serviceLogger.trace("이것은 TRACE 레벨 메시지입니다.");
        serviceLogger.debug("이것은 DEBUG 레벨 메시지입니다.");
        serviceLogger.info("데이터 처리 시작...");
        try {
            // 비즈니스 로직
            throw new RuntimeException("예상치 못한 오류 발생!");
        } catch (Exception e) {
            serviceLogger.error("데이터 처리 중 오류 발생: {}\n", e.getMessage(), e); // 예외 스택 트레이스 포함
        }
        serviceLogger.warn("성능이 저하되고 있을 수 있습니다.");
        serviceLogger.info("데이터 처리 완료.");
    }

    // 나쁜 예시: 로깅 없이 모든 예외를 무시하거나, System.out.println() 사용
    // - 문제 발생 시 원인 파악이 불가능하고, 시스템 상태를 추적하기 어렵습니다.
    // - System.out.println()은 로깅 프레임워크의 유연한 설정(레벨, 출력 포맷)을 사용할 수 없습니다.
    public void badLoggingExample() {
        try {
            int result = 10 / 0;
        } catch (ArithmeticException e) {
            System.out.println("나쁜 예시: 예외 발생! " + e.getMessage()); // System.out.println 사용
        }
    }
}


@SpringBootApplication
public class DeploymentMonitoringApplication {
    public static void main(String[] args) {
        // 프로그램 인자로 프로파일을 활성화할 수 있습니다.
        // 예: --spring.profiles.active=dev
        // System.setProperty("spring.profiles.active", "dev");
        SpringApplication.run(DeploymentMonitoringApplication.class, args);
    }

    @Bean
    public org.springframework.boot.CommandLineRunner run(LoggingService loggingService) {
        return args -> {
            System.out.println("\n--- 로깅 서비스 작업 수행 ---");
            loggingService.performSomeOperation();
            loggingService.badLoggingExample();
            System.out.println("--- 로깅 서비스 작업 완료 ---");
        };
    }
}

/*
이 애플리케이션을 실행하고 다음 절차에 따라 테스트할 수 있습니다:

1. `application.properties` 설정 (src/main/resources/application.properties 파일 생성)
   - 다음 내용을 추가하여 Actuator 엔드포인트를 노출합니다.
     ```properties
     management.endpoints.web.exposure.include=*
     management.endpoint.health.show-details=always
     logging.level.root=INFO
     logging.level.com.example.deploymentmonitoring=DEBUG # 특정 패키지 로깅 레벨 설정
     ```

2. 애플리케이션 실행.

3. Actuator 엔드포인트 확인:
   - 헬스 체크: http://localhost:8080/actuator/health
   - 정보: http://localhost:8080/actuator/info
   - 메트릭: http://localhost:8080/actuator/metrics
   - 로거 레벨: http://localhost:8080/actuator/loggers
   - 사용자 정의 메트릭: http://localhost:8080/metrics/custom (이후 /actuator/metrics/{metricName}에서 확인)

4. 프로파일 활성화 테스트:
   - 애플리케이션 실행 시 VM 옵션 또는 프로그램 인자로 `spring.profiles.active` 설정.
   - 예: `java -jar target/your-app.jar --spring.profiles.active=prod`
   - 콘솔 로그에서 "운영(prod) 환경 설정이 로드되었습니다." 메시지 확인.

5. 로깅 레벨 변경 테스트:
   - `application.properties`에서 `logging.level`을 변경하며 로그 출력 확인.
   - `/actuator/loggers` 엔드포인트를 통해 런타임에 로거 레벨을 변경할 수도 있습니다 (POST 요청).
*/
