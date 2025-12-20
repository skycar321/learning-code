// nestjs/Step4_AdvancedFeatures/current-user.decorator.ts
// NestJS 학습 계획 - 4단계: 고급 기능 및 모범 사례
// 이 파일은 `CurrentUser` 커스텀 데코레이터를 사용하여
// 인증된 사용자 정보를 컨트롤러의 라우트 핸들러에 쉽게 주입하는 방법을 보여줍니다.
//
// 커스텀 데코레이터는 NestJS의 강력한 기능 중 하나로,
// 반복되는 로직을 추상화하여 컨트롤러 코드를 간결하고 재사용 가능하게 만듭니다.

import { createParamDecorator, ExecutionContext } from '@nestjs/common';

// -----------------------------------------------------------------------------
// 학습 포인트 1: `createParamDecorator()` 함수
// - `createParamDecorator()` 함수를 사용하여 커스텀 파라미터 데코레이터를 생성합니다.
// - 이 함수는 `ExecutionContext`를 인자로 받는 팩토리 함수를 기대합니다.
// -----------------------------------------------------------------------------
export const CurrentUser = createParamDecorator(
  (data: unknown, ctx: ExecutionContext) => {
    // -----------------------------------------------------------------------------
    // 학습 포인트 2: `ExecutionContext` 활용
    // - `ExecutionContext` 객체는 현재 요청의 컨텍스트에 대한 정보를 제공합니다.
    //   - `ctx.getType()`: 컨텍스트의 타입 (http, rpc, ws)
    //   - `ctx.switchToHttp().getRequest()`: HTTP 요청 객체에 접근
    // -----------------------------------------------------------------------------
    const request = ctx.switchToHttp().getRequest();
    // -----------------------------------------------------------------------------
    // 학습 포인트 3: `request.user`에서 사용자 정보 추출
    // - `JwtAuthGuard`와 `JwtStrategy`가 성공적으로 인증을 완료하면,
    //   인증된 사용자 정보가 `request.user`에 저장됩니다.
    // - `data` 인자는 데코레이터를 사용할 때 전달되는 선택적 파라미터입니다 (예: `@CurrentUser('id')`는 `id`만 가져옴).
    // -----------------------------------------------------------------------------
    // 나쁜 예시: `request.user` 객체에서 특정 필드를 가져오기 위해
    // - 각 컨트롤러 메서드마다 반복적으로 `req.user.id`, `req.user.email`과 같이 접근하는 것.
    // - 코드 중복을 유발하고, `user` 객체의 구조가 변경될 때 여러 곳을 수정해야 합니다.

    // `data`가 특정 필드명인 경우 해당 필드만 반환 (예: `@CurrentUser('email')`)
    return data ? request.user?.[data as string] : request.user;
  },
);

/*
이 코드를 실행하려면:

1. `src/decorators/current-user.decorator.ts`와 같이 적절한 디렉토리에 이 파일을 생성합니다.
2. `JwtAuthGuard` (Step3의 `jwt.guard.ts`)를 사용하여 라우트를 보호해야 `request.user` 객체에
   사용자 정보가 주입됩니다.
3. 컨트롤러에서 `CurrentUser` 데코레이터를 사용하는 예시:
   ```typescript
   // my.controller.ts
   import { Controller, Get, UseGuards } from '@nestjs/common';
   import { JwtAuthGuard } from './auth/jwt.guard'; // Step3의 JwtAuthGuard
   import { CurrentUser } from './decorators/current-user.decorator'; // CurrentUser 데코레이터

   @Controller('me')
   export class MeController {
     @UseGuards(JwtAuthGuard)
     @Get()
     getProfile(@CurrentUser() user: any) { // 인증된 전체 사용자 객체 가져오기
       return user;
     }

     @UseGuards(JwtAuthGuard)
     @Get('email')
     getEmail(@CurrentUser('email') userEmail: string) { // 사용자 이메일만 가져오기
       return { email: userEmail };
     }
   }
   ```
*/
