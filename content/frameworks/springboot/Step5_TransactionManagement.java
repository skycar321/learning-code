package com.example.springboot;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;

/**
 * ========================================================================================
 * Step 5: 트랜잭션 관리 (Transaction Management) A-Z 완전 정복
 * ========================================================================================
 *
 * 이 파일은 Spring의 선언적 트랜잭션 `@Transactional`의 동작 원리와
 * 실무에서 가장 빈번하게 발생하는 **프록시 내부 호출(Self-Invocation) 문제**를 다룹니다.
 *
 * [학습 목표]
 * 1. 트랜잭션의 ACID 속성과 Spring이 이를 어떻게 보장하는지 이해합니다.
 * 2. 체크 예외(Checked Exception) 발생 시 롤백이 안 되는 함정을 피하는 법을 배웁니다.
 * 3. **프록시 내부 호출**이 무엇이며, 왜 트랜잭션이 적용되지 않는지 원리를 깨닫습니다.
 * 4. 전파 속성(Propagation)을 이용해 트랜잭션을 정교하게 제어하는 법을 익힙니다.
 */

@SpringBootApplication
public class Step5_TransactionManagement {
    public static void main(String[] args) {
        SpringApplication.run(Step5_TransactionManagement.class, args);
    }
}

// ========================================================================================
// 1. [BAD Example] 트랜잭션의 흔한 오해와 실수
// ========================================================================================

@Service
class BadTransactionService {

    /**
     * [실수 1: 예외를 먹어버림 (Swallowing Exception)]
     * try-catch로 예외를 잡아버리면, Spring은 예외가 발생했다는 사실을 모릅니다.
     * 따라서 롤백(Rollback)되지 않고 커밋(Commit)됩니다. 데이터 정합성이 깨집니다.
     */
    @Transactional
    public void doSomethingWrong() {
        try {
            // DB 작업 1 (성공)
            // DB 작업 2 (예외 발생!)
            throw new RuntimeException("DB Error");
        } catch (Exception e) {
            // 로그만 찍고 넘어감 -> 롤백 안 됨!
            System.out.println("에러 났지만 괜찮아...");
        }
    }

    /**
     * [실수 2: 체크 예외 (Checked Exception) 무시]
     * Spring의 기본 설정은 `RuntimeException`과 `Error`만 롤백합니다.
     * `IOException` 같은 체크 예외가 발생하면 롤백하지 않고 커밋합니다.
     */
    @Transactional
    public void fileOperationFailed() throws IOException {
        // DB 저장
        throw new IOException("파일 저장 실패"); // 롤백 안 됨! DB에는 저장됨.
    }

    /**
     * [실수 3: 프록시 내부 호출 (Self-Invocation)] - 매우 중요!
     * `externalCall`에는 트랜잭션이 없고, `internalCall`에는 트랜잭션이 있습니다.
     * 하지만 `this.internalCall()`을 호출하면 트랜잭션이 적용되지 않습니다.
     *
     * [이유] Spring AOP는 프록시 객체를 통해 동작합니다.
     * 외부에서 호출할 땐 프록시를 거치지만(`proxy.externalCall`),
     * 내부에서 `this.`로 호출하면 프록시를 거치지 않고 원본 객체의 메서드를 바로 호출하기 때문입니다.
     */
    public void externalCall() {
        System.out.println("외부 호출 (트랜잭션 없음)");
        this.internalCall(); // 트랜잭션 적용 안 됨!!!
    }

    @Transactional
    public void internalCall() {
        System.out.println("내부 호출 (트랜잭션 적용 기대했으나 실패)");
    }
}

// ========================================================================================
// 2. [GOOD Example] 올바른 트랜잭션 사용 패턴
// ========================================================================================

@Service
class GoodTransactionService {

    /**
     * [해결 1: 체크 예외 롤백 설정]
     * `rollbackFor` 옵션을 사용하여 모든 예외에 대해 롤백하도록 명시합니다.
     */
    @Transactional(rollbackFor = Exception.class)
    public void fileOperationWithRollback() throws IOException {
        // DB 저장
        throw new IOException("파일 저장 실패"); // 이제 롤백 됩니다.
    }

    /**
     * [해결 2: 읽기 전용 트랜잭션]
     * 성능 최적화를 위해 조회 메서드에는 `readOnly = true`를 붙입니다.
     * (Dirty Checking 스냅샷 생성을 안 해서 메모리 절약, 마스터/슬레이브 DB 분기 가능)
     */
    @Transactional(readOnly = true)
    public void getInfo() {
        // 조회 로직
    }
}

// ========================================================================================
// 3. 전파 속성 (Propagation) 활용 - REQUIRES_NEW
// ========================================================================================

@Service
class OrderService {
    private final AuditService auditService; // 별도 서비스로 분리 (Self-Invocation 해결)

    public OrderService(AuditService auditService) {
        this.auditService = auditService;
    }

    /**
     * [시나리오]
     * 주문 처리는 실패해서 롤백되더라도, "주문 시도했다"는 로그(Audit)는 DB에 남겨야 합니다.
     */
    @Transactional
    public void processOrder() {
        try {
            auditService.log("주문 시도"); // 항상 커밋되어야 함
            
            // 핵심 비즈니스 로직
            throw new RuntimeException("결제 실패!"); // 롤백 발생

        } catch (Exception e) {
            System.out.println("주문 실패, 하지만 로그는 남음");
            // 여기서 예외를 다시 던지면 주문 트랜잭션은 롤백됩니다.
        }
    }
}

@Service
class AuditService {
    /**
     * [Propagation.REQUIRES_NEW]
     * 부모 트랜잭션(OrderService)이 있든 없든, 무조건 새로운 트랜잭션을 만듭니다.
     * 부모 트랜잭션이 롤백되어도, 이 트랜잭션은 이미 커밋되었다면 롤백되지 않습니다.
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void log(String message) {
        System.out.println("Audit Log 저장: " + message);
        // DB save logic...
    }
}