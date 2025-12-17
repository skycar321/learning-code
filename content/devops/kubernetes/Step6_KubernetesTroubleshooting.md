# Step 6: Kubernetes 트러블슈팅 가이드 (Troubleshooting Guide)

Kubernetes 운영 중 자주 마주치는 오류 Top 50을 정리했습니다. 현상(Symptom)을 기반으로 검색(`Ctrl+F`)하여 원인과 해결책을 빠르게 찾으세요.

## 1. Pod Lifecycle Errors (파드 생명주기)

### 1-1. `CrashLoopBackOff`
- **현상**: 파드가 시작되자마자 죽고 재시작을 반복함.
- **원인**: 애플리케이션 버그(Exception), 환경변수 누락, 시작 명령어(CMD/ENTRYPOINT) 오류.
- **해결**:
  ```bash
  kubectl logs <pod-name> --previous  # 이전 컨테이너 로그 확인
  kubectl describe pod <pod-name>     # 종료 코드(Exit Code) 확인
  ```

### 1-2. `ImagePullBackOff` / `ErrImagePull`
- **현상**: 이미지를 가져오지 못해 컨테이너 생성이 지연됨.
- **원인**: 이미지 이름 오타, 태그 없음, Private Registry 인증 정보(`imagePullSecrets`) 누락.
- **해결**: 이미지 경로 확인. `kubectl create secret docker-registry`로 시크릿 생성 후 파드에 연동.

### 1-3. `Pending` (Scheduling Failed)
- **현상**: 파드가 노드에 배치되지 않고 계속 대기 중.
- **원인**: CPU/Memory 자원 부족, Taint/Toleration 불일치, NodeAffinity 조건 미충족.
- **해결**:
  - `kubectl describe pod <pod-name>`의 Events 확인 ("Insufficient cpu" 등).
  - Cluster Autoscaler로 노드 증설 또는 파드 리소스 요청량(Request) 감소.

### 1-4. `Evicted`
- **현상**: 노드의 자원 부족(Disk Pressure, Memory Pressure)으로 파드가 강제 종료됨.
- **원인**: 노드 디스크 꽉 참(/var/lib/docker), 메모리 부족.
- **해결**: 불필요한 이미지 정리(`docker system prune`), 로그 로테이션 설정, Ephemeral Storage 제한 설정.

### 1-5. `OOMKilled` (Exit Code 137)
- **현상**: 메모리 사용량 초과로 커널이 프로세스 사살.
- **원인**: 메모리 누수 또는 `resources.limits.memory`가 너무 작게 설정됨.
- **해결**: 메모리 Limit 상향 조정, 애플리케이션 프로파일링.

### 1-6. `Init:Error` / `Init:CrashLoopBackOff`
- **현상**: 초기화 컨테이너(Init Container)가 실패하여 메인 컨테이너가 뜨지 않음.
- **원인**: DB 마이그레이션 실패, 의존성 서비스 접속 불가.
- **해결**: `kubectl logs <pod-name> -c <init-container-name>` 확인.

### 1-7. `CreateContainerConfigError`
- **현상**: 컨테이너 설정 단계에서 실패.
- **원인**: ConfigMap 또는 Secret이 누락되었거나 키 이름이 틀림.
- **해결**: 참조하는 ConfigMap/Secret 존재 여부 확인.

### 1-8. `Liveness probe failed: HTTP probe failed...`
- **현상**: 헬스 체크 실패로 파드가 계속 재시작됨.
- **원인**: 애플리케이션 응답 지연, 타임아웃 설정이 너무 짧음.
- **해결**: `initialDelaySeconds` 늘리기, 애플리케이션 부하 원인 분석.

### 1-9. `Readiness probe failed`
- **현상**: 파드는 Running이지만 Service 엔드포인트에 포함되지 않음(트래픽 안 받음).
- **원인**: 애플리케이션이 준비되지 않음 (DB 연결 중 등).
- **해결**: 정상적인 대기 상태인지, 데드락인지 로그 확인.

### 1-10. `PreStopHookFailed`
- **현상**: 파드 종료 시 Hook 스크립트가 에러를 냄.
- **원인**: 스크립트 권한 문제 또는 타임아웃.
- **해결**: `terminationGracePeriodSeconds` 늘리기.

---

## 2. Networking Errors (네트워크)

### 2-1. `Service Unreachable` (DNS Resolution Failure)
- **현상**: `nslookup my-service` 실패.
- **원인**: CoreDNS 파드 문제, 네트워크 정책(NetworkPolicy) 차단.
- **해결**: `kubectl get pods -n kube-system -l k8s-app=kube-dns` 상태 확인.

### 2-2. Ingress `502 Bad Gateway`
- **현상**: 인그레스 접속 시 502 에러.
- **원인**: 백엔드 파드로 연결 불가 (Service Selector 불일치, 파드 포트 불일치).
- **해결**: Service의 `targetPort`와 파드의 `containerPort` 일치 확인.

### 2-3. Ingress `503 Service Unavailable`
- **현상**: 사용 가능한 백엔드 파드가 없음.
- **원인**: 파드가 모두 CrashLoopBackOff 상태이거나 Readiness Probe 실패 중.
- **해결**: 파드 상태 점검.

### 2-4. Ingress `404 Not Found`
- **현상**: 경로를 찾을 수 없음.
- **원인**: Ingress Path 설정 오류, 애플리케이션이 해당 Context Path를 처리하지 않음.
- **해결**: Ingress의 `path`와 앱의 라우팅 설정 일치 확인. (Rewrite Annotation 필요할 수도 있음).

### 2-5. `CNI Error` / `NetworkPluginNotReady`
- **현상**: 파드가 IP를 할당받지 못해 Pending.
- **원인**: CNI 플러그인(Calico, Flannel 등) 미설치 또는 에러.
- **해결**: CNI 파드 로그 확인, 노드 CIDR 고갈 여부 확인.

### 2-6. `Port Conflict`
- **현상**: `Address already in use`.
- **원인**: `hostPort`를 사용했는데 해당 노드에 이미 사용 중인 포트임.
- **해결**: `hostPort` 대신 `NodePort` 사용 권장.

### 2-7. `External IP Pending` (LoadBalancer)
- **현상**: Service Type이 LoadBalancer인데 IP가 안 나옴.
- **원인**: Cloud Provider 연동 실패, 또는 온프레미스에서 MetalLB 없음.
- **해결**: 클라우드 컨트롤러 매니저 로그 확인.

### 2-8. `CoreDNS Loop Detected`
- **현상**: CoreDNS 파드가 과도한 로그를 뱉으며 재시작.
- **원인**: 호스트의 `/etc/resolv.conf`가 루프백을 가리킴.
- **해결**: CoreDNS ConfigMap 수정 또는 노드 DNS 설정 변경.

### 2-9. `Connection Timed Out` (Pod to Pod)
- **현상**: 특정 파드 간 통신 안 됨.
- **원인**: NetworkPolicy가 Deny All로 설정되어 있거나, MTU 문제.
- **해결**: NetworkPolicy 확인. Overlay 네트워크 MTU 설정 확인.

### 2-10. `HostPort` 사용 시 스케줄링 실패
- **현상**: 파드가 특정 노드에만 뜨려다가 포트 충돌로 실패.
- **원인**: `hostPort`는 노드당 1개만 뜰 수 있음.
- **해결**: 불필요한 `hostPort` 제거.

---

## 3. Storage Errors (스토리지)

### 3-1. `PVC Pending` (No PV Available)
- **현상**: PVC가 Bound 되지 않음.
- **원인**: 요구하는 용량/AccessMode를 만족하는 PV가 없음.
- **해결**: 적절한 PV 생성 또는 Dynamic Provisioning 설정 확인.

### 3-2. `PVC Pending` (StorageClass Issue)
- **현상**: `WaitForFirstConsumer` 상태로 멈춤.
- **원인**: 파드가 생성되어야(스케줄링 되어야) 볼륨을 생성하는 모드임.
- **해결**: 파드를 배포하면 해결됨. 또는 스토리지 클래스 프로비저너 에러 확인.

### 3-3. `MountVolume.SetUp failed` (Permission Denied)
- **현상**: 파드 생성 중 볼륨 마운트 실패.
- **원인**: 스토리지 디렉토리 권한 문제.
- **해결**: `fsGroup` 설정(SecurityContext) 또는 `initContainer`에서 `chown` 수행.

### 3-4. `Multi-Attach Error`
- **현상**: `Volume is already used by pod ...`
- **원인**: `ReadWriteOnce` 볼륨은 하나의 노드에서만 마운트 가능. 다른 노드의 파드가 잡고 있음.
- **해결**: 기존 파드 완전 종료 확인. (Deployment 롤링 업데이트 시 발생 가능 -> `Recreate` 전략 고려).

### 3-5. `Subpath` Error
- **현상**: ConfigMap 등을 특정 경로 파일로 마운트할 때 실패.
- **원인**: 해당 경로가 디렉토리로 존재하거나 파일이 덮어써지지 않음.
- **해결**: `subPath` 설정 확인.

### 3-6. `Volume Resize Stuck`
- **현상**: `FileSystemResizePending`.
- **원인**: 파드가 실행 중이어야 파일시스템 확장이 가능한데, 파드를 껐거나 노드 이슈.
- **해결**: 파드를 다시 실행하면 파일시스템 리사이징 수행됨.

### 3-7. `Provisioner Error` (Cloud)
- **현상**: EBS/PD 생성 실패.
- **원인**: IAM 권한 부족, 쿼터(Quota) 초과.
- **해결**: 클라우드 콘솔에서 쿼터 확인 및 IAM Role 점검.

### 3-8. `NodeAffinity Conflict` (Volume)
- **현상**: 파드가 스케줄링 안 됨 (Volume Node Affinity Conflict).
- **원인**: 볼륨은 Zone A에 있는데, 파드는 Zone B로 가려고 함.
- **해결**: 파드와 볼륨을 같은 가용영역(AZ)에 배치.

### 3-9. `ReadOnlyFileSystem`
- **현상**: 쓰기 작업 실패.
- **원인**: `readOnly: true` 마운트 또는 파일시스템 손상으로 OS가 RO로 전환.
- **해결**: 마운트 옵션 확인.

### 3-10. `Failed to attach volume` (Timeout)
- **현상**: AttachDetachController 타임아웃.
- **원인**: 스토리지 백엔드 응답 지연.
- **해결**: 수동으로 VolumeAttachment 오브젝트 삭제 후 재시도.

---

## 4. RBAC & Security (보안)

### 4-1. `User "system:serviceaccount..." cannot list resource "pods"`
- **현상**: 애플리케이션 로그에 403 Forbidden 에러.
- **원인**: ServiceAccount에 적절한 Role/RoleBinding이 없음.
- **해결**: RBAC 설정 추가 (RoleBinding 생성).

### 4-2. `ServiceAccount Token Invalid`
- **현상**: API 서버 인증 실패.
- **원인**: 시크릿 토큰이 만료되었거나 삭제됨. (K8s 1.24+ 부터는 토큰 자동 생성 안 됨).
- **해결**: `kubectl create token` 또는 Secret 수동 생성.

### 4-3. `Forbidden: User "..." cannot create resource`
- **현상**: `kubectl` 명령 실패.
- **원인**: kubeconfig의 사용자 권한 부족.
- **해결**: 클러스터 관리자에게 권한 요청.

### 4-4. `RoleBinding Missing`
- **현상**: Role은 있는데 적용이 안 됨.
- **원인**: RoleBinding의 `subjects`에 오타가 있거나 Namespace 불일치.
- **해결**: RoleBinding YAML 점검.

### 4-5. `PSP (PodSecurityPolicy) Violation`
- **현상**: 파드 생성 거부. (구버전 K8s)
- **원인**: `privileged` 컨테이너 등 보안 정책 위반.
- **해결**: PSS(Pod Security Standards) 준수하도록 파드 스펙 수정.

---

## 5. Helm & Deployment (배포)

### 5-1. `UPGRADE FAILED: cannot patch ... immutable field`
- **현상**: 헬름 업그레이드 실패.
- **원인**: Deployment의 `labelSelector` 등 변경 불가능한 필드를 수정하려 함.
- **해결**: 기존 리소스 삭제 후 재배포 (`helm uninstall` -> `install`) 또는 해당 필드 변경 취소.

### 5-2. `Release Stuck` (Pending-install/upgrade)
- **현상**: 헬름 명령어가 멈춰있음.
- **원인**: 이전 배포가 실패하고 락(Lock)이 걸림.
- **해결**: `helm rollback <release> 0` 또는 Secret에서 헬름 상태 삭제.

### 5-3. `Values Not Applied`
- **현상**: `values.yaml` 수정했는데 반영 안 됨.
- **원인**: `--reuse-values` 옵션 사용 오해, 템플릿 문법 오류.
- **해결**: `helm template --debug`로 렌더링 결과 확인.

### 5-4. `CRD Conflict`
- **현상**: CRD가 이미 존재하여 설치 실패.
- **원인**: 헬름은 기본적으로 CRD를 업그레이드/삭제하지 않음.
- **해결**: 수동으로 CRD 관리(`kubectl apply`).

### 5-5. `Tiller Error` (Legacy)
- **현상**: Helm v2 연결 실패.
- **원인**: Tiller 파드 문제.
- **해결**: **Helm v3로 업그레이드 필수** (Tiller 없음).

---

## 🔍 Good vs Bad Troubleshooting Habits

### ❌ Bad Practice
- **파드 이름만 보고 판단**: `CrashLoopBackOff`만 보고 바로 파드를 지웠다가 다시 띄운다. (로그 확인 안 함).
- **무조건 권한 부여**: RBAC 에러 나면 `cluster-admin` 권한을 줘버린다.
- **YAML 직접 수정**: 헬름으로 배포한 리소스를 `kubectl edit`으로 수정한다. (다음 배포 때 덮어써짐).

### ✅ Good Practice
- **Describe & Logs**: `kubectl describe`로 이벤트를 보고, `logs`로 애플리케이션 상태를 본다.
- **격리 테스트**: 문제가 생기면 `kubectl run --rm -it debug --image=busybox` 등을 띄워 네트워크/DNS를 테스트한다.
- **IaC 준수**: 모든 변경사항은 Git(Manifest/Helm Chart)에 먼저 반영하고 배포한다.
