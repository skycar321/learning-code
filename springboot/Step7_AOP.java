// Step7_AOP.java
// Spring Boot AOP (Aspect-Oriented Programming) 학습을 위한 코드 예시입니다.
// 이 파일은 Spring AOP의 핵심 개념(Aspect, Join Point, Pointcut, Advice)을 이해하고,
// `@Aspect` 어노테이션을 활용하여 공통 관심사를 효과적으로 분리하는 방법을 보여줍니다.
//
// AOP는 로깅, 보안, 트랜잭션 관리 등 여러 모듈에서 반복적으로 사용되는
// 공통 관심사(Cross-cutting Concerns)를 분리하여 코드의 응집도를 높이고
// 중복을 제거하는 프로그래밍 패러다임입니다.

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
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

// -----------------------------------------------------------------------------
// 학습 포인트 1: Aspect 정의 (@Aspect)
// - `@Aspect` 어노테이션은 해당 클래스가 Aspect임을 나타냅니다.
// - `@Component`와 함께 사용하여 Spring의 빈으로 등록되어야 AOP가 동작합니다.
// -----------------------------------------------------------------------------
@Aspect
@Component
class LoggingAspect {

    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    // -----------------------------------------------------------------------------
    // 학습 포인트 2: Pointcut 정의 (@Pointcut)
    // - `execution()`: 가장 일반적인 Pointcut 지시자로, 메서드 실행 조인 포인트를 매치합니다.
    //   - `* com.example.aop.service.*.*(..)`: `com.example.aop.service` 패키지 아래의 모든 클래스의
    //     모든 메서드에 대해 매치합니다. (첫 번째 `*`는 리턴 타입, 두 번째 `*`는 메서드 이름, `(..)`는 모든 파라미터)
    // - `@annotation()`: 특정 어노테이션이 붙은 메서드에 매치합니다.
    // -----------------------------------------------------------------------------
    @Pointcut("execution(* com.example.aop.service.*.*(..))")
    private void serviceMethods() {}

    @Pointcut("@annotation(com.example.aop.LogExecutionTime)")
    private void logExecutionTimeMethods() {}

    // -----------------------------------------------------------------------------
    // 학습 포인트 3: Advice 정의 (Before, AfterReturning, AfterThrowing, After, Around)
    // - Advice는 Join Point에서 실행되는 실제 코드입니다.
    // - `JoinPoint`: Advice가 실행되는 시점의 정보를 제공합니다 (메서드 이름, 파라미터 등).
    // - `ProceedingJoinPoint`: `@Around` Advice에서 사용되며, 대상 메서드를 직접 실행할 수 있습니다.
    // -----------------------------------------------------------------------------

    // 3.1. `@Before`: 대상 메서드 실행 전에 Advice를 실행합니다.
    @Before("serviceMethods()")
    public void logBefore(JoinPoint joinPoint) {
        logger.info("Before method execution: {}.{}() with args: {}",
                joinPoint.getSignature().getDeclaringTypeName(),
                joinPoint.getSignature().getName(),
                joinPoint.getArgs());
    }

    // 3.2. `@AfterReturning`: 대상 메서드가 성공적으로 리턴된 후에 Advice를 실행합니다.
    // - `returning` 속성을 사용하여 메서드 반환 값을 Advice 메서드 인자로 받을 수 있습니다.
    @AfterReturning(pointcut = "serviceMethods()", returning = "result")
    public void logAfterReturning(JoinPoint joinPoint, Object result) {
        logger.info("After method execution (returning): {}.{}() returned: {}",
                joinPoint.getSignature().getDeclaringTypeName(),
                joinPoint.getSignature().getName(),
                result);
    }

    // 3.3. `@AfterThrowing`: 대상 메서드가 예외를 던진 후에 Advice를 실행합니다.
    // - `throwing` 속성을 사용하여 발생한 예외를 Advice 메서드 인자로 받을 수 있습니다.
    @AfterThrowing(pointcut = "serviceMethods()", throwing = "exception")
    public void logAfterThrowing(JoinPoint joinPoint, Throwable exception) {
        logger.error("After method execution (throwing): {}.{}() threw: {}",
                joinPoint.getSignature().getDeclaringTypeName(),
                joinPoint.getSignature().getName(),
                exception.getMessage());
    }

    // 3.4. `@After`: 대상 메서드 실행 후 (성공/실패와 관계없이) Advice를 실행합니다.
    @After("serviceMethods()")
    public void logAfter(JoinPoint joinPoint) {
        logger.info("After method execution (finally): {}.{}() finished.",
                joinPoint.getSignature().getDeclaringTypeName(),
                joinPoint.getSignature().getName());
    }

    // 3.5. `@Around`: 대상 메서드 실행 전, 후, 또는 예외 발생 시 모든 시점을 제어할 수 있습니다.
    // - `ProceedingJoinPoint`를 통해 대상 메서드 실행(`pjp.proceed()`)을 직접 제어합니다.
    // - 성능 측정, 캐싱 등에서 유용하게 사용됩니다.
    @Around("logExecutionTimeMethods()")
    public Object measureExecutionTime(ProceedingJoinPoint pjp) throws Throwable {
        long startTime = System.nanoTime();
        Object result = null;
        try {
            result = pjp.proceed(); // 대상 메서드 실행
        } finally {
            long endTime = System.nanoTime();
            long duration = TimeUnit.NANOSECONDS.toMillis(endTime - startTime);
            logger.info("Method {}.{}() executed in {} ms",
                    pjp.getSignature().getDeclaringTypeName(),
                    pjp.getSignature().getName(),
                    duration);
        }
        return result;
    }
}

// -----------------------------------------------------------------------------
// 학습 포인트 4: Custom Annotation을 이용한 AOP 적용
// - 특정 기능을 수행하는 메서드에만 AOP를 적용하고 싶을 때 유용합니다.
// -----------------------------------------------------------------------------
@Retention(RetentionPolicy.RUNTIME) // 런타임 시에도 어노테이션 정보를 유지
@Target(ElementType.METHOD) // 메서드에만 어노테이션 적용 가능
@interface LogExecutionTime {
}

// -----------------------------------------------------------------------------
// 예시 서비스: SampleService
// - AOP가 적용될 대상 클래스입니다.
// -----------------------------------------------------------------------------
@Service
class SampleService {

    private final Logger logger = LoggerFactory.getLogger(this.getClass());
    private final Map<Long, String> dataStore = new HashMap<>();

    public SampleService() {
        dataStore.put(1L, "Item A");
        dataStore.put(2L, "Item B");
    }

    public String getItem(Long id) {
        logger.info("Fetching item with ID: {}", id);
        if (!dataStore.containsKey(id)) {
            throw new IllegalArgumentException("Item not found for ID: " + id);
        }
        return dataStore.get(id);
    }

    @LogExecutionTime // Custom Annotation 적용
    public String processItem(Long id) throws InterruptedException {
        logger.info("Processing item with ID: {}", id);
        // 복잡한 비즈니스 로직 시뮬레이션
        TimeUnit.MILLISECONDS.sleep(random.nextInt(200) + 50);
        if (id == 99L) {
            throw new IllegalStateException("Simulated processing error for ID: " + id);
        }
        return "Processed: " + dataStore.getOrDefault(id, "Unknown Item");
    }

    private static final java.util.Random random = new java.util.Random();
}

// -----------------------------------------------------------------------------
// 예시 컨트롤러: SampleController
// - 웹 요청을 처리하고 SampleService를 호출합니다.
// -----------------------------------------------------------------------------
@RestController
@RequestMapping("/aop")
class SampleController {

    private final SampleService sampleService;

    public SampleController(SampleService sampleService) {
        this.sampleService = sampleService;
    }

    @GetMapping("/item/{id}")
    public String getItem(@PathVariable Long id) {
        try {
            return sampleService.getItem(id);
        } catch (IllegalArgumentException e) {
            return e.getMessage();
        }
    }

    @GetMapping("/process/{id}")
    public String processItem(@PathVariable Long id) throws InterruptedException {
        try {
            return sampleService.processItem(id);
        } catch (IllegalStateException e) {
            return e.getMessage();
        }
    }
}

@SpringBootApplication
public class AopApplication {
    public static void main(String[] args) {
        SpringApplication.run(AopApplication.class, args);
    }
}

/*
이 애플리케이션을 실행하고 다음 URL로 접근하여 테스트할 수 있습니다:

1. 정상적인 getItem 호출:
   GET http://localhost:8080/aop/item/1

2. 없는 아이템 조회 (예외 발생):
   GET http://localhost:8080/aop/item/3

3. 정상적인 processItem 호출 (실행 시간 로깅):
   GET http://localhost:8080/aop/process/1

4. processItem 예외 발생 (예외 로깅):
   GET http://localhost:8080/aop/process/99

콘솔 로그를 통해 Before, AfterReturning, AfterThrowing, After Advice 및
@LogExecutionTime 어노테이션에 의해 측정된 실행 시간을 확인할 수 있습니다.
*/