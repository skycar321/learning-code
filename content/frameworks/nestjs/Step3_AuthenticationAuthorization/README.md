# Step3: NestJS 인증 및 인가

이 디렉토리는 NestJS 애플리케이션에서 JWT(JSON Web Token) 기반 인증 및 인가(Authentication & Authorization)를 구현하는 방법을 학습하기 위한 예제 코드입니다. Passport.js와 `@nestjs/jwt`를 통합하여 안전하고 확장 가능한 인증 시스템을 구축합니다.

## 학습 목표

-   JWT 기반 인증 흐름 이해
-   `AuthService`를 이용한 사용자 인증 및 JWT 토큰 발행
-   `JwtStrategy`를 이용한 JWT 토큰 검증
-   `JwtAuthGuard`를 이용한 라우트 보호
-   비밀번호 해싱 (`bcryptjs`)을 이용한 보안 강화

## 프로젝트 구조

```
nestjs/Step3_AuthenticationAuthorization/
├── auth.module.ts            # 인증/인가 관련 모듈
├── auth.controller.ts        # 인증/인가 HTTP 요청 처리
├── auth.service.ts           # 인증/인가 비즈니스 로직 및 JWT 처리
├── dto/
│   └── auth-login.dto.ts     # 로그인 요청 DTO
├── jwt.strategy.ts           # Passport JWT 인증 전략
├── jwt.guard.ts              # JWT 인증 가드
└── README.md
```

## 파일 설명

-   **`auth.module.ts`**:
    -   `@Module()` 데코레이터를 사용하여 `AuthModule`을 정의합니다.
    -   `imports`에 `UserModule`, `PassportModule`, `JwtModule.registerAsync()`를 포함하여 인증 관련 의존성을 설정합니다.
    -   `JwtModule.registerAsync()`를 사용하여 `ConfigService`로부터 JWT 비밀 키를 가져와 동적으로 설정합니다.
    -   `providers`에 `AuthService`와 `JwtStrategy`를 등록합니다.

-   **`auth.controller.ts`**:
    -   `@Controller('auth')` 데코레이터로 `/auth` 경로에 대한 요청을 처리합니다.
    -   `@Post('login')` 엔드포인트는 `AuthLoginDto`를 받아 `AuthService.login()`을 호출하여 사용자 인증 후 JWT 토큰을 발행합니다.
    -   `@UseGuards(JwtAuthGuard)` 데코레이터를 사용하여 `@Get('profile')` 엔드포인트를 보호합니다. 이 엔드포인트는 유효한 JWT 토큰을 가진 사용자만 접근할 수 있습니다.

-   **`auth.service.ts`**:
    -   `@Injectable()` 데코레이터로 프로바이더임을 선언합니다.
    -   `UserService`와 `JwtService`를 주입받아 사용합니다.
    -   `validateUser()`: 사용자 자격 증명(이메일, 비밀번호)을 검증하고, `bcryptjs`를 이용하여 비밀번호를 비교합니다.
    -   `login()`: 검증된 사용자에게 `JwtService.sign()`을 이용하여 JWT 액세스 토큰을 발행합니다.
    -   `hashPassword()`: 비밀번호를 해싱하는 유틸리티 메서드입니다.

-   **`dto/auth-login.dto.ts`**:
    -   `AuthLoginDto` 클래스를 정의하여 사용자 로그인 요청에 대한 데이터 구조를 정의합니다.
    -   `class-validator` 라이브러리의 데코레이터를 사용하여 `email`과 `password` 필드의 유효성 검사 규칙을 선언하는 방법을 설명합니다.

-   **`jwt.strategy.ts`**:
    -   `PassportStrategy(Strategy)`를 상속받아 JWT 인증 전략을 구현합니다.
    -   `secretOrKey`에 `ConfigService`로부터 가져온 JWT 비밀 키를 설정합니다.
    -   `validate()` 메서드는 JWT 토큰이 유효하게 검증된 후에 호출되며, 토큰의 페이로드에서 사용자 정보를 추출하고 `req.user` 객체에 추가합니다.

-   **`jwt.guard.ts`**:
    -   `AuthGuard('jwt')`를 상속받아 JWT 인증 가드를 생성합니다.
    -   `@UseGuards(JwtAuthGuard)` 데코레이터를 사용하여 특정 라우트 핸들러를 보호하는 데 사용됩니다.

## 설정 및 실행 방법

이 예제를 실행하려면 기존 NestJS 프로젝트(`Step1`에서 생성한 프로젝트)를 기반으로 하며, `Step2`에서 구성한 `UserModule`이 필요합니다.

1.  **NestJS 프로젝트 생성 및 Step2 파일 설정**:
    -   `nest new nestjs-auth-app --package-manager npm`
    -   `cd nestjs-auth-app`
    -   `Step2`의 `user.module.ts`, `user.controller.ts`, `user.service.ts`, `user.entity.ts`, `dto/user.dto.ts` 파일을 `src/user/` 및 `src/user/dto/` 경로로 복사합니다.

2.  **필요한 패키지 설치**:
    ```bash
    npm install @nestjs/passport @nestjs/jwt passport passport-jwt bcryptjs jsonwebtoken @nestjs/config
    npm install --save-dev @types/bcryptjs @types/passport-jwt @types/jsonwebtoken
    ```

3.  **파일 복사**:
    -   `auth.module.ts`, `auth.controller.ts`, `auth.service.ts`, `jwt.strategy.ts`, `jwt.guard.ts` 파일을 `src/auth/` 디렉토리로 복사합니다.
    -   `auth-login.dto.ts` 파일을 `src/auth/dto/` 디렉토리로 복사합니다.

4.  **`app.module.ts` 수정**:
    -   `src/app.module.ts` 파일을 열어 `AuthModule`을 임포트하고 `ConfigModule.forRoot()` 설정을 추가합니다.

    ```typescript
    // src/app.module.ts
    import { Module } from '@nestjs/common';
    import { TypeOrmModule } from '@nestjs/typeorm';
    import { ConfigModule } from '@nestjs/config'; // ConfigModule 임포트

    import { AppController } from './app.controller';
    import { AppService } from './app.service';
    import { UserModule } from './user/user.module';
    import { User } from './user/user.entity';
    import { AuthModule } from './auth/auth.module'; // AuthModule 임포트

    @Module({
      imports: [
        ConfigModule.forRoot({
          isGlobal: true,
          envFilePath: '.env',
        }),
        TypeOrmModule.forRoot({
          type: 'sqlite',
          database: 'database.sqlite',
          entities: [User],
          synchronize: true,
          logging: true,
        }),
        UserModule,
        AuthModule,
      ],
      controllers: [AppController],
      providers: [AppService],
    })
    export class AppModule {}
    ```

5.  **`.env` 파일 생성**:
    -   프로젝트 루트에 `.env` 파일을 생성하고 다음 내용을 추가합니다.
        ```
        JWT_SECRET=YOUR_VERY_STRONG_SECRET_KEY
        ```
        -   `YOUR_VERY_STRONG_SECRET_KEY`는 실제 환경에서 강력한 비밀 키로 변경해야 합니다.

6.  **사용자 생성 (선택 사항)**:
    -   `AuthService`의 `validateUser`에서 `userService.findAll()` 대신 `userService.findByEmail()`을 사용하도록 변경하고, `user.service.ts`에 `findByEmail()` 메서드를 추가합니다.
    -   또는 `AppModule`에 `OnModuleInit`을 구현하여 테스트 사용자를 미리 생성합니다.

7.  **애플리케이션 실행**:
    ```bash
    npm run start:dev
    ```

8.  **API 테스트 (예시)**:
    -   Postman 또는 curl을 사용하여 API를 테스트합니다.

    -   **테스트 사용자 생성 (POST)**:
        ```bash
        curl -X POST -H "Content-Type: application/json" -d '{"email": "user@example.com", "password": "password123", "name": "Auth User"}' http://localhost:3000/users
        ```

    -   **로그인 (POST)**:
        ```bash
        curl -X POST -H "Content-Type: application/json" -d '{"email": "user@example.com", "password": "password123"}' http://localhost:3000/auth/login
        ```
        -   응답으로 `access_token`을 받습니다.

    -   **프로필 조회 (GET, JWT 포함)**:
        ```bash
        curl -X GET -H "Authorization: Bearer <받은 access_token>" http://localhost:3000/auth/profile
        ```
        -   올바른 토큰을 포함하면 사용자 정보가 반환됩니다.

    -   **프로필 조회 (GET, JWT 없이)**:
        ```bash
        curl -X GET http://localhost:3000/auth/profile
        ```
        -   `Unauthorized` 에러(HTTP 401)가 발생합니다.

## 나쁜 예시와 좋은 예시 (개념)

`auth.service.ts`, `jwt.strategy.ts`, `auth.controller.ts` 파일 내의 주석을 참조하여, 인증 및 인가 구현 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 특히 JWT 토큰의 보안, 비밀번호 해싱, 가드 및 전략을 이용한 로직 분리는 중요한 개념입니다.
