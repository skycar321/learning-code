# Swagger/OpenAPI 학습 계획

안녕하세요! API 문서화와 테스트의 중요성을 이해하는 여러분을 환영합니다. 이 학습 계획은 RESTful API 개발에서 필수적인 도구인 Swagger와 OpenAPI에 대한 깊이 있는 이해를 돕기 위해 구성되었습니다.

---

## 1. Swagger/OpenAPI란 무엇인가?

### 1.1. OpenAPI Specification (OAS)
*   **정의**: RESTful API를 언어 독립적이고 사람이 읽을 수 있으며 기계가 읽을 수 있는 형태로 기술하기 위한 표준 사양입니다. API의 엔드포인트, 작동 방식, 매개변수, 인증 방법, 응답 구조 등을 명확하게 정의합니다.
*   **역할**: API의 계약(Contract) 역할을 하여, 클라이언트 개발자와 서버 개발자 간의 의사소통 오류를 줄이고 개발 효율성을 높입니다.

### 1.2. Swagger 툴셋
Swagger는 OpenAPI Specification을 기반으로 API를 설계, 빌드, 문서화 및 소비하는 데 도움이 되는 도구 모음입니다.
*   **Swagger UI**:
    *   **기능**: OpenAPI Specification으로 작성된 API 문서를 웹 기반의 대화형 인터페이스로 자동 생성하여 시각화합니다.
    *   **이점**: 개발자는 별도의 클라이언트 코드 없이 웹 브라우저에서 API 엔드포인트를 탐색하고, 직접 요청을 보내고, 응답을 확인할 수 있습니다. API 이해와 테스트를 용이하게 합니다.
*   **Swagger Editor**:
    *   **기능**: 브라우저 기반에서 OpenAPI Specification을 YAML 또는 JSON 형식으로 작성하고 편집할 수 있는 도구입니다. 실시간 유효성 검사 및 구문 강조 기능을 제공합니다.
    *   **이점**: API 설계 단계에서 문서를 작성하며 API 구조를 시각적으로 확인하고 오류를 사전에 방지합니다.
*   **Swagger Codegen**:
    *   **기능**: OpenAPI Specification을 기반으로 다양한 프로그래밍 언어(Java, Python, JavaScript 등)로 API 클라이언트 라이브러리(SDK), 서버 스텁, API 문서를 자동으로 생성해줍니다.
    *   **이점**: 클라이언트/서버 코드 개발 시간을 단축하고, API 변경 시 일관된 코드 업데이트를 보장합니다.

---

## 2. 왜 Swagger/OpenAPI를 사용해야 하는가?

*   **명확한 API 계약**: API의 동작 방식에 대한 모호성을 제거하고, 클라이언트와 서버 간의 정확한 계약을 제공합니다.
*   **개발 생산성 향상**: 자동 생성된 문서를 통해 클라이언트 개발자는 서버 개발자를 기다릴 필요 없이 API를 이해하고 클라이언트를 구현할 수 있습니다.
*   **쉬운 API 테스트**: Swagger UI를 통해 손쉽게 API를 호출하고 응답을 확인하여 API 테스트 과정을 간소화합니다.
*   **일관된 문서화**: API 변경 시 문서를 수동으로 업데이트하는 대신, 코드에서 주석을 통해 자동으로 문서를 생성하여 항상 최신 상태를 유지합니다.
*   **다양한 도구와의 통합**: Postman, Insomnia 등 다양한 API 개발 및 테스트 도구에서 OpenAPI Specification을 가져와 사용할 수 있습니다.

---

## 3. Spring Boot와 Swagger/OpenAPI 통합

Spring Boot 프로젝트에서 Swagger/OpenAPI를 통합하는 가장 일반적인 방법은 `springdoc-openapi` 라이브러리를 사용하는 것입니다. 이 라이브러리는 코드의 어노테이션(예: `@Tag`, `@Operation`, `@ApiResponse`, `@Parameter`, `@RequestBody` 등)을 분석하여 자동으로 OpenAPI Specification 문서를 생성하고 Swagger UI를 제공합니다.

### 주요 어노테이션
*   `@Tag`: 컨트롤러 또는 특정 API 그룹에 대한 설명을 추가합니다.
*   `@Operation`: 개별 API 엔드포인트(메서드)에 대한 요약, 설명, 응답 코드 등을 정의합니다.
*   `@Parameter`: API 엔드포인트의 입력 파라미터(경로, 쿼리, 헤더 등)에 대한 정보를 제공합니다.
*   `@RequestBody`: HTTP 요청 본문에 대한 정보를 정의합니다.
*   `@ApiResponse`: 특정 HTTP 응답 코드에 대한 설명과 반환되는 데이터의 스키마를 정의합니다.
*   `@Schema`: 모델(DTO) 클래스의 속성에 대한 추가 설명을 제공합니다.

---

## 4. 실습: Spring Boot 애플리케이션에 Swagger/OpenAPI 통합

이 섹션에서는 간단한 Spring Boot 애플리케이션을 만들고 `springdoc-openapi` 라이브러리를 사용하여 API 문서를 자동 생성하는 방법을 실습합니다.

**실습 목표**:
*   Spring Boot 프로젝트 생성 및 `springdoc-openapi` 의존성 추가
*   RESTful 컨트롤러 작성 및 주요 Swagger 어노테이션 활용
*   Swagger UI를 통해 자동 생성된 API 문서 확인

자세한 내용은 다음 소스 코드를 참조하세요.

[Swagger 통합 예제 소스 코드: Step1_SwaggerIntegrationExample.java](Step1_SwaggerIntegrationExample.java)
