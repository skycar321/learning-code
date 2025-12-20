// nestjs/Step1_NestJSBasics/main.ts
// NestJS 학습 계획 - 1단계: NestJS 기본 개념 및 시작
// 이 파일은 NestJS 애플리케이션의 메인 엔트리 포인트인 `main.ts` 파일입니다.
// `NestFactory`를 사용하여 NestJS 애플리케이션 인스턴스를 생성하고 시작하는 방법을 보여줍니다.
//
// NestJS는 Angular에서 영감을 받은 모듈식 아키텍처를 사용하여
// 확장 가능하고 유지보수하기 쉬운 서버 사이드 애플리케이션을 구축하도록 돕습니다.

import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  // -----------------------------------------------------------------------------
  // 학습 포인트 1: `NestFactory.create`를 사용하여 NestJS 애플리케이션 인스턴스 생성
  // - `AppModule`은 애플리케이션의 루트 모듈이며, 모든 핵심 컴포넌트를 포함합니다.
  // -----------------------------------------------------------------------------
  const app = await NestFactory.create(AppModule);

  // 나쁜 예시: `enableCors()`를 사용하지 않거나, 보안상 안전하지 않은 CORS 설정을 사용하는 것.
  // - 실제 운영 환경에서는 `origin`, `methods`, `headers` 등을 명시적으로 지정하여
  // - 필요한 도메인과 HTTP 메서드만 허용하도록 엄격하게 설정해야 합니다.
  app.enableCors(); // 모든 도메인에서의 요청 허용 (개발 환경에서 편리하지만, 운영에서는 보안에 취약)

  // -----------------------------------------------------------------------------
  // 학습 포인트 2: `app.listen`을 사용하여 HTTP 리스너 시작
  // - 애플리케이션이 지정된 포트에서 들어오는 HTTP 요청을 수신 대기합니다.
  // -----------------------------------------------------------------------------
  const port = process.env.PORT || 3000; // 환경 변수에서 포트를 가져오거나 기본값 3000 사용
  await app.listen(port);
  console.log(`애플리케이션이 ${await app.getUrl()}에서 실행 중입니다.`);

  // 나쁜 예시: `app.listen()`에서 발생하는 에러를 처리하지 않거나,
  // - 로그 없이 조용히 실패하는 것.
  // - 서버 시작 실패 시에는 적절한 에러 메시지와 함께 애플리케이션을 종료해야 합니다.
}

// -----------------------------------------------------------------------------
// 학습 포인트 3: `bootstrap` 함수 호출
// - `main.ts` 파일은 애플리케이션의 시작점이며, `bootstrap` 함수를 호출하여
//   NestJS 애플리케이션을 초기화하고 실행합니다.
// -----------------------------------------------------------------------------
bootstrap().catch(err => {
  console.error('애플리케이션 시작 실패:', err);
  process.exit(1); // 오류 발생 시 프로세스 종료
});

/*
이 코드를 실행하려면:

1. Node.js 및 npm (또는 yarn) 설치.
2. NestJS CLI 설치: `npm i -g @nestjs/cli`
3. 새 NestJS 프로젝트 생성: `nest new nestjs-basics-app`
   - `src` 디렉토리가 생성될 것입니다.
4. `nestjs-basics-app/src/main.ts` 파일 내용을 이 파일의 내용으로 교체.
5. `nestjs-basics-app/src` 디렉토리에 `app.module.ts`, `app.controller.ts`, `app.service.ts` 파일 생성.
6. `npm run start:dev` (또는 `yarn start:dev`) 명령어로 애플리케이션 실행.
*/
