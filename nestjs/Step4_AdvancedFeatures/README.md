# Step4: NestJS 고급 기능 및 모범 사례

이 디렉토리는 NestJS 애플리케이션의 파이프(Pipes), 필터(Filters), 그리고 커스텀 데코레이터(Custom Decorators)와 같은 고급 기능을 학습하고 모범 사례를 적용하는 방법을 보여주기 위한 예제 코드입니다.

## 학습 목표

-   `ValidationPipe`를 이용한 요청 데이터(DTO) 유효성 검사 자동화
-   `HttpExceptionFilter`를 이용한 전역 예외 처리 및 응답 커스터마이징
-   `CurrentUser` 커스텀 데코레이터를 이용한 컨트롤러 코드 간결화
-   `class-validator`를 이용한 데이터 유효성 검사

## 프로젝트 구조

```
nestjs/Step4_AdvancedFeatures/
├── validation.pipe.ts        # 요청 데이터 유효성 검사 파이프
├── http-exception.filter.ts  # HTTP 예외 처리 필터
├── current-user.decorator.ts # 현재 인증된 사용자 정보 주입 데코레이터
└── README.md
```

## 파일 설명

-   **`validation.pipe.ts`**:
    -   `PipeTransform` 인터페이스를 구현하여 커스텀 유효성 검사 파이프를 생성합니다.
    -   `class-validator` 및 `class-transformer`를 활용하여 DTO 객체의 유효성을 자동으로 검사하고 변환합니다.
    -   유효성 검사 실패 시 `BadRequestException`을 발생시켜 전역 예외 필터에서 처리할 수 있도록 합니다.

-   **`http-exception.filter.ts`**:
    -   `ExceptionFilter` 인터페이스를 구현하고 `@Catch(HttpException)` 데코레이터를 사용하여 `HttpException` 타입의 예외를 처리합니다.
    -   `catch()` 메서드 내에서 요청 객체와 응답 객체를 사용하여 클라이언트에게 반환될 에러 응답의 형식을 커스터마이징합니다.
    -   예외 로깅 및 클라이언트에게는 일반적인 에러 메시지만 전달하는 모범 사례를 포함합니다.

-   **`current-user.decorator.ts`**:
    -   `createParamDecorator()` 함수를 사용하여 `CurrentUser`라는 커스텀 파라미터 데코레이터를 생성합니다.
    -   컨트롤러의 라우트 핸들러에서 `@CurrentUser()`를 사용하여 `request.user`에 저장된 인증된 사용자 정보(JWT 가드에 의해 주입된)를 쉽게 가져올 수 있도록 합니다.
    -   특정 필드만 가져오거나 (`@CurrentUser('id')`), 전체 사용자 객체를 가져오는 (`@CurrentUser()`) 유연성을 제공합니다.

## 설정 및 실행 방법

이 예제를 실행하려면 기존 NestJS 프로젝트(`Step1`에서 생성한 프로젝트)를 기반으로 합니다. `Step2`와 `Step3`에서 구성한 `UserModule`과 `AuthModule`을 함께 사용하면 더 좋습니다.

1.  **NestJS 프로젝트 생성 및 Step2, Step3 파일 설정**:
    -   `nest new nestjs-advanced-app --package-manager npm`
    -   `cd nestjs-advanced-app`
    -   `Step2`와 `Step3`의 모든 파일 및 `.env` 파일을 복사하고 `app.module.ts`를 설정합니다.

2.  **필요한 패키지 설치**:
    -   `class-validator`와 `class-transformer`는 `Step2`와 `Step3`에서 이미 설치했을 것입니다.
    -   `npm install class-validator class-transformer`

3.  **파일 복사**:
    -   `validation.pipe.ts` 파일을 `src/common/pipes/` 디렉토리로 복사합니다. (`src/common` 디렉토리 생성 후 `pipes` 디렉토리 생성)
    -   `http-exception.filter.ts` 파일을 `src/common/filters/` 디렉토리로 복사합니다. (`src/common` 디렉토리 생성 후 `filters` 디렉토리 생성)
    -   `current-user.decorator.ts` 파일을 `src/common/decorators/` 디렉토리로 복사합니다. (`src/common` 디렉토리 생성 후 `decorators` 디렉토리 생성)

4.  **`main.ts` 수정 (전역 파이프 및 필터 적용)**:
    -   `src/main.ts` 파일을 열어 `ValidationPipe`와 `HttpExceptionFilter`를 전역적으로 적용합니다.

    ```typescript
    // src/main.ts
    import { NestFactory } from '@nestjs/core';
    import { AppModule } from './app.module';
    import { ValidationPipe } from './common/pipes/validation.pipe'; // 경로 확인
    import { HttpExceptionFilter } from './common/filters/http-exception.filter'; // 경로 확인

    async function bootstrap() {
      const app = await NestFactory.create(AppModule);
      app.enableCors();
      app.useGlobalPipes(new ValidationPipe()); // 전역 ValidationPipe 적용
      app.useGlobalFilters(new HttpExceptionFilter()); // 전역 HttpExceptionFilter 적용
      const port = process.env.PORT || 3000;
      await app.listen(port);
      console.log(`애플리케이션이 ${await app.getUrl()}에서 실행 중입니다.`);
    }
    bootstrap().catch(err => {
      console.error('애플리케이션 시작 실패:', err);
      process.exit(1);
    });
    ```

5.  **`user/dto/user.dto.ts` 수정 (`class-validator` 데코레이터 주석 해제)**:
    -   `src/user/dto/user.dto.ts` 파일에서 `@IsEmail`, `@IsString`, `@MinLength` 등의 `class-validator` 데코레이터 주석을 해제합니다.

6.  **`auth.controller.ts` 또는 새로운 컨트롤러에서 `CurrentUser` 데코레이터 사용**:
    -   `src/auth/auth.controller.ts`의 `getProfile` 메서드를 수정하거나, 새로운 컨트롤러를 생성하여 `CurrentUser` 데코레이터를 테스트합니다.

    ```typescript
    // src/auth/auth.controller.ts (수정 예시)
    import { Controller, Post, Body, UseGuards, Get } from '@nestjs/common';
    import { AuthService } from './auth.service';
    import { AuthLoginDto } from './dto/auth-login.dto';
    import { JwtAuthGuard } from './jwt.guard';
    import { CurrentUser } from '../common/decorators/current-user.decorator'; // CurrentUser 임포트

    @Controller('auth')
    export class AuthController {
      constructor(private readonly authService: AuthService) {}

      @Post('login')
      async login(@Body() authLoginDto: AuthLoginDto) {
        return this.authService.login(authLoginDto);
      }

      @UseGuards(JwtAuthGuard)
      @Get('profile')
      getProfile(@CurrentUser() user: any) { // CurrentUser 데코레이터 사용
        return user;
      }

      @UseGuards(JwtAuthGuard)
      @Get('email-only')
      getEmailOnly(@CurrentUser('email') email: string) { // email 필드만 가져오기
        return { email };
      }
    }
    ```

7.  **애플리케이션 실행**:
    ```bash
    npm run start:dev
    ```

8.  **API 테스트 (예시)**:
    -   Postman 또는 curl을 사용하여 API를 테스트합니다.

    -   **유효성 검사 실패 테스트 (POST)**:
        ```bash
        curl -X POST -H "Content-Type: application/json" -d '{"email": "invalid-email", "password": "123"}' http://localhost:3000/users
        ```
        -   `ValidationPipe`에 의해 HTTP 400 Bad Request 에러와 함께 유효성 검사 실패 메시지가 반환됩니다. `HttpExceptionFilter`가 이 응답을 처리합니다.

    -   **`CurrentUser` 데코레이터 테스트**:
        -   `Step3`에서와 같이 로그인하여 JWT 토큰을 받은 후, `profile` 또는 `email-only` 엔드포인트에 토큰과 함께 요청을 보냅니다.

## 나쁜 예시와 좋은 예시 (개념)

`validation.pipe.ts`, `http-exception.filter.ts`, `current-user.decorator.ts` 파일 내의 주석을 참조하여, NestJS 고급 기능 사용 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 파이프, 필터, 커스텀 데코레이터를 통해 코드의 중복을 줄이고, 애플리케이션의 구조를 더욱 견고하게 만드는 것이 중요합니다.
