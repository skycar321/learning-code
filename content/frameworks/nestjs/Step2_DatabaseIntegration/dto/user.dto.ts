// nestjs/Step2_DatabaseIntegration/dto/user.dto.ts
// NestJS 학습 계획 - 2단계: 데이터베이스 통합 및 ORM
// 이 파일은 사용자 데이터 전송 객체(DTO: Data Transfer Object)를 정의합니다.
// DTO는 네트워크를 통해 데이터가 전송될 때 데이터의 구조와 유효성 검사 규칙을 정의하는 데 사용됩니다.
//
// NestJS에서는 `class-validator`와 `class-transformer` 라이브러리와 함께 DTO를 사용하여
// 들어오는 요청 본문의 유효성을 자동으로 검사하고 변환할 수 있습니다.

// `class-validator`를 위한 데코레이터 임포트 (설치 필요: `npm install class-validator class-transformer`)
// import { IsEmail, IsString, MinLength, IsBoolean, IsOptional } from 'class-validator';

// -----------------------------------------------------------------------------
// 학습 포인트 1: `CreateUserDto` (사용자 생성 요청)
// - 새로운 사용자 생성 시 클라이언트로부터 받을 데이터를 정의합니다.
// - `@IsEmail()`, `@IsString()`, `@MinLength()` 등 `class-validator` 데코레이터를 사용하여
//   각 필드의 유효성 검사 규칙을 명시적으로 선언합니다.
// -----------------------------------------------------------------------------
export class CreateUserDto {
  // @IsEmail({}, { message: '유효한 이메일 주소를 입력해주세요.' })
  email: string;

  // @IsString({ message: '비밀번호는 문자열이어야 합니다.' })
  // @MinLength(6, { message: '비밀번호는 최소 6자 이상이어야 합니다.' })
  password: string;

  // @IsString({ message: '이름은 문자열이어야 합니다.' })
  // @IsOptional() // 선택적 필드
  name?: string;

  // @IsBoolean({ message: 'isActive는 boolean 값이어야 합니다.' })
  // @IsOptional()
  isActive?: boolean;

  // 나쁜 예시: DTO를 사용하지 않고 컨트롤러 메서드에서 `any` 타입으로 요청 본문을 받거나,
  // - 유효성 검사 로직을 수동으로 `if-else` 문으로 구현하는 것.
  // - 이는 코드 중복을 유발하고, 유효성 검사 로직의 재사용성을 떨어뜨립니다.
}

// -----------------------------------------------------------------------------
// 학습 포인트 2: `UpdateUserDto` (사용자 업데이트 요청)
// - 기존 사용자 정보 업데이트 시 클라이언트로부터 받을 데이터를 정의합니다.
// - 모든 필드가 선택적(`?`)이며, `@IsOptional()` 데코레이터와 함께 사용될 수 있습니다.
// -----------------------------------------------------------------------------
export class UpdateUserDto {
  // @IsEmail({}, { message: '유효한 이메일 주소를 입력해주세요.' })
  // @IsOptional() // 업데이트 시 이메일은 선택적
  email?: string;

  // @IsString({ message: '비밀번호는 문자열이어야 합니다.' })
  // @MinLength(6, { message: '비밀번호는 최소 6자 이상이어야 합니다.' })
  // @IsOptional()
  password?: string;

  // @IsString({ message: '이름은 문자열이어야 합니다.' })
  // @IsOptional()
  name?: string;

  // @IsBoolean({ message: 'isActive는 boolean 값이어야 합니다.' })
  // @IsOptional()
  isActive?: boolean;

  // 나쁜 예시: `UpdateUserDto`를 `CreateUserDto`와 동일하게 정의하여
  // - 모든 필드를 필수적으로 요구하거나, 업데이트 불가능한 필드를 노출하는 것.
  // - 업데이트 시에는 변경될 필드만 선택적으로 받을 수 있도록 설계해야 합니다.
}

/*
이 코드를 실행하려면:

1. `user.service.ts` 파일과 함께 `src/user/dto` 디렉토리에 이 파일을 생성합니다.
2. `class-validator` 및 `class-transformer` 라이브러리가 설치되어 있어야 합니다.
   `npm install class-validator class-transformer`
*/
