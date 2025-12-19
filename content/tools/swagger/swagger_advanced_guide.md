# Swagger/OpenAPI 심화 학습 가이드

## Step 2: Swagger 설정 커스터마이징 (`Step2_SwaggerConfig.java`)
기본 설정만으로도 문서는 생성되지만, 실제 프로젝트에서는 메타데이터(제목, 버전, 라이선스 등)와 보안 설정(JWT 등)이 필요합니다.
*   **OpenAPI Bean**: 글로벌 메타데이터를 설정합니다.
*   **GroupedOpenApi**: API를 `public`, `admin` 등으로 그룹화하여 분리된 문서를 제공할 수 있습니다.
*   **SecuritySchemes**: JWT, OAuth2 등의 인증 방식을 정의합니다.

## Step 3: 고급 어노테이션 활용 (`Step3_AdvancedAnnotations.java`)
단순한 CRUD 외에 복잡한 파라미터나 파일 업로드, Deprecated 처리 등을 명시할 수 있습니다.
*   `@Parameter(in = ParameterIn.QUERY)`: 쿼리 파라미터, 헤더 등을 명시적으로 정의합니다.
*   `allowableValues`: 가능한 값의 목록을 제한(Enum 효과)하여 문서에 표시합니다.
*   `deprecated = true`: 더 이상 사용되지 않는 API임을 명시합니다.

## Step 4: 실전 예제 (DTO와 Schema) (`Step4_RealWorldExample.java`)
실무에서는 엔티티를 직접 노출하기보다 DTO(Data Transfer Object)를 사용합니다. Swagger에서도 DTO에 `@Schema`를 붙여 명확한 예시와 설명을 제공해야 합니다.
*   `@Schema(description, example)`: 필드에 대한 상세 설명과 예시 값을 제공하여, 프론트엔드 개발자가 실제 데이터 형태를 쉽게 파악하게 합니다.
*   `requiredMode`: 필수 필드 여부를 명시합니다.

---
**다음 단계**:
이제 작성된 코드들을 기반으로 실제 Spring Boot 애플리케이션을 실행하고 `/swagger-ui.html` 또는 `/swagger-ui/index.html`에 접속하여 문서를 확인해보세요.
