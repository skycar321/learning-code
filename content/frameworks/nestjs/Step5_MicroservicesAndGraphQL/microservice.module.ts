// nestjs/Step5_MicroservicesAndGraphQL/microservice.module.ts
// NestJS 학습 계획 - 5단계: 마이크로서비스 및 GraphQL
// 이 파일은 마이크로서비스 관련 기능을 관리하는 `MicroserviceModule`입니다.
// 이 모듈은 `MicroserviceController`와 `MicroserviceService`를 포함합니다.
//
// NestJS 마이크로서비스는 독립적인 모듈로 구성되어 다른 서비스와 메시지 기반으로 통신합니다.

import { Module } from '@nestjs/common';
import { MicroserviceService } from './microservice.service';
import { MicroserviceController, MathServiceMicroserviceController } from './microservice.controller';

// -----------------------------------------------------------------------------
// 학습 포인트 1: 마이크로서비스 모듈 구성
// - `@Module()` 데코레이터를 사용하여 `MicroserviceModule`을 정의합니다.
// - `controllers`: `MicroserviceController` (HTTP 게이트웨이용) 및
//   `MathServiceMicroserviceController` (마이크로서비스 서버용)를 등록합니다.
// - `providers`: `MicroserviceService`를 등록하여 비즈니스 로직을 제공합니다.
// -----------------------------------------------------------------------------
@Module({
  controllers: [MicroserviceController, MathServiceMicroserviceController], // 두 컨트롤러 등록
  providers: [MicroserviceService],
  exports: [MicroserviceService], // 다른 모듈에서 MicroserviceService를 사용할 수 있도록 내보내기 (선택 사항)
})
export class MicroserviceModule {}

/*
이 코드를 실행하려면:

1. `microservice.controller.ts` 및 `microservice.service.ts` 파일과 함께
   `src/microservice` 디렉토리에 이 파일을 생성합니다.
*/
