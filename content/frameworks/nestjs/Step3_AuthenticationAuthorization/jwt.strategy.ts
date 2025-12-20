// nestjs/Step3_AuthenticationAuthorization/jwt.strategy.ts
// NestJS 학습 계획 - 3단계: 인증 및 인가
// 이 파일은 JWT(JSON Web Token) 기반 인증을 위한 `JwtStrategy`입니다.
// `JwtStrategy`는 Passport.js에 JWT 토큰을 추출하고 검증하는 방법을 알려줍니다.
//
// Passport.js는 다양한 인증 전략(Local, JWT, OAuth 등)을 플러그인 형태로 제공하며,
// NestJS는 `@nestjs/passport` 패키지를 통해 이를 쉽게 통합할 수 있습니다.

import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt'; // JWT 전략을 위한 모듈 임포트
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config'; // 환경 변수 관리를 위한 ConfigService
import { UserService } from '../Step2_DatabaseIntegration/user.service'; // UserService 임포트

// -----------------------------------------------------------------------------
// 학습 포인트 1: `@Injectable()` 및 `PassportStrategy(Strategy)` 상속
// - `@Injectable()` 데코레이터로 프로바이더임을 선언합니다.
// - `PassportStrategy(Strategy)`를 상속받아 Passport에 JWT 인증 전략을 제공합니다.
// -----------------------------------------------------------------------------
@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    private configService: ConfigService, // ConfigService 주입
    private userService: UserService,   // UserService 주입 (사용자 정보 조회를 위해)
  ) {
    // -----------------------------------------------------------------------------
    // 학습 포인트 2: JWT 전략 구성
    // - `jwtFromRequest`: 요청에서 JWT 토큰을 추출하는 방법을 정의합니다 (예: `Authorization` 헤더의 `Bearer` 토큰).
    // - `ignoreExpiration`: 토큰 만료를 무시할지 여부를 설정합니다 (운영 환경에서는 `false`).
    // - `secretOrKey`: JWT 서명에 사용된 비밀 키를 제공합니다.
    // -----------------------------------------------------------------------------
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(), // Bearer 토큰으로 JWT 추출
      ignoreExpiration: false, // 토큰 만료 여부 검사
      secretOrKey: configService.get<string>('JWT_SECRET'), // 환경 변수에서 JWT 비밀 키 가져오기
    });
  }

  // -----------------------------------------------------------------------------
  // 학습 포인트 3: `validate()` 메서드
  // - JWT 토큰이 유효하게 검증된 후에 호출됩니다.
  // - 토큰의 페이로드(payload)를 인자로 받아, 페이로드에 포함된 사용자 정보를 기반으로
  //   데이터베이스에서 사용자 정보를 조회하고 유효성을 다시 확인합니다.
  // - 반환된 객체는 `@Request()` 데코레이터를 사용하여 컨트롤러에서 `req.user`로 접근할 수 있습니다.
  // -----------------------------------------------------------------------------
  async validate(payload: any) {
    // 페이로드에서 사용자 ID를 추출하여 데이터베이스에서 사용자 정보를 조회 (실제 구현 필요)
    // const user = await this.userService.findOne(payload.sub);
    const user = { id: payload.sub, email: payload.email, roles: payload.roles }; // 예시 사용자 객체

    if (!user) {
      throw new UnauthorizedException('유효하지 않은 토큰입니다.');
    }
    // 나쁜 예시: JWT 페이로드에 민감한 정보(비밀번호 해시 등)를 모두 포함하여
    // - 사용자 정보를 데이터베이스에서 다시 조회하지 않는 것.
    // - JWT는 변조 방지를 위한 서명은 되어 있지만, 인코딩된 정보는 누구나 볼 수 있습니다.
    // - 필요한 최소한의 정보만 페이로드에 담고, 중요한 정보는 DB에서 조회해야 합니다.

    // 반환된 객체는 요청 객체의 `user` 프로퍼티에 할당됩니다 (예: `req.user`).
    return user;
  }
}

/*
이 코드를 실행하려면:

1. `auth.module.ts`, `auth.service.ts`, `auth.controller.ts` 파일과 함께 `src/auth` 디렉토리에 이 파일을 생성합니다.
2. `package.json`에 `@nestjs/passport`, `passport`, `passport-jwt` 패키지가 설치되어 있어야 합니다.
3. `.env` 파일에 `JWT_SECRET=YOUR_VERY_STRONG_SECRET_KEY`가 설정되어 있어야 합니다.
*/
