package com.example.springboot;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.stereotype.Component;
import org.springframework.util.StreamUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.util.ContentCachingRequestWrapper;
import org.springframework.web.util.ContentCachingResponseWrapper;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.charset.StandardCharsets;

/**
 * ========================================================================================
 * Step 15: 서블릿 필터 (Servlet Filter) A-Z 완전 정복
 * ========================================================================================
 *
 * 이 파일은 Spring Boot 웹 애플리케이션의 최전방 방어선인 "필터(Filter)"를 다룹니다.
 * 특히 실무에서 로깅 필터를 구현할 때 **서버를 뻗게 만드는 가장 흔한 실수(InputStream 중복 읽기)**와
 * 이를 해결하는 **표준 패턴(Wrapper)**을 상세히 설명합니다.
 *
 * [학습 목표]
 * 1. **필터의 생명주기(init -> doFilter -> destroy)**와 실행 위치를 이해합니다.
 * 2. `FilterRegistrationBean`을 사용하여 필터의 **실행 순서(Order)**를 제어하는 법을 배웁니다.
 * 3. **[치명적 실수]** Request Body를 필터에서 읽어버리면 컨트롤러가 읽지 못하는 원리를 이해합니다.
 * 4. **[해결책]** `ContentCachingRequestWrapper`를 사용하여 Body를 안전하게 로깅하는 법을 익힙니다.
 */

@SpringBootApplication
public class Step15_Filter {
    public static void main(String[] args) {
        SpringApplication.run(Step15_Filter.class, args);
    }
}

// ========================================================================================
// 1. [BAD Example] 잘못된 필터 구현 (서버 장애 유발)
// ========================================================================================

/**
 * [나쁜 필터: Request Body 직접 읽기]
 * 이 필터가 실행되면 컨트롤러는 `Required request body is missing` 에러를 뱉습니다.
 *
 * [이유: InputStream은 일회용이다!]
 * 1. `request.getInputStream()`은 물이 흐르는 수도관과 같습니다.
 * 2. 필터에서 물(데이터)을 다 마셔버리면(read), 파이프는 텅 빕니다.
 * 3. 이후에 실행되는 DispatcherServlet(컨트롤러)이 파이프를 열어보면 아무것도 없습니다.
 * 4. 결국 JSON 파싱에 실패하여 400 에러가 발생합니다.
 */
// @Component // 주석을 풀면 서버가 정상 동작하지 않습니다.
class BadLoggingFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        System.out.println("--- [BadFilter] 시작 ---");
        
        // 위험한 코드: Body를 읽어버림
        byte[] body = StreamUtils.copyToByteArray(request.getInputStream());
        System.out.println("Request Body: " + new String(body, StandardCharsets.UTF_8));

        // 여기서 chain.doFilter를 호출해도, 전달되는 request 객체의 InputStream은 이미 끝(EOF)에 도달해 있음.
        chain.doFilter(request, response); 
    }
}

// ========================================================================================
// 2. [GOOD Example] 올바른 필터 구현 (Wrapper 사용)
// ========================================================================================

/**
 * [좋은 필터: ContentCachingRequestWrapper 사용]
 * Spring이 제공하는 래퍼(Wrapper) 클래스를 사용하면 InputStream을 여러 번 읽을 수 있습니다.
 *
 * [동작 원리]
 * 1. 요청을 `ContentCachingRequestWrapper`로 감쌉니다.
 * 2. `chain.doFilter()`를 호출하여 컨트롤러가 데이터를 다 읽게(Consume) 합니다.
 * 3. 컨트롤러가 읽는 동안 Wrapper는 데이터를 내부 메모리(byte array)에 복사해 둡니다.
 * 4. `chain.doFilter()`가 리턴된 후(요청 처리 완료 후), Wrapper에 저장된 내용을 꺼내서 로깅합니다.
 */
class GoodLoggingFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        // 1. 래핑 (Wrapping)
        // HttpServletRequest로 형변환 후 래퍼에 담습니다.
        ContentCachingRequestWrapper wrappedRequest = 
                new ContentCachingRequestWrapper((HttpServletRequest) request);
        
        ContentCachingResponseWrapper wrappedResponse = 
                new ContentCachingResponseWrapper((HttpServletResponse) response);

        try {
            // 2. 요청 전달 (이 시점에는 아직 캐시된 데이터가 없음! 컨트롤러가 읽어야 캐시됨)
            // 중요: 원본 request가 아닌 wrappedRequest를 넘겨야 함
            chain.doFilter(wrappedRequest, wrappedResponse);
            
        } finally {
            // 3. 처리가 끝난 후(After Request) 로깅
            // 이제 컨트롤러가 스트림을 다 읽었으므로, 래퍼에 캐시된 데이터를 안전하게 꺼낼 수 있음.
            
            System.out.println("\n--- [GoodFilter] 요청/응답 로깅 ---");
            System.out.println("URI: " + wrappedRequest.getRequestURI());
            
            // Request Body 로깅
            byte[] reqBody = wrappedRequest.getContentAsByteArray();
            if (reqBody.length > 0) {
                System.out.println("Request Body: " + new String(reqBody, StandardCharsets.UTF_8));
            }

            // Response Body 로깅
            byte[] resBody = wrappedResponse.getContentAsByteArray();
            if (resBody.length > 0) {
                System.out.println("Response Body: " + new String(resBody, StandardCharsets.UTF_8));
            }
            
            // 중요: Response Body를 읽어서 로깅하면 클라이언트에게 갈 데이터가 사라짐.
            // 반드시 다시 복사해줘야 함!
            wrappedResponse.copyBodyToResponse();
        }
    }
}

// ========================================================================================
// 3. 필터 등록 및 순서 설정 (Configuration)
// ========================================================================================

@Configuration
class FilterConfiguration {

    /**
     * [FilterRegistrationBean]
     * 필터를 스프링 빈으로 등록하면서, URL 패턴과 실행 순서를 지정합니다.
     */
    @Bean
    public FilterRegistrationBean<GoodLoggingFilter> loggingFilter() {
        FilterRegistrationBean<GoodLoggingFilter> registrationBean = new FilterRegistrationBean<>();
        
        registrationBean.setFilter(new GoodLoggingFilter());
        registrationBean.addUrlPatterns("/api/*"); // /api 하위 경로만 적용
        registrationBean.setOrder(1); // 숫자가 낮을수록 먼저 실행됨 (가장 바깥쪽) 
        
        return registrationBean;
    }
}

// ========================================================================================
// 4. 테스트용 컨트롤러
// ========================================================================================

@RestController
class FilterTestController {

    record UserDto(String name, int age) {}

    /**
     * 이 메서드가 정상 실행되려면 필터가 InputStream을 망가뜨리지 않아야 함.
     */
    @PostMapping("/api/filter/test")
    public String testFilter(@RequestBody UserDto user) {
        System.out.println("[Controller] 받은 데이터: " + user);
        return "Hello, " + user.name();
    }
}

/*
[테스트 방법]
1. 앱 실행
2. POST 요청 전송 (Postman, curl)
   URL: http://localhost:8080/api/filter/test
   Header: Content-Type: application/json
   Body: {"name": "Tester", "age": 25}

[예상 결과]
- 콘솔 로그:
  --- [GoodFilter] 요청/응답 로깅 ---
  URI: /api/filter/test
  Request Body: {"name": "Tester", "age": 25}
  Response Body: Hello, Tester

[실패 케이스 테스트]
- BadLoggingFilter의 @Component 주석을 해제하고 재시작하면,
  Controller에서 "400 Bad Request" 에러가 발생합니다.
*/
