# 🚀 Git 실전 가이드: 복잡한 3단 충돌 해결

이 문서는 `my-workspace` 폴더 안에서 따라 하는 실습 가이드입니다.
이번 시나리오는 **파일의 상단, 중단, 하단** 모든 곳에서 충돌이 발생하는 고난이도 상황입니다.

---

## 📍 Phase 1: 위기 탈출 (Stash & Sync)

### 1. 작업 대피 (Stash)
```bash
git stash push -u -m "SR1과 SR2 혼합 작업 대피"
```

### 2. 동기화 (Sync)
```bash
git pull origin dev
```

---

## 📍 Phase 2: SR1 기능 분리 (핵심 단계)

### 1. SR1 브랜치 생성 및 스태시 적용
```bash
git checkout -b sr1
git stash apply stash@{0}
```

> **🤔 잠깐! 왜 `stash pop`을 안 쓰나요?**
> *   `pop`: 적용 후 스태시 목록에서 **삭제**합니다.
> *   `apply`: 적용만 하고 스태시 목록에 **남겨둡니다**.
> *   우리는 **SR2** 작업을 위해 스태시 내용이 또 필요하므로, 안전하게 `apply`를 씁니다.

🚨 **비상 상황! 3단 콤보 충돌 발생!**
`CoreService.java` 파일 전체가 충돌 마커로 뒤덮였습니다. 하나씩 해결해봅시다.

### 2. 충돌 해결 (Conflict Resolution) 🔍

**[충돌 난 파일 전체 모습 (Full View)]**
```java
<<<<<<< Updated upstream
import java.time.LocalDateTime;
import java.util.UUID;

// [원격 v1.1] 동료가 바꾼 클래스
public class CoreService implements AutoCloseable {
    private static final String SERVICE_VERSION = "1.1";
    // ... 동료의 변수들 ...
=======
import java.time.LocalDate;
import java.util.Locale;

// [내 로컬 v1.0] 내가 쓰던 클래스
public class CoreService implements Runnable {
    private static final String SERVICE_VERSION = "1.0-SR";
    // ... 내 변수들 ...
>>>>>>> Stashed changes
    // ... (중략: 메서드 충돌들) ...
```

**[해결 가이드]**
모든 기능을 합쳐야 합니다. 아래 **정답 코드**처럼 수정하세요.

**[수정 후 최종 모습 (정답)]**
```java
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Locale;
import java.util.UUID;

// [통합 완료] 동료의 AutoCloseable과 내 Runnable을 모두 구현
public class CoreService implements AutoCloseable, Runnable {
    private static final String SERVICE_VERSION = "1.1"; // 버전은 최신으로
    private final UUID instanceId = UUID.randomUUID();
    private int retryLimit = 2; // 동료 설정 따름
    private LocalDateTime lastRunAt = LocalDateTime.now();
    private boolean debugEnabled = true; // 내 설정 유지

    public void processData() {
        System.out.println("Basic Data Processing");
    }

    // [SR1 예정] 이 메서드는 SR1 브랜치로 갑니다.
    public void preProcess() {
        System.out.println("[SR1] Pre-processing Logic Added");
        System.out.println("[SR1] Locale=" + Locale.getDefault());
    }

    // [CommonUtil 통합] 동료 성능개선 + 내 로그 합침
    public void commonUtil() {
        System.out.println("Common Util v1.1 (Performance Improved)");
        System.out.println("[v1.1] Cache warmed");
        System.out.println("[SR1] Extra diagnostics enabled");
    }

    // [동료 메서드들] 원격 v1.1 기능 유지
    public String getInstanceId() { return instanceId.toString(); }
    public void archiveData() {
        System.out.println("[v1.1] Archiving daily data at " + lastRunAt);
    }
    public void close() { System.out.println("Closing resources..."); }

    // [SR2 예정] 이 메서드는 나중에 SR2 브랜치로 갑니다.
    public void createReport() {
        System.out.println("[SR2] Generating PDF Report for " + LocalDate.now());
    }
    public void run() { System.out.println("Running service..."); }
}
```

수정 완료 후:
```bash
git add CoreService.java
```

---

### 3. 부분 스테이징 (Interactive Staging)

이제 섞여 있는 코드 중 **SR1 (`preProcess`, `run`)**만 골라냅니다.

```bash
git add -p CoreService.java
```

**[선택 가이드]**
1.  **Imports/Fields**: `s` (Split) 후 SR1 관련(`Locale`, `Runnable` 등)만 `y`, 나머지는 `n` (이미 원격에 있거나 SR2용).
    *   *팁: 너무 복잡하면 상단은 그냥 다 넣어도 됩니다(y).*
2.  **`preProcess` 메서드**: 👉 **`y`** (SR1 핵심 기능)
3.  **`createReport` 메서드**: 👉 **`n`** (SR2 기능)

### 4. SR1 커밋
```bash
git commit -m "feat(sr1): 전처리 로직 및 실행 인터페이스 구현"
git restore .
git clean -fd
```

---

## 📍 Phase 3: SR2 기능 분리

### 1. SR2 브랜치 및 스태시
```bash
git checkout dev
git checkout -b sr2
git stash apply stash@{0}
```

### 2. SR2 커밋
```bash
git add .
git commit -m "feat(sr2): 리포트 생성 기능 추가"
```

---

## 📍 Phase 4: 종료
```bash
git stash drop stash@{0}
```