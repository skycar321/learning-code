// nestjs/Step5_MicroservicesAndGraphQL/graphql.resolver.ts
// NestJS 학습 계획 - 5단계: 마이크로서비스 및 GraphQL
// 이 파일은 GraphQL 서버의 리졸버(Resolver)를 정의합니다.
// 리졸버는 GraphQL 쿼리(Query) 또는 뮤테이션(Mutation)이 요청될 때
// 실제 데이터를 가져오거나 변경하는 로직을 구현합니다.
//
// NestJS는 `@nestjs/graphql` 패키지를 통해 GraphQL 통합을 강력하게 지원합니다.
// Code-first 또는 Schema-first 방식으로 GraphQL API를 구축할 수 있습니다.

import { Resolver, Query, Mutation, Args } from '@nestjs/graphql';
import { Post } from './graphql.schema'; // Post 타입 임포트 (아직 생성되지 않음)

// -----------------------------------------------------------------------------
// 학습 포인트 1: `@Resolver()` 데코레이터
// - GraphQL 리졸버 클래스를 선언합니다.
// - 일반적으로 리졸버가 처리할 타입의 이름을 인자로 받습니다 (예: `@Resolver(() => Post)`).
//   여기서는 루트 쿼리/뮤테이션을 처리하므로 인자를 생략합니다.
// -----------------------------------------------------------------------------
@Resolver()
export class PostResolver {
  private readonly posts: Post[] = [ // 임시 데이터 저장소
    { id: 1, title: '첫 번째 게시글', content: 'GraphQL 학습 중입니다.', authorId: 101 },
    { id: 2, title: '두 번째 게시글', content: 'NestJS와 GraphQL 연동!', authorId: 102 },
  ];
  private nextPostId = 3;

  // -----------------------------------------------------------------------------
  // 학습 포인트 2: `@Query()` 데코레이터
  // - GraphQL 쿼리를 처리하는 메서드를 정의합니다.
  // - `() => [Post]`는 이 쿼리가 `Post` 타입의 배열을 반환함을 GraphQL 스키마에 알립니다.
  // -----------------------------------------------------------------------------
  @Query(() => [Post]) // 모든 게시글을 조회하는 쿼리
  async posts(): Promise<Post[]> {
    return this.posts;
  }

  @Query(() => Post, { nullable: true }) // 특정 ID 게시글을 조회하는 쿼리 (널 허용)
  async post(@Args('id') id: number): Promise<Post> {
    // 나쁜 예시: 리졸버 메서드 내에서 복잡한 데이터베이스 쿼리를 직접 수행하거나,
    // - 여러 서비스의 비즈니스 로직을 포함하는 것.
    // - 리졸버는 데이터를 가져오는 역할에 집중하고, 실제 데이터 로직은 서비스 레이어로 위임해야 합니다.
    return this.posts.find(post => post.id === id);
  }

  // -----------------------------------------------------------------------------
  // 학습 포인트 3: `@Mutation()` 데코레이터
  // - GraphQL 뮤테이션(데이터 생성, 업데이트, 삭제)을 처리하는 메서드를 정의합니다.
  // - `() => Post`는 이 뮤테이션이 생성된 `Post` 객체를 반환함을 알립니다.
  // - `@Args()` 데코레이터를 사용하여 클라이언트로부터 전달되는 인자를 받습니다.
  // -----------------------------------------------------------------------------
  @Mutation(() => Post) // 새 게시글을 생성하는 뮤테이션
  async createPost(@Args('title') title: string, @Args('content') content: string): Promise<Post> {
    const newPost = {
      id: this.nextPostId++,
      title,
      content,
      authorId: 999, // 임시 authorId
    };
    this.posts.push(newPost);
    return newPost;
  }

  // 나쁜 예시: `createPost` 뮤테이션에서 `authorId`를 클라이언트로부터 직접 받는 것.
  // - 보안상 문제가 될 수 있습니다. `authorId`는 인증된 사용자 정보에서 가져와야 합니다.
  // - `@Args()`에 직접적으로 모든 데이터를 받는 대신, DTO(Input Type)를 사용하는 것이 좋습니다.
}

/*
이 코드를 실행하려면:

1. `microservice.module.ts`, `microservice.service.ts`, `microservice.controller.ts` 파일과 함께
   `src/graphql` 디렉토리(또는 `src`)에 이 파일을 생성합니다.
2. `graphql.schema.ts` 파일도 함께 생성해야 합니다.
3. `package.json`에 `@nestjs/graphql`, `graphql`, `apollo-server-express` 패키지를 설치해야 합니다.
   `npm install @nestjs/graphql graphql apollo-server-express`
4. `AppModule`에 `GraphQLModule.forRoot()` 설정을 추가하고 `PostResolver`를 프로바이더로 등록해야 합니다.
   ```typescript
   // src/app.module.ts
   import { Module } from '@nestjs/common';
   import { GraphQLModule } from '@nestjs/graphql'; // GraphQLModule 임포트
   import { ApolloDriver, ApolloDriverConfig } from '@nestjs/apollo'; // ApolloDriver 임포트

   import { AppController } from './app.controller';
   import { AppService } from './app.service';
   // ... other modules

   import { PostResolver } from './graphql.resolver'; // PostResolver 임포트

   @Module({
     imports: [
       // ... other imports
       GraphQLModule.forRoot<ApolloDriverConfig>({
         driver: ApolloDriver,
         autoSchemaFile: true, // 스키마 파일을 자동으로 생성
         // autoSchemaFile: join(process.cwd(), 'src/schema.gql'), // 특정 경로에 스키마 파일 생성
         // context: ({ req, res }) => ({ req, res }), // 리졸버에서 요청/응답 객체 접근
       }),
     ],
     controllers: [AppController],
     providers: [AppService, PostResolver], // PostResolver를 프로바이더로 등록
   })
   export class AppModule {}
   ```
*/
