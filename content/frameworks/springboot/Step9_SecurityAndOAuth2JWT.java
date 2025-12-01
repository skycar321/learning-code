// Step9_SecurityAndOAuth2JWT.java
// Spring Boot 보안 (Spring Security & OAuth2/JWT) 학습을 위한 코드 예시입니다.
// 이 파일은 Spring Security를 사용하여 기본적인 인증/인가를 구현하고,
// OAuth2 및 JWT(JSON Web Token)를 활용하여 RESTful API의 보안을 강화하는 방법을 보여줍니다.
//
// Spring Security는 강력하고 유연한 인증(Authentication) 및 인가(Authorization) 기능을 제공하여
// 웹 애플리케이션의 보안을 쉽게 구축할 수 있도록 돕습니다.

package com.example.securityoauth2jwt;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.authentication.www.BasicAuthenticationFilter;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.filter.OncePerRequestFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.security.Key;
import java.time.Instant;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

// -----------------------------------------------------------------------------
// 학습 포인트 1: Spring Security 기본 설정
// - `@EnableWebSecurity`: Spring Security 활성화.
// - `WebSecurityConfigurerAdapter` 상속: 보안 설정을 커스터마이징.
// - `configure(AuthenticationManagerBuilder)`: 사용자 인증 설정.
// - `configure(HttpSecurity)`: HTTP 요청에 대한 보안 설정 (인가, 세션 관리 등).
// -----------------------------------------------------------------------------
@Configuration
@EnableWebSecurity
class SecurityConfig extends WebSecurityConfigurerAdapter {

    private final UserDetailsService myUserDetailsService;
    private final JwtRequestFilter jwtRequestFilter;

    public SecurityConfig(UserDetailsService myUserDetailsService, JwtRequestFilter jwtRequestFilter) {
        this.myUserDetailsService = myUserDetailsService;
        this.jwtRequestFilter = jwtRequestFilter;
    }

    // 1.1. 인증 관리자 설정: 사용자 정보(UserDetailsService)와 비밀번호 암호화(PasswordEncoder)를 정의
    @Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
        auth.userDetailsService(myUserDetailsService).passwordEncoder(passwordEncoder());
    }

    // 1.2. HTTP 요청 보안 설정: 어떤 요청에 인증이 필요한지, 세션은 어떻게 관리할지 등을 정의
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.csrf().disable() // REST API에서는 CSRF 보호가 필요하지 않은 경우가 많으므로 비활성화
                .authorizeRequests()
                .antMatchers("/authenticate", "/public/**", "/h2-console/**").permitAll() // 인증 없이 접근 허용
                .antMatchers("/admin/**").hasRole("ADMIN") // ADMIN 역할만 접근 허용
                .anyRequest().authenticated() // 그 외 모든 요청은 인증 필요
                .and().exceptionHandling()
                .authenticationEntryPoint((req, res, authException) -> {
                    // 인증 실패 시 401 Unauthorized 응답
                    res.setStatus(HttpStatus.UNAUTHORIZED.value());
                    res.setContentType(MediaType.APPLICATION_JSON_VALUE);
                    res.getWriter().write(new ObjectMapper().writeValueAsString(Map.of("error", "Unauthorized", "message", authException.getMessage())));
                })
                .accessDeniedHandler((req, res, accessDeniedException) -> {
                    // 인가 실패 시 403 Forbidden 응답
                    res.setStatus(HttpStatus.FORBIDDEN.value());
                    res.setContentType(MediaType.APPLICATION_JSON_VALUE);
                    res.getWriter().write(new ObjectMapper().writeValueAsString(Map.of("error", "Forbidden", "message", accessDeniedException.getMessage())));
                })
                .and().sessionManagement()
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS); // JWT 사용 시 세션 불필요 (Stateless)

        // JWT 필터 추가: UsernamePasswordAuthenticationFilter 이전에 JWT 토큰을 검증하는 필터를 등록
        http.addFilterBefore(jwtRequestFilter, UsernamePasswordAuthenticationFilter.class);

        // H2 Console 프레임 설정 (개발 환경에서만 사용)
        http.headers().frameOptions().sameOrigin();
    }

    // 1.3. 비밀번호 암호화 빈 등록: BCryptPasswordEncoder 사용
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    // 1.4. AuthenticationManager 빈 등록: @Autowired로 사용하기 위해 노출
    @Bean
    @Override
    public AuthenticationManager authenticationManagerBean() throws Exception {
        return super.authenticationManagerBean();
    }
}

// -----------------------------------------------------------------------------
// 학습 포인트 2: Custom UserDetailsService 구현
// - `UserDetailsService` 인터페이스를 구현하여 사용자 정보를 로드합니다.
// - 실제 DB에서 사용자 정보를 가져오는 로직을 여기에 구현합니다.
// -----------------------------------------------------------------------------
@Service
class MyUserDetailsService implements UserDetailsService {

    private final PasswordEncoder passwordEncoder;
    private final Map<String, UserDetails> users = new HashMap<>();

    public MyUserDetailsService(PasswordEncoder passwordEncoder) {
        this.passwordEncoder = passwordEncoder;
        // 예시 사용자: 실제 환경에서는 DB에서 가져옵니다.
        users.put("user", User.withUsername("user")
                .password(passwordEncoder.encode("password"))
                .roles("USER").build());
        users.put("admin", User.withUsername("admin")
                .password(passwordEncoder.encode("adminpass"))
                .roles("ADMIN", "USER").build());
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        UserDetails user = users.get(username);
        if (user == null) {
            throw new UsernameNotFoundException("사용자를 찾을 수 없습니다: " + username);
        }
        return user;
    }
}

// -----------------------------------------------------------------------------
// 학습 포인트 3: JWT (JSON Web Token) 구현
// - JWT는 클라이언트와 서버 간에 정보를 안전하게 전송하기 위한 간결하고 자가수용적인 토큰입니다.
// - `JwtUtil`: JWT 생성 및 유효성 검증 유틸리티 클래스.
// - `JwtRequestFilter`: 요청 헤더에서 JWT를 추출하고 검증하여 Spring Security Context에 인증 정보를 설정하는 필터.
// -----------------------------------------------------------------------------
class JwtUtil {
    // 실제 환경에서는 이 키를 외부에서 안전하게 관리해야 합니다 (환경 변수, Key Vault 등).
    // 여기에 하드코딩하지 마십시오.
    private static final Key SECRET_KEY = Keys.secretKeyFor(SignatureAlgorithm.HS256);
    private static final long EXPIRATION_TIME_MS = 1000 * 60 * 60 * 10; // 10시간

    public String generateToken(UserDetails userDetails) {
        Map<String, Object> claims = new HashMap<>();
        // JWT에 클레임(Claim) 추가: 사용자 역할(권한) 등을 포함할 수 있습니다.
        claims.put("roles", userDetails.getAuthorities().stream()
                .map(grantedAuthority -> grantedAuthority.getAuthority())
                .collect(Collections.toList()));

        return Jwts.builder()
                .setClaims(claims)
                .setSubject(userDetails.getUsername())
                .setIssuedAt(Date.from(Instant.now()))
                .setExpiration(Date.from(Instant.now().plusMillis(EXPIRATION_TIME_MS)))
                .signWith(SECRET_KEY, SignatureAlgorithm.HS256)
                .compact();
    }

    public Boolean validateToken(String token, UserDetails userDetails) {
        final String username = extractUsername(token);
        return (username.equals(userDetails.getUsername()) && !isTokenExpired(token));
    }

    public String extractUsername(String token) {
        return extractAllClaims(token).getSubject();
    }

    private Claims extractAllClaims(String token) {
        return Jwts.parserBuilder().setSigningKey(SECRET_KEY).build().parseClaimsJws(token).getBody();
    }

    private Boolean isTokenExpired(String token) {
        return extractAllClaims(token).getExpiration().before(new Date());
    }
}

@Component
class JwtRequestFilter extends OncePerRequestFilter {

    private final MyUserDetailsService userDetailsService;
    private final JwtUtil jwtUtil;

    public JwtRequestFilter(MyUserDetailsService userDetailsService, JwtUtil jwtUtil) {
        this.userDetailsService = userDetailsService;
        this.jwtUtil = jwtUtil;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {

        final String authorizationHeader = request.getHeader("Authorization");

        String username = null;
        String jwt = null;

        if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
            jwt = authorizationHeader.substring(7);
            try {
                username = jwtUtil.extractUsername(jwt);
            } catch (Exception e) {
                // 토큰 만료 또는 유효하지 않은 토큰 처리
                logger.warn("JWT 토큰 파싱 중 오류 발생: {}", e.getMessage());
            }
        }

        if (username != null && org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication() == null) {
            UserDetails userDetails = this.userDetailsService.loadUserByUsername(username);

            if (jwtUtil.validateToken(jwt, userDetails)) {
                UsernamePasswordAuthenticationToken usernamePasswordAuthenticationToken =
                        new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
                org.springframework.security.core.context.SecurityContextHolder.getContext().setAuthentication(usernamePasswordAuthenticationToken);
            }
        }
        chain.doFilter(request, response);
    }
}

// -----------------------------------------------------------------------------
// 학습 포인트 4: OAuth2 개념 및 Spring Security에서의 통합 (개념적 설명)
// - OAuth2는 인가(Authorization)를 위한 프레임워크입니다.
// - 클라이언트가 리소스 소유자를 대신하여 리소스 서버의 보호된 리소스에 접근할 수 있도록 하는 과정을 정의합니다.
// - `Authorization Code Grant`, `Client Credentials Grant` 등 다양한 흐름이 있습니다.
// - Spring Security는 `spring-security-oauth2-client` 및 `spring-security-oauth2-resource-server` 모듈을 통해
//   OAuth2 클라이언트 및 리소스 서버를 쉽게 구현할 수 있도록 지원합니다.
// - JWT는 OAuth2의 액세스 토큰으로 사용될 수 있습니다.
// -----------------------------------------------------------------------------
// 나쁜 예시: 모든 서드파티 서비스 연동 시 사용자 ID/PW를 직접 저장하거나 주고받는 방식
// - 보안 취약점이 크고, 사용자 동의 없이 접근 권한을 행사할 수 있게 됩니다.

// 좋은 예시: OAuth2를 통해 사용자 동의 기반으로 안전하게 접근 토큰을 발급받아 사용
// - 사용자 ID/PW를 직접 다룰 필요 없이, 필요한 권한(scope)만 얻어 리소스에 접근합니다.
// - Spring Security 5부터는 OAuth2 클라이언트 및 리소스 서버 기능을 내장하여 개발이 더욱 용이해졌습니다.
//   - application.yml에 OAuth2 클라이언트(예: Google, GitHub) 설정을 추가하면 됩니다.
//   - `spring.security.oauth2.client.registration.google.client-id=...`
//   - `spring.security.oauth2.client.registration.google.client-secret=...`

// -----------------------------------------------------------------------------
// 인증 및 인가 테스트를 위한 컨트롤러
// -----------------------------------------------------------------------------
@RestController
class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtUtil jwtUtil;
    private final UserDetailsService userDetailsService;

    public AuthController(AuthenticationManager authenticationManager, JwtUtil jwtUtil, UserDetailsService userDetailsService) {
        this.authenticationManager = authenticationManager;
        this.jwtUtil = jwtUtil;
        this.userDetailsService = userDetailsService;
    }

    // JWT 토큰 발급을 위한 인증 엔드포인트
    // POST /authenticate
    // Request Body: {"username": "user", "password": "password"}
    // Response: {"jwt": "eyJ..."}
    @PostMapping("/authenticate")
    public ResponseEntity<?> createAuthenticationToken(@RequestBody AuthenticationRequest authenticationRequest) throws Exception {
        try {
            // 사용자 인증 시도
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(authenticationRequest.getUsername(), authenticationRequest.getPassword())
            );
        } catch (BadCredentialsException e) {
            // 나쁜 예시: 클라이언트에게 "비밀번호가 틀렸습니다"와 같은 구체적인 오류 메시지를 직접 노출
            // 좋은 예시: "인증 실패"와 같은 일반적인 메시지를 반환하여 계정 유추를 어렵게 함
            throw new Exception("사용자 이름 또는 비밀번호가 잘못되었습니다.", e);
        }

        final UserDetails userDetails = userDetailsService.loadUserByUsername(authenticationRequest.getUsername());
        final String jwt = jwtUtil.generateToken(userDetails); // JWT 토큰 생성

        return ResponseEntity.ok(new AuthenticationResponse(jwt));
    }

    @GetMapping("/hello")
    public String hello(Authentication authentication) {
        // 인증된 사용자 정보는 Authentication 객체에서 얻을 수 있습니다.
        return "Hello, " + authentication.getName() + "! Your roles: " + authentication.getAuthorities();
    }

    @GetMapping("/admin/dashboard")
    public String adminDashboard(Authentication authentication) {
        return "Welcome to Admin Dashboard, " + authentication.getName() + "!";
    }

    @GetMapping("/public/info")
    public String publicInfo() {
        return "이 정보는 누구나 접근할 수 있습니다.";
    }
}

// 인증 요청 DTO
class AuthenticationRequest {
    private String username;
    private String password;

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
}

// 인증 응답 DTO
class AuthenticationResponse {
    private final String jwt;

    public AuthenticationResponse(String jwt) { this.jwt = jwt; }
    public String getJwt() { return jwt; }
}


@SpringBootApplication
public class SecurityOAuth2JwtApplication {
    public static void main(String[] args) {
        SpringApplication.run(SecurityOAuth2JwtApplication.class, args);
    }
}

/*
이 애플리케이션을 실행하고 다음 절차에 따라 테스트할 수 있습니다:

1. 애플리케이션 실행.

2. H2 Console 접근 (개발 환경에서 DB 확인용):
   - http://localhost:8080/h2-console
   - JDBC URL: jdbc:h2:mem:testdb
   - User Name: sa, Password: (비워둠)

3. 공개 정보 접근 (인증 불필요):
   GET http://localhost:8080/public/info

4. JWT 토큰 발급 (POST 요청):
   POST http://localhost:8080/authenticate
   Content-Type: application/json
   Body:
     {
       "username": "user",
       "password": "password"
     }
   응답으로 받은 JWT 토큰을 복사합니다.

5. 인증된 사용자만 접근 가능한 리소스 (`/hello`) 접근:
   GET http://localhost:8080/hello
   Headers:
     Authorization: Bearer <복사한 JWT 토큰>
   (예상 응답: "Hello, user! Your roles: [ROLE_USER]")

6. 관리자만 접근 가능한 리소스 (`/admin/dashboard`) 접근:
   - `user` 계정으로 시도 시 403 Forbidden 응답
     GET http://localhost:8080/admin/dashboard
     Headers:
       Authorization: Bearer <user 계정으로 발급받은 JWT 토큰>

   - `admin` 계정으로 토큰 발급 후 시도 시 정상 접근
     POST http://localhost:8080/authenticate
     Body:
       {
         "username": "admin",
         "password": "adminpass"
       }
     응답으로 받은 admin JWT 토큰으로 /admin/dashboard 접근
     GET http://localhost:8080/admin/dashboard
     Headers:
       Authorization: Bearer <admin 계정으로 발급받은 JWT 토큰>
     (예상 응답: "Welcome to Admin Dashboard, admin!")

7. 잘못된 토큰 또는 만료된 토큰으로 접근 시 401 Unauthorized 응답.
*/