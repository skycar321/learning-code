// nestjs/Step2_DatabaseIntegration/user.entity.ts
// NestJS 학습 계획 - 2단계: 데이터베이스 통합 및 ORM
// 이 파일은 TypeORM을 사용하여 데이터베이스 테이블과 매핑되는 `User` 엔티티를 정의합니다.
//
// 엔티티(Entity)는 데이터베이스의 테이블을 나타내는 클래스이며,
// `@Entity()`, `@PrimaryGeneratedColumn()`, `@Column()`과 같은 데코레이터를 사용하여
// 테이블 스키마와 필드(컬럼)를 정의합니다.

import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

// -----------------------------------------------------------------------------
// 학습 포인트 1: `@Entity()` 데코레이터
// - 클래스를 TypeORM 엔티티로 선언합니다.
// - 데이터베이스의 테이블과 매핑됩니다.
// - 선택적으로 테이블 이름을 지정할 수 있습니다. (예: `@Entity('users')`)
// -----------------------------------------------------------------------------
@Entity() // 이 클래스가 데이터베이스 테이블과 매핑되는 엔티티임을 선언
export class User {
  // -----------------------------------------------------------------------------
  // 학습 포인트 2: `@PrimaryGeneratedColumn()` 데코레이터
  // - 기본 키(Primary Key) 컬럼을 선언합니다.
  // - 데이터베이스 시스템에 의해 자동으로 값이 생성됩니다 (AUTO_INCREMENT).
  // -----------------------------------------------------------------------------
  @PrimaryGeneratedColumn() // 고유 ID를 자동으로 생성하는 기본 키 컬럼
  id: number;

  // -----------------------------------------------------------------------------
  // 학습 포인트 3: `@Column()` 데코레이터
  // - 클래스 프로퍼티를 데이터베이스 테이블의 컬럼과 매핑합니다.
  // - 선택적으로 컬럼의 속성(타입, 길이, 널 허용 여부, 기본값 등)을 지정할 수 있습니다.
  //   - `unique: true`: 해당 컬럼의 값이 고유해야 함을 나타냅니다. (중복 불가)
  //   - `nullable: false`: 해당 컬럼은 널 값을 허용하지 않습니다. (기본값)
  // -----------------------------------------------------------------------------
  @Column({ unique: true, nullable: false }) // 이메일 컬럼: 고유하며 널을 허용하지 않음
  email: string;

  @Column({ nullable: false }) // 비밀번호 컬럼: 널을 허용하지 않음
  password: string;

  @Column({ nullable: true }) // 이름 컬럼: 널을 허용
  name: string;

  @Column({ default: true }) // 활성화 여부 컬럼: 기본값은 true
  isActive: boolean;

  // 나쁜 예시: 비밀번호 같은 민감 정보를 암호화하지 않고 평문으로 저장하는 것.
  // - 데이터 유출 시 심각한 보안 문제가 발생합니다.
  // - 비밀번호는 반드시 해싱(Hashing)하여 저장해야 합니다 (예: BCrypt).
  // - @Column({ type: 'text', nullable: false }) // 평문 비밀번호 저장
  // password: string;
}

/*
이 코드를 실행하려면:

1. `user.module.ts` 파일과 함께 `src/user` 디렉토리에 이 파일을 생성합니다.
2. `package.json`에 `typeorm` 패키지를 설치해야 합니다. (예: `npm install typeorm`)
*/
