# Step 2: IAM과 계정 보안

## 학습 목표

AWS 환경의 모든 활동이 API 호출을 통해 이루어짐을 이해하고, IAM(Identity and Access Management)을 사용하여 '누가(Principal), 무엇을(Action), 어떤 리소스(Resource)에 대해, 어떤 조건(Condition)에서' 접근할 수 있는지를 제어하는 방법을 학습합니다. 최소 권한 원칙(Principle of Least Privilege)을 적용하여 안전한 클라우드 환경을 구축합니다.

---

## 1. 핵심 개념 (Professional's View)

-   **Principal (주체)**: 인증 및 권한 부여의 대상.
    -   **Root User**: 계정 생성 시 부여되는 최상위 권한. 일상 작업에 절대 사용해서는 안 되며, MFA(Multi-Factor Authentication)를 설정하고 안전하게 보관해야 합니다.
    -   **IAM User**: AWS와 상호작용하는 영구적인 자격 증명을 가진 사람 또는 애플리케이션.
    -   **IAM Role**: 특정 조건 하에 AWS 서비스나 다른 계정의 사용자가 수임(Assume)할 수 있는 임시 자격 증명. Access Key를 코드에 노출하지 않는 가장 안전한 방법입니다.

-   **Authentication (인증)** & **Authorization (인가)**:
    -   **인증**: '당신이 누구인지'를 증명하는 과정 (ID/PW, Access Key).
    -   **인가**: 인증된 주체가 '무엇을 할 수 있는지'를 결정하는 과정. IAM Policy를 통해 이루어집니다.

-   **Policy (정책)**: 권한을 정의하는 JSON 문서.
    -   `Effect`: `Allow` 또는 `Deny`. `Deny`가 항상 우선합니다.
    -   `Action`: 허용/거부할 서비스 작업 (예: `s3:GetObject`).
    -   `Resource`: 작업이 적용될 AWS 리소스의 ARN (Amazon Resource Name).
    -   `Condition`: 정책이 유효한 조건 (예: 특정 IP 주소에서 온 요청일 경우).

-   **Principle of Least Privilege (최소 권한 원칙)**: 모든 주체는 자신의 업무를 수행하는 데 필요한 최소한의 권한만을 가져야 한다는 보안의 기본 원칙입니다. `AdministratorAccess`나 `*:*` 같은 와일드카드 권한 부여를 지양해야 합니다.

---

## 2. 쉬운 비유 (Beginner's View)

-   **IAM 시스템**은 거대한 **회사의 '보안팀'** 입니다.
-   **Root User**는 회사의 모든 문을 열 수 있는 **'마스터키'를 가진 CEO**입니다. 이 키는 평소에 금고에 보관하고 절대 사용하지 않습니다.
-   **IAM User**는 ID 카드와 비밀번호를 가진 **'정직원'** 입니다.
-   **IAM Group**은 '개발팀', '기획팀' 같은 **'부서'** 입니다. 부서 단위로 권한을 주면 관리가 편합니다.
-   **IAM Policy**는 "개발팀은 서버실 출입 가능, 기획팀은 회의실만 사용 가능"과 같이 적힌 **'출입 규칙서'** 입니다.
-   **IAM Role**은 **'임시 방문증'** 입니다. 정직원(User)이 아닌 컴퓨터(EC2)나 외부인에게 일을 시킬 때, 내 사원증을 주는 대신 "30분간 서버실에만 들어갈 수 있는 방문증"을 주는 것입니다. 훨씬 안전합니다.

---

## 3. 시각화 (Architecture)

```mermaid
graph TD
    subgraph "AWS 회사"
        Root(CEO - 마스터키)
        IAM(인사/보안팀)
        
        subgraph "리소스 (사무실/장비)"
            EC2(서버 컴퓨터)
            S3(파일 창고)
            DB(고객 데이터베이스)
        end
    end

    subgraph "직원 및 방문객"
        User[김개발]
        Group[개발팀]
        Role(임시 방문증<br>컴퓨터(EC2)용)
    end
    
    IAM --"정책(규칙) 적용"--> Group
    User --"개발팀에 소속"--> Group
    
    Group --"서버/파일 접근 권한 부여"--> EC2
    Group --"서버/파일 접근 권한 부여"--> S3
    Group --"DB 접근은 불가!"--x DB

    IAM --"임시 역할 부여"--> Role
    Role --"DB 읽기 전용 권한"--> DB
    EC2 --"이 역할(방문증)을 사용해!"--> Role

    style Root fill:#ffb3ba,stroke:#333,stroke-width:2px;
```

---

## 4. 나쁜 예시 (Bad Practice)

### 모든 권한을 가진 User의 Access Key 사용
-   **코드**:
    ```python
    # Access Key와 Secret Key를 코드나 환경변수에 하드코딩
    s3 = boto3.client(
        's3',
        aws_access_key_id='AKIA...', # AdministratorAccess 권한을 가진 키
        aws_secret_access_key='wJal...'
    )
    ```
-   **문제점**:
    -   **자격 증명 노출**: 코드가 Git 저장소 등에 유출되면 Access Key가 그대로 노출됩니다. 이는 회사 전체 AWS 계정을 해커에게 넘겨주는 것과 같습니다.
    -   **최소 권한 원칙 위반**: 애플리케이션은 S3 파일 업로드만 필요한데, DB 삭제, 서버 중지 등 모든 권한을 갖게 되어 잠재적 위험이 매우 큽니다.

---

## 5. 좋은 예시 (Good Practice)

### IAM Role을 사용하여 EC2 인스턴스에 임시 권한 부여
-   **프로세스**:
    1.  **정책 생성**: '특정 S3 버킷에 `s3:PutObject` 작업만 허용'하는 IAM Policy를 생성합니다.
    2.  **역할 생성**: EC2 서비스가 수임할 수 있는 IAM Role을 생성하고, 위에서 만든 정책을 연결합니다.
    3.  **EC2에 역할 적용**: EC2 인스턴스를 시작할 때 이 IAM Role을 지정합니다.
-   **코드**:
    ```python
    # 코드에는 어떤 자격 증명도 없음!
    # EC2 인스턴스가 부여받은 Role을 통해 자동으로 권한을 획득
    s3 = boto3.client('s3')
    
    def upload_file_to_s3(bucket, key, file_path):
        s3.upload_file(file_path, bucket, key)
    ```
-   **개선점**:
    -   **자격 증명 추상화**: 코드에서 Access Key가 완전히 사라져 유출 위험이 원천적으로 차단됩니다.
    -   **최소 권한 원칙 준수**: EC2 인스턴스는 정확히 자신이 할 일(S3 파일 업로드)에 필요한 권한만 임시로 부여받습니다. 이 서버가 해킹당해도 공격자는 S3 파일 업로드 외의 다른 작업은 수행할 수 없습니다.
    -   **관리 용이성**: 권한 변경이 필요할 때 코드 수정 없이 IAM 콘솔에서 정책만 수정하면 되므로 유연하고 관리가 편합니다.

---

## 6. 핵심 학습 포인트

-   **절대 Root User를 사용하지 마라**: Root User는 계정 설정, 결제 등 제한적인 용도로만 사용하고, 모든 일상 작업은 IAM User를 통해 수행해야 합니다.
-   **권한은 항상 최소한으로**: "나중에 필요할지 모르니 미리 넓게 주자"는 생각이 가장 위험합니다. 지금 당장 필요한 최소한의 권한만 부여하고, 필요할 때 점진적으로 추가해야 합니다.
-   **사람에게는 Group, 기계에게는 Role**: 사람 개발자는 IAM Group을 통해 권한을 관리하고, EC2, Lambda 등 AWS 리소스에는 IAM Role을 부여하는 것이 보안 모범 사례의 핵심입니다.
-   **Deny가 Allow보다 우선한다**: 어떤 정책에서 `Allow`를 했더라도, 다른 정책에서 `Deny`가 명시되어 있다면 최종적으로 거부됩니다. 이는 복잡한 권한 문제를 분석할 때 중요한 원칙입니다.
