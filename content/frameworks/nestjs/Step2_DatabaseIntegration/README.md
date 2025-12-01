# Step2: NestJS 데이터베이스 통합 및 ORM

이 디렉토리는 NestJS 애플리케이션에 데이터베이스를 통합하고 TypeORM(Object-Relational Mapping)을 사용하여 데이터를 관리하는 방법을 학습하기 위한 예제 코드입니다.

## 학습 목표

-   `@nestjs/typeorm` 모듈을 이용한 TypeORM 통합
-   엔티티(`@Entity`, `@PrimaryGeneratedColumn`, `@Column`)를 사용한 데이터베이스 스키마 정의
-   `UserService`에서 `Repository`를 주입받아 CRUD(Create, Read, Update, Delete) 작업 구현
-   `UserController`에서 RESTful API 엔드포인트를 통해 사용자 데이터를 관리

## 프로젝트 구조

```
nestjs/Step2_DatabaseIntegration/
├── user.module.ts            # 사용자 관련 모듈
├── user.controller.ts        # 사용자 HTTP 요청 처리
├── user.service.ts           # 사용자 비즈니스 로직 및 DB 작업
├── user.entity.ts            # TypeORM 엔티티 (데이터베이스 테이블 매핑)
├── dto/
│   └── user.dto.ts           # 사용자 데이터 전송 객체 (유효성 검사)
└── README.md
```

## 파일 설명

-   **`user.module.ts`**:
    -   `@Module()` 데코레이터를 사용하여 `UserModule`을 정의합니다.
    -   `imports` 배열에 `TypeOrmModule.forFeature([User])`를 추가하여 `User` 엔티티를 이 모듈에서 사용할 수 있도록 TypeORM에 등록합니다.
    -   `controllers`와 `providers`에 각각 `UserController`와 `UserService`를 등록합니다.
    -   `exports: [UserService]`를 통해 다른 모듈(예: `AuthModule`)에서 `UserService`를 주입받아 사용할 수 있도록 합니다.

-   **`user.entity.ts`**:
    -   `@Entity()` 데코레이터를 사용하여 `User` 클래스를 데이터베이스 테이블과 매핑되는 엔티티로 선언합니다.
    -   `@PrimaryGeneratedColumn()`으로 `id`를 기본 키로 정의합니다.
    -   `@Column()`으로 `email`, `password`, `name`, `isActive` 필드를 데이터베이스 컬럼으로 매핑합니다. `email`은 `unique: true`로 설정되어 중복을 허용하지 않습니다.

-   **`user.service.ts`**:
    -   `@Injectable()` 데코레이터로 프로바이더임을 선언합니다.
    -   `@InjectRepository(User)`를 통해 `User` 엔티티의 TypeORM `Repository`를 주입받습니다.
    -   `create`, `findAll`, `findOne`, `update`, `remove` 등 `User` 엔티티에 대한 CRUD 비즈니스 로직을 구현합니다.
    -   비밀번호 해싱, 트랜잭션 관리 등 고급 비즈니스 로직에 대한 개념적인 설명과 모범 사례를 포함합니다.

-   **`dto/user.dto.ts`**:
    -   `CreateUserDto`와 `UpdateUserDto` 클래스를 정의하여 사용자 생성 및 업데이트 요청에 대한 데이터 구조를 정의합니다.
    -   `class-validator` 라이브러리의 데코레이터를 사용하여 각 필드의 유효성 검사 규칙을 선언하는 방법을 설명합니다.

-   **`user.controller.ts`**:
    -   `@Controller('users')` 데코레이터로 `/users` 경로에 대한 요청을 처리합니다.
    -   `UserService`를 주입받아 HTTP 요청을 처리하고, `UserService`의 메서드를 호출하여 비즈니스 로직을 수행합니다.
    -   `@Post()`, `@Get()`, `@Put(':id')`, `@Delete(':id')` 등 HTTP 메서드 데코레이터와 `@Body()`, `@Param()`을 사용하여 RESTful API 엔드포인트를 구현합니다.

## 설정 및 실행 방법

이 예제를 실행하려면 기존 NestJS 프로젝트(`Step1`에서 생성한 프로젝트)를 기반으로 합니다.

1.  **NestJS 프로젝트 생성**:
    ```bash
    nest new nestjs-db-app --package-manager npm
    cd nestjs-db-app
    ```

2.  **필요한 패키지 설치**:
    ```bash
    npm install @nestjs/typeorm typeorm sqlite3 class-validator class-transformer
    # 또는 yarn add @nestjs/typeorm typeorm sqlite3 class-validator class-transformer
    ```

3.  **파일 복사**:
    -   `user.module.ts`, `user.controller.ts`, `user.service.ts`, `user.entity.ts` 파일을 `src/user/` 디렉토리로 복사합니다.
    -   `user.dto.ts` 파일을 `src/user/dto/` 디렉토리로 복사합니다. (`src/user` 아래에 `dto` 디렉토리 생성)

4.  **`app.module.ts` 수정**:
    -   `src/app.module.ts` 파일을 열어 `UserModule`을 임포트하고 `TypeOrmModule.forRoot()` 설정을 추가합니다.

    ```typescript
    // src/app.module.ts
    import { Module } from '@nestjs/common';
    import { AppController } from './app.controller';
    import { AppService } from './app.service';
    import { TypeOrmModule } from '@nestjs/typeorm';
    import { UserModule } from './user/user.module';
    import { User } from './user/user.entity'; // User 엔티티 경로 확인

    @Module({
      imports: [
        TypeOrmModule.forRoot({
          type: 'sqlite',
          database: 'database.sqlite', // 프로젝트 루트에 database.sqlite 파일 생성
          entities: [User],
          synchronize: true, // 개발 환경에서만 true, 운영에서는 마이그레이션 사용
          logging: true, // SQL 쿼리 로그 활성화 (개발용)
        }),
        UserModule, // UserModule 임포트
      ],
      controllers: [AppController],
      providers: [AppService],
    })
    export class AppModule {}
    ```

5.  **애플리케이션 실행**:
    ```bash
    npm run start:dev
    # 또는 yarn start:dev
    ```

6.  **API 테스트 (예시)**:
    -   Postman 또는 curl을 사용하여 API를 테스트합니다.

    -   **사용자 생성 (POST)**:
        ```bash
        curl -X POST -H "Content-Type: application/json" -d '{"email": "test@example.com", "password": "password123", "name": "Test User"}' http://localhost:3000/users
        ```

    -   **모든 사용자 조회 (GET)**:
        ```bash
        curl http://localhost:3000/users
        ```

    -   **특정 사용자 조회 (GET)**:
        ```bash
        curl http://localhost:3000/users/1
        ```

    -   **사용자 업데이트 (PUT)**:
        ```bash
        curl -X PUT -H "Content-Type: application/json" -d '{"name": "Updated User"}' http://localhost:3000/users/1
        ```

    -   **사용자 삭제 (DELETE)**:
        ```bash
        curl -X DELETE http://localhost:3000/users/1
        ```

## 나쁜 예시와 좋은 예시 (개념)

`user.service.ts` 및 `user.controller.ts` 파일 내의 주석을 참조하여, 데이터베이스 통합 및 ORM 사용 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 특히 보안(비밀번호 해싱), DTO를 이용한 유효성 검사, 컨트롤러와 서비스의 역할 분리는 중요한 개념입니다.
