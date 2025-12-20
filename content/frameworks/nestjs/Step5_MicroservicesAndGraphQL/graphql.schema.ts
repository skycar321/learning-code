// nestjs/Step5_MicroservicesAndGraphQL/graphql.schema.ts
// NestJS 학습 계획 - 5단계: 마이크로서비스 및 GraphQL
// 이 파일은 GraphQL 스키마를 정의하는 TypeScript 파일입니다.
// Code-first 접근 방식을 사용할 때 `@ObjectType()` 및 `@Field()` 데코레이터를 사용하여
// GraphQL 타입과 필드를 정의합니다.
//
// NestJS는 TypeScript 클래스를 기반으로 GraphQL 스키마를 자동으로 생성할 수 있습니다.

import { Field, Int, ObjectType } from '@nestjs/graphql';

// -----------------------------------------------------------------------------
// 학습 포인트 1: `@ObjectType()` 데코레이터
// - 클래스를 GraphQL 객체 타입으로 선언합니다.
// - 이 클래스는 GraphQL 스키마에서 `type Post { ... }`와 같이 정의됩니다.
// -----------------------------------------------------------------------------
@ObjectType()
export class Post {
  // -----------------------------------------------------------------------------
  // 학습 포인트 2: `@Field()` 데코레이터
  // - 클래스 프로퍼티를 GraphQL 필드로 정의합니다.
  // - `@Field(() => Int)`와 같이 GraphQL 타입을 명시적으로 지정할 수 있습니다.
  // - `nullable: true`를 사용하여 해당 필드가 널 값을 허용함을 나타낼 수 있습니다.
  // -----------------------------------------------------------------------------
  @Field(() => Int) // `id` 필드를 GraphQL의 `Int` 타입으로 선언
  id: number;

  @Field() // `title` 필드를 GraphQL의 `String` 타입으로 선언 (기본 String 타입으로 추론)
  title: string;

  @Field({ nullable: true }) // `content` 필드는 널을 허용하는 `String` 타입으로 선언
  content?: string;

  @Field(() => Int) // `authorId` 필드를 `Int` 타입으로 선언
  authorId: number;

  // 나쁜 예시: GraphQL 스키마를 TypeScript 클래스로 정의하지 않고,
  // - `.graphql` 파일을 직접 작성하여 스키마를 정의하는 것 (Schema-first).
  // - Code-first 방식은 TypeScript의 타입 시스템을 활용하여 스키마와 코드를 동기화하기 쉽고,
  // - 유지보수성이 더 높습니다. Schema-first는 스키마의 명확성이 더 중요할 때 사용됩니다.
}

/*
이 코드를 실행하려면:

1. `graphql.resolver.ts` 파일과 함께 `src/graphql` 디렉토리(또는 `src`)에 이 파일을 생성합니다.
2. `package.json`에 `@nestjs/graphql`, `graphql` 패키지를 설치해야 합니다.
3. `PostResolver`를 프로바이더로 등록하고 `GraphQLModule.forRoot()` 설정이 `AppModule`에 추가되어 있어야 합니다.
*/
