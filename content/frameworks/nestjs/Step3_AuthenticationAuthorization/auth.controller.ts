// nestjs/Step3_AuthenticationAuthorization/auth.controller.ts
// NestJS 학습 계획 - 3단계: 인증 및 인가
// 이 파일은 `AuthModule`의 `AuthController`입니다.
// `AuthController`는 사용자 로그인 및 인증과 관련된 HTTP 요청을 처리합니다.
//
// NestJS에서 컨트롤러는 라우팅 메커니즘을 통해 특정 엔드포인트에 대한 요청을 담당하며,
// `AuthService`를 통해 비즈니스 로직을 수행합니다.

import { Controller, Post, Body, UseGuards, Request, Get } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthLoginDto } from './dto/auth-login.dto';
import { JwtAuthGuard } from './jwt.guard'; // JWT 인증 가드 임포트 (아직 생성되지 않음)

// -----------------------------------------------------------------------------
// 학습 포인트 1: `@Controller('auth')` 데코레이터
// - 클래스를 NestJS 컨트롤러로 선언하고, 경로 접두사를 `/auth`로 지정합니다.
// - 이 컨트롤러의 모든 엔드포인트는 `/auth`로 시작합니다.
// -----------------------------------------------------------------------------
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  // -----------------------------------------------------------------------------
  // 학습 포인트 2: 로그인 엔드포인트 (`/auth/login`)
  // - `@Post('login')`: 로그인 요청을 처리하는 엔드포인트를 정의합니다.
  // - `@Body()`: 요청 본문에서 `AuthLoginDto` 데이터를 가져옵니다.
  // - `AuthService.login()`을 호출하여 사용자 인증 및 JWT 토큰을 발행합니다.
  // -----------------------------------------------------------------------------
  @Post('login')
  async login(@Body() authLoginDto: AuthLoginDto) {
    // 나쁜 예시: 컨트롤러에서 직접 사용자 인증 로직을 구현하거나,
    // - JWT 토큰을 생성하는 로직을 포함하는 것.
    // - 컨트롤러는 요청 처리와 응답 반환에 집중하고, 인증/인가 비즈니스 로직은 `AuthService`에 위임해야 합니다.
    return this.authService.login(authLoginDto);
  }

  // -----------------------------------------------------------------------------
  // 학습 포인트 3: 보호된 엔드포인트 (`/auth/profile`)
  // - `@UseGuards(JwtAuthGuard)`: 이 엔드포인트에 접근하기 전에 `JwtAuthGuard`를 사용하여
  //   JWT 토큰의 유효성을 검증하도록 지시합니다.
  // - `@Request()`: 요청 객체(`req`)를 주입받아 JWT 검증 후 `req.user`에 저장된
  //   인증된 사용자 정보를 가져올 수 있습니다.
  // -----------------------------------------------------------------------------
  @UseGuards(JwtAuthGuard) // 이 엔드포인트는 JWT 인증이 필요합니다.
  @Get('profile')
  getProfile(@Request() req) {
    // JwtAuthGuard가 성공적으로 인증되면 요청 객체에 `user` 정보가 추가됩니다.
    return req.user;
  }

  // 나쁜 예시: JWT 토큰의 유효성 검사를 각 컨트롤러 메서드 내에서 수동으로 구현하는 것.
  // - 코드 중복을 유발하고 유지보수를 어렵게 만듭니다.
  // - `AuthGuard` (또는 커스텀 가드)를 사용하여 인증/인가 로직을 중앙 집중식으로 관리해야 합니다.
}

/*
이 코드를 실행하려면:

1. `auth.module.ts`, `auth.service.ts`, `dto/auth-login.dto.ts`, `jwt.guard.ts` 파일과 함께
   `src/auth` 디렉토리에 이 파일을 생성합니다.
*/
