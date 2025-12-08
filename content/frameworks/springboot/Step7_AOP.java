package com.example.aop;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import java.util.concurrent.TimeUnit;

/**
 * ========================================================================================
 * Step 7: Spring AOP (Aspect Oriented Programming) A-Z 완전 정복
 * ========================================================================================
 *
 * 이 파일은 Spring Boot에서 AOP를 사용하는 "좋은 예"와 "나쁜 예"를 비교하며,
 * AOP의 핵심 개념부터 실무 활용 패턴까지 상세히 설명합니다.
 *
 * [학습 목표]
 * 1. AOP(관점 지향 프로그래밍)가 무엇이며, 왜 필요한지 이해합니다. (횡단 관심사 분리)
 * 2. AOP의 5가지 핵심 용어(Aspect, JoinPoint, Pointcut, Advice, Weaving)를 코드로 익힙니다.
 * 3. 프록시(Proxy) 패턴이 Spring AOP에서 어떻게 동작하는지 이해합니다.
 * 4. 커스텀 어노테이션을 만들어 AOP를 우아하게 적용하는 방법을 배웁니다.
 *
 * [핵심 용어 설명]
 * - **횡단 관심사 (Cross-cutting Concerns)**: 로깅, 보안, 트랜잭션처럼 여러 핵심 로직에 공통적으로 들어가는 기능입니다.
 * - **Aspect**: 횡단 관심사를 모듈화한 것입니다. (예: "로그 남기는 기능 묶음")
 * - **Advice**: "언제" 공통 기능을 실행할지 정의합니다. (예: 메서드 시작 전? 끝난 후? 에러 났을 때?)
 * - **Pointcut**: "어디에" 공통 기능을 적용할지 정의합니다. (예: "UserService의 모든 메서드에")
 * - **JoinPoint**: Advice가 적용될 수 있는 지점입니다. (메서드 실행 시점 등)
 */

@SpringBootApplication
public class Step7_AOP {
    public static void main(String[] args) {
        SpringApplication.run(Step7_AOP.class, args);
    }
}

// ========================================================================================
// 1. [BAD Example] AOP 없이 횡단 관심사를 구현한 경우 (나쁜 예)
// ========================================================================================

/**
 * [문제점]
 * 1. 코드 중복: 모든 메서드마다 실행 시간 측정 코드가 반복됩니다.
 * 2. 유지보수 어려움: 측정 로직을 변경하려면 모든 메서드를 찾아가서 수정해야 합니다.
 * 3. 가독성 저하: 핵심 비즈니스 로직(데이터 조회 등)이 부가적인 로직(시간 측정)에 파묻혀 잘 안 보입니다.
 */
@Service
class BadService {
    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    public void doSomethingBad() {
        long startTime = System.currentTimeMillis(); // 공통 관심사 (시작 시간 측정)
        logger.info("메서드 시작");               // 공통 관심사 (로깅)

        try {
            // 핵심 비즈니스 로직
            Thread.sleep(100);
            logger.info("비즈니스 로직 실행 중...");

        } catch (InterruptedException e) {
            e.printStackTrace();
        } finally {
            long endTime = System.currentTimeMillis(); // 공통 관심사 (종료 시간 측정)
            logger.info("메서드 종료, 소요시간: {}ms", endTime - startTime); // 공통 관심사 (로깅)
        }
    }
}

// ========================================================================================
// 2. [GOOD Example] AOP를 사용하여 횡단 관심사를 분리한 경우 (좋은 예)
// ========================================================================================

/**
 * [개선된 점]
 * 1. 핵심 로직(`GoodService`)은 순수하게 비즈니스 로직만 남습니다.
 * 2. 공통 로직(`LoggingAspect`, `PerformanceAspect`)은 별도의 클래스로 분리되어 관리됩니다.
 * 3. 어노테이션(`@LogExecutionTime`) 하나만 붙이면 어디서든 기능을 재사용할 수 있습니다.
 */

// 2.1. 커스텀 어노테이션 정의
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
@interface LogExecutionTime {
    // 이 어노테이션이 붙은 메서드는 실행 시간을 측정하겠다는 표시입니다.
}

@Service
class GoodService {
    // 핵심 로직에만 집중! 지저분한 로깅 코드가 사라졌습니다.
    @LogExecutionTime
    public void doSomethingGood() throws InterruptedException {
        Thread.sleep(100);
        System.out.println("핵심 비즈니스 로직 실행 (GoodService)");
    }
}

// 2.2. Aspect 정의 (공통 기능 모듈화)
@Aspect // 이 클래스가 Aspect(공통 관심사 모듈)임을 나타냅니다.
@Component // Spring 빈으로 등록해야 AOP가 동작합니다.
class PerformanceAspect {
    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    /**
     * @Around Advice
     * - 가장 강력한 Advice입니다.
     * - 대상 메서드 실행 전(Before), 후(After), 예외 발생 시점 등을 모두 제어할 수 있습니다.
     * - ProceedingJoinPoint를 통해 대상 메서드를 언제 실행할지(`proceed()`) 결정합니다.
     */
    @Around("@annotation(com.example.aop.LogExecutionTime)") // Pointcut: 이 어노테이션이 붙은 곳에 적용
    public Object logExecutionTime(ProceedingJoinPoint joinPoint) throws Throwable {
        long startTime = System.currentTimeMillis();
        
        // Before 로직
        String methodName = joinPoint.getSignature().getName();
        logger.info("[AOP] {} 메서드 실행 시작", methodName);

        Object result = null;
        try {
            // 핵심 비즈니스 로직 실행 (Delegate)
            result = joinPoint.proceed(); 
        } catch (Exception e) {
            // 예외 처리 로직도 여기서 공통화 가능
            logger.error("[AOP] 메서드 실행 중 예외 발생: {}", e.getMessage());
            throw e;
        } finally {
            // After 로직
            long endTime = System.currentTimeMillis();
            logger.info("[AOP] {} 메서드 종료, 소요시간: {}ms", methodName, endTime - startTime);
        }

        return result;
    }
}

// ========================================================================================
// 3. 다양한 Advice 활용 예시 (A-Z 가이드)
// ========================================================================================

@Aspect
@Component
class GlobalLoggingAspect {
    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    // Pointcut 표현식 예시: com.example.aop 패키지 하위의 모든 Controller의 모든 메서드
    @Pointcut("execution(* com.example.aop.*Controller.*(..))")
    private void allControllerMethods() {}

    /**
     * @Before: 메서드 실행 '직전'에 실행됩니다.
     * - 주로 권한 체크, 입력값 검증, 로그 남기기 등에 사용됩니다.
     * - 메서드 실행을 막거나 리턴값을 변경할 수는 없습니다.
     */
    @Before("allControllerMethods()")
    public void beforeAdvice(JoinPoint joinPoint) {
        logger.info("[Before] 요청 들어옴: {}", joinPoint.getSignature().toShortString());
    }

    /**
     * @AfterReturning: 메서드가 '성공적으로' 리턴된 직후에 실행됩니다.
     * - 리턴값을 참조(`returning` 속성)하여 후처리 로직을 수행할 수 있습니다. (예: 응답 데이터 변환)
     */
    @AfterReturning(pointcut = "allControllerMethods()", returning = "result")
    public void afterReturningAdvice(JoinPoint joinPoint, Object result) {
        logger.info("[AfterReturning] 응답 데이터: {}", result);
    }

    /**
     * @AfterThrowing: 메서드 실행 중 '예외가 발생했을 때' 실행됩니다.
     * - 예외 발생 시 공통적으로 알림을 보내거나 에러 로그를 남길 때 유용합니다.
     */
    @AfterThrowing(pointcut = "allControllerMethods()", throwing = "ex")
    public void afterThrowingAdvice(JoinPoint joinPoint, Exception ex) {
        logger.error("[AfterThrowing] 에러 발생! : {}", ex.getMessage());
    }

    /**
     * @After: 메서드 종료 후 (성공/실패 여부 상관없이, 자바의 finally 블록처럼) 무조건 실행됩니다.
     * - 리소스 해제 등에 사용될 수 있습니다.
     */
    @After("allControllerMethods()")
    public void afterAdvice(JoinPoint joinPoint) {
        logger.info("[After] 메서드 실행 완료 (성공/실패 무관)");
    }
}

// 테스트용 컨트롤러
@RestController
class AopController {
    private final GoodService goodService;
    private final BadService badService;

    public AopController(GoodService goodService, BadService badService) {
        this.goodService = goodService;
        this.badService = badService;
    }

    @GetMapping("/aop/good")
    public String testGood() throws InterruptedException {
        goodService.doSomethingGood();
        return "Good Service executed";
    }

    @GetMapping("/aop/bad")
    public String testBad() {
        badService.doSomethingBad();
        return "Bad Service executed";
    }
    
    @GetMapping("/aop/error")
    public String testError() {
        throw new RuntimeException("의도적인 에러 발생!");
    }
}
