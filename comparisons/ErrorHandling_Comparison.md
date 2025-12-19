# 에러 처리 방식 비교: Java vs Rust vs Python

## 목차
1. [각 언어별 에러 처리 철학](#각-언어별-에러-처리-철학)
2. [코드 예시: 나쁜 예시 vs 좋은 예시](#코드-예시-나쁜-예시-vs-좋은-예시)
3. [비교표](#비교표)
4. [실무 활용 팁](#실무-활용-팁)

---

## 각 언어별 에러 처리 철학

### Java: 예외(Exception) 기반 처리

Java는 **예외(Exception)** 메커니즘을 사용하여 에러를 처리합니다.

- **체크 예외(Checked Exception)**: 컴파일 타임에 반드시 처리해야 하는 예외
- **언체크 예외(Unchecked Exception)**: RuntimeException을 상속하며, 처리가 강제되지 않음
- **Error**: 시스템 레벨의 심각한 오류 (OutOfMemoryError 등)

```java
// Java의 예외 계층 구조
// Throwable
// ├── Error (복구 불가능한 시스템 오류)
// └── Exception
//     ├── Checked Exception (IOException, SQLException 등)
//     └── RuntimeException (Unchecked Exception)
//         ├── NullPointerException
//         ├── IllegalArgumentException
//         └── ...
```

### Rust: Result 타입 기반 처리

Rust는 **Result<T, E>** 타입을 사용하여 에러를 명시적으로 처리합니다.

- 예외가 없음 - 모든 에러는 반환 값으로 처리
- **Result<T, E>**: 성공(Ok) 또는 실패(Err)를 명시적으로 표현
- **panic!**: 복구 불가능한 치명적 오류에만 사용
- 컴파일러가 에러 처리를 강제함

```rust
// Rust의 Result 타입
enum Result<T, E> {
    Ok(T),   // 성공 시 값 T 반환
    Err(E),  // 실패 시 에러 E 반환
}
```

### Python: 예외(Exception) 기반 처리

Python은 Java와 유사하게 **예외** 메커니즘을 사용하지만, 모든 예외가 언체크입니다.

- 체크 예외가 없음 - 모든 예외 처리는 선택적
- **EAFP** (Easier to Ask for Forgiveness than Permission) 철학
- 덕 타이핑과 결합된 유연한 예외 처리
- 예외 체이닝 지원 (`raise ... from ...`)

```python
# Python의 예외 계층 구조
# BaseException
# ├── SystemExit
# ├── KeyboardInterrupt
# └── Exception
#     ├── ValueError
#     ├── TypeError
#     ├── IOError
#     └── ...
```

---

## 코드 예시: 나쁜 예시 vs 좋은 예시

### Java 에러 처리

#### 나쁜 예시

```java
// 나쁜 예시 1: 예외를 무시함
public void readFile(String path) {
    try {
        FileReader reader = new FileReader(path);
        // 파일 읽기 로직
    } catch (FileNotFoundException e) {
        // 아무것도 하지 않음 - 절대 하지 말 것!
    }
}

// 나쁜 예시 2: 너무 넓은 범위의 예외 캐치
public void processData() {
    try {
        // 복잡한 로직
        readFile("data.txt");
        parseData();
        saveToDatabase();
    } catch (Exception e) {
        // 모든 예외를 한꺼번에 처리 - 디버깅 어려움
        System.out.println("에러 발생");
    }
}

// 나쁜 예시 3: 예외를 리턴 값으로 사용
public String getUserName(int id) {
    try {
        return userRepository.findById(id).getName();
    } catch (UserNotFoundException e) {
        return null;  // null 반환은 NullPointerException 유발 가능
    }
}
```

#### 좋은 예시

```java
// 좋은 예시 1: 구체적인 예외 처리와 로깅
public void readFile(String path) throws IOException {
    try (FileReader reader = new FileReader(path)) {
        // 파일 읽기 로직
    } catch (FileNotFoundException e) {
        // 로그 기록 후 적절한 예외로 변환하여 다시 던짐
        logger.error("파일을 찾을 수 없습니다: {}", path, e);
        throw new DataLoadException("데이터 파일 로드 실패", e);
    }
}

// 좋은 예시 2: 각 예외를 구체적으로 처리
public void processData() {
    try {
        readFile("data.txt");
    } catch (FileNotFoundException e) {
        logger.warn("설정 파일이 없어 기본값을 사용합니다.");
        useDefaultConfig();
    } catch (IOException e) {
        logger.error("파일 읽기 중 오류 발생", e);
        throw new ProcessingException("데이터 처리 실패", e);
    }
}

// 좋은 예시 3: Optional 사용으로 null 안전성 확보
public Optional<String> getUserName(int id) {
    try {
        User user = userRepository.findById(id);
        return Optional.ofNullable(user.getName());
    } catch (UserNotFoundException e) {
        logger.debug("사용자를 찾을 수 없음: id={}", id);
        return Optional.empty();
    }
}

// 좋은 예시 4: 커스텀 예외 정의
public class BusinessException extends RuntimeException {
    private final ErrorCode errorCode;

    public BusinessException(ErrorCode errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
    }

    public BusinessException(ErrorCode errorCode, String message, Throwable cause) {
        super(message, cause);
        this.errorCode = errorCode;
    }
}
```

### Rust 에러 처리

#### 나쁜 예시

```rust
// 나쁜 예시 1: unwrap() 남용 - 패닉 발생 가능
fn read_config() -> Config {
    let content = std::fs::read_to_string("config.toml").unwrap();  // 파일 없으면 패닉!
    toml::from_str(&content).unwrap()  // 파싱 실패해도 패닉!
}

// 나쁜 예시 2: expect()를 의미 없는 메시지와 함께 사용
fn get_user(id: u32) -> User {
    database.find_user(id).expect("에러")  // 도움이 되지 않는 메시지
}

// 나쁜 예시 3: 에러 정보 손실
fn process_file(path: &str) -> Result<Data, String> {
    let content = std::fs::read_to_string(path)
        .map_err(|_| "파일 읽기 실패".to_string())?;  // 원본 에러 정보 손실
    Ok(parse_data(&content))
}
```

#### 좋은 예시

```rust
use thiserror::Error;
use anyhow::{Context, Result};

// 좋은 예시 1: 커스텀 에러 타입 정의 (thiserror 사용)
#[derive(Error, Debug)]
pub enum ConfigError {
    #[error("설정 파일을 읽을 수 없습니다: {path}")]
    FileReadError {
        path: String,
        #[source]
        source: std::io::Error,
    },

    #[error("설정 파일 파싱 실패")]
    ParseError(#[from] toml::de::Error),
}

// 좋은 예시 2: ? 연산자와 컨텍스트 추가 (anyhow 사용)
fn read_config(path: &str) -> Result<Config> {
    let content = std::fs::read_to_string(path)
        .with_context(|| format!("설정 파일 읽기 실패: {}", path))?;

    let config: Config = toml::from_str(&content)
        .context("설정 파일 TOML 파싱 실패")?;

    Ok(config)
}

// 좋은 예시 3: match를 사용한 명시적 에러 처리
fn get_user_name(id: u32) -> String {
    match database.find_user(id) {
        Ok(user) => user.name,
        Err(DbError::NotFound) => {
            log::warn!("사용자를 찾을 수 없음: id={}", id);
            "알 수 없는 사용자".to_string()
        }
        Err(DbError::ConnectionError(e)) => {
            log::error!("데이터베이스 연결 오류: {:?}", e);
            panic!("치명적 오류: 데이터베이스 연결 실패");
        }
        Err(e) => {
            log::error!("예상치 못한 오류: {:?}", e);
            "오류".to_string()
        }
    }
}

// 좋은 예시 4: Result 체이닝
fn process_user_data(id: u32) -> Result<ProcessedData> {
    let user = fetch_user(id)?;
    let raw_data = download_user_data(&user)?;
    let processed = transform_data(raw_data)?;
    validate_data(&processed)?;
    Ok(processed)
}
```

### Python 에러 처리

#### 나쁜 예시

```python
# 나쁜 예시 1: 빈 except 블록
def read_file(path):
    try:
        with open(path, 'r') as f:
            return f.read()
    except:  # 모든 예외를 잡음 - KeyboardInterrupt도 잡힘!
        pass  # 아무것도 하지 않음

# 나쁜 예시 2: 너무 넓은 예외 처리
def process_data(data):
    try:
        result = complex_operation(data)
        save_to_database(result)
        send_notification()
    except Exception as e:
        print("에러 발생")  # 어떤 에러인지 알 수 없음

# 나쁜 예시 3: 예외로 흐름 제어
def find_item(items, target):
    try:
        return items.index(target)
    except ValueError:
        return -1  # 예외를 정상적인 흐름 제어에 사용
```

#### 좋은 예시

```python
import logging
from typing import Optional
from dataclasses import dataclass

logger = logging.getLogger(__name__)

# 좋은 예시 1: 구체적인 예외 처리
def read_config(path: str) -> dict:
    """설정 파일을 읽어 딕셔너리로 반환합니다."""
    try:
        with open(path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except FileNotFoundError:
        logger.warning(f"설정 파일이 없습니다: {path}, 기본값 사용")
        return get_default_config()
    except json.JSONDecodeError as e:
        logger.error(f"JSON 파싱 실패: {path}, 라인 {e.lineno}")
        raise ConfigurationError(f"잘못된 설정 파일 형식: {path}") from e

# 좋은 예시 2: 커스텀 예외 클래스 정의
class ApplicationError(Exception):
    """애플리케이션 기본 예외 클래스"""
    def __init__(self, message: str, error_code: str = None):
        super().__init__(message)
        self.error_code = error_code

class ValidationError(ApplicationError):
    """유효성 검사 실패 예외"""
    pass

class DatabaseError(ApplicationError):
    """데이터베이스 관련 예외"""
    pass

# 좋은 예시 3: 컨텍스트 매니저를 사용한 리소스 관리
from contextlib import contextmanager

@contextmanager
def database_transaction():
    """데이터베이스 트랜잭션을 관리하는 컨텍스트 매니저"""
    connection = get_database_connection()
    try:
        yield connection
        connection.commit()
        logger.info("트랜잭션 커밋 완료")
    except Exception as e:
        connection.rollback()
        logger.error(f"트랜잭션 롤백: {e}")
        raise
    finally:
        connection.close()

# 좋은 예시 4: Optional 타입 힌트와 None 체크
def find_user(user_id: int) -> Optional[User]:
    """사용자를 조회합니다. 없으면 None을 반환합니다."""
    try:
        return user_repository.get(user_id)
    except UserNotFoundError:
        logger.debug(f"사용자를 찾을 수 없음: {user_id}")
        return None

# 좋은 예시 5: 예외 체이닝
def process_order(order_id: int) -> Order:
    """주문을 처리합니다."""
    try:
        order = fetch_order(order_id)
        validate_order(order)
        return process(order)
    except ValidationError as e:
        raise OrderProcessingError(
            f"주문 처리 실패: {order_id}"
        ) from e  # 원인 예외 연결
```

---

## 비교표

### 에러 처리 메커니즘 비교

| 특성 | Java | Rust | Python |
|------|------|------|--------|
| **기본 메커니즘** | 예외 (Exception) | Result 타입 | 예외 (Exception) |
| **체크 예외** | 있음 (강제 처리) | 없음 (Result가 대체) | 없음 |
| **언체크 예외** | RuntimeException | panic! (복구 불가) | 모든 예외가 언체크 |
| **컴파일 타임 검사** | 체크 예외만 | Result 처리 강제 | 없음 |
| **에러 전파** | throws 선언 | ? 연산자 | 자동 전파 |
| **Null 안전성** | Optional (Java 8+) | Option 타입 | None + 타입 힌트 |
| **에러 체이닝** | cause 필드 | source 속성 | `__cause__` |

### 에러 처리 패턴 비교

| 패턴 | Java | Rust | Python |
|------|------|------|--------|
| **에러 무시** | `catch (E e) {}` | `.unwrap()` (위험) | `except: pass` (위험) |
| **기본값 반환** | `catch` + return | `.unwrap_or(default)` | `except` + return |
| **에러 변환** | `catch` + throw new | `.map_err()` | `raise ... from ...` |
| **에러 로깅** | Logger + rethrow | `log::error!` + `?` | `logger.error` + raise |
| **복구 시도** | catch + 복구 로직 | `match` + 복구 로직 | `except` + 복구 로직 |

### 언어별 에러 처리 도구/라이브러리

| 용도 | Java | Rust | Python |
|------|------|------|--------|
| **커스텀 에러** | extends Exception | `thiserror` | class 상속 |
| **에러 컨텍스트** | 예외 체이닝 | `anyhow` | `raise from` |
| **유효성 검사** | Bean Validation | `validator` | `pydantic` |
| **로깅** | SLF4J, Log4j | `log`, `tracing` | `logging` |

---

## 실무 활용 팁

### Java

1. **체크 예외는 신중하게 사용하세요**
   - 호출자가 합리적으로 복구할 수 있는 경우에만 체크 예외 사용
   - 프로그래밍 오류는 RuntimeException 사용

2. **예외는 예외적인 상황에만 사용하세요**
   ```java
   // 나쁜 예시: 예외로 흐름 제어
   try {
       int i = 0;
       while(true) {
           array[i++].doSomething();
       }
   } catch (ArrayIndexOutOfBoundsException e) {}

   // 좋은 예시: 일반적인 흐름 제어
   for (Element element : array) {
       element.doSomething();
   }
   ```

3. **try-with-resources를 활용하세요**
   ```java
   try (Connection conn = getConnection();
        PreparedStatement ps = conn.prepareStatement(sql)) {
       // 자동으로 리소스 해제
   }
   ```

4. **예외 메시지에 충분한 정보를 포함하세요**
   ```java
   throw new IllegalArgumentException(
       String.format("나이는 0보다 커야 합니다: 입력값=%d", age));
   ```

### Rust

1. **라이브러리 코드에서는 `thiserror`, 애플리케이션에서는 `anyhow` 사용**
   ```rust
   // 라이브러리: 구체적인 에러 타입 정의
   #[derive(Error, Debug)]
   pub enum MyLibError { ... }

   // 애플리케이션: 유연한 에러 처리
   fn main() -> anyhow::Result<()> { ... }
   ```

2. **`unwrap()`과 `expect()`는 프로토타이핑에서만 사용**
   - 프로덕션 코드에서는 명시적 에러 처리 필수
   - 테스트 코드에서는 사용 가능

3. **`?` 연산자를 적극 활용하세요**
   ```rust
   fn read_username_from_file() -> Result<String, io::Error> {
       let mut username = String::new();
       File::open("username.txt")?.read_to_string(&mut username)?;
       Ok(username)
   }
   ```

4. **에러에 컨텍스트 추가하기**
   ```rust
   fs::read_to_string(path)
       .with_context(|| format!("{}에서 설정을 읽는 데 실패", path))?
   ```

### Python

1. **EAFP vs LBYL 상황에 맞게 선택**
   ```python
   # EAFP (Easier to Ask Forgiveness than Permission)
   try:
       value = my_dict[key]
   except KeyError:
       value = default_value

   # LBYL (Look Before You Leap) - 때로는 이게 더 명확
   if key in my_dict:
       value = my_dict[key]
   else:
       value = default_value

   # 가장 파이썬스러운 방법
   value = my_dict.get(key, default_value)
   ```

2. **bare except를 사용하지 마세요**
   ```python
   # 나쁜 예시
   except:
       pass

   # 좋은 예시
   except Exception as e:
       logger.exception("예상치 못한 오류")
       raise
   ```

3. **예외 체이닝으로 원인 보존**
   ```python
   try:
       connect_to_database()
   except ConnectionError as e:
       raise ServiceUnavailable("서비스 일시 중단") from e
   ```

4. **타입 힌트로 None 가능성 명시**
   ```python
   from typing import Optional

   def find_user(id: int) -> Optional[User]:
       """사용자를 찾으면 User, 없으면 None 반환"""
       ...
   ```

### 공통 권장사항

1. **에러 메시지는 명확하고 실행 가능하게**
   - 무엇이 잘못되었는지
   - 왜 잘못되었는지
   - 어떻게 해결할 수 있는지

2. **로깅은 필수**
   - 개발 환경: DEBUG 레벨
   - 프로덕션: INFO/WARN/ERROR 레벨
   - 민감한 정보는 로깅하지 않기

3. **에러 복구 전략 수립**
   - 재시도 (지수 백오프)
   - 폴백 (대체 값/서비스)
   - 서킷 브레이커 패턴

4. **테스트 작성**
   - 성공 케이스뿐 아니라 실패 케이스도 테스트
   - 경계 조건 테스트
