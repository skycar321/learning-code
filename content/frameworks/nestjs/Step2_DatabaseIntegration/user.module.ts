// nestjs/Step2_DatabaseIntegration/user.module.ts
// NestJS 학습 계획 - 2단계: 데이터베이스 통합 및 ORM
// 이 파일은 사용자(User) 관련 기능을 관리하는 `UserModule`입니다.
// TypeORM과 같은 ORM(Object-Relational Mapping)을 사용하여 데이터베이스와 연동하고,
// `User` 엔티티를 관리하는 `UserService`와 `UserController`를 포함합니다.
//
// NestJS는 `@nestjs/typeorm` 패키지를 통해 TypeORM과 쉽게 통합할 수 있습니다.
// 이를 통해 데이터베이스 작업을 객체 지향적인 방식으로 처리할 수 있습니다.

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm'; // TypeORM 모듈 임포트
import { UserController } from './user.controller';
import { UserService } from './user.service';
import { User } from './user.entity'; // User 엔티티 임포트

// -----------------------------------------------------------------------------
// 학습 포인트 1: `TypeOrmModule.forFeature()`
// - `forFeature()` 메서드는 현재 모듈에서 사용할 엔티티를 TypeORM에 등록합니다.
// - 이를 통해 `UserService`와 같은 프로바이더에서 `Repository`를 주입받아
//   해당 엔티티에 대한 CRUD 작업을 수행할 수 있습니다.
// -----------------------------------------------------------------------------
@Module({
  imports: [
    // `TypeOrmModule.forRoot()`는 루트 모듈(AppModule)에서 데이터베이스 연결 설정을 담당합니다.
    // 여기서는 `forFeature()`를 사용하여 특정 엔티티를 현재 모듈에 등록합니다.
    TypeOrmModule.forFeature([User]), // User 엔티티를 TypeORM에 등록
  ],
  controllers: [UserController],
  providers: [UserService],
  exports: [UserService], // UserModule을 임포트하는 다른 모듈에서 UserService를 사용할 수 있도록 내보냅니다.
})
export class UserModule {}

/*
이 코드를 실행하려면:

1. `main.ts` 및 `app.module.ts`가 설정된 NestJS 프로젝트에 이 파일을 생성합니다.
2. `user.controller.ts`, `user.service.ts`, `user.entity.ts` 파일도 함께 생성해야 합니다.
3. `AppModule`에 `UserModule`을 임포트해야 합니다.
   `app.module.ts`에 `imports: [UserModule]` 추가.
4. `package.json`에 `@nestjs/typeorm`, `typeorm`, `mysql` 또는 `sqlite3` 등
   사용할 데이터베이스 드라이버를 설치해야 합니다. (예: `npm install @nestjs/typeorm typeorm sqlite3`)
5. `AppModule`의 `TypeOrmModule.forRoot()` 설정 (AppModule.ts에 추가 필요):
   ```typescript
   import { TypeOrmModule } from '@nestjs/typeorm';
   import { User } from './user/user.entity'; // user.entity 경로 확인

   @Module({
     imports: [
       TypeOrmModule.forRoot({
         type: 'sqlite', // 사용할 데이터베이스 타입 (mysql, postgres, sqlite 등)
         database: 'database.sqlite', // SQLite 파일 경로
         entities: [User], // 애플리케이션의 모든 엔티티 등록
         synchronize: true, // 개발 환경에서만 true로 설정하여 스키마를 자동으로 동기화 (운영에서는 false)
       }),
       UserModule, // UserModule 임포트
     ],
     controllers: [AppController],
     providers: [AppService],
   })
   export class AppModule {}
   ```
*/
