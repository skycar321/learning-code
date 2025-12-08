package com.example.springboot;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.provisioning.InMemoryUserDetailsManager;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.filter.OncePerRequestFilter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.security.Key;
import java.util.Date;

/**
 * ========================================================================================
 * Step 9: Spring Security & JWT (A-Z 완전 정복) - 최신 Boot 3.x 기준
 * ========================================================================================
 *
 * 이 파일은 최신 Spring Security 6.x (Spring Boot 3.x) 표준에 맞춰
 * JWT 인증 및 권한 관리(Authorization)를 구현하는 방법을 다룹니다.
 * (구버전의 WebSecurityConfigurerAdapter는 사용하지 않습니다.)
 *
 * [학습 목표]
 * 1. **Stateful(세션) vs Stateless(토큰)** 보안 아키텍처의 차이를 이해합니다.
 * 2. **SecurityFilterChain** 빈을 통해 보안 정책을 설정하는 법을 배웁니다.
 * 3. **JWT(JSON Web Token)**의 구조와 생성/검증 원리를 코드로 익힙니다.
 * 4. `OncePerRequestFilter`를 상속받아 커스텀 인증 필터를 만드는 법을 배웁니다.
 */

@SpringBootApplication
public class Step9_SecurityAndOAuth2JWT {
    public static void main(String[] args) {
        SpringApplication.run(Step9_SecurityAndOAuth2JWT.class, args);
    }
}

// ========================================================================================
// 1. [Core] Spring Security 설정 (SecurityFilterChain)
// ========================================================================================

@Configuration
@EnableWebSecurity
class SecurityConfig {

    private final JwtFilter jwtFilter;

    public SecurityConfig(JwtFilter jwtFilter) {
        this.jwtFilter = jwtFilter;
    }

    /**
     * [보안 정책 설정]
     * - CSRF 비활성화 (REST API는 세션 쿠키를 안 쓰므로 보통 끔)
     * - Session 비활성화 (STATELESS)
     * - URL별 접근 권한 설정
     * - JWT 필터 끼워넣기
     */
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(AbstractHttpConfigurer::disable) // CSRF 끄기
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)) // 세션 끄기
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**").permitAll() // 로그인, 회원가입은 누구나 접근 가능
                .requestMatchers("/api/admin/**").hasRole("ADMIN") // 관리자만 접근 가능
                .anyRequest().authenticated() // 나머지는 로그인해야 접근 가능
            )
            // UsernamePasswordAuthenticationFilter(기본 로그인 필터) 앞에 JwtFilter를 실행시킴
            .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    // 비밀번호 암호화 (BCrypt: 단방향 해시 알고리즘)
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    // 인증 매니저 (로그인 처리를 담당하는 핵심 객체)
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authenticationConfiguration) throws Exception {
        return authenticationConfiguration.getAuthenticationManager();
    }

    // 테스트용 인메모리 유저 (실무에서는 DB 연동)
    @Bean
    public UserDetailsService userDetailsService(PasswordEncoder encoder) {
        UserDetails user = User.withUsername("user")
                .password(encoder.encode("1234")) // 암호화해서 저장해야 함
                .roles("USER")
                .build();
        
        UserDetails admin = User.withUsername("admin")
                .password(encoder.encode("admin"))
                .roles("ADMIN")
                .build();

        return new InMemoryUserDetailsManager(user, admin);
    }
}

// ========================================================================================
// 2. [JWT] 토큰 생성 및 검증 유틸리티
// ========================================================================================

@Component
class JwtUtil {
    // 주의: 실무에서는 application.properties 파일에서 읽어와야 함 (@Value 사용)
    // 32바이트 이상의 강력한 시크릿 키 필요
    private static final Key SECRET_KEY = Keys.secretKeyFor(SignatureAlgorithm.HS256);
    private static final long EXPIRATION_TIME = 1000 * 60 * 60; // 1시간

    // 토큰 생성
    public String createToken(String username) {
        return Jwts.builder()
                .setSubject(username)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION_TIME))
                .signWith(SECRET_KEY)
                .compact();
    }

    // 토큰에서 username 추출
    public String getUsername(String token) {
        return parseClaims(token).getSubject();
    }

    // 토큰 유효성 검증
    public boolean validateToken(String token) {
        try {
            Claims claims = parseClaims(token);
            return !claims.getExpiration().before(new Date()); // 만료 안 됐으면 true
        } catch (Exception e) {
            return false; // 파싱 실패(조작됨) 또는 만료됨
        }
    }

    private Claims parseClaims(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(SECRET_KEY)
                .build()
                .parseClaimsJws(token)
                .getBody();
    }
}

// ========================================================================================
// 3. [Filter] 커스텀 인증 필터 (OncePerRequestFilter)
// ========================================================================================

@Component
class JwtFilter extends OncePerRequestFilter {

    private final JwtUtil jwtUtil;
    private final UserDetailsService userDetailsService;

    public JwtFilter(JwtUtil jwtUtil, UserDetailsService userDetailsService) {
        this.jwtUtil = jwtUtil;
        this.userDetailsService = userDetailsService;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        
        // 1. 헤더에서 Authorization 토큰 추출
        String header = request.getHeader("Authorization");
        
        if (header != null && header.startsWith("Bearer ")) {
            String token = header.substring(7); // "Bearer " 이후 부분

            // 2. 토큰 검증
            if (jwtUtil.validateToken(token)) {
                String username = jwtUtil.getUsername(token);
                
                // 3. 유저 정보 로드 (DB 조회 등)
                UserDetails userDetails = userDetailsService.loadUserByUsername(username);

                // 4. SecurityContext에 인증 정보 저장 (Spring에게 "이 사람 로그인 됐어!"라고 알려줌)
                UsernamePasswordAuthenticationToken auth = 
                        new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
                
                org.springframework.security.core.context.SecurityContextHolder.getContext().setAuthentication(auth);
            }
        }

        // 5. 다음 필터로 넘김
        chain.doFilter(request, response);
    }
}

// ========================================================================================
// 4. 인증 컨트롤러 (로그인 API)
// ========================================================================================

@RestController
class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtUtil jwtUtil;

    public AuthController(AuthenticationManager authenticationManager, JwtUtil jwtUtil) {
        this.authenticationManager = authenticationManager;
        this.jwtUtil = jwtUtil;
    }

    record LoginRequest(String username, String password) {}

    @PostMapping("/api/auth/login")
    public String login(@RequestBody LoginRequest request) {
        // 1. ID/PW 인증 시도 (실패 시 BadCredentialsException 발생)
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.username(), request.password())
        );

        // 2. 인증 성공 시 토큰 발급
        return jwtUtil.createToken(authentication.getName());
    }
}
