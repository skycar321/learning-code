// nestjs/Step4_AdvancedFeatures/validation.pipe.ts
// NestJS 학습 계획 - 4단계: 고급 기능 및 모범 사례
// 이 파일은 `ValidationPipe`를 사용하여 요청 데이터(DTO)의 유효성 검사를 자동화하는 방법을 보여줍니다.
//
// 파이프(Pipe)는 컨트롤러의 라우트 핸들러에 의해 처리되기 전에 입력 데이터를 변환하거나
// 유효성을 검사하는 데 사용되는 클래스입니다.
// `class-validator`와 `class-transformer` 라이브러리와 함께 사용될 때 매우 강력합니다.

import { PipeTransform, Injectable, ArgumentMetadata, BadRequestException } from '@nestjs/common';
import { validate } from 'class-validator';
import { plainToClass } from 'class-transformer';

// -----------------------------------------------------------------------------
// 학습 포인트 1: `PipeTransform` 인터페이스 구현
// - 커스텀 파이프를 생성하려면 `PipeTransform` 인터페이스를 구현해야 합니다.
// - `transform()` 메서드는 파이프의 핵심 로직을 포함합니다.
//   - `value`: 핸들러 메서드로 전달되는 인자 (예: `@Body()`의 DTO 객체).
//   - `metadata`: 핸들러 인자에 대한 메타데이터 (타입, 이름 등).
// -----------------------------------------------------------------------------
@Injectable()
export class ValidationPipe implements PipeTransform<any> {
  async transform(value: any, { metatype }: ArgumentMetadata) {
    // -----------------------------------------------------------------------------
    // 학습 포인트 2: 메타데이터를 이용한 타입 유효성 검사
    // - `@Body()` 데코레이터와 함께 DTO 클래스가 사용된 경우, `metatype`은 해당 DTO 클래스입니다.
    // - `metatype`이 없거나 `String`, `Boolean`, `Number`, `Array`, `Object`와 같은
    //   기본 타입이면 유효성 검사를 수행하지 않습니다.
    // -----------------------------------------------------------------------------
    if (!metatype || !this.toValidate(metatype)) {
      return value;
    }

    // -----------------------------------------------------------------------------
    // 학습 포인트 3: `plainToClass`와 `validate` 함수
    // - `plainToClass`: 일반 JavaScript 객체(클라이언트에서 전송된 JSON)를
    //   `metatype`(DTO 클래스)의 인스턴스로 변환합니다. 이를 통해 `class-validator`
    //   데코레이터를 사용할 수 있게 됩니다.
    // - `validate`: `class-validator` 데코레이터에 정의된 규칙에 따라 객체의 유효성을 검사합니다.
    //   유효성 검사 오류가 있으면 `ValidationError` 객체 배열을 반환합니다.
    // -----------------------------------------------------------------------------
    const object = plainToClass(metatype, value);
    const errors = await validate(object); // 유효성 검사 수행

    if (errors.length > 0) {
      // 나쁜 예시: 유효성 검사 실패 시 컨트롤러에서 수동으로 에러를 처리하는 것.
      // - 모든 컨트롤러 메서드에 유효성 검사 로직이 중복되어 코드가 길어지고 유지보수가 어려워집니다.
      // 좋은 예시: 파이프를 사용하여 유효성 검사 로직을 중앙 집중식으로 관리하고,
      // - `BadRequestException`을 발생시켜 전역 예외 필터(Exception Filter)에서 처리하도록 합니다.
      throw new BadRequestException('유효성 검사 실패', this.formatErrors(errors));
    }
    return value;
  }

  // 기본 타입인지 확인
  private toValidate(metatype: Function): boolean {
    const types: Function[] = [String, Boolean, Number, Array, Object];
    return !types.includes(metatype);
  }

  // 유효성 검사 오류를 더 읽기 쉬운 형식으로 변환 (선택 사항)
  private formatErrors(errors: any[]) {
    return errors.map(err => {
      for (const property in err.constraints) {
        return err.constraints[property];
      }
    }).filter(Boolean).join(', '); // 중복 메시지 제거, null/undefined 제거, 쉼표로 연결
  }
}

/*
이 코드를 실행하려면:

1. NestJS 프로젝트에 `class-validator` 및 `class-transformer` 라이브러리 설치:
   `npm install class-validator class-transformer`
2. `src/pipes/validation.pipe.ts`와 같이 적절한 디렉토리에 이 파일을 생성합니다.
3. 이 파이프를 전역적으로 적용하려면 `main.ts` 파일에 다음 코드를 추가합니다:
   ```typescript
   // main.ts
   import { ValidationPipe } from './pipes/validation.pipe'; // 파이프 경로 확인

   async function bootstrap() {
     const app = await NestFactory.create(AppModule);
     app.useGlobalPipes(new ValidationPipe()); // 전역적으로 ValidationPipe 적용
     await app.listen(3000);
   }
   ```
4. 특정 컨트롤러나 라우트 핸들러에만 적용하려면 `@UsePipes(ValidationPipe)` 데코레이터를 사용합니다.
*/
