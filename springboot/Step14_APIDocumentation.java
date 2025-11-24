package com.example.springboot;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.HttpStatus; // HttpStatus 임포트 추가

import java.util.Collections;
import java.util.List;

// Step 14: API Documentation with OpenAPI (Swagger)

/*
 * 이 스텝에서는 Spring Boot 애플리케이션에 OpenAPI (Swagger)를 통합하여
 * API 문서를 자동 생성하고 관리하는 방법을 학습합니다.
 * 특히 `@Operation` 어노테이션과 함께 자주 사용되는 다른 OpenAPI 관련 어노테이션들을 살펴봅니다.
 *
 * OpenAPI는 RESTful API를 설명, 생산, 소비, 시각화할 수 있도록 표준화된 형식을 제공합니다.
 * Spring Boot에서는 주로 Springdoc OpenAPI 라이브러리를 사용하여 이를 구현합니다.
 *
 * Springdoc OpenAPI를 사용하려면 build.gradle 또는 pom.xml에 다음 의존성을 추가해야 합니다.
 *
 * Maven (pom.xml) 예시:
 * <dependency>
 *     <groupId>org.springdoc</groupId>
 *     <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
 *     <version>2.X.X</version> <!-- 사용 가능한 최신 버전을 확인하여 적용하세요. 예: 2.3.0 -->
 * </dependency>
 *
 * Gradle (build.gradle) 예시:
 * implementation 'org.springdoc:springdoc-openapi-starter-webmvc-ui:2.X.X' // 사용 가능한 최신 버전을 확인하여 적용하세요. 예: 2.3.0
 *
 * 위 의존성을 추가한 후 애플리케이션을 실행하면, 다음 URL에서 Swagger UI를 통해
 * 자동으로 생성된 API 문서를 웹 인터페이스로 확인할 수 있습니다:
 * http://localhost:8080/swagger-ui.html
 * (기본 포트 8080 기준)
 *
 * 또한, 원시 OpenAPI 3.0 JSON 정의는 다음 URL에서 확인할 수 있습니다:
 * http://localhost:8080/v3/api-docs
 */

@SpringBootApplication
public class Step14_APIDocumentation {

    public static void main(String[] args) {
        SpringApplication.run(Step14_APIDocumentation.class, args);
    }

    /**
     * {@code @RestController}는 이 클래스가 RESTful 웹 서비스의 컨트롤러임을 나타냅니다.
     * {@code @RequestMapping("/api/v1/users")}는 이 컨트롤러 내의 모든 핸들러 메서드가
     * "/api/v1/users" 경로를 기본으로 사용함을 의미합니다.
     *
     * {@code @Tag} 어노테이션은 이 컨트롤러에 의해 노출되는 API 엔드포인트들을 그룹화하고
     * Swagger UI에 표시될 이름과 설명을 정의합니다. 이는 API 문서의 가독성을 높입니다.
     *   - {@code name}: Swagger UI에서 이 API 그룹의 제목으로 표시됩니다.
     *   - {@code description}: 이 API 그룹에 대한 자세한 설명을 제공합니다.
     */
    @RestController
    @RequestMapping("/api/v1/users")
    @Tag(name = "User Management", description = "사용자 정보를 관리하는 API")
    public static class UserController {

        /**
         * {@code @Operation} 어노테이션은 특정 API 오퍼레이션(엔드포인트)에 대한 자세한 정보를 정의합니다.
         * 이 정보는 Swagger UI에 표시되어 개발자가 API의 기능을 쉽게 이해하도록 돕습니다.
         *   - {@code summary}: API 호출의 짧은 요약 설명을 제공합니다.
         *   - {@code description}: API 호출에 대한 더 상세한 설명을 제공합니다.
         *   - {@code tags}: 이 오퍼레이션이 속하는 하나 이상의 태그(그룹)를 지정합니다. {@code @Tag}와 연동됩니다.
         *   - {@code responses}: 이 오퍼레이션이 반환할 수 있는 다양한 HTTP 응답들을 정의합니다.
         *     {@code @ApiResponse} 내부에서 각 응답 코드(예: 200, 500)에 대한 설명과 반환될 데이터의 스키마를 정의합니다.
         *       - {@code responseCode}: HTTP 상태 코드 (예: "200", "404", "500").
         *       - {@code description}: 해당 응답 코드의 의미를 설명합니다.
         *       - {@code content}: 응답 본문의 미디어 타입(예: application/json)과 데이터 구조(스키마)를 정의합니다.
         *         - {@code @Content(mediaType = "application/json", schema = @Schema(implementation = User.class))}:
         *           응답이 JSON 형식이며, {@code User.class}의 구조를 따른다는 것을 나타냅니다.
         */
        @Operation(
            summary = "모든 사용자 조회",
            description = "시스템에 등록된 모든 사용자 목록을 반환합니다.",
            tags = {"User Management"},
            responses = {
                @ApiResponse(responseCode = "200", description = "사용자 목록 조회 성공",
                    content = @Content(mediaType = "application/json",
                    schema = @Schema(implementation = User.class))),
                @ApiResponse(responseCode = "500", description = "서버 오류: 서버 내부에서 처리되지 않은 예외 발생 시")
            }
        )
        @GetMapping // HTTP GET 요청을 처리하며, 경로 변수가 없으므로 "/api/v1/users"에 매핑됩니다.
        public List<User> getAllUsers() {
            // 실제 구현에서는 데이터베이스나 다른 서비스로부터 사용자 목록을 조회합니다.
            // 여기서는 예시를 위해 더미 데이터를 반환합니다.
            return Collections.singletonList(new User(1L, "Test User", "test@example.com"));
        }

        /**
         * {@code @Operation} 어노테이션을 통해 특정 사용자 조회 API에 대한 상세 정보를 제공합니다.
         *   - {@code parameters}: 이 오퍼레이션이 받는 경로 변수나 쿼리 파라미터를 정의합니다.
         *     {@code @Parameter} 내부에서 각 파라미터의 이름, 설명, 필수 여부, 예시 값 등을 지정합니다.
         *       - {@code name}: 파라미터의 이름. {@code @PathVariable}의 변수명과 일치해야 합니다.
         *       - {@code description}: 파라미터의 용도를 설명합니다.
         *       - {@code required}: 이 파라미터가 필수인지 여부 (true/false).
         *       - {@code example}: Swagger UI에 표시될 파라미터의 예시 값.
         *
         * {@code @GetMapping("/{id}")}는 "/api/v1/users/{id}" 경로로 들어오는 HTTP GET 요청을 처리합니다.
         * {@code @PathVariable Long id}는 URL 경로에서 "id" 값을 추출하여 {@code id} 변수에 매핑합니다.
         */
        @Operation(
            summary = "특정 사용자 조회",
            description = "ID를 통해 특정 사용자 정보를 조회합니다. 사용자가 존재하지 않을 경우 404 Not Found를 반환합니다.",
            parameters = @Parameter(name = "id", description = "조회할 사용자의 고유 ID", required = true, example = "1"),
            responses = {
                @ApiResponse(responseCode = "200", description = "사용자 조회 성공",
                    content = @Content(mediaType = "application/json",
                    schema = @Schema(implementation = User.class))),
                @ApiResponse(responseCode = "404", description = "사용자를 찾을 수 없음: 제공된 ID에 해당하는 사용자가 없을 경우"),
                @ApiResponse(responseCode = "500", description = "서버 오류: 서버 내부에서 처리되지 않은 예외 발생 시")
            }
        )
        @GetMapping("/{id}")
        public User getUserById(@PathVariable Long id) {
            // 실제 구현에서는 데이터베이스에서 ID에 해당하는 사용자를 찾아 반환합니다.
            if (id == 1L) {
                return new User(id, "Test User", "test@example.com");
            }
            // 사용자가 없을 경우 Custom 예외를 발생시키고, @ResponseStatus에 의해 404 응답을 반환합니다.
            throw new UserNotFoundException("User not found with id: " + id);
        }

        /**
         * {@code @Operation} 어노테이션을 통해 새로운 사용자 생성 API에 대한 상세 정보를 제공합니다.
         *   - {@code requestBody}: 이 오퍼레이션이 받는 요청 본문(request body)에 대한 정보를 정의합니다.
         *     {@code @io.swagger.v3.oas.annotations.parameters.RequestBody} (Swagger의 RequestBody 어노테이션) 내부에서
         *     요청 본문의 설명, 필수 여부, 데이터 스키마 등을 지정합니다.
         *       - {@code description}: 요청 본문의 용도를 설명합니다.
         *       - {@code required}: 요청 본문이 필수인지 여부.
         *       - {@code content}: 요청 본문의 미디어 타입과 데이터 구조를 정의합니다.
         *         - {@code @Content(mediaType = "application/json", schema = @Schema(implementation = User.class))}:
         *           요청 본문이 JSON 형식이며, {@code User.class}의 구조를 따른다는 것을 나타냅니다.
         *
         * {@code @PostMapping}는 "/api/v1/users" 경로로 들어오는 HTTP POST 요청을 처리합니다.
         * {@code @RequestBody User user}는 HTTP 요청 본문을 {@code User} 객체로 변환합니다.
         * (Spring의 MessageConverter가 JSON/XML 등을 Java 객체로 자동 변환)
         */
        @Operation(
            summary = "새로운 사용자 생성",
            description = "새로운 사용자 정보를 시스템에 등록합니다. 성공 시 생성된 사용자 정보와 201 Created 응답을 반환합니다.",
            requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(
                description = "생성할 사용자 정보 (ID는 자동 생성되므로 포함하지 않아도 됩니다.)",
                required = true,
                content = @Content(mediaType = "application/json",
                schema = @Schema(implementation = User.class))
            ),
            responses = {
                @ApiResponse(responseCode = "201", description = "사용자 생성 성공",
                    content = @Content(mediaType = "application/json",
                    schema = @Schema(implementation = User.class))),
                @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터: 필수 필드 누락 또는 형식 오류"),
                @ApiResponse(responseCode = "500", description = "서버 오류: 서버 내부에서 처리되지 않은 예외 발생 시")
            }
        )
        @ResponseStatus(HttpStatus.CREATED) // HTTP 201 Created 상태 코드를 반환하도록 지정
        @PostMapping
        public User createUser(@RequestBody User user) {
            // 실제 구현에서는 사용자 정보를 데이터베이스에 저장하고, 저장된 객체를 반환합니다.
            // 여기서는 예시를 위해 임시 ID를 부여하여 반환합니다.
            return new User(2L, user.name, user.email); // 임시 ID 부여
        }
    }

    /**
     * {@code User} 클래스는 API에서 사용자 데이터의 요청/응답 스키마를 정의하는 Data Transfer Object (DTO) 역할을 합니다.
     * {@code @Schema(implementation = User.class)}와 같은 어노테이션에서 이 클래스의 구조를 참조하여
     * Swagger UI에 사용자 객체의 속성(id, name, email)이 자동으로 문서화됩니다.
     * 필드명과 타입, 접근자(getter/setter)가 OpenAPI 스키마 정의에 사용됩니다.
     */
    public static class User {
        private Long id;
        private String name;
        private String email;

        public User() {} // 기본 생성자는 객체 역직렬화를 위해 필요합니다.

        public User(Long id, String name, String email) {
            this.id = id;
            this.name = name;
            this.email = email;
        }

        public Long getId() {
            return id;
        }

        public void setId(Long id) {
            this.id = id;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getEmail() {
            return email;
        }

        public void setEmail(String email) {
            this.email = email;
        }
    }

    /**
     * {@code UserNotFoundException}은 특정 사용자를 찾을 수 없을 때 발생하는 사용자 정의 예외입니다.
     * {@code @ResponseStatus(HttpStatus.NOT_FOUND)} 어노테이션은 이 예외가 발생했을 때
     * Spring이 자동으로 HTTP 404 Not Found 상태 코드를 클라이언트에게 반환하도록 지시합니다.
     * 이를 통해 명시적인 try-catch 블록 없이도 예외 발생 시 적절한 HTTP 응답을 보낼 수 있습니다.
     */
    @ResponseStatus(HttpStatus.NOT_FOUND) // org.springframework.http.HttpStatus 임포트 필요
    public static class UserNotFoundException extends RuntimeException {
        public UserNotFoundException(String message) {
            super(message);
        }
    }
}