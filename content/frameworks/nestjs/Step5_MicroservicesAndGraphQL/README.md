# Step5: NestJS 마이크로서비스 및 GraphQL

이 디렉토리는 NestJS 애플리케이션에서 마이크로서비스 아키텍처와 GraphQL API를 구축하는 방법을 학습하기 위한 예제 코드입니다.

## 학습 목표

-   NestJS 마이크로서비스(TCP 트랜스포터)를 이용한 서비스 간 통신
    -   `ClientProxy`를 이용한 클라이언트 구현
    -   `@MessagePattern()`을 이용한 서버 핸들러 구현
-   GraphQL API 구축 (`@nestjs/graphql`)
    -   Code-first 방식의 스키마 정의 (`@ObjectType()`, `@Field()`)
    -   리졸버 (`@Resolver()`, `@Query()`, `@Mutation()`) 구현

## 프로젝트 구조

```
nestjs/Step5_MicroservicesAndGraphQL/
├── microservice.module.ts    # 마이크로서비스 관련 모듈
├── microservice.controller.ts# 마이크로서비스 클라이언트 및 서버 핸들러
├── microservice.service.ts   # 마이크로서비스 비즈니스 로직
├── graphql.resolver.ts       # GraphQL 쿼리/뮤테이션 리졸버
├── graphql.schema.ts         # GraphQL 스키마 타입 정의
└── README.md
```

## 파일 설명

-   **`microservice.module.ts`**: 마이크로서비스 서버의 컨트롤러와 서비스를 포함하는 모듈입니다.
-   **`microservice.controller.ts`**:
    -   HTTP 게이트웨이 역할을 하는 `MicroserviceController`와 마이크로서비스 서버의 메시지 패턴 핸들러 역할을 하는 `MathServiceMicroserviceController`를 모두 포함합니다.
    -   `@Inject('MATH_SERVICE') private client: ClientProxy`를 통해 마이크로서비스 클라이언트를 주입받아 메시지를 보냅니다.
    -   `@MessagePattern('add')` 데코레이터를 사용하여 특정 메시지 패턴에 대한 핸들러를 정의합니다.
-   **`microservice.service.ts`**: 마이크로서비스에서 처리할 실제 비즈니스 로직(예: 숫자 합산, 곱셈)을 구현합니다.
-   **`graphql.resolver.ts`**:
    -   `@Resolver()` 데코레이터로 GraphQL 리졸버 클래스를 선언합니다.
    -   `@Query()` 데코레이터로 데이터를 조회하는 쿼리를, `@Mutation()` 데코레이터로 데이터를 변경하는 뮤테이션을 정의합니다.
    -   `@Args()` 데코레이터를 사용하여 GraphQL 인자를 받습니다.
-   **`graphql.schema.ts`**:
    -   `@ObjectType()` 데코레이터로 GraphQL 객체 타입(예: `Post`)을 선언합니다.
    -   `@Field()` 데코레이터로 객체의 필드와 그 GraphQL 타입을 정의합니다. `nullable: true`로 널 허용 여부를 지정할 수 있습니다.

## 설정 및 실행 방법

이 예제를 실행하려면 기존 NestJS 프로젝트를 두 개의 별도 프로세스로 실행해야 합니다. 하나는 HTTP 요청을 처리하는 게이트웨이 역할(클라이언트 포함), 다른 하나는 마이크로서비스 요청을 처리하는 서버 역할입니다.

1.  **NestJS 프로젝트 생성 및 Step1~4 파일 설정**:
    -   `nest new nestjs-microservice-graphql-app --package-manager npm`
    -   `cd nestjs-microservice-graphql-app`
    -   `Step1`~`Step4`의 모든 파일 및 `.env` 파일을 복사하고 `app.module.ts`를 설정합니다.

2.  **필요한 패키지 설치**:
    ```bash
    npm install @nestjs/microservices @nestjs/graphql apollo-server-express graphql
    ```

3.  **파일 복사**:
    -   `microservice.module.ts`, `microservice.controller.ts`, `microservice.service.ts` 파일을 `src/microservice/` 디렉토리로 복사합니다.
    -   `graphql.resolver.ts`, `graphql.schema.ts` 파일을 `src/graphql/` 디렉토리로 복사합니다.

4.  **`app.module.ts` 수정**:
    -   `src/app.module.ts` 파일을 열어 `MicroserviceModule`을 임포트하고, `ClientsModule`을 설정하여 마이크로서비스 클라이언트를 정의합니다.
    -   `GraphQLModule.forRoot()` 설정을 추가하고 `PostResolver`를 프로바이더로 등록합니다.

    ```typescript
    // src/app.module.ts
    import { Module } from '@nestjs/common';
    import { ClientsModule, Transport } from '@nestjs/microservices'; // ClientsModule 임포트
    import { GraphQLModule } from '@nestjs/graphql';
    import { ApolloDriver, ApolloDriverConfig } from '@nestjs/apollo';
    import { join } from 'path';

    import { AppController } from './app.controller';
    import { AppService } from './app.service';
    // ... 기타 모듈 (UserModule, AuthModule 등)
    import { MicroserviceModule } from './microservice/microservice.module'; // MicroserviceModule 임포트
    import { PostResolver } from './graphql/graphql.resolver'; // PostResolver 임포트
    import { ConfigModule } from '@nestjs/config';

    @Module({
      imports: [
        ConfigModule.forRoot({ isGlobal: true, envFilePath: '.env' }),
        // ... TypeOrmModule.forRoot(), UserModule, AuthModule
        MicroserviceModule, // MicroserviceModule 임포트
        ClientsModule.register([ // 마이크로서비스 클라이언트 설정
          {
            name: 'MATH_SERVICE', // 클라이언트 프록시 토큰
            transport: Transport.TCP,
            options: { port: 3001 }, // 마이크로서비스 서버 포트와 동일하게 설정
          },
        ]),
        GraphQLModule.forRoot<ApolloDriverConfig>({
          driver: ApolloDriver,
          autoSchemaFile: join(process.cwd(), 'src/schema.gql'), // 스키마 파일을 자동으로 생성
          sortSchema: true, // 스키마 필드를 알파벳 순으로 정렬
        }),
      ],
      controllers: [AppController],
      providers: [AppService, PostResolver], // PostResolver를 프로바이더로 등록
    })
    export class AppModule {}
    ```

5.  **`main.ts` 파일 복사본 생성 (`main.microservice.ts`)**:
    -   `src/main.ts` 파일을 `src/main.microservice.ts`로 복사하고, 내용을 마이크로서비스 서버용으로 수정합니다.

    ```typescript
    // src/main.microservice.ts
    import { NestFactory } from '@nestjs/core';
    import { MicroserviceModule } from './microservice/microservice.module'; // MicroserviceModule 경로 확인
    import { Transport } from '@nestjs/microservices';

    async function bootstrap() {
      const app = await NestFactory.createMicroservice(MicroserviceModule, {
        transport: Transport.TCP,
        options: { port: 3001 }, // 마이크로서비스 포트
      });
      await app.listen();
      console.log('Microservice is listening on port 3001');
    }
    bootstrap();
    ```

6.  **`package.json` 수정 (마이크로서비스 시작 스크립트 추가)**:
    -   `package.json` 파일의 `scripts` 섹션에 다음을 추가합니다.
        ```json
        "start:microservice": "nest start --watch --entryFile main.microservice"
        ```

7.  **애플리케이션 실행**:
    -   **마이크로서비스 서버 실행**:
        ```bash
        npm run start:microservice
        ```
    -   **게이트웨이(HTTP) 서버 실행**:
        ```bash
        npm run start:dev
        ```
        (두 터미널에서 각각 실행해야 합니다.)

8.  **API 테스트 (예시)**:
    -   Postman, curl 또는 GraphQL Playground를 사용하여 API를 테스트합니다.

    -   **마이크로서비스 통신 테스트 (GET)**:
        ```bash
        curl http://localhost:3000/microservice/add/10/20
        # 응답: 마이크로서비스에서 계산된 값: 30

        curl http://localhost:3000/microservice/multiply/5/4
        # 응답: 마이크로서비스에서 계산된 값: 20
        ```

    -   **GraphQL 테스트 (POST)**:
        -   `http://localhost:3000/graphql` 로 접속하여 GraphQL Playground를 엽니다.

        -   **게시글 목록 조회 쿼리**:
            ```graphql
            query {
              posts {
                id
                title
                content
                authorId
              }
            }
            ```

        -   **게시글 생성 뮤테이션**:
            ```graphql
            mutation {
              createPost(title: "새로운 GraphQL 게시글", content: "뮤테이션 테스트입니다!") {
                id
                title
                content
                authorId
              }
            }
            ```

## 나쁜 예시와 좋은 예시 (개념)

`microservice.controller.ts` 및 `graphql.resolver.ts` 파일 내의 주석을 참조하여, 마이크로서비스 및 GraphQL API 구축 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 특히 마이크로서비스 간 통신의 견고성, GraphQL 리졸버의 역할 분리는 중요한 개념입니다.
