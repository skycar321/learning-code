// nestjs/Step5_MicroservicesAndGraphQL/microservice.service.ts
// NestJS 학습 계획 - 5단계: 마이크로서비스 및 GraphQL
// 이 파일은 NestJS 마이크로서비스 서버의 `MicroserviceService`입니다.
// `MicroserviceService`는 마이크로서비스에서 처리할 실제 비즈니스 로직을 포함합니다.
//
// 마이크로서비스는 특정 기능에 집중하여 개발되므로, 서비스의 역할이 명확합니다.

import { Injectable } from '@nestjs/common';

// -----------------------------------------------------------------------------
// 학습 포인트 1: `MicroserviceService` (비즈니스 로직)
// - `@Injectable()` 데코레이터로 프로바이더임을 선언합니다.
// - 마이크로서비스 컨트롤러(`MathServiceMicroserviceController` 등)에서 호출되는
//   실제 비즈니스 로직을 구현합니다.
// -----------------------------------------------------------------------------
@Injectable()
export class MicroserviceService {
  accumulate(data: number[]): number {
    // 나쁜 예시: 마이크로서비스 내부에서 복잡한 외부 시스템 호출이나
    // - 시간 소모적인 작업을 동기적으로 처리하여 메시지 큐를 블로킹하는 것.
    // - 마이크로서비스는 빠르게 응답하고, 복잡한 작업은 비동기적으로 처리하거나
    // - 다른 마이크로서비스에 위임해야 합니다.
    return (data || []).reduce((a, b) => a + b); // 배열 요소의 합 계산
  }

  multiply(data: number[]): number {
    return (data || []).reduce((a, b) => a * b); // 배열 요소의 곱 계산
  }
}

/*
이 코드를 실행하려면:

1. `microservice.controller.ts` 파일과 함께 `src/microservice` 디렉토리에 이 파일을 생성합니다.
2. 마이크로서비스 모듈을 위한 `microservice.module.ts` 파일도 필요합니다.
   ```typescript
   // nestjs/Step5_MicroservicesAndGraphQL/microservice.module.ts
   import { Module } from '@nestjs/common';
   import { MicroserviceController, MathServiceMicroserviceController } from './microservice.controller';
   import { MicroserviceService } from './microservice.service';

   @Module({
     controllers: [MicroserviceController, MathServiceMicroserviceController], // 두 컨트롤러 등록
     providers: [MicroserviceService],
   })
   export class MicroserviceModule {}
   ```
*/
