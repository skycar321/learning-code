// nestjs/Step5_MicroservicesAndGraphQL/microservice.controller.ts
// NestJS 학습 계획 - 5단계: 마이크로서비스 및 GraphQL
// 이 파일은 NestJS 마이크로서비스(Microservice) 클라이언트/서버 통신을 보여주는 `MicroserviceController`입니다.
// NestJS 마이크로서비스는 다양한 트랜스포터(Transport) 레이어(TCP, Redis, Kafka, RabbitMQ 등)를 지원합니다.
// 여기서는 TCP 트랜스포터를 사용한 요청-응답 패턴을 예시로 보여줍니다.
//
// 마이크로서비스 아키텍처는 애플리케이션을 작고 독립적인 서비스들로 분리하여
// 개발, 배포, 확장을 유연하게 만듭니다.

import { Controller, Get, Param, OnModuleInit, Inject } from '@nestjs/common';
import { ClientProxy, ClientTCP, MessagePattern } from '@nestjs/microservices';
import { MicroserviceService } from './microservice.service';

// -----------------------------------------------------------------------------
// 학습 포인트 1: `ClientProxy`를 이용한 마이크로서비스 클라이언트 구현
// - `@Inject('MATH_SERVICE')` 데코레이터를 사용하여 클라이언트 프록시를 주입받습니다.
// - `client.send()` 메서드를 사용하여 마이크로서비스 서버에 메시지를 보냅니다.
// - `onModuleInit()` 라이프사이클 훅을 사용하여 클라이언트 연결을 보장합니다.
// -----------------------------------------------------------------------------
@Controller('microservice')
export class MicroserviceController implements OnModuleInit {
  constructor(
    private readonly microserviceService: MicroserviceService,
    @Inject('MATH_SERVICE') private client: ClientProxy, // 'MATH_SERVICE'는 클라이언트 프록시의 토큰 (AppModule에서 정의)
  ) {}

  async onModuleInit() {
    // 클라이언트가 마이크로서비스 서버에 연결될 때까지 기다립니다.
    // 연결이 실패하면 요청이 제대로 전달되지 않을 수 있습니다.
    await this.client.connect();
  }

  // -----------------------------------------------------------------------------
  // 학습 포인트 2: 요청-응답 패턴 (Request-Response Pattern)
  // - 클라이언트가 메시지를 보내고 서버로부터 응답을 기다립니다.
  // - `client.send(pattern, payload)` 형식으로 메시지를 보냅니다.
  //   - `pattern`: 메시지를 처리할 핸들러를 식별하는 문자열 또는 객체.
  //   - `payload`: 마이크로서비스 서버로 보낼 데이터.
  // -----------------------------------------------------------------------------
  @Get('add/:a/:b')
  async accumulate(@Param('a') a: number, @Param('b') b: number) {
    // 나쁜 예시: 마이크로서비스 간의 통신에서 에러 처리, 타임아웃, 재시도 로직을 고려하지 않는 것.
    // - 마이크로서비스는 분산 시스템이므로 네트워크 지연, 서비스 장애 등의 문제가 발생할 수 있습니다.
    // - 모든 통신에는 타임아웃, 폴백(fallback), 서킷 브레이커(circuit breaker) 등의 패턴을 적용해야 합니다.
    const result = await this.client.send<number, number[]>('add', [+a, +b]).toPromise();
    return `마이크로서비스에서 계산된 값: ${result}`;
  }

  @Get('multiply/:a/:b')
  async multiply(@Param('a') a: number, @Param('b') b: number) {
    const result = await this.client.send<number, number[]>('multiply', [+a, +b]).toPromise();
    return `마이크로서비스에서 계산된 값: ${result}`;
  }

  // 나쁜 예시: 클라이언트 측에서 마이크로서비스의 내부 로직을 직접 호출하는 것처럼
  // - 강하게 결합된 코드를 작성하는 것.
  // - 마이크로서비스는 독립적으로 변경되고 배포될 수 있어야 합니다.
  // - `client.send()`와 같은 메시지 기반 통신을 사용하여 느슨하게 결합되어야 합니다.
}

// -----------------------------------------------------------------------------
// 학습 포인트 3: 마이크로서비스 서버 핸들러 구현
// - `@MessagePattern()` 데코레이터를 사용하여 특정 메시지 패턴에 대한 핸들러를 정의합니다.
// - `MicroserviceService`에서 실제 비즈니스 로직을 처리합니다.
// -----------------------------------------------------------------------------
@Controller()
export class MathServiceMicroserviceController {
  constructor(private readonly microserviceService: MicroserviceService) {}

  @MessagePattern('add') // 'add' 패턴에 대한 메시지를 처리
  add(data: number[]): number {
    return this.microserviceService.accumulate(data);
  }

  @MessagePattern('multiply') // 'multiply' 패턴에 대한 메시지를 처리
  multiply(data: number[]): number {
    return this.microserviceService.multiply(data);
  }

  // 나쁜 예시: 마이크로서비스 서버 핸들러에서 복잡한 HTTP 응답 처리 로직을 포함하는 것.
  // - 마이크로서비스는 보통 내부 서비스 간 통신을 위해 사용되므로 HTTP 응답보다는
  // - 메시지 페이로드와 상태 코드(에러 메시지)를 명확히 전달해야 합니다.
}

/*
이 코드를 실행하려면:

1. `main.ts` 및 `app.module.ts`가 설정된 NestJS 프로젝트에 이 파일을 생성합니다.
2. `microservice.service.ts` 파일도 함께 생성해야 합니다.
3. `package.json`에 `@nestjs/microservices` 패키지를 설치해야 합니다. (예: `npm install @nestjs/microservices`)
4. NestJS 애플리케이션을 두 개의 별도 프로세스로 실행해야 합니다 (하나는 게이트웨이, 다른 하나는 마이크로서비스).

게이트웨이(HTTP) 애플리케이션 (`main.ts`):
```typescript
// main.ts (게이트웨이)
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  await app.listen(3000); // HTTP 포트
  console.log(`HTTP Gateway is running on: ${await app.getUrl()}`);
}
bootstrap();
```

마이크로서비스(TCP) 애플리케이션 (`main.microservice.ts`):
```typescript
// main.microservice.ts
import { NestFactory } from '@nestjs/core';
import { MicroserviceModule } from './microservice/microservice.module'; // microservice.module 경로 확인
import { Transport } from '@nestjs/microservices';

async function bootstrap() {
  const app = await NestFactory.createMicroservice(MicroserviceModule, {
    transport: Transport.TCP,
    options: { port: 3001 }, // 마이크로서비스 포트
  });
  await app.listen();
  console.log('Microservice is listening on port 3001');
}
bootstrap();
```
그리고 `app.module.ts`에 `MicroserviceModule`을 임포트하고 클라이언트 프록시를 설정해야 합니다.
```typescript
// app.module.ts (게이트웨이)
import { Module } from '@nestjs/common';
import { ClientsModule, Transport } from '@nestjs/microservices'; // ClientsModule 임포트

import { AppController } from './app.controller';
import { AppService } from './app.service';
import { MicroserviceModule } from './microservice/microservice.module'; // MicroserviceModule 임포트

@Module({
  imports: [
    MicroserviceModule,
    ClientsModule.register([
      {
        name: 'MATH_SERVICE', // 클라이언트 프록시 토큰
        transport: Transport.TCP,
        options: { port: 3001 }, // 마이크로서비스 포트와 동일하게 설정
      },
    ]),
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
```

*/
