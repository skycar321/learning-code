package com.example.springboot;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Random;

/**
 * ========================================================================================
 * Step 12: 배포 및 모니터링 (Deployment & Monitoring) A-Z 완전 정복
 * ========================================================================================
 *
 * 이 파일은 Spring Boot 애플리케이션을 실제 운영 환경(Production)에 배포할 때
 * 반드시 알아야 할 **Actuator**, **Graceful Shutdown**, **Profile** 전략을 다룹니다.
 *
 * [학습 목표]
 * 1. **Actuator**를 통해 애플리케이션의 상태(Health, Metrics)를 모니터링하는 법을 배웁니다.
 * 2. **Graceful Shutdown**이 무엇이며, 왜 Kubernetes 환경에서 필수적인지 이해합니다.
 * 3. **Profile(dev/prod)**을 분리하여 환경별로 다른 설정을 적용하는 법을 익힙니다.
 * 4. [보안 주의] Actuator 엔드포인트를 외부에 노출하면 해킹의 타겟이 됨을 인지합니다.
 */

@SpringBootApplication
public class Step12_DeploymentAndMonitoring {
    public static void main(String[] args) {
        SpringApplication.run(Step12_DeploymentAndMonitoring.class, args);
    }
}

// ========================================================================================
// 1. [Actuator] 커스텀 헬스 체크 (Custom Health Indicator)
// ========================================================================================

/**
 * [Health Indicator]
 * K8s나 로드밸런서는 `/actuator/health`를 호출해서 서버가 살았는지 죽었는지 판단합니다.
 * 기본적으로 DB 연결, Disk 공간 등을 체크하지만, 비즈니스 로직상 중요한 외부 API 연결 상태 등을
 * 커스텀하게 추가할 수 있습니다.
 */
@Component
class ExternalApiHealthIndicator implements HealthIndicator {

    @Override
    public Health health() {
        // 예: 외부 결제 서비스 연결 상태 체크 로직
        boolean isConnected = checkExternalService();

        if (isConnected) {
            return Health.up().withDetail("ExternalService", "Available").build();
        } else {
            // DOWN 상태를 리턴하면 HTTP 503 Service Unavailable이 반환됨 -> 로드밸런서 제외됨
            return Health.down().withDetail("ExternalService", "Unreachable").build();
        }
    }

    private boolean checkExternalService() {
        // 실제로는 Ping을 날리거나 소켓 연결 테스트
        return new Random().nextBoolean(); // 랜덤으로 UP/DOWN 시뮬레이션
    }
}

// ========================================================================================
// 2. [Graceful Shutdown] 우아한 종료
// ========================================================================================

/**
 * [설정 방법 (application.properties)]
 * server.shutdown=graceful
 * spring.lifecycle.timeout-per-shutdown-phase=20s
 *
 * [동작 원리]
 * 1. 종료 시그널(SIGTERM)을 받으면 더 이상 새로운 요청을 받지 않습니다. (404/503 등 리턴 아님, 그냥 거부)
 * 2. 이미 처리 중인 요청이 있다면, 타임아웃 시간(20s) 동안 처리가 끝날 때까지 기다려줍니다.
 * 3. 처리가 다 끝나거나 타임아웃이 되면 그때 톰캣을 끕니다.
 * -> 사용자 입장에서 "갑자기 연결 끊김" 오류를 경험하지 않게 됩니다.
 */
@RestController
class GracefulShutdownController {

    @GetMapping("/api/long-process")
    public String longProcess() throws InterruptedException {
        System.out.println("긴 작업 시작... (종료 시그널을 보내보세요)");
        Thread.sleep(10000); // 10초 걸리는 작업
        System.out.println("긴 작업 완료!");
        return "Process Finished";
    }
}

// ========================================================================================
// 3. [Profile] 환경별 설정 분리 (dev vs prod)
// ========================================================================================

interface EnvironmentService {
    String getCurrentMode();
}

/**
 * @Profile("dev"): `spring.profiles.active=dev` 일 때만 빈으로 등록됩니다.
 */
@Component
@Profile("dev")
class DevEnvironmentService implements EnvironmentService {
    @Override
    public String getCurrentMode() {
        return "개발 환경 (H2 DB, Debug Log)";
    }
}

/**
 * @Profile("prod"): `spring.profiles.active=prod` 일 때만 빈으로 등록됩니다.
 */
@Component
@Profile("prod")
class ProdEnvironmentService implements EnvironmentService {
    @Override
    public String getCurrentMode() {
        return "운영 환경 (MySQL, Info Log, Actuator 보안 적용)";
    }
}

// ========================================================================================
// 4. [BAD Example] 운영 환경에서 절대 하지 말아야 할 설정
// ========================================================================================

/*
 * [application.properties 예시]
 *
 * # [BAD] 보안 위험! 모든 엔드포인트 노출
 * # management.endpoints.web.exposure.include=* 
 * # -> 환경변수, Bean 정보, 힙덤프까지 다 노출되어 해커가 서버를 완전히 장악할 수 있습니다.
 *
 * # [GOOD] 꼭 필요한 것만 노출
 * management.endpoints.web.exposure.include=health,metrics,prometheus
 *
 * # [BAD] 운영 DB 비밀번호 하드코딩
 * spring.datasource.password=1234 
 *
 * # [GOOD] 환경 변수 사용
 * spring.datasource.password=${DB_PASSWORD}
 */