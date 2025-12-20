// nestjs/Step2_DatabaseIntegration/user.controller.ts
// NestJS 학습 계획 - 2단계: 데이터베이스 통합 및 ORM
// 이 파일은 `UserModule`의 `UserController`입니다.
// `UserController`는 사용자 관련 HTTP 요청(RESTful API)을 처리하고,
// `UserService`를 통해 비즈니스 로직 및 데이터베이스 작업을 수행합니다.
//
// 컨트롤러는 요청을 받고 응답을 반환하는 역할에 집중하며,
// 복잡한 비즈니스 로직은 서비스 레이어로 위임하는 것이 좋습니다.

import { Controller, Get, Post, Body, Put, Param, Delete, HttpCode, HttpStatus } from '@nestjs/common';
import { UserService } from './user.service';
import { CreateUserDto, UpdateUserDto } from './dto/user.dto';
import { User } from './user.entity';

// -----------------------------------------------------------------------------
// 학습 포인트 1: `@Controller('users')` 데코레이터
// - 클래스를 NestJS 컨트롤러로 선언하고, 경로 접두사를 `/users`로 지정합니다.
// - 이 컨트롤러의 모든 엔드포인트는 `/users`로 시작합니다.
// -----------------------------------------------------------------------------
@Controller('users') // '/users' 경로로 시작하는 요청을 처리
export class UserController {
  constructor(private readonly userService: UserService) {}

  // -----------------------------------------------------------------------------
  // 학습 포인트 2: CRUD 엔드포인트 구현
  // - `@Post()`, `@Get()`, `@Put()`, `@Delete()` 데코레이터를 사용하여
  //   RESTful API의 기본적인 CRUD 작업을 위한 엔드포인트를 정의합니다.
  // - `@Body()`, `@Param()` 데코레이터를 사용하여 요청 본문 및 경로 파라미터를 가져옵니다.
  // -----------------------------------------------------------------------------

  // POST /users
  // 새 사용자 생성
  @Post()
  @HttpCode(HttpStatus.CREATED) // HTTP 201 Created 응답
  async create(@Body() createUserDto: CreateUserDto): Promise<User> {
    // 나쁜 예시: 컨트롤러 메서드에서 DTO 유효성 검사를 수동으로 하거나,
    // - Service에서 처리해야 할 복잡한 비즈니스 로직을 직접 수행하는 것.
    // - NestJS의 Pipe(예: ValidationPipe)를 사용하여 DTO 유효성 검사를 자동화하고,
    // - 비즈니스 로직은 Service로 위임하는 것이 컨트롤러의 역할을 명확히 합니다.
    return this.userService.create(createUserDto);
  }

  // GET /users
  // 모든 사용자 조회
  @Get()
  async findAll(): Promise<User[]> {
    return this.userService.findAll();
  }

  // GET /users/:id
  // 특정 ID 사용자 조회
  @Get(':id')
  async findOne(@Param('id') id: string): Promise<User> {
    // `id`는 경로 파라미터로 문자열로 넘어오므로, `+id` 또는 `parseInt(id)`로 숫자로 변환합니다.
    return this.userService.findOne(+id);
  }

  // PUT /users/:id
  // 특정 ID 사용자 업데이트
  @Put(':id')
  async update(@Param('id') id: string, @Body() updateUserDto: UpdateUserDto): Promise<User> {
    return this.userService.update(+id, updateUserDto);
  }

  // DELETE /users/:id
  // 특정 ID 사용자 삭제
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT) // HTTP 204 No Content 응답 (삭제 성공 시)
  async remove(@Param('id') id: string): Promise<void> {
    return this.userService.remove(+id);
  }

  // 나쁜 예시: 컨트롤러 메서드에서 데이터베이스 관련 예외를 직접 처리하는 것.
  // - 예외 처리는 NestJS의 필터(Filter) 또는 글로벌 예외 핸들러를 사용하여
  //   중앙 집중식으로 관리하는 것이 좋습니다.
  // - 컨트롤러는 비즈니스 로직이 아닌 API 엔드포인트 정의에 집중해야 합니다.
}

/*
이 코드를 실행하려면:

1. `user.module.ts`, `user.service.ts`, `user.entity.ts`, `dto/user.dto.ts` 파일과 함께
   `src/user` 디렉토리에 이 파일을 생성합니다.
*/
