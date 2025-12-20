# Kubernetes 학습 계획 - 1단계: 컨테이너 및 Kubernetes 기본
# 이 파일은 Kubernetes 학습 계획의 1단계인 '컨테이너 및 Kubernetes 기본'을 위한
# 개념적인 설명입니다. 컨테이너의 개념과 Docker, 그리고 Kubernetes의 탄생 배경,
# 목적, 아키텍처 및 kubectl 도구 사용법을 이해하는 데 중점을 둡니다.

## 개요 (Overview)
클라우드 네이티브 애플리케이션 개발에서 컨테이너와 Kubernetes는 필수적인 기술 스택입니다.
컨테이너는 애플리케이션과 그 실행 환경을 격리하여 이식성과 일관성을 제공하며,
Kubernetes는 이러한 컨테이너화된 애플리케이션의 배포, 관리, 스케일링을 자동화하는
오케스트레이션 도구입니다.

## 학습 목표 (Learning Objectives)
*   컨테이너 개념 및 Docker의 역할 이해
*   가상화 기술과의 차이점 파악
*   Kubernetes의 탄생 배경, 목적, 주요 특징 이해
*   Kubernetes 아키텍처(Master/Control Plane, Worker Node) 구성 요소 파악
*   `kubectl` 도구 설치 및 기본적인 사용법 익히기
*   Minikube 또는 Kind를 이용한 로컬 Kubernetes 클러스터 생성 및 관리

## 학습 내용 (Learning Content)

### 1. 컨테이너 개념 및 Docker (Container Concepts & Docker)
*   **컨테이너란?**: 애플리케이션과 그 실행에 필요한 모든 것(코드, 런타임, 시스템 도구, 시스템 라이브러리, 설정)을 패키징하는 표준화된 단위입니다.
    -   호스트 OS 커널을 공유하며, 각각의 컨테이너는 독립적인 사용자 공간을 가집니다.
    -   이식성, 일관성, 격리성을 제공합니다.
*   **Docker**: 컨테이너 기술을 대중화시킨 오픈소스 플랫폼입니다.
    -   **Docker Image**: 컨테이너를 생성하기 위한 읽기 전용 템플릿입니다. 애플리케이션과 모든 종속성을 포함합니다.
    -   **Docker Container**: Docker Image를 실행 가능한 형태로 만든 인스턴스입니다.
*   **가상화와의 비교**:
    -   **가상 머신 (VM)**: 하이퍼바이저 위에 각 VM마다 별도의 OS를 가상화하여 실행합니다. 무겁고 시작 시간이 오래 걸립니다.
    -   **컨테이너**: 호스트 OS 커널을 공유하며, 애플리케이션 계층만 격리합니다. 가볍고 시작 시간이 빠릅니다.

### 2. Kubernetes 소개 (Introduction to Kubernetes)
*   **탄생 배경**: Google 내부에서 컨테이너 오케스트레이션 시스템인 Borg를 운영하던 경험을 바탕으로 오픈소스화되었습니다.
    -   수백만 개의 컨테이너를 관리하는 복잡한 문제를 해결하기 위해 개발.
*   **목적**: 컨테이너화된 워크로드와 서비스를 선언적으로 관리하기 위한 플랫폼입니다.
    -   자동화된 배포, 스케일링, 복구, 로드 밸런싱 등을 제공.
*   **특징**:
    -   **오케스트레이션**: 컨테이너의 배포, 스케일링, 관리 자동화.
    -   **자체 복구 (Self-healing)**: 실패한 컨테이너를 자동으로 재시작, 노드 장애 시 다른 노드로 컨테이너 재배치.
    -   **서비스 디스커버리 및 로드 밸런싱**: 컨테이너 그룹에 대한 네트워크 접근을 제공하고 트래픽을 분산.
    -   **수평적 스케일링**: 명령어 또는 사용량 기반으로 컨테이너 수를 자동으로 조절.
    -   **롤아웃 및 롤백**: 무중단 서비스 배포 및 문제 발생 시 이전 버전으로 자동 롤백.

### 3. Kubernetes 아키텍처 (Kubernetes Architecture)
*   Kubernetes 클러스터는 크게 **컨트롤 플레인 (Control Plane)**과 **워커 노드 (Worker Node)**로 구성됩니다.
    -   **컨트롤 플레인 (Master Node)**: 클러스터를 관리하고 조정하는 구성 요소들의 집합입니다.
        -   **Kube-apiserver**: Kubernetes API를 노출하는 컴포넌트. 모든 통신의 중심.
        -   **etcd**: 클러스터의 모든 데이터를 저장하는 분산 키-값 저장소.
        -   **Kube-scheduler**: 새로 생성된 Pod를 실행할 적절한 노드를 선택.
        -   **Kube-controller-manager**: 컨트롤러 프로세스를 실행. (Node Controller, Replication Controller, Endpoint Controller, Service Account Controller 등)
        -   **Cloud-controller-manager (선택 사항)**: 클라우드 프로바이더 특정 컨트롤러와 연동.
    -   **워커 노드 (Worker Node)**: 컨테이너화된 애플리케이션을 실행하는 물리 또는 가상 머신입니다.
        -   **Kubelet**: 각 노드에서 실행되는 에이전트. Pod의 컨테이너가 노드에서 실행되도록 관리.
        -   **Kube-proxy**: 각 노드에서 실행되는 네트워크 프록시. 클러스터 외부 또는 내부 통신을 위한 네트워크 규칙을 관리.
        -   **Container Runtime**: 컨테이너를 실행하는 소프트웨어 (예: Docker, containerd, CRI-O).

### 4. `kubectl` 도구 설치 및 설정 (Installing & Configuring `kubectl`)
*   **`kubectl`**: Kubernetes 클러스터를 제어하는 명령줄 도구입니다.
    -   클러스터 상태 확인, 리소스 배포, 업데이트, 삭제 등 모든 클러스터 관리 작업을 수행.
*   **설치**: 운영 체제에 맞는 방식으로 `kubectl`을 설치합니다 (예: `brew install kubectl` (macOS), `choco install kubernetes-cli` (Windows)).
*   **설정**: `kubectl`은 `~/.kube/config` 파일을 참조하여 클러스터에 연결합니다.
    -   `kubeconfig` 파일에는 클러스터 정보, 사용자 인증 정보, 컨텍스트 정보가 포함됩니다.
    -   `kubectl config use-context <context-name>`: 특정 클러스터에 연결할 컨텍스트를 전환.

### 5. Minikube 또는 Kind를 이용한 로컬 클러스터 생성 (Creating Local Cluster with Minikube/Kind)
*   **목표**: 개발 및 테스트 목적으로 개인 로컬 머신에 경량 Kubernetes 클러스터를 생성합니다.
*   **Minikube**: 단일 노드 Kubernetes 클러스터를 로컬 환경에 빠르게 구축.
    -   VM 드라이버 (VirtualBox, KVM, Hyper-V 등) 또는 Docker 드라이버 사용.
    -   설치: Minikube 공식 문서 참조.
    -   명령어:
        -   `minikube start`: 클러스터 시작.
        -   `minikube dashboard`: Kubernetes 대시보드 실행.
        -   `minikube stop`: 클러스터 중지.
        -   `minikube delete`: 클러스터 삭제.
*   **Kind (Kubernetes in Docker)**: Docker 컨테이너를 사용하여 로컬 Kubernetes 클러스터를 실행.
    -   Minikube보다 더 가볍고 빠르게 클러스터를 생성할 수 있으며, 멀티 노드 클러스터 구성도 가능.
    -   설치: Kind 공식 문서 참조.
    -   명령어:
        -   `kind create cluster`: 클러스터 생성.
        -   `kind delete cluster`: 클러스터 삭제.

## 실습 가이드 (Practical Guide)
1.  **kubectl 설치**: 사용 중인 OS에 맞게 `kubectl`을 설치합니다.
2.  **Minikube 또는 Kind 설치**: 둘 중 하나를 선택하여 설치합니다.
3.  **로컬 클러스터 시작**:
    -   Minikube: `minikube start`
    -   Kind: `kind create cluster`
4.  **클러스터 상태 확인**:
    -   `kubectl cluster-info`: 클러스터 정보 확인.
    -   `kubectl get nodes`: 클러스터의 노드 목록 확인.
    -   `kubectl get pods -A`: 모든 네임스페이스의 Pod 목록 확인.

이러한 기본 준비가 완료되면, 다음 단계부터는 Kubernetes의 주요 리소스 객체들을 활용하여
애플리케이션을 배포하고 관리하는 방법을 학습할 수 있습니다.
