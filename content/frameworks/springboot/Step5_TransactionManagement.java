// Step5_TransactionManagement.java
// Spring Boot 트랜잭션 관리 학습을 위한 코드 예시입니다.
// 이 파일은 `@Transactional` 어노테이션의 다양한 사용법과 동작 원리를 이해하는 데 중점을 둡니다.
//
// Spring Boot는 선언적 트랜잭션 관리를 위해 AOP(Aspect-Oriented Programming) 기반의
// `@Transactional` 어노테이션을 제공합니다. 이를 통해 비즈니스 로직과 트랜잭션 로직을
// 분리하여 코드의 가독성과 유지보수성을 높일 수 있습니다.

package com.example.transactionmanagement;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.PostConstruct;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import java.util.List;

// -----------------------------------------------------------------------------
// 학습 포인트 1: 기본적인 `@Transactional` 어노테이션 사용법
// - 클래스 레벨: 해당 클래스의 모든 public 메서드에 트랜잭션 적용
// - 메서드 레벨: 특정 메서드에만 트랜잭션 적용 (클래스 레벨보다 우선순위 높음)
// - 런타임 예외(RuntimeException) 발생 시 롤백, 체크 예외(Checked Exception) 발생 시 커밋 (기본 동작)
// -----------------------------------------------------------------------------

// 예시 엔티티: User
@Entity
class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private int balance;

    public User() {}

    public User(String name, int balance) {
        this.name = name;
        this.balance = balance;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public int getBalance() { return balance; }
    public void setBalance(int balance) { this.balance = balance; }

    @Override
    public String toString() {
        return "User{id=" + id + ", name='" + name + "', balance=" + balance + "}";
    }
}

// 예시 Repository: UserRepository
@Repository
interface UserRepository extends JpaRepository<User, Long> {
    List<User> findByName(String name);
}

// 예시 서비스: UserService
@Service
class UserService {

    @Autowired
    private UserRepository userRepository;

    // 좋은 예시: 클래스 레벨에 @Transactional을 적용하여 모든 public 메서드가 트랜잭션 내에서 실행되도록 합니다.
    // 이렇게 하면 각 메서드마다 어노테이션을 붙일 필요 없이 일관된 트랜잭션 관리가 가능합니다.
    @Transactional
    public User createUser(String name, int balance) {
        User user = new User(name, balance);
        return userRepository.save(user);
    }

    // 나쁜 예시: 트랜잭션이 필요한 작업인데 @Transactional이 없는 경우
    // - 데이터 일관성이 깨질 위험이 있습니다.
    // - 예를 들어, 이 메서드 내에서 여러 DB 작업을 수행하다가 중간에 오류가 나면
    //   일부 작업만 커밋되고 일부는 커밋되지 않아 데이터 정합성이 훼손될 수 있습니다.
    public void transferMoneyBadExample(Long fromUserId, Long toUserId, int amount) {
        // 이 메서드에는 @Transactional이 없으므로, 두 save() 호출이 별개의 트랜잭션으로 처리되거나
        // 아예 트랜잭션 없이 실행될 수 있습니다. 만약 첫 번째 save 후 두 번째 save에서 예외가 발생하면
        // fromUser의 잔액만 줄어들고 toUser의 잔액은 늘어나지 않아 문제가 발생합니다.
        User fromUser = userRepository.findById(fromUserId).orElseThrow(() -> new IllegalArgumentException("보내는 유저를 찾을 수 없습니다."));
        User toUser = userRepository.findById(toUserId).orElseThrow(() -> new IllegalArgumentException("받는 유저를 찾을 수 없습니다."));

        if (fromUser.getBalance() < amount) {
            throw new IllegalArgumentException("잔액이 부족합니다.");
        }

        fromUser.setBalance(fromUser.getBalance() - amount);
        userRepository.save(fromUser); // 첫 번째 DB 작업

        // 만약 이 지점에서 예상치 못한 오류가 발생한다면? (예: 네트워크 문제, toUser 저장 실패)
        // fromUser의 잔액은 이미 줄어들었지만, toUser의 잔액은 늘어나지 않아 문제가 발생합니다.

        toUser.setBalance(toUser.getBalance() + amount);
        userRepository.save(toUser); // 두 번째 DB 작업
    }

    // 좋은 예시: 트랜잭션이 필요한 복합 작업에 @Transactional을 적용합니다.
    // - 두 번의 DB 작업(잔액 감소, 잔액 증가)이 하나의 논리적인 단위로 묶여 실행됩니다.
    // - 중간에 어떤 예외(RuntimeException)가 발생하더라도 모든 DB 작업이 롤백되어 데이터의 일관성을 유지합니다.
    @Transactional
    public void transferMoneyGoodExample(Long fromUserId, Long toUserId, int amount) {
        User fromUser = userRepository.findById(fromUserId).orElseThrow(() -> new IllegalArgumentException("보내는 유저를 찾을 수 없습니다."));
        User toUser = userRepository.findById(toUserId).orElseThrow(() -> new IllegalArgumentException("받는 유저를 찾을 수 없습니다."));

        if (fromUser.getBalance() < amount) {
            throw new IllegalArgumentException("잔액이 부족합니다.");
        }

        fromUser.setBalance(fromUser.getBalance() - amount);
        userRepository.save(fromUser);

        // 의도적인 오류 발생 지점 (테스트를 위해 주석 처리)
        // if (true) throw new RuntimeException("송금 중 의도적인 오류 발생!");

        toUser.setBalance(toUser.getBalance() + amount);
        userRepository.save(toUser);
    }

    // -----------------------------------------------------------------------------
    // 학습 포인트 2: 트랜잭션 전파 (Propagation)
    // - REQUIRED (기본값): 기존 트랜잭션이 있으면 참여, 없으면 새로 생성.
    // - REQUIRES_NEW: 항상 새 트랜잭션 생성. 기존 트랜잭션은 일시 중단.
    // - NESTED: 기존 트랜잭션 내에 중첩 트랜잭션 생성 (세이브포인트). JDBC가 지원해야 함.
    // - SUPPORTS: 기존 트랜잭션이 있으면 참여, 없으면 트랜잭션 없이 실행.
    // - NOT_SUPPORTED: 트랜잭션 없이 실행. 기존 트랜잭션은 일시 중단.
    // - NEVER: 트랜잭션 없이 실행. 기존 트랜잭션이 있으면 예외 발생.
    // - MANDATORY: 기존 트랜잭션이 있어야만 실행. 없으면 예외 발생.
    // -----------------------------------------------------------------------------

    // Propagation.REQUIRES_NEW 예시:
    // 이 메서드는 항상 새로운 트랜잭션을 시작합니다. 외부 트랜잭션의 성공/실패와 관계없이
    // 이 메서드 내의 작업은 독자적으로 커밋/롤백됩니다.
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void logTransaction(String message) {
        // 트랜잭션 로그를 저장하는 Repository (가상)
        // logRepository.save(new TransactionLog(message));
        System.out.println("새로운 트랜잭션으로 로그를 기록합니다: " + message);
        // 의도적으로 롤백 테스트를 위해 RuntimeException 발생
        // if (true) throw new RuntimeException("로그 트랜잭션 강제 롤백!");
    }

    @Transactional
    public void outerTransactionWithNewPropagation(String fromUserName, String toUserName, int amount) {
        System.out.println("외부 트랜잭션 시작.");
        // transferMoneyGoodExample은 REQUIRED (기본값)이므로 외부 트랜잭션에 참여합니다.
        transferMoneyGoodExample(userRepository.findByName(fromUserName).get(0).getId(),
                                 userRepository.findByName(toUserName).get(0).getId(),
                                 amount);

        // logTransaction은 REQUIRES_NEW 이므로 새로운 트랜잭션을 시작합니다.
        // 여기서 예외가 발생하더라도 transferMoneyGoodExample의 커밋에는 영향을 주지 않습니다.
        logTransaction("사용자 " + fromUserName + "에서 " + toUserName + "로 " + amount + " 송금 완료.");

        System.out.println("외부 트랜잭션 종료.");
        // 만약 여기서 RuntimeException이 발생하면, transferMoneyGoodExample은 롤백되지만, 
        // logTransaction은 REQUIRES_NEW로 이미 커밋되었을 수 있습니다 (logTransaction 내부에서 롤백되지 않았다면).
        // throw new RuntimeException("외부 트랜잭션 강제 롤백!");
    }


    // -----------------------------------------------------------------------------
    // 학습 포인트 3: 트랜잭션 격리 수준 (Isolation Level)
    // - 데이터베이스 트랜잭션이 동시에 실행될 때, 서로 간섭하지 않도록 보장하는 수준입니다.
    // - DEFAULT (기본값): DB의 기본 격리 수준을 따릅니다.
    // - READ_UNCOMMITTED: 커밋되지 않은 데이터 읽기 허용 (Dirty Read 발생 가능성 높음)
    // - READ_COMMITTED: 커밋된 데이터만 읽기 허용 (Dirty Read 방지, Non-Repeatable Read 발생 가능)
    // - REPEATABLE_READ: 트랜잭션 내에서 동일한 데이터를 여러 번 읽어도 항상 같은 값 보장 (Non-Repeatable Read 방지, Phantom Read 발생 가능)
    // - SERIALIZABLE: 가장 높은 격리 수준. 트랜잭션을 순차적으로 실행하는 것처럼 보장 (모든 읽기 일관성 보장, 성능 저하)
    // -----------------------------------------------------------------------------

    // Isolation.READ_COMMITTED 예시:
    // 이 메서드는 커밋된 데이터만 읽을 수 있도록 보장합니다.
    @Transactional(readOnly = true, isolation = Isolation.READ_COMMITTED)
    public List<User> getAllUsersReadCommitted() {
        System.out.println("READ_COMMITTED 격리 수준으로 모든 사용자 조회.");
        return userRepository.findAll();
    }

    // -----------------------------------------------------------------------------
    // 학습 포인트 4: readOnly 속성
    // - `readOnly = true`: 읽기 전용 트랜잭션으로 설정.
    //   - DB 리소스 최적화 (읽기 전용 연결 사용 가능)
    //   - 플러싱(flushing) 동작 변경 (Dirty Checking 안 함)
    //   - 데이터 변경 작업 시 예외 발생 (일반적으로)
    // -----------------------------------------------------------------------------

    @Transactional(readOnly = true)
    public List<User> getAllUsersReadOnly() {
        System.out.println("읽기 전용 트랜잭션으로 모든 사용자 조회.");
        return userRepository.findAll();
    }

    // readOnly 트랜잭션 내에서 쓰기 작업 시도 -> 예외 발생 (일반적으로)
    @Transactional(readOnly = true)
    public void attemptUpdateInReadOnlyTransaction(Long userId, String newName) {
        User user = userRepository.findById(userId).orElseThrow();
        user.setName(newName);
        // userRepository.save(user); // 이 시점에서 변경 감지 또는 플러싱 시 오류가 발생할 수 있습니다.
        System.out.println("읽기 전용 트랜잭션 내에서 업데이트 시도: " + newName);
    }

    public List<User> findAllUsers() {
        return userRepository.findAll();
    }
}

@SpringBootApplication
public class TransactionManagementApplication {

    @Autowired
    private UserService userService;
    @Autowired
    private UserRepository userRepository;

    public static void main(String[] args) {
        SpringApplication.run(TransactionManagementApplication.class, args);
    }

    @PostConstruct
    public void init() {
        // 초기 데이터 설정
        if (userRepository.count() == 0) {
            userService.createUser("Alice", 1000);
            userService.createUser("Bob", 500);
        }

        System.out.println("\n--- 초기 사용자 상태 ---");
        userService.findAllUsers().forEach(System.out::println);

        // 나쁜 예시 테스트: 트랜잭션 없이 송금 시도 (주석 해제 후 테스트)
        // System.out.println("\n--- 트랜잭션 없는 송금 (나쁜 예시) ---");
        // try {
        //     userService.transferMoneyBadExample(1L, 2L, 300);
        // } catch (Exception e) {
        //     System.err.println("오류 발생: " + e.getMessage());
        // }
        // System.out.println("--- 송금 후 사용자 상태 ---");
        // userService.findAllUsers().forEach(System.out::println);


        // 좋은 예시 테스트: 트랜잭션 적용 송금
        System.out.println("\n--- 트랜잭션 적용 송금 (좋은 예시) ---");
        try {
            userService.transferMoneyGoodExample(1L, 2L, 200);
            System.out.println("송금 성공!");
        } catch (Exception e) {
            System.err.println("송금 오류: " + e.getMessage());
        }
        System.out.println("--- 송금 후 사용자 상태 ---");
        userService.findAllUsers().forEach(System.out::println);

        // 롤백 테스트: 의도적인 오류 발생 시 롤백 확인
        System.out.println("\n--- 롤백 테스트 (의도적인 오류 발생) ---");
        try {
            // transferMoneyGoodExample 내부에 의도적인 RuntimeException을 주석 해제 후 테스트
            userService.transferMoneyGoodExample(1L, 2L, 5000); // 잔액 부족으로 예외 발생
            System.out.println("송금 성공!");
        } catch (Exception e) {
            System.err.println("송금 오류 (롤백 예상): " + e.getMessage());
        }
        System.out.println("--- 롤백 후 사용자 상태 (변경 없음 예상) ---");
        userService.findAllUsers().forEach(System.out::println);


        // Propagation.REQUIRES_NEW 테스트
        System.out.println("\n--- Propagation.REQUIRES_NEW 테스트 ---");
        // logTransaction 내부에서 RuntimeException을 주석 해제 후 테스트
        try {
            // Alice -> Bob 100 송금 시도. logTransaction은 새로운 트랜잭션에서 실행
            userService.outerTransactionWithNewPropagation("Alice", "Bob", 100);
            System.out.println("외부 트랜잭션 완료.");
        } catch (Exception e) {
            System.err.println("외부 트랜잭션 오류: " + e.getMessage());
        }
        System.out.println("--- Propagation 테스트 후 사용자 상태 ---");
        userService.findAllUsers().forEach(System.out::println);


        // readOnly 트랜잭션 내에서 업데이트 시도 테스트
        System.out.println("\n--- readOnly 트랜잭션 내 업데이트 시도 ---");
        try {
            userService.attemptUpdateInReadOnlyTransaction(1L, "Updated Alice");
            System.out.println("읽기 전용 트랜잭션에서 업데이트 성공 (?)");
        } catch (Exception e) {
            System.err.println("읽기 전용 트랜잭션에서 업데이트 오류 (예상): " + e.getMessage());
        }
        System.out.println("--- readOnly 업데이트 시도 후 사용자 상태 ---");
        userService.findAllUsers().forEach(System.out::println);
    }
}
