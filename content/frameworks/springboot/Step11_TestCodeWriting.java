package com.example.testcodewriting;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import org.junit.jupiter.params.provider.ValueSource;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.bind.annotation.*;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * ========================================================================================
 * Step 11: Spring Boot 테스트 코드 작성 A-Z (JUnit 5 + Mockito + AssertJ)
 * ========================================================================================
 *
 * 이 파일은 Spring Boot 애플리케이션 테스트의 "좋은 예"와 "나쁜 예"를 비교하며,
 * 단위 테스트부터 통합 테스트까지의 모범 사례를 제공합니다.
 *
 * [학습 목차]
 * 1. 기본 개념: 단위 테스트 vs 통합 테스트
 * 2. Domain & Repository: Entity 및 DB 계층 테스트
 * 3. Service Layer (단위 테스트): Mockito 활용 및 Good/Bad 패턴
 * 4. Controller Layer (슬라이스 테스트): @WebMvcTest 활용
 * 5. Advanced: ParameterizedTest(파라미터화 테스트), Nested(계층형 테스트)
 *
 * [필수 의존성 (pom.xml / build.gradle)]
 * - spring-boot-starter-test (JUnit 5, Mockito, AssertJ, Hamcrest 포함)
 * - com.h2database:h2 (Repository 테스트용 인메모리 DB)
 */

@SpringBootApplication
public class Step11_TestCodeWriting {
    public static void main(String[] args) {
        SpringApplication.run(Step11_TestCodeWriting.class, args);
    }
}

// ========================================================================================
// 0. 테스트 대상 도메인 및 컴포넌트 정의
// ========================================================================================

@Entity
class Member {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String email;
    private String name;
    private int age;

    protected Member() {} // JPA용 기본 생성자

    public Member(String email, String name, int age) {
        if (age < 0) throw new IllegalArgumentException("나이는 0보다 커야 합니다.");
        this.email = email;
        this.name = name;
        this.age = age;
    }

    // Getters
    public Long getId() { return id; }
    public String getEmail() { return email; }
    public String getName() { return name; }
    public int getAge() { return age; }
}

@Repository
interface MemberRepository extends JpaRepository<Member, Long> {
    Optional<Member> findByEmail(String email);
}

@Service
class MemberService {
    private final MemberRepository memberRepository;

    public MemberService(MemberRepository memberRepository) {
        this.memberRepository = memberRepository;
    }

    public Member createMember(String email, String name, int age) {
        // 중복 검사
        if (memberRepository.findByEmail(email).isPresent()) {
            throw new IllegalStateException("이미 존재하는 이메일입니다.");
        }
        return memberRepository.save(new Member(email, name, age));
    }

    public Member getMember(Long id) {
        return memberRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));
    }
}

@RestController
@RequestMapping("/api/members")
class MemberController {
    private final MemberService memberService;

    public MemberController(MemberService memberService) {
        this.memberService = memberService;
    }

    @PostMapping
    public Member createMember(@RequestBody MemberDto dto) {
        return memberService.createMember(dto.email(), dto.name(), dto.age());
    }

    @GetMapping("/{id}")
    public Member getMember(@PathVariable Long id) {
        return memberService.getMember(id);
    }

    // DTO (Java 16+ Record)
    record MemberDto(String email, String name, int age) {}
}

// ========================================================================================
// 1. Service Layer 테스트 (Unit Test) - 가장 중요한 부분!
// ========================================================================================

/**
 * [BAD Example] 잘못된 서비스 테스트 패턴
 * 1. @SpringBootTest 남용: 단위 테스트인데 스프링 컨텍스트를 띄워 느림.
 * 2. AssertJ 대신 System.out.println으로 검증: 자동화되지 않은 검증.
 * 3. 예외 테스트 누락: Happy Path만 테스트함.
 */
@SpringBootTest // BAD: 단위 테스트에 너무 무거운 어노테이션
class BadMemberServiceTest {
    @Autowired MemberService memberService; // 실제 빈 주입 (DB 연결 필요 등 복잡도 증가)

    @Test
    void createMember() {
        Member member = memberService.createMember("bad@test.com", "Bad", 20);
        System.out.println(member.getEmail()); // BAD: 눈으로 확인해야 함. 실패해도 테스트는 통과될 수 있음.
    }
}

/**
 * [GOOD Example] 올바른 서비스 단위 테스트 패턴
 * 1. @ExtendWith(MockitoExtension.class): 스프링 없이 Mockito만 사용하여 빠름.
 * 2. @Mock, @InjectMocks: 의존성 격리.
 * 3. BDDMockito (given/when/then): 가독성 높은 테스트 흐름.
 * 4. AssertJ (assertThat): 풍부하고 읽기 쉬운 검증.
 * 5. 예외 케이스 꼼꼼히 검증.
 */
@ExtendWith(MockitoExtension.class)
class GoodMemberServiceTest {

    @Mock // 가짜 객체 생성 (껍데기)
    private MemberRepository memberRepository;

    @InjectMocks // 가짜 객체를 주입받을 대상
    private MemberService memberService;

    @Test
    @DisplayName("회원가입 성공: 중복되지 않은 이메일이면 저장이 호출된다")
    void createMember_Success() {
        // given (준비)
        String email = "good@test.com";
        String name = "Good";
        int age = 25;
        Member savedMember = new Member(email, name, age);
        ReflectionTestUtils.setField(savedMember, "id", 1L); // ID는 DB 생성 값이므로 리플렉션으로 주입 (단위테스트의 한계 해결)

        // Mock 행동 정의: findByEmail 호출시 빈 값 반환 (중복 없음)
        given(memberRepository.findByEmail(email)).willReturn(Optional.empty());
        // Mock 행동 정의: save 호출시 저장된 객체 반환
        given(memberRepository.save(any(Member.class))).willReturn(savedMember);

        // when (실행)
        Member result = memberService.createMember(email, name, age);

        // then (검증)
        assertThat(result.getId()).isEqualTo(1L);
        assertThat(result.getEmail()).isEqualTo(email);
        
        // 중요: 리포지토리의 save가 정확히 1번 호출되었는지 행위 검증
        verify(memberRepository, times(1)).save(any(Member.class));
    }

    @Test
    @DisplayName("회원가입 실패: 중복된 이메일이면 예외가 발생한다")
    void createMember_Fail_DuplicateEmail() {
        // given
        String email = "duplicate@test.com";
        given(memberRepository.findByEmail(email)).willReturn(Optional.of(new Member(email, "Exist", 30)));

        // when & then (AssertJ의 예외 검증 스타일)
        assertThatThrownBy(() -> memberService.createMember(email, "New", 20))
                .isInstanceOf(IllegalStateException.class)
                .hasMessage("이미 존재하는 이메일입니다.");
        
        // save가 호출되지 않았음을 검증
        verify(memberRepository, never()).save(any(Member.class));
    }
}

// ========================================================================================
// 2. Controller Layer 테스트 (Slice Test)
// ========================================================================================

/**
 * [GOOD Example] 컨트롤러 슬라이스 테스트
 * - @WebMvcTest: 웹 계층 관련 빈만 로드 (가벼움).
 * - MockMvc: HTTP 요청/응답 시뮬레이션.
 * - @MockBean: 컨테이너에 있는 실제 Service 빈 대신 Mock 객체를 바꿔치기.
 */
@WebMvcTest(MemberController.class)
class MemberControllerTest {

    @Autowired MockMvc mockMvc; // 가짜 요청 보내는 도구
    @MockBean MemberService memberService; // 컨트롤러가 의존하는 서비스 Mocking
    @Autowired ObjectMapper objectMapper; // JSON 변환용

    @Test
    @DisplayName("회원 조회 API: 성공 시 200 OK와 JSON 반환")
    void getMember_Success() throws Exception {
        // given
        Long memberId = 1L;
        Member member = new Member("test@test.com", "Tester", 20);
        given(memberService.getMember(memberId)).willReturn(member);

        // when & then
        mockMvc.perform(get("/api/members/{id}", memberId)
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk()) // HTTP 200 확인
                .andExpect(jsonPath("$.email").value("test@test.com")) // JSON 필드 검증
                .andExpect(jsonPath("$.name").value("Tester"));
    }

    @Test
    @DisplayName("회원 생성 API: 입력값 전송 시 200 OK")
    void createMember_Success() throws Exception {
        // given
        MemberController.MemberDto request = new MemberController.MemberDto("new@test.com", "Newbie", 10);
        Member response = new Member("new@test.com", "Newbie", 10);
        given(memberService.createMember(any(), any(), anyInt())).willReturn(response);

        // when & then
        mockMvc.perform(post("/api/members")
                .content(objectMapper.writeValueAsString(request)) // 객체 -> JSON String
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.email").value("new@test.com"));
    }
}

// ========================================================================================
// 3. Repository Layer 테스트 (Data Access Test)
// ========================================================================================

/**
 * [GOOD Example] 리포지토리 테스트
 * - @DataJpaTest: JPA 관련 설정만 로드, 내장 DB(H2) 자동 구성, 트랜잭션 자동 롤백.
 * - 굳이 기본 메서드(save, findById)를 테스트하기보다, '커스텀 쿼리'나 '옵션' 검증에 집중.
 */
@DataJpaTest
class MemberRepositoryTest {

    @Autowired MemberRepository memberRepository;

    @Test
    @DisplayName("이메일로 회원 찾기")
    void findByEmail() {
        // given
        Member member = new Member("repo@test.com", "RepoUser", 40);
        memberRepository.save(member); // H2 DB에 저장

        // when
        Member found = memberRepository.findByEmail("repo@test.com").orElseThrow();

        // then
        assertThat(found.getName()).isEqualTo("RepoUser");
    }
}

// ========================================================================================
// 4. Advanced: 더 나은 테스트 작성을 위한 팁 (JUnit 5 기능 활용)
// ========================================================================================

class AdvancedJUnit5Test {

    // 팁 1: @DisplayNameGeneration 으로 테스트 이름 자동화 가능 (생략)
    
    // 팁 2: @Nested로 관련된 테스트 묶기 (BDD 스타일 구조화에 유리)
    @Nested
    @DisplayName("회원 나이 유효성 검사")
    class AgeValidation {
        
        @Test
        @DisplayName("나이가 양수면 성공")
        void positiveAge() {
            assertThat(new Member("t@t.com", "T", 1).getAge()).isEqualTo(1);
        }

        @Test
        @DisplayName("나이가 음수면 예외 발생")
        void negativeAge() {
            assertThatThrownBy(() -> new Member("t@t.com", "T", -1))
                    .isInstanceOf(IllegalArgumentException.class);
        }
    }

    // 팁 3: @ParameterizedTest로 여러 데이터셋 한번에 테스트 (중복 코드 제거)
    @ParameterizedTest(name = "나이가 {0}이면 예외가 발생하지 않는다")
    @ValueSource(ints = {1, 10, 100})
    void validateAge_Parameterized(int age) {
        Member member = new Member("test@t.com", "Name", age);
        assertThat(member.getAge()).isEqualTo(age);
    }
    
    // 팁 4: CSV 형태로 복합 데이터 테스트
    @ParameterizedTest
    @CsvSource({
        "test@t.com, Tester, 20",
        "admin@t.com, Admin, 30"
    })
    void createMember_Csv(String email, String name, int age) {
        Member member = new Member(email, name, age);
        assertThat(member.getEmail()).isEqualTo(email);
    }
}