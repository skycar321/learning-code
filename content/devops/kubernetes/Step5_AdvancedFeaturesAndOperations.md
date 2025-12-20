# Kubernetes 학습 계획 - 5단계: 고급 기능 및 운영
# 이 파일은 Kubernetes 학습 계획의 5단계인 '고급 기능 및 운영'을 위한
# 개념적인 설명입니다. Helm을 이용한 애플리케이션 패키지 관리, 헬스 체크,
# 리소스 제한, 스케줄링, 로깅/모니터링, 보안 등 Kubernetes 운영에 필요한
# 고급 기능 및 모범 사례를 다룹니다.

## 개요 (Overview)
Kubernetes는 컨테이너 오케스트레이션을 위한 강력한 플랫폼이지만, 대규모 환경에서
애플리케이션을 효율적으로 운영하고 관리하기 위해서는 단순히 Pod, Deployment, Service만으로는
부족합니다. Helm, Health Checks, Resource Limits 등 다양한 고급 기능을 이해하고
적절히 활용해야 합니다.

## 학습 목표 (Learning Objectives)
*   Helm을 이용한 Kubernetes 애플리케이션 패키지 관리
*   Pod의 상태를 정확하게 진단하는 Health Checks (Liveness, Readiness Probe)
*   컨테이너의 리소스 사용량을 효율적으로 제어하는 Resource Limits and Requests
*   Pod를 특정 노드에 배치하거나 배제하는 스케줄링 기법 (Node Affinity, Taints & Tolerations)
*   Kubernetes 환경에서 로깅 및 모니터링 시스템 구축
*   Kubernetes 클러스터 보안 강화 방안 이해 (RBAC, Network Policy)

## 학습 내용 (Learning Content)

### 1. Helm (헬름) - Kubernetes 애플리케이션 패키지 관리
*   **목표**: Kubernetes 애플리케이션의 복잡한 배포를 단순화하고 재사용 가능한 패키지로 관리.
*   **Helm Chart**: 미리 구성된 Kubernetes 리소스(Deployment, Service, ConfigMap 등)의 템플릿 모음.
    -   `Chart.yaml`: 차트 정보 (이름, 버전, 설명).
    -   `values.yaml`: 차트 배포 시 재정의 가능한 변수.
    -   `templates/`: Kubernetes 리소스 YAML 파일 템플릿.
    -   `charts/`: 다른 차트를 의존성으로 포함 (Subcharts).
*   **Helm CLI**:
    -   `helm install <release-name> <chart-path>`: 차트 배포.
    -   `helm upgrade <release-name> <chart-path>`: 차트 업데이트.
    -   `helm uninstall <release-name>`: 차트 삭제.
*   **나쁜 예시**: 복잡한 애플리케이션을 여러 개의 수동 `kubectl apply -f` 명령어로 배포하는 것.
    -   오류 발생 가능성이 높고, 버전 관리 및 재사용이 어렵습니다.
*   **좋은 예시**: Helm Chart를 사용하여 애플리케이션의 모든 Kubernetes 리소스를 템플릿화하고, `values.yaml`을 통해 환경별 설정을 관리하여 일관된 배포를 수행하는 것.

### 2. Health Checks (헬스 체크)
*   **목표**: Pod 내 컨테이너의 상태를 주기적으로 확인하고, 문제가 발생하면 자동으로 재시작하거나 트래픽을 차단하여 서비스의 가용성을 높입니다.
*   **유형**:
    -   **Liveness Probe (활성 프로브)**: 컨테이너가 잘 "살아 있는지(running)" 확인.
        -   실패 시 컨테이너를 재시작합니다.
        -   예: HTTP GET, TCP Socket, Exec.
    -   **Readiness Probe (준비 프로브)**: 컨테이너가 사용자 요청을 처리할 "준비가 되었는지(ready)" 확인.
        -   실패 시 Service의 Endpoint 목록에서 제거하여 트래픽을 받지 못하게 합니다. (컨테이너는 계속 실행 중)
    -   **Startup Probe (시작 프로브)**: 컨테이너가 시작하는 데 필요한 시간을 제공하여, 컨테이너가 시작하는 동안 Liveness/Readiness Probe가 실패하지 않도록 합니다.
*   **나쁜 예시**: Health Check를 설정하지 않거나, 너무 단순하게 설정하여 컨테이너가 비정상 상태인데도 트래픽을 계속 보내는 것.
    -   서비스의 안정성이 떨어지고 장애 발생 시 복구가 지연됩니다.

### 3. Resource Limits and Requests (리소스 제한 및 요청)
*   **목표**: Pod 내 컨테이너에 CPU 및 메모리 사용량을 정의하여 클러스터 리소스를 효율적으로 관리하고 안정성을 높입니다.
*   **`requests`**: 컨테이너가 실행되는 데 필요한 최소한의 리소스 양.
    -   스케줄러가 Pod를 노드에 배치할 때 사용합니다.
*   **`limits`**: 컨테이너가 사용할 수 있는 최대 리소스 양.
    -   CPU: 이 값 이상으로 사용하려 하면 스로틀링(throttling)됩니다.
    -   Memory: 이 값 이상으로 사용하려 하면 OOMKilled (Out Of Memory Killed)될 수 있습니다.
*   **QoS (Quality of Service) 클래스**: `requests`와 `limits` 설정에 따라 Pod의 QoS 클래스가 결정됩니다.
    -   `Guaranteed`: `requests == limits` 일치 시. 가장 높은 우선순위.
    -   `Burstable`: `requests < limits` 일치 시. 중간 우선순위.
    -   `BestEffort`: `requests`, `limits` 모두 미지정 시. 가장 낮은 우선순위.
*   **나쁜 예시**: `requests`와 `limits`를 설정하지 않아 노드 리소스 부족 시 Pod가 강제 종료되거나, 특정 Pod가 노드의 모든 리소스를 독점하는 것.

### 4. 스케줄링 (Scheduling)
*   **목표**: Pod를 클러스터 내의 특정 노드에 배치하거나 배제하는 고급 전략.
*   **Node Affinity (노드 어피니티)**: Pod를 특정 레이블을 가진 노드에 "선호" 또는 "필수"적으로 배치합니다.
    -   `requiredDuringSchedulingIgnoredDuringExecution`: 스케줄링 시 필수.
    -   `preferredDuringSchedulingIgnoredDuringExecution`: 스케줄링 시 선호.
*   **Taints and Tolerations (테인트 및 톨러레이션)**:
    -   **Taint (테인트)**: 노드에 "오염"을 부여하여 특정 Pod가 해당 노드에 스케줄링되지 않도록 합니다.
    -   **Toleration (톨러레이션)**: Pod가 특정 Taint를 "용인"하여 해당 노드에 스케줄링될 수 있게 합니다.
    -   예: `node-role.kubernetes.io/master:NoSchedule` (마스터 노드에 일반 Pod 스케줄링 방지).
*   **나쁜 예시**: 스케줄링 정책 없이 모든 Pod를 모든 노드에 무작위로 스케줄링하여 리소스 불균형이나 특정 워크로드의 성능 저하를 유발하는 것.

### 5. 로깅 및 모니터링 (Logging & Monitoring)
*   **목표**: Kubernetes 클러스터 및 애플리케이션의 상태, 성능, 이벤트를 수집, 분석, 시각화하여 문제를 빠르게 감지하고 해결.
*   **로깅**:
    -   **컨테이너 로그**: `kubectl logs`로 조회 가능. Fluentd, Filebeat 등을 통해 중앙 로깅 시스템(ELK Stack, Grafana Loki)으로 전송.
*   **모니터링**:
    -   **Prometheus**: 메트릭 수집 및 시계열 데이터베이스.
    -   **Grafana**: Prometheus에서 수집된 데이터를 시각화하는 대시보드 도구.
    -   **Alertmanager**: Prometheus의 경고를 처리하고 알림(Slack, Email 등) 전송.
*   **나쁜 예시**: 중앙 로깅/모니터링 시스템 없이 각 Pod의 로그를 개별적으로 확인하거나, 클러스터의 상태를 수동으로 모니터링하는 것.

### 6. 보안 (Security)
*   **목표**: Kubernetes 클러스터 및 애플리케이션을 외부 위협으로부터 보호하고 최소 권한 원칙을 적용.
*   **RBAC (Role-Based Access Control)**: 사용자 및 서비스 계정에게 클러스터 리소스에 대한 접근 권한을 정의.
    -   `Role`, `ClusterRole`, `RoleBinding`, `ClusterRoleBinding`.
*   **Network Policy (네트워크 정책)**: Pod 간 네트워크 통신을 제어하여 보안 강화.
    -   특정 Pod만 다른 Pod와 통신할 수 있도록 허용.
*   **Pod Security Standards (PSS) / Pod Security Admission (PSA)**: Pod의 보안 컨텍스트를 제어하여 컨테이너의 권한을 제한.
*   **Secret Management**: 민감 정보를 Secret으로 관리하고, KMS와 연동하여 암호화된 상태로 저장.
*   **나쁜 예시**: `kubeconfig` 파일을 공유하거나, 모든 서비스 계정에 클러스터 전체 관리자 권한을 부여하는 것.

### 7. Kubernetes 클러스터 배포 (Deploying Kubernetes Clusters)
*   **`kubeadm`**: 온프레미스 환경에서 Kubernetes 클러스터를 설치하는 표준 도구.
*   **클라우드 관리형 서비스**:
    -   **AKS (Azure Kubernetes Service)**: Microsoft Azure.
    -   **GKE (Google Kubernetes Engine)**: Google Cloud Platform.
    -   **EKS (Amazon Elastic Kubernetes Service)**: Amazon Web Services.
*   **나쁜 예시**: 프로덕션 환경에 수동으로 클러스터를 구성하거나, 클라우드 제공업체의 관리형 서비스를 사용하지 않고 직접 클러스터의 모든 컴포넌트를 관리하는 것.

이러한 고급 기능과 운영 전략을 통해 Kubernetes 클러스터를 안정적이고 효율적으로 운영할 수 있습니다.
실제 운영 환경에서는 이 모든 요소들을 종합적으로 고려하여 최적의 설정을 찾아야 합니다.
