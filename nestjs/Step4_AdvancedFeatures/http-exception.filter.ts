// nestjs/Step4_AdvancedFeatures/http-exception.filter.ts
// NestJS 학습 계획 - 4단계: 고급 기능 및 모범 사례
// 이 파일은 `HttpExceptionFilter`를 사용하여 NestJS 애플리케이션에서 발생하는
// 예외(Exception)를 중앙 집중식으로 처리하는 방법을 보여줍니다.
//
// 필터(Filter)는 컨트롤러의 라우트 핸들러에서 발생하는 예외를 가로채어
// 클라이언트에게 반환될 응답을 커스터마이징하는 데 사용됩니다.

import { ExceptionFilter, Catch, ArgumentsHost, HttpException, HttpStatus } from '@nestjs/common';
import { Request, Response } from 'express';

// -----------------------------------------------------------------------------
// 학습 포인트 1: `@Catch()` 데코레이터 및 `ExceptionFilter` 인터페이스 구현
// - `@Catch(HttpException)`: 이 필터가 `HttpException` 타입의 예외를 처리하도록 지정합니다.
// - `ExceptionFilter<T>` 인터페이스를 구현해야 하며, `catch()` 메서드를 오버라이드해야 합니다.
// - `T`는 필터가 처리할 예외의 타입입니다.
// -----------------------------------------------------------------------------
@Catch(HttpException) // HttpException 타입의 예외를 처리하도록 지정
export class HttpExceptionFilter implements ExceptionFilter {
  // -----------------------------------------------------------------------------
  // 학습 포인트 2: `catch()` 메서드
  // - 예외가 발생했을 때 호출되는 핵심 메서드입니다.
  // - `exception`: 현재 발생한 예외 객체입니다.
  // - `host`: `ArgumentsHost` 객체로, 현재 실행 컨텍스트에 대한 유틸리티 메서드를 제공합니다.
  //   - `host.switchToHttp()`: HTTP 컨텍스트를 가져옵니다.
  //   - `getRequest()`, `getResponse()`: 요청 및 응답 객체를 가져옵니다.
  // -----------------------------------------------------------------------------
  catch(exception: HttpException, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();
    const status = exception.getStatus(); // 예외의 HTTP 상태 코드 가져오기
    const exceptionResponse = exception.getResponse(); // 예외의 응답 본문 가져오기

    // 나쁜 예시: 모든 예외를 동일한 HTTP 상태 코드(예: 500 Internal Server Error)로 처리하는 것.
    // - 클라이언트에게 정확한 정보를 전달하기 어렵고, 디버깅을 복잡하게 만듭니다.
    // - 각 예외 타입에 맞는 적절한 HTTP 상태 코드를 반환해야 합니다.

    // 응답 본문 구성
    const errorResponse = {
      statusCode: status,
      timestamp: new Date().toISOString(),
      path: request.url,
      method: request.method,
      message: (typeof exceptionResponse === 'string')
        ? exceptionResponse
        : (exceptionResponse as any).message || exception.message,
      error: (typeof exceptionResponse === 'string')
        ? HttpStatus[status]
        : (exceptionResponse as any).error || exception.name,
    };

    response
      .status(status)
      .json(errorResponse); // 클라이언트에게 JSON 응답 반환

    // 나쁜 예시: 예외 필터 내에서 예외를 로깅하지 않거나,
    // - 중요한 에러 정보를 사용자에게 직접 노출하는 것.
    // - 예외는 항상 서버 측 로그에 상세히 기록하고, 클라이언트에게는 일반적인 에러 메시지만 전달해야 합니다.
    console.error(`[${request.method}] ${request.url} - ${status} (${errorResponse.message})`);
    console.error(exception.stack);
  }
}

/*
이 코드를 실행하려면:

1. `src/filters/http-exception.filter.ts`와 같이 적절한 디렉토리에 이 파일을 생성합니다.
2. 이 필터를 전역적으로 적용하려면 `main.ts` 파일에 다음 코드를 추가합니다:
   ```typescript
   // main.ts
   import { HttpExceptionFilter } from './filters/http-exception.filter'; // 필터 경로 확인

   async function bootstrap() {
     const app = await NestFactory.create(AppModule);
     app.useGlobalFilters(new HttpExceptionFilter()); // 전역적으로 HttpExceptionFilter 적용
     await app.listen(3000);
   }
   ```
3. 특정 컨트롤러나 라우트 핸들러에만 적용하려면 `@UseFilters(HttpExceptionFilter)` 데코레이터를 사용합니다.
*/
