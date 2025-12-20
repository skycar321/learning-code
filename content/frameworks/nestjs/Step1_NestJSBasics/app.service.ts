// nestjs/Step1_NestJSBasics/app.service.ts
// NestJS 학습 계획 - 1단계: NestJS 기본 개념 및 시작
// 이 파일은 NestJS 애플리케이션의 `AppService`입니다.
// 서비스(Service)는 프로바이더(Provider)의 일종으로,
// 컨트롤러에서 요청을 받아 비즈니스 로직을 처리하는 역할을 합니다.
//
// 프로바이더는 의존성 주입(Dependency Injection) 메커니즘을 통해
// 컨트롤러나 다른 서비스에 주입되어 사용될 수 있습니다.

import { Injectable } from '@nestjs/common';

// -----------------------------------------------------------------------------
// 학습 포인트 1: `@Injectable()` 데코레이터
// - 클래스를 NestJS 프로바이더로 선언합니다.
// - `@Injectable()`이 붙은 클래스는 NestJS IoC 컨테이너에 의해 관리되며,
//   다른 컴포넌트에 주입될 수 있습니다.
// - 이 데코레이터가 없으면 의존성 주입이 작동하지 않습니다.
// -----------------------------------------------------------------------------
@Injectable()
export class AppService {
  getHello(): string {
    return 'Hello World from AppService!';
  }

  getGreeting(name: string): string {
    // 나쁜 예시: 서비스 메서드 내에서 직접 HTTP 응답을 조작하거나,
    // - 클라이언트와 관련된 처리를 하는 것.
    // - 서비스는 순수한 비즈니스 로직에 집중해야 합니다.
    // - 응답 형식 지정, HTTP 상태 코드 설정 등은 컨트롤러의 역할입니다.
    if (!name) {
      // name이 없을 때의 비즈니스 로직 처리 (예: 기본 이름 사용)
      return "Hello, Guest from AppService!";
    }
    return `Hello, ${name} from AppService!`;
  }
}

/*
이 코드를 실행하려면:

1. `main.ts`, `app.module.ts`, `app.controller.ts` 파일과 함께 `src` 디렉토리에 이 파일을 생성합니다.
*/
