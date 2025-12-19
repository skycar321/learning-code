package com.example.springboot;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;

/**
 * ========================================================================================
 * Step 2: 의존성 주입 (Dependency Injection) A-Z 완전 정복
 * ========================================================================================
 *
 * 이 파일은 Spring의 핵심 엔진인 DI(Dependency Injection)와 IoC(Inversion of Control)를 다룹니다.
 * 특히 실무에서 가장 논쟁이 많은 "필드 주입 vs 생성자 주입"에 대해 명확한 결론을 내려드립니다.
 *
 * [학습 목표]
 * 1. IoC(제어의 역전)와 DI(의존성 주입)가 무엇인지 개념을 잡습니다.
 * 2. 왜 "필드 주입(@Autowired private)"이 나쁜 패턴인지 이해합니다.
 * 3. 왜 "생성자 주입"이 좋은 패턴인지, Lombok과 함께 어떻게 사용하는지 배웁니다.
 * 4. @Component와 @Bean의 차이를 이해합니다.
 *
 * [핵심 개념: IoC & DI]
 * - **IoC (Inversion of Control)**: "제어의 역전". 개발자가 객체를 직접 생성(`new Service()`)하지 않고,
 *   Spring 프레임워크(컨테이너)가 객체의 생명주기를 관리하는 것입니다.
 * - **DI (Dependency Injection)**: "의존성 주입". 객체가 필요로 하는 의존 객체(Service, Repository 등)를
 *   직접 만드는 게 아니라, 외부(Spring)에서 주입받는 것입니다.
 */

@SpringBootApplication
public class Step2_DependencyInjection {
    public static void main(String[] args) {
        SpringApplication.run(Step2_DependencyInjection.class, args);
    }
}

// ========================================================================================
// 1. [BAD Example] 필드 주입 (Field Injection) - 사용하지 마세요!
// ========================================================================================

/**
 * [나쁜 예시: 필드 주입]
 * 과거에는 코드가 간결해서 많이 썼지만, 지금은 안티 패턴(Anti-Pattern)으로 취급됩니다.
 *
 * [단점 및 위험성]
 * 1. **테스트 어려움**: 단위 테스트 시 `BadService`를 생성해서 테스트하고 싶은데, `emailService`를 주입할 방법이 없습니다.
 *    (Spring 컨테이너 없이 순수 Java 코드로 테스트 불가능 -> 리플렉션 강제 사용)
 * 2. **불변성(Immutability) 위반**: 필드에 `final`을 붙일 수 없습니다. 객체가 생성된 후에 의존성이 변경될 수 있습니다.
 * 3. **순환 참조 숨김**: A가 B를 참조하고, B가 A를 참조하는 경우, 애플리케이션 구동 시점에 에러가 안 나고
 *    실제 호출 시점에 `StackOverflowError`가 터질 수 있습니다.
 */
@Service
class BadService {
    @Autowired // 필드에 바로 주입
    private EmailService emailService;

    public void send() {
        emailService.sendEmail();
    }
}

// ========================================================================================
// 2. [GOOD Example] 생성자 주입 (Constructor Injection) - 권장!
// ========================================================================================

/**
 * [좋은 예시: 생성자 주입]
 * Spring 4.3부터는 생성자가 하나만 있으면 `@Autowired`를 생략해도 자동으로 주입됩니다.
 *
 * [장점]
 * 1. **불변성 보장**: 필드에 `final` 키워드를 사용할 수 있습니다. (생성 시점에 주입되고 변경 불가)
 * 2. **테스트 용이**: 순수 Java 코드로 단위 테스트를 짤 때, 생성자로 가짜(Mock) 객체를 넣어줄 수 있습니다.
 *    예: `new GoodService(new MockEmailService());`
 * 3. **순환 참조 방지**: 앱 구동 시점에 순환 참조가 있으면 `BeanCurrentlyInCreationException`을 발생시켜 바로 알려줍니다.
 */
@Service
class GoodService {
    private final EmailService emailService; // final 사용 가능!

    // 생성자 주입 (Autowired 생략 가능)
    public GoodService(EmailService emailService) {
        this.emailService = emailService;
    }

    public void send() {
        emailService.sendEmail();
    }
}

// ========================================================================================
// 3. [BEST Practice] Lombok을 활용한 생성자 주입 (실무 표준)
// ========================================================================================

/**
 * [실무 추천 패턴]
 * 생성자 코드를 일일이 작성하는 것도 귀찮습니다. Lombok의 `@RequiredArgsConstructor`를 쓰면
 * `final`이 붙은 필드를 모아서 자동으로 생성자를 만들어줍니다. 코드가 가장 깔끔합니다.
 */
@Service
@RequiredArgsConstructor // Lombok: final 필드에 대한 생성자 자동 생성
class BestService {
    private final EmailService emailService;
    private final SmsService smsService;

    public void sendAll() {
        emailService.sendEmail();
        smsService.sendSms();
    }
}

// ========================================================================================
// 4. @Component vs @Bean 차이점
// ========================================================================================

/**
 * [질문] 언제 @Component를 쓰고, 언제 @Bean을 쓰나요?
 *
 * 1. **@Component (@Service, @Repository, @Controller)**:
 *    - 내가 작성한 클래스에 붙입니다.
 *    - Spring이 클래스파일을 스캔해서 자동으로 빈으로 등록합니다.
 *
 * 2. **@Bean**:
 *    - 외부 라이브러리(Gson, ObjectMapper 등)를 빈으로 등록할 때 씁니다.
 *    - 내가 코드를 수정할 수 없는 클래스는 클래스 위에 @Component를 못 붙이니까요.
 *    - 주로 `@Configuration` 클래스 안에서 메서드 위에 붙입니다.
 */
@Configuration
class AppConfig {

    @Bean // 외부 라이브러리 객체를 빈으로 등록
    public String globalAppName() {
        return "My Application";
    }
}

// ========================================================================================
// * 의존성 클래스들 (학습용)
// ========================================================================================

@Component
class EmailService {
    public void sendEmail() {
        System.out.println("Sending Email...");
    }
}

@Component
class SmsService {
    public void sendSms() {
        System.out.println("Sending SMS...");
    }
}