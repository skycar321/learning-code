# ArgoCD 모니터링 및 운영 - 문제 해결 가이드
# 이 파일은 ArgoCD 학습 계획의 5단계인 '모니터링 및 운영'을 위한
# ArgoCD 사용 중 발생할 수 있는 일반적인 문제에 대한 해결 가이드입니다.

## 개요 (Overview)
ArgoCD를 운영하다 보면 동기화 실패, 애플리케이션 상태 불일치, UI/CLI 접근 문제 등
다양한 문제가 발생할 수 있습니다. 이 가이드는 일반적인 문제 상황을 진단하고 해결하는 데
도움을 주기 위해 작성되었습니다.

## 문제 해결 단계 (Troubleshooting Steps)

### 1. ArgoCD 시스템 상태 확인 (Check ArgoCD System Status)
가장 먼저 ArgoCD 컨트롤 플레인의 컴포넌트들이 정상적으로 동작하는지 확인합니다.

*   **ArgoCD 파드 상태 확인**:
    ```bash
    kubectl get pods -n argocd
    ```
    모든 파드가 `Running` 상태이고 `READY` 컬럼이 `X/X` 형태(예: `1/1`)인지 확인합니다.
    `CrashLoopBackOff`, `Pending` 등의 상태가 있다면 해당 파드의 로그를 확인합니다.

*   **파드 로그 확인**:
    ```bash
    kubectl logs -f <pod-name> -n argocd
    ```
    오류 메시지나 경고를 찾아 원인을 파악합니다.

*   **이벤트 확인**:
    ```bash
    kubectl describe pod <pod-name> -n argocd
    ```
    파드와 관련된 Kubernetes 이벤트를 통해 문제의 힌트를 얻을 수 있습니다.

### 2. ArgoCD 애플리케이션 상태 확인 (Check ArgoCD Application Status)
특정 애플리케이션에 문제가 발생한 경우, 해당 애플리케이션의 상태를 상세히 확인합니다.

*   **애플리케이션 목록 확인**:
    ```bash
    argocd app list
    ```
    `HEALTH`와 `SYNC STATUS`를 확인하여 문제가 있는 애플리케이션을 식별합니다.

*   **애플리케이션 상세 정보 확인**:
    ```bash
    argocd app get <application-name>
    ```
    `STATUS` 섹션에서 `Health Status`와 `Sync Status`를 확인하고,
    `Message` 필드에 동기화 실패 또는 헬스 체크 실패에 대한 상세한 정보가 있는지 확인합니다.
    `EVENTS` 섹션도 유용합니다.

*   **동기화 오류 확인**:
    `argocd app get` 명령 출력에서 `Sync Status: OutOfSync` 또는 `Sync Status: Failed`이고
    `MESSAGE` 필드에 "Failed to sync"와 같은 메시지가 있다면, 동기화 과정에서 문제가 발생한 것입니다.
    *   **Git Repository 접근 문제**: `repoURL`이 올바른지, ArgoCD에 Git Repository에 접근할 수 있는 권한이 있는지 확인합니다. SSH Key, HTTPS 인증 정보 등이 올바르게 설정되었는지 확인합니다.
    *   **Manifest 구문 오류**: 배포하려는 Kubernetes Manifest 파일(YAML)에 구문 오류가 있는지 확인합니다. `kubectl dry-run` 등으로 검증해볼 수 있습니다.
    *   **클러스터 리소스 부족**: 클러스터에 CPU, Memory 등의 리소스가 부족하여 파드가 스케줄링되지 못하거나 OOMKilled 되는 경우.
    *   **RBAC 권한 문제**: ArgoCD가 대상 클러스터에 리소스를 생성하거나 업데이트할 충분한 권한이 없는 경우. ArgoCD의 `ServiceAccount`, `Role`, `RoleBinding` 설정을 확인합니다.

### 3. 클러스터 리소스 직접 확인 (Directly Check Cluster Resources)
ArgoCD에서 문제가 진단되지 않거나, 보다 근본적인 문제를 파악하기 위해 Kubernetes 클러스터의
실제 리소스를 직접 확인합니다.

*   **대상 네임스페이스의 파드 확인**:
    ```bash
    kubectl get pods -n <target-namespace>
    kubectl describe pod <problematic-pod-name> -n <target-namespace>
    kubectl logs -f <problematic-pod-name> -n <target-namespace>
    ```
    애플리케이션의 파드가 `CrashLoopBackOff`, `ImagePullBackOff`, `Pending` 상태인 경우,
    `describe`와 `logs` 명령을 통해 원인(예: 이미지 풀 실패, 환경 변수 오류, 컨테이너 크래시)을 파악합니다.

*   **대상 네임스페이스의 다른 리소스 확인**:
    `Service`, `Ingress`, `Deployment`, `ReplicaSet` 등 배포하려는 다른 리소스들도
    정상적으로 생성되었는지 확인합니다.

### 4. Git Repository 확인 (Check Git Repository)
ArgoCD는 Git Repository를 "단일 진실 공급원"으로 사용하므로, Git Repository의 상태도 중요합니다.

*   **최신 커밋 확인**: ArgoCD가 참조하는 Git Repository의 `targetRevision`에 해당하는 커밋이
    정말로 의도한 최신 상태인지 확인합니다.
*   **파일 존재 여부 및 경로**: `path`에 지정된 경로에 배포하려는 Manifest 파일이 실제로 존재하는지 확인합니다.

### 5. ArgoCD 설정 확인 (Check ArgoCD Configuration)
때로는 ArgoCD 자체의 설정 문제일 수도 있습니다.

*   **ConfigMap 및 Secret 확인**: `argocd-cm`, `argocd-rbac-cm`, `argocd-secret` 등
    ArgoCD 관련 ConfigMap과 Secret이 올바르게 구성되었는지 확인합니다. 특히 클러스터 연결 정보나
    리포지토리 인증 정보가 여기에 포함될 수 있습니다.

*   **ArgoCD UI/CLI 문제**:
    *   **UI 접근 안됨**: `argocd-server` 파드 상태 확인 및 `port-forward` 명령이 올바른지 확인합니다.
    *   **로그인 문제**: 초기 비밀번호 또는 SSO 설정이 올바른지 확인합니다.

## 일반적인 문제 및 해결 (Common Issues & Solutions)

*   **`OutOfSync` 상태**:
    *   Git Repository와 클러스터 상태가 다른 경우입니다. `argocd app diff <application-name>` 명령으로 차이점을 확인하고, 필요시 `argocd app sync <application-name>`으로 동기화를 시도합니다.
    *   ArgoCD가 리소스를 수정할 권한이 없거나, 매니페스트에 오류가 있는 경우 발생할 수 있습니다.

*   **`Health: Missing` 또는 `Health: Degraded`**:
    *   애플리케이션의 Kubernetes 리소스 중 일부가 없거나, 비정상 상태(예: 파드가 `CrashLoopBackOff`)인 경우입니다. `kubectl get events -n <target-namespace>` 및 파드 로그를 확인하여 원인을 찾습니다.

*   **`ImagePullBackOff`**:
    *   컨테이너 이미지를 가져오는 데 실패한 경우입니다. 이미지 이름이나 태그가 올바른지, private registry를 사용하는 경우 인증 정보(`imagePullSecrets`)가 올바르게 설정되었는지 확인합니다.

*   **`CrashLoopBackOff`**:
    *   애플리케이션 컨테이너가 반복적으로 시작 및 종료되는 경우입니다. 컨테이너 내부의 로그를 확인하여 애플리케이션 코드 오류, 잘못된 설정 파일, 환경 변수 누락 등을 찾아야 합니다.

이 가이드는 일반적인 문제 해결에 대한 시작점이며, 실제 상황에서는 더 심층적인 분석과 디버깅이 필요할 수 있습니다.
항상 ArgoCD 공식 문서와 Kubernetes 문서를 참조하여 최신 정보를 확인하는 것이 좋습니다.
