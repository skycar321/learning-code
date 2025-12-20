// nestjs/Step1_NestJSBasics/app.controller.ts
// NestJS 학습 계획 - 1단계: NestJS 기본 개념 및 시작
// 이 파일은 NestJS 애플리케이션의 `AppController`입니다.
// 컨트롤러(Controller)는 들어오는 요청을 처리하고 클라이언트에게 응답을 반환하는 역할을 합니다.
//
// NestJS에서 컨트롤러는 라우팅 메커니즘을 통해 특정 엔드포인트에 대한 요청을 담당합니다.

import { Controller, Get, Post, Body, Param } from '@nestjs/common';
import { AppService } from './app.service';

// -----------------------------------------------------------------------------
// 학습 포인트 1: `@Controller()` 데코레이터
// - 클래스를 NestJS 컨트롤러로 선언하고, 선택적으로 경로 접두사를 지정할 수 있습니다.
// - `@Controller('users')`는 `/users` 경로로 시작하는 요청을 이 컨트롤러에서 처리함을 의미합니다.
// -----------------------------------------------------------------------------
@Controller() // 경로 접두사 없이 루트 경로('/') 요청을 처리
export class AppController {
  // -----------------------------------------------------------------------------
  // 학습 포인트 2: 의존성 주입 (Dependency Injection)
  // - 생성자 주입(Constructor Injection)을 통해 `AppService` 인스턴스를 주입받습니다.
  // - NestJS의 IoC(Inversion of Control) 컨테이너가 자동으로 의존성을 해결하고 주입합니다.
  // -----------------------------------------------------------------------------
  constructor(private readonly appService: AppService) {}

  // -----------------------------------------------------------------------------
  // 학습 포인트 3: HTTP 요청 핸들러 데코레이터
  // - `@Get()`, `@Post()`, `@Put()`, `@Delete()`, `@Patch()` 등을 사용하여
  //   특정 HTTP 메서드와 경로에 대한 핸들러 메서드를 정의합니다.
  // - 선택적으로 경로를 지정할 수 있습니다. `@Get('hello')`는 `/hello` 경로에 대한 GET 요청 처리.
  // -----------------------------------------------------------------------------

  // GET /
  @Get()
  getHello(): string {
    // 나쁜 예시: 컨트롤러 메서드 내에서 복잡한 비즈니스 로직을 직접 처리하는 것.
    // - 컨트롤러는 요청을 받고 응답을 반환하는 역할에 집중해야 합니다.
    // - 비즈니스 로직은 서비스(Service) 레이어로 분리하여 캡슐화해야 합니다.
    return this.appService.getHello();
  }

  // GET /greet/:name
  @Get('greet/:name')
  getGreeting(@Param('name') name: string): string {
    return this.appService.getGreeting(name);
  }

  // POST /data
  @Post('data')
  postData(@Body() data: any): string {
    return `데이터 수신 완료: ${JSON.stringify(data)}`;
  }

  // 나쁜 예시: DTO(Data Transfer Object)를 사용하지 않고 `@Body() data: any`와 같이
  // - `any` 타입을 사용하여 요청 본문을 받는 것.
  // - 타입 안정성을 해치고, 유효성 검사(Validation)를 어렵게 만듭니다.
  // - `class-validator`와 함께 DTO 클래스를 정의하여 요청 본문의 유효성을 검사하는 것이 좋습니다.
}

/*
이 코드를 실행하려면:

1. `main.ts`, `app.module.ts` 파일과 함께 `src` 디렉토리에 이 파일을 생성합니다.
2. `app.service.ts` 파일도 함께 생성해야 합니다.
*/
