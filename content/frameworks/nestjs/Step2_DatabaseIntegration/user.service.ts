// nestjs/Step2_DatabaseIntegration/user.service.ts
// NestJS 학습 계획 - 2단계: 데이터베이스 통합 및 ORM
// 이 파일은 `UserModule`의 `UserService`입니다.
// `UserService`는 `User` 엔티티와 관련된 비즈니스 로직 및 데이터베이스 작업을 처리합니다.
//
// TypeORM의 `Repository` 패턴을 사용하여 데이터베이스와 상호작용하고,
// `User` 데이터를 생성(Create), 조회(Read), 업데이트(Update), 삭제(Delete)하는
// CRUD(Create, Read, Update, Delete) 작업을 구현합니다.

import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm'; // Repository 주입을 위한 데코레이터
import { Repository } from 'typeorm'; // TypeORM Repository
import { User } from './user.entity'; // User 엔티티 임포트
import { CreateUserDto, UpdateUserDto } from './dto/user.dto'; // DTO 임포트 (아직 생성되지 않음)

// -----------------------------------------------------------------------------
// 학습 포인트 1: `@InjectRepository()` 데코레이터
// - `Repository<User>` 인스턴스를 주입받아 `User` 엔티티에 대한 데이터베이스 작업을 수행합니다.
// - `UserModule`의 `TypeOrmModule.forFeature([User])`를 통해 `User` 엔티티가 등록되어 있어야 합니다.
// -----------------------------------------------------------------------------
@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User) // User 엔티티의 Repository 주입
    private usersRepository: Repository<User>,
  ) {}

  // -----------------------------------------------------------------------------
  // 학습 포인트 2: CRUD 작업 구현
  // - `create()`: 새로운 사용자를 생성하여 데이터베이스에 저장합니다.
  // - `findAll()`: 모든 사용자를 조회합니다.
  // - `findOne()`: 특정 ID를 가진 사용자를 조회합니다.
  // - `update()`: 특정 ID를 가진 사용자의 정보를 업데이트합니다.
  // - `remove()`: 특정 ID를 가진 사용자를 삭제합니다.
  // -----------------------------------------------------------------------------

  async create(createUserDto: CreateUserDto): Promise<User> {
    // 나쁜 예시: 비밀번호를 암호화하지 않고 DTO에서 받은 그대로 저장하는 것.
    // - 심각한 보안 취약점입니다. 비밀번호는 반드시 해싱해야 합니다.
    // - const user = this.usersRepository.create(createUserDto);
    // 좋은 예시: 비밀번호를 해싱한 후 저장 (여기서는 간단히 DTO 사용)
    const user = this.usersRepository.create(createUserDto);
    // 실제로는 여기에 비밀번호 해싱 로직이 들어가야 합니다. (예: `user.password = await bcrypt.hash(createUserDto.password, 10);`)
    return this.usersRepository.save(user);
  }

  async findAll(): Promise<User[]> {
    return this.usersRepository.find();
  }

  async findOne(id: number): Promise<User> {
    const user = await this.usersRepository.findOne({ where: { id } });
    if (!user) {
      // 나쁜 예시: 사용자에게 'User not found'와 같은 불필요한 상세 정보를 노출하는 것.
      // - 모든 사용자에게 NotFoundException이 발생했음을 알리거나,
      // - 사용자 ID를 특정할 수 없는 일반적인 메시지를 제공하는 것이 좋습니다.
      throw new NotFoundException(`ID가 ${id}인 사용자를 찾을 수 없습니다.`);
    }
    return user;
  }

  async update(id: number, updateUserDto: UpdateUserDto): Promise<User> {
    const user = await this.findOne(id); // 먼저 사용자가 존재하는지 확인
    this.usersRepository.merge(user, updateUserDto); // 기존 엔티티에 새 데이터 병합
    return this.usersRepository.save(user);
  }

  async remove(id: number): Promise<void> {
    const result = await this.usersRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException(`ID가 ${id}인 사용자를 찾을 수 없습니다.`);
    }
  }

  // -----------------------------------------------------------------------------
  // 학습 포인트 3: 트랜잭션 관리 (개념적 설명)
  // - TypeORM은 `Connection` 객체를 통해 트랜잭션을 수동으로 제어할 수 있습니다.
  // - `@Transactional()`과 같은 데코레이터를 사용하여 선언적 트랜잭션을 구현할 수도 있습니다.
  // -----------------------------------------------------------------------------
  async transferMoney(fromUserId: number, toUserId: number, amount: number): Promise<void> {
    // 이 메서드는 트랜잭션 관리가 필요한 복잡한 비즈니스 로직의 예시입니다.
    // 두 사용자 간의 송금 작업을 하나의 트랜잭션으로 묶어 데이터 일관성을 보장해야 합니다.
    //
    // 나쁜 예시: 여러 데이터베이스 작업을 별도의 트랜잭션으로 처리하여
    // - 일부 작업만 성공하고 일부는 실패하는 등 데이터 불일치를 초래하는 것.
    // - 예: fromUser의 잔액은 줄었는데 toUser의 잔액은 늘어나지 않는 경우.
    //
    // 좋은 예시: TypeORM의 QueryRunner를 사용하여 수동 트랜잭션을 제어하거나,
    // - NestJS의 `TypeOrmModule.forRootAsync()`를 통해 `RequestContext`를 사용하여
    // - 선언적 트랜잭션을 구현하는 것이 좋습니다.
    //
    // try {
    //   await this.usersRepository.manager.transaction(async transactionalEntityManager => {
    //     // fromUser 잔액 감소
    //     await transactionalEntityManager.decrement(User, { id: fromUserId }, 'balance', amount);
    //     // toUser 잔액 증가
    //     await transactionalEntityManager.increment(User, { id: toUserId }, 'balance', amount);
    //   });
    // } catch (error) {
    //   // 트랜잭션 실패 시 롤백
    //   throw new InternalServerErrorException('송금 처리 중 오류 발생');
    // }
    console.log(`사용자 ${fromUserId}에서 ${toUserId}로 ${amount} 송금 (개념적)`);
    // 실제 로직 구현 필요
  }
}

/*
이 코드를 실행하려면:

1. `user.module.ts`, `user.entity.ts` 파일과 함께 `src/user` 디렉토리에 이 파일을 생성합니다.
2. `src/user/dto/user.dto.ts` 파일도 함께 생성해야 합니다.
*/
