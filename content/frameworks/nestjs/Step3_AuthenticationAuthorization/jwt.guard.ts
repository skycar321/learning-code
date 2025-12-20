// nestjs/Step3_AuthenticationAuthorization/jwt.guard.ts
// NestJS 학습 계획 - 3단계: 인증 및 인가
// 이 파일은 JWT(JSON Web Token) 기반 인증을 위한 `JwtAuthGuard`입니다.
// 가드(Guard)는 특정 라우트 핸들러(컨트롤러 메서드)에 접근하기 전에
// 요청을 가로채어 인증 및 인가 로직을 수행합니다.
//
// NestJS는 `@nestjs/passport`를 통해 Passport.js의 인증 가드를 쉽게 사용할 수 있도록 합니다.

import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport'; // Passport의 AuthGuard 임포트

// -----------------------------------------------------------------------------
// 학습 포인트 1: `@Injectable()` 및 `AuthGuard('jwt')` 상속
// - `@Injectable()` 데코레이터로 프로바이더임을 선언합니다.
// - `AuthGuard('jwt')`를 상속받아 Passport의 'jwt' 전략을 사용하는 인증 가드를 생성합니다.
// - 이 가드는 자동으로 요청 헤더에서 JWT 토큰을 추출하고 `JwtStrategy`를 사용하여 검증합니다.
// -----------------------------------------------------------------------------
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  // `AuthGuard`는 자동으로 다음을 수행합니다:
  // 1. 요청에서 JWT 토큰을 추출합니다.
  // 2. `JwtStrategy`에 정의된 `secretOrKey`를 사용하여 토큰의 유효성을 검증합니다.
  // 3. 토큰이 유효하면 `JwtStrategy`의 `validate()` 메서드를 호출합니다.
  // 4. `validate()` 메서드에서 반환된 사용자 객체를 요청 객체의 `user` 프로퍼티에 할당합니다 (`req.user`).
  // 5. 인증이 성공하면 `true`를 반환하여 라우트 핸들러로 요청을 전달합니다.
  // 6. 인증이 실패하면 `UnauthorizedException`을 발생시킵니다.

  // 나쁜 예시: 각 컨트롤러 메서드마다 수동으로 토큰을 파싱하고 유효성을 검사하는 것.
  // - 코드 중복을 유발하고 보안 로직의 일관성을 해칩니다.
  // - `AuthGuard`를 사용하여 인증 로직을 중앙 집중식으로 관리하는 것이 좋습니다.

  // 추가적인 커스터마이징을 위해 `canActivate`나 `handleRequest` 메서드를 오버라이드할 수 있습니다.
  // @Override
  // canActivate(context: ExecutionContext) {
  //   // 인증 로직을 커스터마이징할 수 있습니다.
  //   return super.canActivate(context);
  // }

  // @Override
  // handleRequest(err, user, info) {
  //   // 인증 실패 시 에러 응답을 커스터마이징할 수 있습니다.
  //   if (err || !user) {
  //     throw err || new UnauthorizedException('인증 실패: 유효한 토큰이 필요합니다.');
  //   }
  //   return user;
  // }
}

/*
이 코드를 실행하려면:

1. `auth.module.ts`, `auth.service.ts`, `auth.controller.ts`, `jwt.strategy.ts` 파일과 함께
   `src/auth` 디렉토리에 이 파일을 생성합니다.
2. `AuthModule`에 `PassportModule`과 `JwtModule`이 올바르게 설정되어 있어야 합니다.
*/
