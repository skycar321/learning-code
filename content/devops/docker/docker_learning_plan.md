# 실무 Docker 코드 학습 계획

안녕하세요! 미래의 멋진 Docker 개발자 여러분!

이 학습 계획은 여러분이 단순한 문법 지식을 넘어, 실제 프로젝트에서 마주하게 될 상황에 대비하여 견고하고 유지보수하기 쉬운 컨테이너 기반 애플리케이션을 구성하고 관리하는 데 필요한 핵심 역량을 길러주기 위해 기획되었습니다. 각 단계에서 제시하는 '나쁜 예시'를 통해 흔히 저지르는 실수를 파악하고, '좋은 예시'를 통해 모범 사례와 그 배경에 있는 원칙을 깊이 있게 이해하는 것이 중요합니다.

각 학습 주제는 상세한 설명과 코드 예시를 포함하며, '왜', '어떤 상황에서', '이 해당 패턴을 사용해야 하는지'를 깊이 있게 이해하는 학습이 되도록 합니다. 주도적인 학습을 위해 직접 예시 코드를 실행해보고, 나쁜 코드를 좋은 코드로 리팩토링하는 연습을 해볼 것을 강력히 추천합니다! 모든 학습 과정을 성공적으로 마치고 나면, 여러분은 자신감 넘치는 개발자로 성장해 있을 것입니다. 자, 그럼 시작해볼까요!

---

### **학습 로드맵**

| 단계 | 주제 | 학습 목표 | 상태 |
| :-- | :--- | :--- | :--- |
| **Step 1** | **컨테이너와 Docker의 이해** | 가상화와 컨테이너의 차이, Docker의 핵심 구성 요소 (Daemon, CLI, Images, Containers) 이해 | 완료 |
| **Step 2** | **Docker Image 생성 및 관리** | `Dockerfile` 작성과 이미지 빌드 (`docker build`), 이미지 레지스트리(Docker Hub) 사용 | 완료 |
| **Step 3** | **Docker Container 실행 및 관리** | 컨테이너 실행 (`docker run`), 생명주기 관리(`start`, `stop`, `rm`), 컨테이너 상태 확인 | 완료 |
| **Step 4** | **Docker Volume 사용** | 컨테이너 데이터의 영속성을 위한 Volume 개념 이해 및 활용법 학습 | 완료 |
| **Step 5** | **Docker Network 구성** | 컨테이너 간 통신 및 외부 노출을 위한 네트워크 드라이버 및 사용자 정의 네트워크 | 완료 |
| **Step 6** | **Docker Compose를 사용한 다중 컨테이너 관리** | `docker-compose.yml` 파일 작성, 서비스 정의, 다중 컨테이너 애플리케이션 실행 | 완료 |
| **Step 7** | **Dockerize 애플리케이션 (Node.js, Java, Python 예시)** | 실제 애플리케이션을 Docker 이미지로 만들고 실행하는 실습 | 완료 |
| **Step 8** | **컨테이너 보안** | Dockerfile 모범 사례, 이미지 취약점 스캔, Rootless 모드 등 보안 고려사항 | 완료 |
| **Step 9** | **Docker Swarm 또는 Kubernetes 기초** | 대규모 컨테이너 오케스트레이션을 위한 Swarm 또는 Kubernetes의 기본 개념 | 완료 |
| **Step 10** | **CI/CD 파이프라인에 Docker 활용** | Jenkins, GitLab CI 등 CI/CD 도구와 Docker를 연동하여 자동화된 배포 프로세스 구축 | 완료 |

---

### **각 단계별 상세 내용 (예시)**

#### **Step 2: Docker Image 생성 및 관리**
- **나쁜 예시**: 하나의 레이어에 모든 명령을 넣거나, 불필요한 파일(로그, 임시 파일)을 포함하여 이미지 크기를 비대하게 만듭니다.
- **좋은 예시**: 멀티-스테이지 빌드를 사용하여 최종 이미지 크기를 최소화하고, `.dockerignore`를 사용하여 불필요한 파일이 이미지에 포함되지 않도록 합니다. 각 `RUN` 명령을 논리적으로 분리하여 레이어 캐시를 효율적으로 활용합니다.
- **학습 포인트**: 작고 효율적인 이미지는 배포 속도를 높이고 보안 위험을 줄입니다. Dockerfile의 각 명령이 이미지 레이어를 생성하는 원리를 이해하고, 레이어 캐시와 멀티-스테이지 빌드를 적극적으로 활용하는 것이 중요합니다.

---

### **생성될 Docker 파일 목록**

`c:/Users/Nam/Documents/Cursor/Workspace/origin/learning-code/docker` 경로에 다음 파일들이 생성될 예정입니다. 각 파일은 특정 단계의 Docker 명령어 또는 Dockerfile 예시를 포함할 것입니다.

```
learning-code/docker/
├── Step1_UnderstandingContainers.md
├── Step2_CreatingImages/
│   ├── Dockerfile.bad
│   └── Dockerfile.good
├── Step3_ManagingContainers.sh
├── Step4_UsingVolumes.sh
├── Step5_ConfiguringNetworks.sh
├── Step6_UsingDockerCompose/
│   └── docker-compose.yml
├── Step7_DockerizingApps/
│   ├── nodejs/
│   └── java/
├── Step8_ContainerSecurity.md
├── Step9_OrchestrationBasics.md
└── Step10_CI_CD_Integration.md
```

---

### **추가 학습 권장 사항**

| 주제 | 설명 | 난이도 |
|:-----|:-----|:------:|
| **Kubernetes 심화** | Pod, Deployment, Service, Ingress 등 Kubernetes 핵심 리소스와 운영 방법을 학습합니다. | 중급 |
| **Helm Charts** | Kubernetes 애플리케이션 패키징 및 배포를 위한 Helm 차트 작성과 관리를 익힙니다. | 중급 |
| **컨테이너 모니터링** | Prometheus, Grafana, ELK Stack을 활용한 컨테이너 환경 모니터링과 로깅을 학습합니다. | 중급 |
| **Istio/Service Mesh** | 마이크로서비스 간 통신, 트래픽 관리, 보안을 위한 서비스 메시 아키텍처를 익힙니다. | 고급 |
| **GitOps (ArgoCD, Flux)** | Git을 단일 진실 공급원으로 활용한 선언적 인프라 및 애플리케이션 배포를 학습합니다. | 고급 |
