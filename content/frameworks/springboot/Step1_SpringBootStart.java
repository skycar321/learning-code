package com.example.springboot;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * ========================================================================================
 * Step 1: Spring Boot 시작하기 A-Z (Spring Boot Start)
 * ========================================================================================
 *
 * 이 파일은 Spring Boot 애플리케이션의 구조, 시작 방법, 그리고 핵심 원리인 '자동 설정(Auto Configuration)'에 대해
 * "좋은 예"와 "나쁜 예"를 비교하며 상세히 설명합니다.
 *
 * [학습 목표]
 * 1. `@SpringBootApplication` 어노테이션이 도대체 무슨 일을 하는지 마법을 해부합니다.
 * 2. Spring Boot가 어떻게 톰캣(Tomcat)을 내장하고 실행하는지 이해합니다.
 * 3. 프로젝트 패키지 구조를 어떻게 잡아야 하는지(Best Practice) 배웁니다.
 *
 * [핵심 개념: Auto Configuration (자동 설정)]
 * Spring Boot의 가장 큰 장점은 "설정보다 관례(Convention over Configuration)"입니다.
 * - 과거(Legacy Spring): DB 연결 하나 하려면 `context.xml`에 DataSource 빈 등록하고, 트랜잭션 매니저 설정하고... (복잡함)
 * - 현재(Spring Boot): `spring-boot-starter-data-jpa` 라이브러리만 넣으면, Spring Boot가
 *   "어? 라이브러리가 있네? 내가 자동으로 DataSource랑 EntityManager 만들어줄게!"라고 동작합니다.
 *   이것이 바로 `@EnableAutoConfiguration`의 역할입니다.
 */

// ========================================================================================
// 1. [BAD Example] 잘못된 구조와 습관
// ========================================================================================

/*
 * [나쁜 예시 1: 메인 클래스에 모든 로직 때려넣기]
 * - 초보자들이 흔히 하는 실수입니다.
 * - 메인 애플리케이션 클래스 파일 하나에 컨트롤러, 서비스, 리포지토리 클래스를 모두 내부 클래스로 정의하거나
 *   메인 메서드 안에 로직을 구현하면 안 됩니다.
 * - 이유:
 *   1. 유지보수 불가: 코드가 길어지면 읽을 수 없습니다.
 *   2. 테스트 불가: 단위 테스트를 작성하기 매우 어렵습니다.
 *   3. 객체지향 위반: 단일 책임 원칙(SRP)을 위반합니다.
 */
// class BadApp {
//     public static void main(String[] args) {
//         // 절차지향적인 코드...
//         System.out.println("서버 시작...");
//         handleRequest();
//     }
//     static void handleRequest() { ... }
// }


// ========================================================================================
// 2. [GOOD Example] 올바른 Spring Boot 애플리케이션 구조
// ========================================================================================

/**
 * [좋은 예시: @SpringBootApplication 활용 및 명확한 역할 분리]
 *
 * 1. `@SpringBootApplication`의 비밀
 *    이 어노테이션은 사실 다음 3가지 어노테이션을 합친 것입니다:
 *    - `@Configuration`: 이 클래스가 설정 파일(Bean 정의)임을 나타냅니다.
 *    - `@EnableAutoConfiguration`: classpath에 있는 라이브러리를 보고 필요한 빈을 자동으로 등록합니다.
 *      (예: H2 DB가 있으면 H2 Console을 자동 설정)
 *    - `@ComponentScan`: 현재 패키지(`com.example.springboot`)와 그 하위 패키지에서
 *      `@Component`, `@Service`, `@Repository`, `@Controller`가 붙은 클래스를 찾아 빈으로 등록합니다.
 *
 * 2. 패키지 구조 주의사항 (매우 중요!)
 *    메인 클래스(`Step1_SpringBootStart`)는 항상 **최상위 패키지(Root Package)**에 위치해야 합니다.
 *    예를 들어, 메인 클래스가 `com.example.app`에 있다면,
 *    - `com.example.app.user` (O: 스캔됨)
 *    - `com.example.app.order` (O: 스캔됨)
 *    - `com.example.other` (X: 스캔 안 됨 -> 빈 등록 실패 에러 발생!)
 */
@SpringBootApplication
public class Step1_SpringBootStart {

    public static void main(String[] args) {
        // SpringApplication.run():
        // 1. 내장 톰캣(Embedded Tomcat)을 시작합니다.
        // 2. Spring IoC 컨테이너(ApplicationContext)를 생성합니다.
        // 3. 톰캣과 스프링 컨텍스트를 연결합니다.
        SpringApplication.run(Step1_SpringBootStart.class, args);
    }

    /**
     * [팁] 간단한 전역 설정 빈 등록
     * 복잡한 로직은 별도 클래스로 분리해야 하지만,
     * 애플리케이션 전반에 걸친 간단한 설정은 메인 클래스에 @Bean으로 정의하기도 합니다.
     */
    @Bean
    public String applicationName() {
        return "Learning Platform v1.0";
    }
}

// ========================================================================================
// 3. 컴포넌트 분리 예시 (같은 파일에 있지만 실제로는 파일 분리 권장)
// ========================================================================================

/**
 * 실제 프로젝트에서는 `controller` 패키지를 만들고 그 안에 `HelloController.java`로 분리해야 합니다.
 * 여기서는 학습 편의를 위해 하나의 파일에 작성했습니다.
 */
@RestController // @Controller + @ResponseBody
class HelloController {

    @GetMapping("/")
    public String home() {
        return "Hello, Spring Boot! (Step 1: Start)";
    }

    @GetMapping("/info")
    public String info() {
        return "Spring Boot는 톰캣을 내장하고 있어 별도의 WAS 설치가 필요 없습니다.";
    }
}