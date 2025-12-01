// nestjs/Step3_AuthenticationAuthorization/auth.service.ts
// NestJS 학습 계획 - 3단계: 인증 및 인가
// 이 파일은 `AuthModule`의 `AuthService`입니다.
// `AuthService`는 사용자 로그인, JWT(JSON Web Token) 생성 및 검증과 같은
// 핵심 인증 로직을 처리합니다.
//
// NestJS는 `@nestjs/jwt`와 `UserService`를 통합하여 인증 서비스를 구현할 수 있습니다.

import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt'; // JWT 서비스 임포트
import * as bcrypt from 'bcryptjs'; // 비밀번호 해싱을 위한 bcryptjs 임포트
import { UserService } from '../Step2_DatabaseIntegration/user.service'; // UserService 임포트
import { AuthLoginDto } from './dto/auth-login.dto'; // AuthLoginDto 임포트 (아직 생성되지 않음)

// -----------------------------------------------------------------------------
// 학습 포인트 1: `JwtService`, `UserService` 의존성 주입
// - `AuthService`는 `JwtService`를 사용하여 JWT 토큰을 생성하고,
// - `UserService`를 사용하여 사용자 정보를 데이터베이스에서 조회합니다.
// -----------------------------------------------------------------------------
@Injectable()
export class AuthService {
  constructor(
    private userService: UserService, // UserService 주입
    private jwtService: JwtService,   // JwtService 주입
  ) {}

  // -----------------------------------------------------------------------------
  // 학습 포인트 2: 사용자 유효성 검사 (`validateUser`)
  // - 로그인 요청 시 사용자의 자격 증명(이메일, 비밀번호)을 검증합니다.
  // - 데이터베이스에서 사용자 정보를 조회하고, 비밀번호를 비교합니다.
  // -----------------------------------------------------------------------------
  async validateUser(email: string, pass: string): Promise<any> {
    const user = await this.userService.findAll().then(users => users.find(u => u.email === email)); // 실제로는 findByEmail 사용
    if (user && bcrypt.compareSync(pass, user.password)) { // 비밀번호 비교
      // 나쁜 예시: 사용자 객체에 비밀번호를 포함하여 반환하는 것.
      // - 민감 정보는 API 응답에서 제외해야 합니다.
      const { password, ...result } = user; // 비밀번호 제외
      return result;
    }
    return null;
  }

  // -----------------------------------------------------------------------------
  // 학습 포인트 3: 로그인 (`login`) 및 JWT 토큰 생성
  // - `validateUser`를 통해 검증된 사용자에게 JWT 액세스 토큰을 발행합니다.
  // - `JwtService.sign()` 메서드를 사용하여 토큰을 생성합니다.
  // - JWT 페이로드(payload)에는 사용자 ID, 이메일, 역할 등 필요한 정보만 포함합니다.
  // -----------------------------------------------------------------------------
  async login(authLoginDto: AuthLoginDto) {
    const user = await this.validateUser(authLoginDto.email, authLoginDto.password);
    if (!user) {
      throw new UnauthorizedException('이메일 또는 비밀번호가 올바르지 않습니다.');
    }
    // JWT 페이로드 (payload) 정의
    const payload = { email: user.email, sub: user.id, roles: ['user'] }; // roles는 실제 DB에서 가져와야 함

    return {
      access_token: this.jwtService.sign(payload), // JWT 토큰 생성
    };
  }

  // -----------------------------------------------------------------------------
  // 학습 포인트 4: 비밀번호 해싱 (`hashPassword`) (예시)
  // - 사용자 비밀번호를 데이터베이스에 저장하기 전에 안전하게 해싱합니다.
  // -----------------------------------------------------------------------------
  async hashPassword(password: string): Promise<string> {
    const salt = await bcrypt.genSalt(10); // 솔트(salt) 생성
    return bcrypt.hash(password, salt); // 비밀번호 해싱
  }

  // 나쁜 예시: 비밀번호를 암호화하지 않고 평문으로 데이터베이스에 저장하는 것.
  // - 또는 약한 해싱 알고리즘을 사용하거나, 솔트 없이 해싱하는 것.
  // - `bcrypt`와 같이 강력한 해싱 알고리즘과 충분히 긴 솔트를 사용하는 것이 중요합니다.
}

/*
이 코드를 실행하려면:

1. `auth.module.ts`, `auth.controller.ts`, `jwt.strategy.ts` 파일과 함께 `src/auth` 디렉토리에 이 파일을 생성합니다.
2. `src/auth/dto/auth-login.dto.ts` 파일도 함께 생성해야 합니다.
3. `package.json`에 `bcryptjs` 패키지를 설치해야 합니다. (예: `npm install bcryptjs @types/bcryptjs`)
*/
