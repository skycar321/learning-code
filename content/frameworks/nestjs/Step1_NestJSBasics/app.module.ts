// nestjs/Step1_NestJSBasics/app.module.ts
// NestJS 학습 계획 - 1단계: NestJS 기본 개념 및 시작
// 이 파일은 NestJS 애플리케이션의 루트 모듈인 `AppModule`입니다.
// 모듈(Module)은 NestJS 애플리케이션의 구조를 조직화하는 데 사용되는 핵심 빌딩 블록입니다.
//
// 모든 NestJS 애플리케이션은 하나 이상의 모듈을 가집니다.
// 루트 모듈(`AppModule`)은 애플리케이션의 진입점 역할을 하며,
// 다른 모듈들을 임포트(import)하여 애플리케이션의 기능을 확장합니다.

import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';

// -----------------------------------------------------------------------------
// 학습 포인트 1: `@Module()` 데코레이터
// - 클래스를 NestJS 모듈로 선언합니다.
// - 모듈은 `@Module()` 데코레이터에 메타데이터 객체를 전달하여 구성됩니다.
// - `imports`: 이 모듈이 사용하는 다른 모듈들을 배열로 선언합니다.
// - `controllers`: 이 모듈에서 정의된 컨트롤러들을 배열로 선언합니다.
// - `providers`: 이 모듈에서 정의된 프로바이더(서비스, 레포지토리 등)들을 배열로 선언합니다.
// - `exports`: 이 모듈의 프로바이더를 다른 모듈에서 사용 가능하도록 내보낼 때 사용합니다.
// -----------------------------------------------------------------------------
@Module({
  // `imports` 배열에 다른 모듈들을 추가하여 애플리케이션의 기능을 확장할 수 있습니다.
  // 예: `TypeOrmModule.forRoot(...)`, `AuthModule`, `UserModule`
  imports: [],
  // `controllers` 배열에 이 모듈에서 사용하는 컨트롤러를 등록합니다.
  // 컨트롤러는 들어오는 요청을 처리하고 응답을 반환합니다.
  controllers: [AppController],
  // `providers` 배열에 이 모듈에서 사용하는 프로바이더를 등록합니다.
  // 프로바이더는 서비스, 레포지토리, 팩토리, 헬퍼 등 다양한 목적으로 사용될 수 있으며,
  // 의존성 주입(Dependency Injection)을 통해 다른 컴포넌트에서 사용될 수 있습니다.
  providers: [AppService],
  // 나쁜 예시: `providers`에 등록하지 않은 서비스를 컨트롤러에서 사용하려 하는 것.
  // - 의존성 주입이 제대로 작동하지 않아 런타임 에러가 발생합니다.
  // - 모든 프로바이더는 해당 모듈의 `providers` 배열에 명시적으로 등록해야 합니다.
  // - 또는 `@Injectable()`이 붙은 클래스를 다른 모듈에서 `@Module({ imports: [...] })`로 임포트하여 사용 가능하게 해야 합니다.
})
export class AppModule {}

/*
이 코드를 실행하려면:

1. `main.ts` 파일과 함께 `src` 디렉토리에 이 파일을 생성합니다.
2. `app.controller.ts`와 `app.service.ts` 파일도 함께 생성해야 합니다.
*/
