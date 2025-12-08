package com.example.springboot;

import jakarta.persistence.*;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * ========================================================================================
 * Step 4: 데이터베이스 연동 및 JPA A-Z 완전 정복
 * ========================================================================================
 *
 * 이 파일은 Spring Boot에서 JPA(Java Persistence API)를 사용하는 방법과
 * 실무에서 가장 빈번하게 발생하는 **N+1 문제**의 원인과 해결책을 다룹니다.
 *
 * [학습 목표]
 * 1. JPA, Hibernate, Spring Data JPA의 관계를 이해합니다.
 * 2. Entity 설계 시 주의사항(Setter 지양, 기본 생성자 필수 등)을 배웁니다.
 * 3. **N+1 문제**가 무엇인지, 왜 발생하는지, `Fetch Join`으로 어떻게 해결하는지 체득합니다.
 *
 * [핵심 용어]
 * - **ORM (Object-Relational Mapping)**: 객체와 DB 테이블을 매핑해주는 기술.
 * - **JPA**: 자바 ORM 표준 인터페이스.
 * - **Hibernate**: JPA의 가장 대표적인 구현체 라이브러리.
 * - **Spring Data JPA**: JPA를 더 쉽게 쓰도록 감싼 스프링 모듈 (`JpaRepository` 등).
 */

@SpringBootApplication
public class Step4_DatabaseIntegration {
    public static void main(String[] args) {
        SpringApplication.run(Step4_DatabaseIntegration.class, args);
    }
}

// ========================================================================================
// 0. 도메인 모델 (Entity) 정의
// ========================================================================================

@Entity
class Team {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;

    // 양방향 연관관계 (Team -> Member)
    // 1:N 관계에서 'mappedBy'는 연관관계의 주인이 아님을 표시 (읽기 전용)
    @OneToMany(mappedBy = "team", fetch = FetchType.LAZY) // 지연 로딩 권장
    private List<Member> members = new ArrayList<>();

    protected Team() {} // JPA용 필수
    public Team(String name) { this.name = name; }
    
    public Long getId() { return id; }
    public String getName() { return name; }
    public List<Member> getMembers() { return members; }
}

@Entity
class Member {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String username;

    // N:1 관계 (Member -> Team)
    // 연관관계의 주인 (외래키를 관리함)
    @ManyToOne(fetch = FetchType.LAZY) // 중요: 모든 연관관계는 지연 로딩(LAZY)으로 설정!
    @JoinColumn(name = "team_id")
    private Team team;

    protected Member() {}
    public Member(String username, Team team) {
        this.username = username;
        this.team = team;
    }
    
    public String getUsername() { return username; }
    public Team getTeam() { return team; }
}

// ========================================================================================
// 1. Repository 정의 (Spring Data JPA Magic)
// ========================================================================================

/**
 * 인터페이스만 정의하면 Spring이 자동으로 구현체(Proxy)를 만들어 빈으로 등록합니다.
 * @Repository 어노테이션 생략 가능.
 */
interface TeamRepository extends JpaRepository<Team, Long> {
    // 일반 조회 (N+1 문제 발생 가능)
    // 메서드 이름만으로 쿼리 생성: select * from team
}

interface MemberRepository extends JpaRepository<Member, Long> {
    
    // [GOOD] 페치 조인 (Fetch Join)
    // JPQL을 사용하여 연관된 Team까지 한 번의 쿼리로 가져옴 (N+1 해결)
    @Query("select m from Member m join fetch m.team")
    List<Member> findAllWithTeam();
}

// ========================================================================================
// 2. [BAD Example] N+1 문제 발생 시나리오
// ========================================================================================

@Service
@Transactional(readOnly = true) // 읽기 전용 트랜잭션 (성능 최적화)
class BadService {
    private final MemberRepository memberRepository;

    BadService(MemberRepository memberRepository) {
        this.memberRepository = memberRepository;
    }

    /**
     * [N+1 문제란?]
     * 1. `findAll()` 호출 시: `select * from member` (쿼리 1번) -> 회원 100명 조회.
     * 2. 루프를 돌면서 `m.getTeam().getName()` 호출 시:
     *    - Member 엔티티의 Team은 프록시(가짜) 객체 상태.
     *    - 실제 이름을 꺼내려는 순간 DB에 `select * from team where id = ?` 쿼리 날림.
     *    - 만약 회원이 100명이고 팀이 다 다르다면? -> 쿼리 100번 추가 발생.
     * => 총 1 + N(100) = 101번 쿼리 실행. (성능 폭망)
     */
    public List<String> getAllMemberTeamNames() {
        List<Member> members = memberRepository.findAll(); // 쿼리 1번
        
        return members.stream()
                .map(m -> m.getTeam().getName()) // 여기서 N번 쿼리 발생! (지연 로딩 초기화)
                .collect(Collectors.toList());
    }
}

// ========================================================================================
// 3. [GOOD Example] 페치 조인(Fetch Join)을 통한 성능 최적화
// ========================================================================================

@Service
@Transactional(readOnly = true)
class GoodService {
    private final MemberRepository memberRepository;

    GoodService(MemberRepository memberRepository) {
        this.memberRepository = memberRepository;
    }

    /**
     * [해결책]
     * Repository에서 정의한 `join fetch` 쿼리를 사용합니다.
     * `select m.*, t.* from member m inner join team t on m.team_id = t.id`
     * => DB에서 조인해서 한 방 쿼리로 다 가져옵니다.
     * => 총 쿼리 1번. (성능 굿)
     */
    public List<String> getAllMemberTeamNames() {
        List<Member> members = memberRepository.findAllWithTeam(); // 쿼리 1번 (조인 포함)
        
        return members.stream()
                .map(m -> m.getTeam().getName()) // 이미 데이터가 있으므로 DB 조회 안 함
                .collect(Collectors.toList());
    }
    
    /**
     * [팁] 트랜잭션 관리
     * 데이터를 변경(CUD)하는 메서드에는 @Transactional을 붙여야 합니다.
     * 그래야 예외 발생 시 자동으로 롤백(Rollback) 됩니다.
     */
    @Transactional // 기본은 readOnly=false
    public void updateMemberName(Long memberId, String newName) {
        Member member = memberRepository.findById(memberId).orElseThrow();
        
        // JPA의 변경 감지(Dirty Checking) 기능
        // setUsername만 호출해도 트랜잭션 종료 시점에 update 쿼리가 자동으로 나갑니다.
        // memberRepository.save(member)를 호출할 필요가 없습니다.
        // member.setUsername(newName); // (Setter가 있다면)
    }
}