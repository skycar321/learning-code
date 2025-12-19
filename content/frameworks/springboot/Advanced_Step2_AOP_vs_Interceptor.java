package com.example.springboot;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Configuration;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.Arrays;

/**
 * ========================================================================================
 * Advanced Step 2: Filter vs Interceptor vs AOP 완전 정복
 * ========================================================================================
 *
 * 이 파일은 Spring 웹 애플리케이션의 3대 공통 관심사 처리 기술을 심층 비교합니다.
 * 실행 시점의 차이뿐만 아니라, 실무에서 마주하는 다양한 시나리오별로
 * "도대체 무엇을 써야 하는가?"에 대한 명확한 해답(Decision Matrix)을 제공합니다.
 *
 * [실행 순서 흐름도]
 * Client Request
 *    ↓
 * [Filter] (Web Container 영역: 인코딩, 보안 필터)
 *    ↓
 * DispatcherServlet (Spring MVC 진입)
 *    ↓
 * [Interceptor] preHandle (Handler Mapping 후)
 *    ↓
 * [AOP] @Around Before (Proxy 진입)
 *    ↓
 * [Controller] 비즈니스 로직 수행
 *    ↓
 * [AOP] @Around After (Proxy 탈출)
 *    ↓
 * [Interceptor] postHandle (View 렌더링 전)
 *    ↓
 * [Interceptor] afterCompletion (View 렌더링 후)
 *    ↓
 * [Filter] (Response 나가기 전)
 *    ↓
 * Client Response
 */

@SpringBootApplication
public class Advanced_Step2_AOP_vs_Interceptor {
    public static void main(String[] args) {
        SpringApplication.run(Advanced_Step2_AOP_vs_Interceptor.class, args);
    }
}

// (기존 Interceptor, AOP, Controller 코드는 동일하게 유지하되, 시나리오 섹션을 대폭 확장합니다.)

// ========================================================================================
// 1. Spring MVC Interceptor (웹 계층 제어)
// ========================================================================================
@Component
class CompareInterceptor implements HandlerInterceptor {
    private final Logger logger = LoggerFactory.getLogger(CompareInterceptor.class);

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        logger.info("[Interceptor] 1. preHandle - 요청 URI: {}", request.getRequestURI());
        return true;
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {
        logger.info("[Interceptor] 4. postHandle - 컨트롤러 실행 후");
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
        logger.info("[Interceptor] 5. afterCompletion - 요청 처리 완전 종료");
    }
}

@Configuration
class WebConfig implements WebMvcConfigurer {
    private final CompareInterceptor compareInterceptor;

    public WebConfig(CompareInterceptor compareInterceptor) {
        this.compareInterceptor = compareInterceptor;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(compareInterceptor).addPathPatterns("/compare/**");
    }
}

// ========================================================================================
// 2. Spring AOP (비즈니스 계층 제어)
// ========================================================================================
@Aspect
@Component
class CompareAspect {
    private final Logger logger = LoggerFactory.getLogger(CompareAspect.class);

    @Around("execution(* com.example.springboot.CompareController.*(..))")
    public Object aroundAdvice(ProceedingJoinPoint joinPoint) throws Throwable {
        logger.info("[AOP] 2. @Around (Before) - 메서드: {}", joinPoint.getSignature().getName());
        Object result = joinPoint.proceed();
        logger.info("[AOP] 3. @Around (After) - 리턴값: {}", result);
        return result;
    }
}

// ========================================================================================
// 3. 비교 테스트용 컨트롤러
// ========================================================================================
@RestController
@RequestMapping("/compare")
class CompareController {
    private final Logger logger = LoggerFactory.getLogger(CompareController.class);

    @GetMapping("/{name}")
    public String testMethod(@PathVariable String name) {
        logger.info("[Controller] 핵심 비즈니스 로직 실행 (name: {})", name);
        return "Hello, " + name;
    }
}

// ========================================================================================
// 4. [핵심] 시나리오별 Best Practice 가이드 (Filter vs Interceptor vs AOP)
// ========================================================================================

/*
 * 실무에서 자주 마주하는 12가지 시나리오에 대한 기술 선택 가이드입니다.
 *
 * [카테고리 1: 보안 및 인증 (Security)]
 * -----------------------------------------------------------------------------------------
 * 1. "전역적으로 XSS(Cross-Site Scripting) 공격을 방어하고 싶어."
 *    -> [정답] Filter
 *    -> [이유] 악성 스크립트가 담긴 Request Body를 읽어서 정화(Sanitize)하려면,
 *       Spring이 데이터를 객체로 변환하기 전에(DispatcherServlet 이전) 처리해야 합니다.
 *       (HttpServletRequestWrapper를 사용하여 Body를 감싸야 함)
 *
 * 2. "특정 URL 패턴(/admin/**)에 접근하는 사용자의 세션/JWT를 검사하고 싶어."
 *    -> [정답] Filter (Spring Security) 또는 Interceptor
 *    -> [이유] Spring Security는 Filter Chain 기반입니다. 만약 Security를 안 쓴다면
 *       Interceptor가 URL 패턴 매칭이 쉽고 컨트롤러와 가까워 구현하기 편리합니다.
 *
 * 3. "CORS(Cross-Origin) 설정을 전역적으로 처리해야 해."
 *    -> [정답] Filter
 *    -> [이유] 브라우저의 Preflight 요청(OPTIONS 메서드)은 DispatcherServlet까지 도달하지 않을 수 있습니다.
 *       가장 앞단인 Filter에서 처리하는 것이 확실합니다.
 *
 * [카테고리 2: 데이터 조작 및 변환 (Data Manipulation)]
 * -----------------------------------------------------------------------------------------
 * 4. "모든 요청/응답의 인코딩을 UTF-8로 강제하고 싶어."
 *    -> [정답] Filter
 *    -> [이유] 인코딩은 데이터를 읽기 시작하기 전에 설정해야 합니다. (CharacterEncodingFilter)
 *
 * 5. "들어오는 JSON 데이터를 파싱해서 특정 필드를 암호화/복호화하고 싶어."
 *    -> [정답] AOP (또는 RequestBodyAdvice)
 *    -> [이유] Filter/Interceptor는 JSON 문자열 상태만 볼 수 있습니다.
 *       이미 객체(DTO)로 변환된 상태에서 필드를 조작하려면 AOP가 가장 적합합니다.
 *
 * 6. "View(HTML)에 '사용자 이름', '현재 메뉴명' 같은 공통 속성을 넘겨주고 싶어."
 *    -> [정답] Interceptor (postHandle)
 *    -> [이유] ModelAndView 객체에 접근하여 데이터를 추가할 수 있는 유일한 단계입니다.
 *
 * [카테고리 3: 로깅 및 감사 (Logging & Audit)]
 * -----------------------------------------------------------------------------------------
 * 7. "들어온 요청의 Raw Body(JSON 원문)를 그대로 로그에 남기고 싶어."
 *    -> [정답] Filter (CachingRequestWrapper 사용)
 *    -> [이유] InputStream은 한 번 읽으면 사라집니다. Filter에서 래핑(Wrapping)해두지 않으면
 *       Controller가 Body를 읽을 때 에러가 납니다.
 *
 * 8. "어떤 Controller의 어떤 메서드가 호출되었고, 파라미터 값이 무엇인지 상세히 남기고 싶어."
 *    -> [정답] AOP
 *    -> [이유] Method Signature와 Arguments 객체에 직접 접근할 수 있는 것은 AOP뿐입니다.
 *
 * 9. "API 처리 소요 시간을 측정해서 슬로우 쿼리를 잡고 싶어."
 *    -> [정답] Interceptor (전체 API 시간) 또는 AOP (메서드별 정밀 시간)
 *    -> [이유] HTTP 요청~응답 전체 시간은 Interceptor가, Service/Repository 단위 시간은 AOP가 적합합니다.
 *
 * [카테고리 4: 기타 (Others)]
 * -----------------------------------------------------------------------------------------
 * 10. "이미지 리사이징이나 파일 압축을 하고 싶어."
 *     -> [정답] Filter
 *     -> [이유] 바이너리 데이터 스트림을 조작하는 것은 가장 Low Level인 Filter가 효율적입니다.
 *
 * 11. "트랜잭션(@Transactional)을 관리하고 싶어."
 *     -> [정답] AOP
 *     -> [이유] 트랜잭션은 비즈니스 로직의 성공/실패(예외)에 따라 커밋/롤백을 결정해야 하므로
 *        메서드 실행을 감싸는 AOP가 필수입니다. (Spring의 트랜잭션도 AOP 기반)
 *
 * 12. "다국어(Locale) 설정을 쿠키나 헤더에서 읽어오고 싶어."
 *     -> [정답] Interceptor (LocaleChangeInterceptor)
 *     -> [이유] Spring MVC의 LocaleResolver와 연동하기 가장 좋은 위치입니다.
 */