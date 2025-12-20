// nestjs/Step3_AuthenticationAuthorization/auth.module.ts
// NestJS 학습 계획 - 3단계: 인증 및 인가
// 이 파일은 사용자 인증(Authentication) 및 인가(Authorization) 기능을 관리하는 `AuthModule`입니다.
// JWT(JSON Web Token) 기반 인증을 구현하며, Passport.js와 `@nestjs/jwt`,
// 그리고 `@nestjs/passport` 패키지를 통합합니다.
//
// NestJS는 모듈식 아키텍처와 데코레이터를 통해 인증/인가 로직을 구조화하고 재사용하기 쉽게 만듭니다.

import { Module } from '@nestjs/common';
import { PassportModule } from '@nestjs/passport'; // Passport 모듈 임포트
import { JwtModule } from '@nestjs/jwt'; // JWT 모듈 임포트
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { UserModule } from '../Step2_DatabaseIntegration/user.module'; // UserModule 임포트
import { JwtStrategy } from './jwt.strategy'; // JWT Strategy 임포트
import { ConfigModule, ConfigService } from '@nestjs/config'; // 환경 변수 관리를 위한 ConfigModule

// -----------------------------------------------------------------------------
// 학습 포인트 1: `PassportModule`, `JwtModule` 통합
// - `PassportModule.register({ defaultStrategy: 'jwt' })`: Passport의 기본 전략을 JWT로 설정.
// - `JwtModule.registerAsync()`: JWT 모듈을 비동기적으로 등록하여 `ConfigService`에서
//   JWT 비밀 키(`secret`)와 만료 시간(`expiresIn`)을 가져올 수 있도록 합니다.
// - `imports`: `UserModule`을 임포트하여 `AuthService`에서 `UserService`를 사용할 수 있도록 합니다.
// -----------------------------------------------------------------------------
@Module({
  imports: [
    UserModule, // 사용자 정보를 조회하기 위해 UserModule 필요
    PassportModule.register({ defaultStrategy: 'jwt' }), // Passport의 기본 전략을 JWT로 설정

    // JwtModule 비동기 등록: 환경 변수에서 JWT 설정 가져오기
    JwtModule.registerAsync({
      imports: [ConfigModule], // ConfigModule을 임포트하여 ConfigService 사용
      useFactory: async (configService: ConfigService) => ({
        secret: configService.get<string>('JWT_SECRET'), // 환경 변수에서 JWT 비밀 키 가져오기
        signOptions: { expiresIn: '60s' }, // 토큰 만료 시간 설정 (예: 60초)
      }),
      inject: [ConfigService], // ConfigService 주입
    }),
    ConfigModule, // 환경 변수 관리를 위한 ConfigModule
  ],
  controllers: [AuthController],
  providers: [AuthService, JwtStrategy], // AuthService와 JwtStrategy 프로바이더 등록
  exports: [AuthService, JwtModule, PassportModule], // 다른 모듈에서 사용 가능하도록 내보내기
})
export class AuthModule {}

/*
이 코드를 실행하려면:

1. `main.ts`, `app.module.ts`가 설정된 NestJS 프로젝트에 이 파일을 생성합니다.
2. `auth.controller.ts`, `auth.service.ts`, `jwt.strategy.ts` 파일도 함께 생성해야 합니다.
3. `package.json`에 `@nestjs/passport`, `@nestjs/jwt`, `passport`, `passport-jwt`, `bcryptjs`, `jsonwebtoken`
   등 필요한 패키지를 설치해야 합니다. (예: `npm install @nestjs/passport @nestjs/jwt passport passport-jwt bcryptjs jsonwebtoken`)
4. `UserModule`이 미리 설정되어 있어야 합니다.
5. `AppModule`에 `AuthModule`을 임포트하고, `ConfigModule.forRoot()`를 추가해야 합니다.
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
       ConfigModule.forRoot({ // 환경 변수 로드
         isGlobal: true, // 전역적으로 사용 가능하도록 설정
         envFilePath: '.env', // .env 파일 경로 지정
       }),
       TypeOrmModule.forRoot({
         type: 'sqlite',
         database: 'database.sqlite',
         entities: [User],
         synchronize: true,
       }),
       UserModule,
       AuthModule, // AuthModule 임포트
     ],
     controllers: [AppController],
     providers: [AppService],
   })
   export class AppModule {}
   ```
6. 프로젝트 루트에 `.env` 파일을 생성하고 `JWT_SECRET=YOUR_VERY_STRONG_SECRET_KEY`를 추가합니다.
*/
