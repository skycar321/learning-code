// Step8_InterceptorAndFilter.java
// Spring Boot 인터셉터(Interceptor)와 서블릿 필터(Filter) 학습을 위한 코드 예시입니다.
// 이 파일은 웹 요청 처리 흐름에서 인터셉터와 필터가 어떻게 동작하며,
// 각각의 역할과 사용 시나리오, 구현 방법을 보여줍니다.
//
// 필터는 서블릿 스펙에 포함되어 있으며 DispatcherServlet 이전에 동작하여
// 모든 요청에 대해 공통적인 전/후 처리를 담당합니다.
// 인터셉터는 Spring MVC 스펙에 포함되어 있으며 DispatcherServlet 이후,
// 컨트롤러 메서드 이전에 동작하여 보다 세밀한 제어(HandlerInterceptor)가 가능합니다.

package com.example.interceptorfilter;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Collections;

// -----------------------------------------------------------------------------
// 학습 포인트 1: 서블릿 필터(Filter) 구현
// - `javax.servlet.Filter` 인터페이스를 구현합니다.
// - `doFilter` 메서드에서 실제 필터 로직을 구현합니다.
// - `FilterRegistrationBean`을 통해 Spring Boot에 등록합니다.
// - 특징: DispatcherServlet 이전에 동작, 요청/응답 전체에 적용, 서블릿 스펙.
// - 용도: 인코딩, 보안(XSS, CSRF), 로깅, 인증/인가(모든 요청에 대해), 이미지/정적 파일 처리 등.
// -----------------------------------------------------------------------------
class CustomFilter implements Filter {

    private static final Logger filterLogger = LoggerFactory.getLogger(CustomFilter.class);

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        filterLogger.info("CustomFilter 초기화됨.");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        filterLogger.info("필터 시작: 요청 URI = {}", httpRequest.getRequestURI());

        // 나쁜 예시: 필터에서 너무 많은 비즈니스 로직을 처리하거나, ControllerAdvice처럼
        // 예외를 직접 처리하려고 시도하는 것. 필터는 공통적인 웹 계층 로직에 집중해야 합니다.

        // 좋은 예시: 요청 전/후 로깅, 인코딩 설정, 보안 헤더 추가 등
        long startTime = System.currentTimeMillis();

        chain.doFilter(request, response); // 다음 필터 또는 DispatcherServlet으로 요청 전달

        long endTime = System.currentTimeMillis();
        filterLogger.info("필터 종료: 요청 URI = {}, 처리 시간 = {}ms", httpRequest.getRequestURI(), (endTime - startTime));
    }

    @Override
    public void destroy() {
        filterLogger.info("CustomFilter 소멸됨.");
    }
}

@Configuration
class FilterConfig {
    @Bean
    public FilterRegistrationBean<CustomFilter> customFilterRegistration() {
        FilterRegistrationBean<CustomFilter> registration = new FilterRegistrationBean<>();
        registration.setFilter(new CustomFilter());
        registration.setUrlPatterns(Collections.singletonList("/*")); // 모든 URL에 필터 적용
        registration.setOrder(1); // 필터 체인에서 순서 지정 (낮은 숫자가 먼저 실행)
        return registration;
    }

    // 다른 필터가 있다면 여기에 추가 등록할 수 있습니다.
    // 예를 들어, XSS 방지 필터, 인증 필터 등
}


// -----------------------------------------------------------------------------
// 학습 포인트 2: Spring MVC 인터셉터(Interceptor) 구현
// - `org.springframework.web.servlet.HandlerInterceptor` 인터페이스를 구현합니다.
// - `preHandle`, `postHandle`, `afterCompletion` 메서드를 오버라이드하여 로직 구현.
// - `WebMvcConfigurer`를 통해 Spring에 등록하고 URL 패턴을 지정합니다.
// - 특징: DispatcherServlet 이후, 컨트롤러 호출 전/후에 동작, Spring MVC 스펙.
// - 용도: 인증/인가(컨트롤러 기반), 권한 체크, 요청/응답 데이터 가공, 로깅, 다국어 처리, API 호출 시간 측정 등.
// -----------------------------------------------------------------------------
class CustomInterceptor implements HandlerInterceptor {

    private static final Logger interceptorLogger = LoggerFactory.getLogger(CustomInterceptor.class);

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // 요청 처리 전에 호출됩니다.
        // true를 반환하면 다음 인터셉터 또는 컨트롤러로 진행, false를 반환하면 요청 체인 중단.
        interceptorLogger.info("인터셉터 preHandle: 요청 URI = {}", request.getRequestURI());

        // 나쁜 예시: 인증/권한 로직을 직접 구현하여 컨트롤러에 부담을 주거나,
        // 모든 요청에 대해 복잡한 DB 쿼리를 실행하여 성능 저하를 유발하는 것.
        // 인터셉터는 경량화된 사전/사후 처리에 집중해야 합니다.

        // 좋은 예시: 세션 체크, 사용자 권한 확인 (특정 URI 패턴에만), 요청 속성 추가
        if (request.getRequestURI().startsWith("/admin") && request.getSession().getAttribute("userRole") == null) {
            interceptorLogger.warn("인증되지 않은 사용자 관리자 페이지 접근 시도.");
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized Access to Admin Page");
            return false; // 요청 처리 중단
        }
        request.setAttribute("requestStartTime", System.currentTimeMillis());
        return true;
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler,
                           ModelAndView modelAndView) throws Exception {
        // 컨트롤러 메서드 실행 후, 뷰 렌더링 전에 호출됩니다.
        // Model 데이터나 View 이름을 조작할 수 있습니다.
        interceptorLogger.info("인터셉터 postHandle: 요청 URI = {}", request.getRequestURI());
        if (modelAndView != null) {
            modelAndView.addObject("appName", "MySpringBootApp");
        }
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex)
            throws Exception {
        // 뷰 렌더링이 완료된 후 (요청 처리 완료 후) 호출됩니다.
        // 예외 발생 여부와 관계없이 실행되며, 자원 해제 등에 사용됩니다.
        long requestStartTime = (Long) request.getAttribute("requestStartTime");
        long endTime = System.currentTimeMillis();
        interceptorLogger.info("인터셉터 afterCompletion: 요청 URI = {}, 총 처리 시간 = {}ms, 예외 발생 여부 = {}",
                request.getRequestURI(), (endTime - requestStartTime), (ex != null ? "Yes" : "No"));
    }
}

@Configuration
class WebConfig implements WebMvcConfigurer {
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new CustomInterceptor())
                .addPathPatterns("/**") // 모든 URL에 인터셉터 적용
                .excludePathPatterns("/css/**", "/js/**"); // 정적 리소스 제외
        // 특정 패턴에만 적용하거나, 제외 패턴을 지정하여 세밀하게 제어할 수 있습니다.
    }

    // 다른 인터셉터가 있다면 여기에 추가 등록할 수 있습니다.
    // 예를 들어, 다국어 처리 인터셉터, 로케일 변경 인터셉터 등
}

// -----------------------------------------------------------------------------
// 예시 컨트롤러: InterceptorFilterController
// - 필터와 인터셉터가 동작하는 것을 확인하기 위한 간단한 컨트롤러입니다.
// -----------------------------------------------------------------------------
@RestController
@RequestMapping("/api")
class InterceptorFilterController {

    private static final Logger controllerLogger = LoggerFactory.getLogger(InterceptorFilterController.class);

    @GetMapping("/hello")
    public String hello() {
        controllerLogger.info("컨트롤러 메서드 실행: /api/hello");
        return "Hello from Spring Boot!";
    }

    @GetMapping("/greet/{name}")
    public String greet(@PathVariable String name) {
        controllerLogger.info("컨트롤러 메서드 실행: /api/greet/{}", name);
        return "Hello, " + name + "!";
    }

    @GetMapping("/admin/dashboard")
    public String adminDashboard(HttpServletRequest request) {
        // 이 경로는 CustomInterceptor에 의해 인증되지 않은 접근이 차단됩니다.
        request.getSession().setAttribute("userRole", "admin"); // 세션에 관리자 역할 설정 (테스트용)
        return "Welcome to Admin Dashboard!";
    }
}


@SpringBootApplication
public class InterceptorFilterApplication {
    public static void main(String[] args) {
        SpringApplication.run(InterceptorFilterApplication.class, args);
    }
}

/*
이 애플리케이션을 실행하고 다음 URL로 접근하여 테스트할 수 있습니다:

콘솔/로그에서 필터와 인터셉터의 로그를 확인하세요.

1. 정상적인 요청:
   GET http://localhost:8080/api/hello
   GET http://localhost:8080/api/greet/World

2. (인터셉터에 의해) 접근이 차단되는 관리자 페이지 요청:
   GET http://localhost:8080/api/admin/dashboard
   (로그에 "Unauthorized Access to Admin Page"가 표시되고 HTTP 401 에러를 받습니다.)

3. 관리자 권한 부여 후 접근 (세션 설정이 필요):
   - /api/admin/dashboard를 호출하기 전에 세션에 'userRole'을 'admin'으로 설정하는 과정이 필요합니다.
     이는 보통 로그인 처리 과정에서 이루어지지만, 이 예제에서는 편의상 컨트롤러에 추가했습니다.
     실제로는 Postman 등에서 세션을 유지하며 테스트해야 합니다.
     (간단한 테스트를 위해 /api/admin/dashboard 메서드 내에 request.getSession().setAttribute("userRole", "admin");
     코드를 임시로 활성화하고 테스트해볼 수 있습니다.)

*/
