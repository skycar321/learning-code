package com.example.springboot;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * ========================================================================================
 * Step 3: RESTful API 개발 A-Z 완전 정복
 * ========================================================================================
 *
 * 이 파일은 Spring Boot로 REST API를 설계하고 구현하는 "좋은 예"와 "나쁜 예"를 비교합니다.
 * 특히 실무에서 반드시 지켜야 할 **DTO 패턴**과 **HTTP 상태 코드** 활용법을 중점적으로 다룹니다.
 *
 * [학습 목표]
 * 1. REST(Representational State Transfer)의 기본 원칙과 HTTP 메서드 의미를 이해합니다.
 * 2. 왜 Entity(DB 객체)를 직접 반환하면 안 되는지(DTO 패턴의 필요성) 깨닫습니다.
 * 3. `@RestController`, `@RequestBody`, `@PathVariable` 등 핵심 어노테이션을 마스터합니다.
 * 4. 적절한 HTTP 상태 코드(200, 201, 204, 400, 404)를 반환하는 방법을 배웁니다.
 */

@SpringBootApplication
public class Step3_RestfulApiDevelopment {
    public static void main(String[] args) {
        SpringApplication.run(Step3_RestfulApiDevelopment.class, args);
    }
}

// ========================================================================================
// 0. 도메인 모델 (Entity) - DB 테이블과 매핑되는 객체
// ========================================================================================
class UserEntity {
    private Long id;
    private String username;
    private String password; // 보안상 절대 노출되면 안 되는 필드!

    public UserEntity(Long id, String username, String password) {
        this.id = id;
        this.username = username;
        this.password = password;
    }

    // Getters
    public Long getId() { return id; }
    public String getUsername() { return username; }
    public String getPassword() { return password; }
}

// ========================================================================================
// 1. [BAD Example] 잘못된 API 설계 패턴
// ========================================================================================

/**
 * [나쁜 예시의 문제점]
 * 1. **Entity 직접 노출**: `UserEntity`를 그대로 반환하면 `password` 같은 민감 정보가 JSON에 다 나옵니다. (보안 사고!)
 * 2. **HTTP 메서드 오남용**: 데이터를 삭제하는데 `@GetMapping`을 썼습니다. (웹 표준 위반)
 * 3. **상태 코드 무시**: 무조건 `200 OK`만 반환합니다. 클라이언트는 에러가 났는지 알기 어렵습니다.
 */
@RestController // @Controller + @ResponseBody
@RequestMapping("/api/bad/users")
class BadUserController {

    @GetMapping("/delete/{id}") // BAD: 삭제는 DELETE 메서드를 써야 함
    public UserEntity deleteUser(@PathVariable Long id) {
        // ... DB에서 삭제 로직 ...
        // BAD: 비밀번호가 포함된 Entity를 그대로 리턴
        return new UserEntity(id, "removedUser", "secret1234");
    }
}

// ========================================================================================
// 2. [GOOD Example] 올바른 REST API 설계 패턴 (DTO 사용)
// ========================================================================================

/**
 * [좋은 예시의 특징]
 * 1. **DTO (Data Transfer Object) 사용**: `UserResponseDto`를 만들어 필요한 정보만 클라이언트에 전달합니다.
 * 2. **올바른 HTTP 메서드**: 조회(GET), 생성(POST), 수정(PUT/PATCH), 삭제(DELETE) 의미에 맞게 사용합니다.
 * 3. **ResponseEntity 활용**: 상황에 맞는 정확한 HTTP 상태 코드를 반환합니다.
 */

// 2.1 DTO 정의 (API 응답용 껍데기 객체)
// Java 16+ Record 기능을 사용하면 불변 DTO를 아주 쉽게 만들 수 있습니다.
record UserResponseDto(Long id, String username) {
    // 비밀번호 필드가 아예 없으므로 안전함!
    
    // Entity -> DTO 변환 팩토리 메서드
    public static UserResponseDto from(UserEntity entity) {
        return new UserResponseDto(entity.getId(), entity.getUsername());
    }
}

record UserCreateRequestDto(String username, String password) {}

@RestController
@RequestMapping("/api/users")
class GoodUserController {

    // 가짜 DB (메모리 저장소)
    private final Map<Long, UserEntity> userDb = new HashMap<>();

    public GoodUserController() {
        userDb.put(1L, new UserEntity(1L, "tester", "1234"));
    }

    /**
     * [GET] 리소스 조회
     * - 성공 시: 200 OK
     * - 실패 시: 404 Not Found
     */
    @GetMapping("/{id}")
    public ResponseEntity<UserResponseDto> getUser(@PathVariable Long id) {
        if (!userDb.containsKey(id)) {
            return ResponseEntity.notFound().build(); // 404
        }
        
        UserEntity user = userDb.get(id);
        // Entity를 DTO로 변환하여 반환 (비밀번호 제외됨)
        return ResponseEntity.ok(UserResponseDto.from(user)); // 200
    }

    /**
     * [POST] 리소스 생성
     * - 성공 시: 201 Created (생성된 리소스 정보 포함 권장)
     */
    @PostMapping
    public ResponseEntity<UserResponseDto> createUser(@RequestBody UserCreateRequestDto request) {
        // 실제로는 Service 계층에서 수행할 로직
        Long newId = userDb.size() + 1L;
        UserEntity newUser = new UserEntity(newId, request.username(), request.password());
        userDb.put(newId, newUser);

        return ResponseEntity
                .status(HttpStatus.CREATED) // 201
                .body(UserResponseDto.from(newUser));
    }

    /**
     * [PUT] 리소스 전체 수정 (덮어쓰기)
     * - 참고: 부분 수정은 [PATCH] 메서드를 사용합니다.
     */
    @PutMapping("/{id}")
    public ResponseEntity<UserResponseDto> updateUser(@PathVariable Long id, @RequestBody UserCreateRequestDto request) {
        if (!userDb.containsKey(id)) {
            return ResponseEntity.notFound().build();
        }

        UserEntity updatedUser = new UserEntity(id, request.username(), request.password());
        userDb.put(id, updatedUser);

        return ResponseEntity.ok(UserResponseDto.from(updatedUser));
    }

    /**
     * [DELETE] 리소스 삭제
     * - 성공 시: 204 No Content (본문 없음)
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        if (userDb.remove(id) == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.noContent().build(); // 204
    }
}