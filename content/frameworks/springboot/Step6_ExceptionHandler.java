package com.example.springboot;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;

/**
 * ========================================================================================
 * Step 6: 예외 처리 (Exception Handling) A-Z 완전 정복
 * ========================================================================================
 *
 * 이 파일은 Spring Boot에서 발생하는 예외를 "우아하게" 처리하는 방법을 다룹니다.
 *
 * [학습 목표]
 * 1. `@RestControllerAdvice`를 사용해 예외를 중앙에서 관리하는 법을 배웁니다.
 * 2. `try-catch` 지옥에서 벗어나 코드의 가독성을 높입니다.
 * 3. 클라이언트에게 항상 일관된 JSON 에러 응답(DTO)을 내려주는 표준을 만듭니다.
 * 4. 보안상 위험한 스택 트레이스(Stack Trace) 노출을 막는 법을 이해합니다.
 */

@SpringBootApplication
public class Step6_ExceptionHandler {
    public static void main(String[] args) {
        SpringApplication.run(Step6_ExceptionHandler.class, args);
    }
}

// ========================================================================================
// 0. 표준 에러 응답 DTO (Standard Error Response)
// ========================================================================================

/**
 * [DTO 패턴]
 * 에러가 날 때마다 중구난방인 포맷(Map, String 등)으로 리턴하면 프론트엔드 개발자가 힘들어합니다.
 * 항상 똑같은 구조(`errorCode`, `message`)로 내려주는 것이 API 설계의 핵심입니다.
 */
record ErrorResponse(
    String errorCode,
    String message,
    LocalDateTime timestamp
) {
    public static ErrorResponse of(String errorCode, String message) {
        return new ErrorResponse(errorCode, message, LocalDateTime.now());
    }
}

// ========================================================================================
// 1. 커스텀 예외 (Custom Exceptions)
// ========================================================================================

// 비즈니스 로직 최상위 예외
class BusinessException extends RuntimeException {
    private final String errorCode;

    public BusinessException(String errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
    }

    public String getErrorCode() { return errorCode; }
}

// 구체적인 예외 상황
class UserNotFoundException extends BusinessException {
    public UserNotFoundException(Long id) {
        super("USER_NOT_FOUND", "사용자를 찾을 수 없습니다. ID: " + id);
    }
}

class InvalidInputException extends BusinessException {
    public InvalidInputException(String message) {
        super("INVALID_INPUT", message);
    }
}

// ========================================================================================
// 2. [BAD Example] 컨트롤러에서 직접 try-catch (나쁜 예)
// ========================================================================================

@RestController
@RequestMapping("/api/bad")
class BadController {

    @GetMapping("/users/{id}")
    public ResponseEntity<?> getUser(@PathVariable Long id) {
        try {
            if (id == 0) throw new IllegalArgumentException("ID는 0일 수 없음");
            return ResponseEntity.ok("User Info");
        } catch (IllegalArgumentException e) {
            // BAD: 컨트롤러마다 예외처리 코드가 중복됨.
            // BAD: 에러 메시지 포맷이 제각각임.
            return ResponseEntity.status(400).body("Error: " + e.getMessage());
        } catch (Exception e) {
            // BAD: 보안상 위험한 스택 트레이스를 노출할 수도 있음.
            e.printStackTrace(); 
            return ResponseEntity.status(500).body(e.toString());
        }
    }
}

// ========================================================================================
// 3. [GOOD Example] 전역 예외 처리기 (Global Exception Handler)
// ========================================================================================

/**
 * [@RestControllerAdvice]
 * - 모든 컨트롤러에서 발생하는 예외를 여기서 가로채서 처리합니다. (AOP 방식)
 * - `@ControllerAdvice` + `@ResponseBody`가 합쳐진 형태입니다.
 */
@RestControllerAdvice
class GlobalExceptionHandler {

    /**
     * [시나리오 1] 비즈니스 로직 예외 처리
     * 우리가 의도적으로 던진 `BusinessException`을 잡아서 처리합니다.
     */
    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ErrorResponse> handleBusinessException(BusinessException e) {
        // 로그 기록 (서버에만 남김)
        System.err.println("[Business Error] " + e.getErrorCode() + ": " + e.getMessage());

        // 클라이언트에는 깔끔한 DTO 리턴
        ErrorResponse response = ErrorResponse.of(e.getErrorCode(), e.getMessage());
        
        // 예외 종류에 따라 HTTP 상태 코드 분기 가능
        HttpStatus status = HttpStatus.BAD_REQUEST;
        if (e instanceof UserNotFoundException) {
            status = HttpStatus.NOT_FOUND;
        }

        return ResponseEntity.status(status).body(response);
    }

    /**
     * [시나리오 2] 예상치 못한 시스템 예외 처리 (최후의 방어선)
     * NullPointerException 등 우리가 미처 잡지 못한 에러를 처리합니다.
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleException(Exception e) {
        // 중요: 실제 에러 내용(스택 트레이스)은 서버 로그에만 남깁니다!
        // 클라이언트에게 e.getMessage()를 그대로 보여주면 해커에게 힌트가 될 수 있습니다. (SQL 구조 등)
        e.printStackTrace(); 

        // 클라이언트에게는 "서버 에러"라는 뭉뚱그린 메시지만 전달
        ErrorResponse response = ErrorResponse.of("INTERNAL_SERVER_ERROR", "서버 내부 오류가 발생했습니다. 관리자에게 문의하세요.");
        
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
    }
}

// ========================================================================================
// 4. 테스트용 컨트롤러
// ========================================================================================

@RestController
@RequestMapping("/api/good")
class GoodController {

    @GetMapping("/users/{id}")
    public String getUser(@PathVariable Long id) {
        if (id == 0) {
            throw new InvalidInputException("ID는 1 이상이어야 합니다.");
        }
        if (id == 99) {
            throw new UserNotFoundException(id);
        }
        if (id == -1) {
            throw new RuntimeException("예상치 못한 버그 발생!");
        }
        return "User Found: " + id;
    }
}