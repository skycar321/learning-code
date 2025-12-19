package com.example.springboot;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.enums.SecuritySchemeType;
import io.swagger.v3.oas.annotations.info.Info;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.security.SecurityScheme;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springdoc.core.models.GroupedOpenApi;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Profile;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * ========================================================================================
 * Step 14: API 문서화 (OpenAPI/Swagger) A-Z 완전 정복
 * ========================================================================================
 *
 * 이 파일은 코드만 짜면 문서가 자동으로 생성되는 **Springdoc (OpenAPI)**의 사용법을 다룹니다.
 * 특히 실무에서 필수적인 **JWT 인증 버튼(Authorize)** 추가 방법과 **API 그룹화** 전략을 포함합니다.
 *
 * [학습 목표]
 * 1. **Code-First 문서화**의 장점(코드와 문서의 동기화)을 이해합니다.
 * 2. `@Operation`, `@Schema` 등 핵심 어노테이션으로 문서를 풍성하게 만드는 법을 배웁니다.
 * 3. **Swagger UI에서 JWT 토큰을 넣고 API를 테스트**하는 설정을 익힙니다.
 * 4. 운영(Prod) 환경에서 문서를 숨기는 보안 설정을 이해합니다.
 */

@SpringBootApplication
// 1. 문서 기본 정보 설정
@OpenAPIDefinition(
    info = @Info(
        title = "Learning Platform API",
        version = "v1.0",
        description = "Spring Boot 학습용 API 문서입니다."
    )
)
// 2. JWT 인증 설정 (Swagger UI에 자물쇠 버튼 생성)
@SecurityScheme(
    name = "Bearer Authentication",
    type = SecuritySchemeType.HTTP,
    bearerFormat = "JWT",
    scheme = "bearer"
)
public class Step14_APIDocumentation {

    public static void main(String[] args) {
        SpringApplication.run(Step14_APIDocumentation.class, args);
    }

    // 3. API 그룹화 (v1, v2 또는 Admin/User 분리 시 유용)
    @Bean
    public GroupedOpenApi publicApi() {
        return GroupedOpenApi.builder()
                .group("v1-public")
                .pathsToMatch("/api/v1/**")
                .build();
    }
    
    // [보안 팁] 운영 환경에서는 Swagger를 끄는 것이 좋습니다.
    // application-prod.properties -> springdoc.api-docs.enabled=false
}

// ========================================================================================
// 4. [Good Example] 상세한 문서화가 적용된 컨트롤러
// ========================================================================================

@RestController
@RequestMapping("/api/v1/users")
@Tag(name = "User API", description = "사용자 관리(CRUD) 관련 API")
class UserDocsController {

    /**
     * [문서화 포인트]
     * 1. summary: API 요약
     * 2. description: 상세 설명 (마크다운 지원)
     * 3. security: 이 API는 인증이 필요함을 명시 (자물쇠 버튼 활성화)
     * 4. responses: 성공/실패 케이스별 응답 명세
     */
    @Operation(
        summary = "사용자 조회",
        description = "ID를 기반으로 **사용자 상세 정보**를 조회합니다.",
        security = @SecurityRequirement(name = "Bearer Authentication"), 
        responses = {
            @ApiResponse(responseCode = "200", description = "성공", 
                content = @Content(schema = @Schema(implementation = UserDto.class))),
            @ApiResponse(responseCode = "404", description = "사용자 없음"),
            @ApiResponse(responseCode = "401", description = "인증 실패 (토큰 누락/만료)")
        }
    )
    @GetMapping("/{id}")
    public UserDto getUser(
        @Parameter(description = "사용자 ID (Long)", example = "1") 
        @PathVariable Long id
    ) {
        return new UserDto(id, "tester", "test@example.com");
    }

    @Operation(summary = "사용자 등록")
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public UserDto createUser(@RequestBody UserCreateDto request) {
        return new UserDto(1L, request.name(), request.email());
    }
}

// ========================================================================================
// 5. [Schema] DTO 문서화
// ========================================================================================

@Schema(description = "사용자 응답 DTO")
record UserDto(
    @Schema(description = "사용자 고유 ID", example = "1") 
    Long id,
    
    @Schema(description = "사용자명", example = "HongGilDong") 
    String name,
    
    @Schema(description = "이메일 주소", example = "hong@test.com") 
    String email
) {}

@Schema(description = "사용자 생성 요청 DTO")
record UserCreateDto(
    @Schema(description = "사용자명 (필수)", requiredMode = Schema.RequiredMode.REQUIRED)
    String name,
    
    @Schema(description = "이메일 (형식 준수)", example = "user@mail.com")
    String email
) {}
