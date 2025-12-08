package com.example.springboot;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * ========================================================================================
 * Step 8: 필터(Filter)와 인터셉터(Interceptor) A-Z 완전 정복
 * ========================================================================================
 *
 * 이 파일은 웹 요청의 앞단에서 공통 로직을 처리하는 두 가지 핵심 기술을 비교합니다.
 * 면접에서 가장 많이 물어보는 질문 중 하나인 "필터와 인터셉터의 차이"를 코드로 확실히 이해합시다.
 *
 * [학습 목표]
 * 1. 실행 시점의 차이(DispatcherServlet 전/후)를 이해합니다.
 * 2. 필터(Filter)가 서블릿 컨테이너 레벨에서 동작함을 이해합니다. (Spring Bean 사용 주의)
 * 3. 인터셉터(Interceptor)가 Spring MVC 레벨에서 동작함을 이해합니다. (Controller 정보 접근 가능)
 * 4. [주의] 필터에서 Request Body를 읽으면 컨트롤러에서 못 읽는 문제 해결법을 배웁니다.
 */

@SpringBootApplication
public class Step8_InterceptorAndFilter {
    public static void main(String[] args) {
        SpringApplication.run(Step8_InterceptorAndFilter.class, args);
    }
}

// ========================================================================================
// 1. 서블릿 필터 (Filter) - 웹 애플리케이션의 대문
// ========================================================================================

/**
 * [Filter 특징]
 * - 위치: Client <-> Filter <-> DispatcherServlet
 * - 관할: Web Container (Tomcat)
 * - 용도: 인코딩 변환(UTF-8), 보안(XSS, CORS), 전역 로깅
 * - 주의: 여기서 예외가 터지면 @ControllerAdvice가 못 잡습니다! (ErrorController로 감)
 */
@Component // Spring Bean으로 등록 (자동으로 모든 URL 패턴에 적용됨)
class LoggingFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest req = (HttpServletRequest) request;
        long startTime = System.currentTimeMillis();
        
        System.out.println("[Filter] 요청 들어옴: " + req.getRequestURI());

        /*
         * [주의: Request Body 읽기 금지]
         * 여기서 `req.getInputStream()`을 해서 Body를 읽어버리면,
         * 스트림은 한 번만 읽을 수 있기 때문에 뒤에 있는 Controller가 Body를 읽을 수 없어서
         * "Required request body is missing" 에러가 발생합니다.
         * -> 해결책: ContentCachingRequestWrapper 사용 (고급 주제)
         */

        // 다음 필터 또는 서블릿으로 전달 (필수!)
        chain.doFilter(request, response);

        long duration = System.currentTimeMillis() - startTime;
        System.out.println("[Filter] 응답 나감 (소요시간: " + duration + "ms)");
    }
}

/**
 * [팁] 필터 순서 지정이나 특정 URL 패턴만 적용하고 싶다면?
 * @Component 대신 FilterRegistrationBean을 사용하세요.
 */
@Configuration
class FilterConfig {
    // @Bean
    public FilterRegistrationBean<LoggingFilter> loggingFilter() {
        FilterRegistrationBean<LoggingFilter> registrationBean = new FilterRegistrationBean<>();
        registrationBean.setFilter(new LoggingFilter());
        registrationBean.addUrlPatterns("/api/*"); // 특정 URL만 적용
        registrationBean.setOrder(1); // 순서 지정
        return registrationBean;
    }
}

// ========================================================================================
// 2. 스프링 인터셉터 (Interceptor) - 컨트롤러의 비서
// ========================================================================================

/**
 * [Interceptor 특징]
 * - 위치: DispatcherServlet <-> Interceptor <-> Controller
 * - 관할: Spring Context
 * - 용도: 인증/인가(JWT 검사), API 호출 로깅, Controller로 넘겨주는 데이터 가공
 * - 장점: HandlerMethod 파라미터를 통해 "어떤 컨트롤러 메서드"가 호출될지 알 수 있음.
 */
@Component
class AuthInterceptor implements HandlerInterceptor {

    // 컨트롤러 실행 전 (return false면 컨트롤러 실행 안 함)
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        System.out.println("[Interceptor] preHandle - 컨트롤러 실행 직전");
        
        // 예: 인증 헤더 검사
        String authHeader = request.getHeader("Authorization");
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            // response.sendError(401, "Unauthorized");
            // return false; // 차단
            System.out.println("[Interceptor] 인증 헤더 없음 (테스트를 위해 통과)");
        }
        
        return true; // 통과
    }

    // 컨트롤러 실행 후 (뷰 렌더링 전)
    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {
        System.out.println("[Interceptor] postHandle - 컨트롤러 실행 완료, 응답 나가기 전");
    }

    // 뷰 렌더링까지 완료 후
    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
        System.out.println("[Interceptor] afterCompletion - 완전히 끝남");
        if (ex != null) {
            System.out.println("[Interceptor] 예외 발생했음: " + ex.getMessage());
        }
    }
}

// 인터셉터 등록 설정
@Configuration
class WebMvcConfig implements WebMvcConfigurer {
    
    private final AuthInterceptor authInterceptor;

    public WebMvcConfig(AuthInterceptor authInterceptor) {
        this.authInterceptor = authInterceptor;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(authInterceptor)
                .addPathPatterns("/api/**") // 적용할 패턴
                .excludePathPatterns("/api/public/**"); // 제외할 패턴
    }
}

// ========================================================================================
// 3. 테스트용 컨트롤러
// ========================================================================================

@RestController
class TestController {

    @GetMapping("/api/hello")
    public String hello() {
        System.out.println("[Controller] hello 메서드 실행");
        return "Hello World";
    }
}