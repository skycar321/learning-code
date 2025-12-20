// nestjs/Step3_AuthenticationAuthorization/dto/auth-login.dto.ts
// NestJS 학습 계획 - 3단계: 인증 및 인가
// 이 파일은 사용자 로그인 요청에 사용되는 데이터 전송 객체(DTO)인 `AuthLoginDto`를 정의합니다.
//
// DTO는 `class-validator`와 `class-transformer` 라이브러리와 함께 사용하여
// 요청 본문의 유효성을 자동으로 검사하고 변환할 수 있도록 합니다.

// `class-validator`를 위한 데코레이터 임포트 (설치 필요: `npm install class-validator class-transformer`)
// import { IsEmail, IsString, MinLength } from 'class-validator';

// -----------------------------------------------------------------------------
// 학습 포인트 1: `AuthLoginDto` 정의
// - 로그인 요청 시 클라이언트로부터 받을 데이터를 정의합니다.
// - `email`과 `password`는 필수 필드입니다.
// - `@IsEmail()`, `@IsString()`, `@MinLength()` 등 `class-validator` 데코레이터를 사용하여
//   각 필드의 유효성 검사 규칙을 명시적으로 선언합니다.
// -----------------------------------------------------------------------------
export class AuthLoginDto {
  // @IsEmail({}, { message: '유효한 이메일 주소를 입력해주세요.' })
  email: string;

  // @IsString({ message: '비밀번호는 문자열이어야 합니다.' })
  // @MinLength(6, { message: '비밀번호는 최소 6자 이상이어야 합니다.' })
  password: string;

  // 나쁜 예시: 로그인 DTO에 `username`과 `password` 외에 불필요한 필드를 포함하는 것.
  // - 불필요한 데이터는 요청 본문의 크기를 늘리고 보안에 잠재적인 위험을 초래할 수 있습니다.
  // - DTO는 해당 요청에 필요한 최소한의 데이터만 포함해야 합니다.
}

/*
이 코드를 실행하려면:

1. `auth.service.ts` 파일과 함께 `src/auth/dto` 디렉토리에 이 파일을 생성합니다.
2. `class-validator` 및 `class-transformer` 라이브러리가 설치되어 있어야 합니다.
   `npm install class-validator class-transformer`
*/
