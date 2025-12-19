# Kubectl Cheatsheet (Kubernetes CLI)

> 쿠버네티스 클러스터 상태를 확인하고 리소스를 관리하는 핵심 도구입니다.

## 1. 리소스 조회 (Get & Describe)
클러스터의 현재 상태를 파악합니다.

```bash
# 모든 네임스페이스의 파드 조회
kubectl get pods --all-namespaces

# 특정 파드의 상세 정보 확인 (이벤트, 에러 원인 파악용)
kubectl describe pod <pod_name>

# 노드 상태 및 IP 확인
kubectl get nodes -o wide
```

## 2. 로그 및 디버깅
```bash
# 파드 로그 확인 (실시간)
kubectl logs -f <pod_name>

# 파드 내부 쉘 접속
kubectl exec -it <pod_name> -- /bin/bash

# 로컬 포트를 파드 포트로 포워딩 (디버깅용)
kubectl port-forward <pod_name> 8080:80
```

## 3. 리소스 생성 및 관리
YAML 파일을 사용하여 선언적으로 관리합니다.

```bash
# YAML 파일로 리소스 생성/업데이트
kubectl apply -f deployment.yaml

# 리소스 삭제
kubectl delete -f deployment.yaml
# 또는 이름으로 삭제
kubectl delete pod <pod_name>
```

## 4. 컨텍스트 설정 (Config)
여러 클러스터를 관리할 때 사용합니다.

```bash
# 현재 컨텍스트 확인
kubectl config current-context

# 컨텍스트 변경 (클러스터 전환)
kubectl config use-context my-cluster
```
