# Kubernetes Top 50 Troubleshooting Guide

This guide covers the 50 most common errors encountered in Kubernetes environments, categorized by component. Each entry includes symptoms, diagnosis commands, root causes, and solutions.

---

## 1. Pod Issues

### 1. CrashLoopBackOff
- **Symptoms**: Pod status cycles between `Running` and `CrashLoopBackOff`.
- **Diagnosis**: `kubectl logs <pod-name> --previous`, `kubectl describe pod <pod-name>`
- **Root Cause**: Application crash (panic/exception), Misconfigured Liveness Probe, Missing config/secret.
- **Solution**: Fix application code, adjust probe `initialDelaySeconds`, ensure dependencies exist.

### 2. ImagePullBackOff / ErrImagePull
- **Symptoms**: Pod stuck in `Pending` or `ImagePullBackOff`.
- **Diagnosis**: `kubectl describe pod <pod-name>` (Check Events).
- **Root Cause**: Invalid image name/tag, private registry authentication failure (missing `imagePullSecrets`).
- **Solution**: Correct image name, create/link Docker registry secret.

### 3. Pending (Scheduling Failed)
- **Symptoms**: Pod status remains `Pending` indefinitely.
- **Diagnosis**: `kubectl describe pod <pod-name>`
- **Root Cause**: Insufficient cluster resources (CPU/RAM), Taint/Toleration mismatch, NodeSelector unsatisfied.
- **Solution**: Scale up cluster, adjust resource requests, fix node affinity/tolerations.

### 4. CreateContainerConfigError
- **Symptoms**: Pod status `CreateContainerConfigError`.
- **Diagnosis**: `kubectl describe pod <pod-name>`
- **Root Cause**: Missing ConfigMap or Secret referenced in `env` or `volumes`.
- **Solution**: Create the missing ConfigMap/Secret or fix the reference name.

### 5. OOMKilled (Exit Code 137)
- **Symptoms**: Container restarts with "OOMKilled" in `kubectl describe pod`.
- **Diagnosis**: `kubectl top pod`, Check `resources.limits.memory`.
- **Root Cause**: Application memory leak or insufficient memory limit.
- **Solution**: Increase memory limit, debug memory leak.

### 6. RunContainerError
- **Symptoms**: Container fails to start immediately.
- **Diagnosis**: `kubectl describe pod <pod-name>`
- **Root Cause**: Volume mount permission denied, Read-only filesystem, executable permission missing.
- **Solution**: Check volume permissions, ensure container user has access.

### 7. Pod Stuck Terminating
- **Symptoms**: Pod stuck in `Terminating` state for a long time.
- **Diagnosis**: `kubectl get pod <pod-name> -o yaml` (Check `finalizers`).
- **Root Cause**: Finalizer preventing deletion (e.g., PVC protection, LoadBalancer cleanup).
- **Solution**: Fix the underlying resource or force delete (Last resort: `kubectl delete pod <pod> --grace-period=0 --force`).

### 8. Liveness/Readiness Probe Failed
- **Symptoms**: Pod restarts frequently (Liveness) or is removed from Service endpoints (Readiness).
- **Diagnosis**: `kubectl describe pod` (Events).
- **Root Cause**: Probe timeout, wrong path/port, app startup too slow.
- **Solution**: Increase `initialDelaySeconds` and `failureThreshold`.

### 9. InitContainerCrash
- **Symptoms**: Pod status `Init:CrashLoopBackOff`.
- **Diagnosis**: `kubectl logs <pod-name> -c <init-container-name>`
- **Root Cause**: Pre-requisite check failed (DB connection, script error).
- **Solution**: Fix init script, ensure dependencies are ready.

### 10. Evicted
- **Symptoms**: Pod status `Evicted`.
- **Diagnosis**: `kubectl describe pod` (Message: "The node was low on resource...").
- **Root Cause**: Node disk pressure or memory pressure.
- **Solution**: Free up node resources, add autoscaling.

---

## 2. Node Issues

### 11. Node NotReady
- **Symptoms**: `kubectl get nodes` shows `NotReady`.
- **Diagnosis**: `kubectl describe node <node>`, SSH to node & check `kubelet` logs.
- **Root Cause**: Kubelet stopped, Network partition, Disk pressure.
- **Solution**: Restart kubelet, check network, clean up disk space.

### 12. Node DiskPressure
- **Symptoms**: Pods evicted, Node condition `DiskPressure=True`.
- **Diagnosis**: `df -h` on node.
- **Root Cause**: Logs/Images filling up `/var/lib/docker`.
- **Solution**: `docker image prune`, setup log rotation.

### 13. Node MemoryPressure
- **Symptoms**: Node condition `MemoryPressure=True`, OOM kills.
- **Diagnosis**: `free -m`, `top`.
- **Root Cause**: System processes or Pods without limits consuming RAM.
- **Solution**: Set limits on all Pods, upgrade Node.

### 14. PIDPressure
- **Symptoms**: Node condition `PIDPressure=True`, cannot start new processes.
- **Diagnosis**: `sysctl kernel.pid_max`.
- **Root Cause**: Too many processes/threads (Zombie processes).
- **Solution**: Increase `pid_max`, debug process leaking apps.

### 15. NetworkUnavailable
- **Symptoms**: Node condition `NetworkUnavailable=True`.
- **Diagnosis**: Check CNI logs (Calico/Flannel/AWS-CNI).
- **Root Cause**: CNI plugin failed to initialize, route table full.
- **Solution**: Restart CNI pods, check overlay network config.

### 16. Kubelet Certificate Expired
- **Symptoms**: Node `NotReady`, logs show "certificate verify failed".
- **Diagnosis**: Check certificate dates in `/etc/kubernetes/pki`.
- **Root Cause**: Auto-renewal failed.
- **Solution**: `kubeadm certs renew` or restart kubelet to trigger renewal.

### 17. Clock Skew (Time Sync)
- **Symptoms**: TLS errors, strange log timestamps.
- **Diagnosis**: Compare `date` across nodes.
- **Root Cause**: NTP service failed.
- **Solution**: Enable/Restart `ntpd` or `chronyd`.

### 18. High Load Average
- **Symptoms**: Node slow, timeouts.
- **Diagnosis**: `uptime`, `top`.
- **Root Cause**: CPU saturation (Steal time in cloud).
- **Solution**: Drain node, investigate high CPU pods.

---

## 3. Network Issues

### 19. Service Endpoint Empty
- **Symptoms**: Service exists but cannot connect; `kubectl get endpoints` is empty.
- **Diagnosis**: `kubectl get pods --show-labels`.
- **Root Cause**: Service `selector` does not match Pod `labels`.
- **Solution**: Fix labels in Service definition.

### 20. DNS Resolution Failed
- **Symptoms**: `Could not resolve host: google.com` inside Pod.
- **Diagnosis**: `nslookup kubernetes.default`, Check CoreDNS logs.
- **Root Cause**: CoreDNS down, Node DNS config (`/etc/resolv.conf`) wrong.
- **Solution**: Scale CoreDNS, fix node DNS.

### 21. Service Connection Refused
- **Symptoms**: `curl` to Service IP fails immediately.
- **Diagnosis**: Check target container port listening status.
- **Root Cause**: Container not listening on the configured port.
- **Solution**: Ensure app listens on `0.0.0.0`, match `targetPort` in Service.

### 22. Gateway Timeout (504)
- **Symptoms**: Ingress returns 504.
- **Diagnosis**: Check Ingress Controller logs.
- **Root Cause**: Upstream (Pod) slow response or timeout too short.
- **Solution**: Optimize app, increase Ingress proxy timeout annotations.

### 23. LoadBalancer IP Pending
- **Symptoms**: Service `EXTERNAL-IP` is `<pending>` forever.
- **Diagnosis**: `kubectl describe svc`.
- **Root Cause**: Cloud Provider Quota exceeded, Controller Manager issue.
- **Solution**: Request quota increase, check Cloud Controller logs.

### 24. CNI IP Exhaustion
- **Symptoms**: Pods stuck in `ContainerCreating` with "failed to assign IP".
- **Diagnosis**: Check AWS-CNI/Calico IP pool.
- **Root Cause**: Subnet ran out of IP addresses.
- **Solution**: Add secondary CIDR, delete unused Pods.

### 25. NetworkPolicy Blocking
- **Symptoms**: Connection timeout between specific Pods.
- **Diagnosis**: `kubectl get networkpolicy`.
- **Root Cause**: `DefaultDeny` policy exists but no `Allow` rule.
- **Solution**: Add NetworkPolicy to allow specific traffic.

### 26. NodePort Inaccessible
- **Symptoms**: Can't access `<NodeIP>:<NodePort>`.
- **Diagnosis**: `netstat -tulnp` on Node, Security Groups.
- **Root Cause**: Firewall/Security Group blocking port range (30000-32767).
- **Solution**: Open firewall ports.

---

## 4. Storage Issues

### 27. PVC Pending (Binding Failed)
- **Symptoms**: PVC status `Pending`.
- **Diagnosis**: `kubectl describe pvc`.
- **Root Cause**: No matching PV, StorageClass provisioner error.
- **Solution**: Check StorageClass default, check provisioner logs.

### 28. Multi-Attach Error
- **Symptoms**: Pod creation fails with "Volume is already attached by pod X".
- **Diagnosis**: `kubectl describe pod`.
- **Root Cause**: `ReadWriteOnce` volume cannot be mounted on two Nodes.
- **Solution**: Use `ReadWriteMany` (NFS) or ensure Pods schedule on same Node (not recommended for HA).

### 29. MountPermissionDenied
- **Symptoms**: Pod starts but app crashes reading file.
- **Diagnosis**: `ls -l` in container.
- **Root Cause**: Volume mounted as root, container running as non-root (`securityContext`).
- **Solution**: Use `fsGroup` in `securityContext` or `initContainer` to `chown`.

### 30. PV Reclamation Failed
- **Symptoms**: PV stuck in `Released` but not Available.
- **Diagnosis**: `kubectl get pv`.
- **Root Cause**: `persistentVolumeReclaimPolicy` is `Retain`.
- **Solution**: Manually clean up data and delete PV, or change policy to `Delete`.

---

## 5. Security & RBAC

### 31. Forbidden (403)
- **Symptoms**: App logs "User ... cannot list resource ...".
- **Diagnosis**: `kubectl auth can-i list pods --as=system:serviceaccount:ns:sa`.
- **Root Cause**: Missing Role/RoleBinding.
- **Solution**: Create RoleBinding granting necessary permissions.

### 32. Secret Not Found
- **Symptoms**: Pod fails to start, "secret not found".
- **Diagnosis**: `kubectl get secret`.
- **Root Cause**: Secret in different Namespace (Secrets are namespaced).
- **Solution**: Copy secret to Pod's namespace.

### 33. ServiceAccount Token Mount Failed
- **Symptoms**: Pod fails with "serviceaccount token invalid".
- **Root Cause**: `automountServiceAccountToken: false` or API server issue.
- **Solution**: Check SA configuration.

---

## 6. Deployment & Autoscaling

### 34. HPA Not Scaling
- **Symptoms**: Replicas do not increase under load.
- **Diagnosis**: `kubectl get hpa`.
- **Root Cause**: Metrics Server missing, Target value too high.
- **Solution**: Install `metrics-server`, adjust target utilization.

### 35. RollingUpdate Stuck
- **Symptoms**: Deployment hangs, old pods not terminating.
- **Diagnosis**: `kubectl rollout status deploy`.
- **Root Cause**: `maxUnavailable` is 0 or new pods failing readiness.
- **Solution**: Fix readiness probe, check `strategy`.

### 36. Job Completion Failed (BackoffLimitExceeded)
- **Symptoms**: Job status `Failed`.
- **Root Cause**: App logic error, exit code non-zero.
- **Solution**: Debug app logic, increase `backoffLimit`.

### 37. CronJob Not Starting
- **Symptoms**: Scheduled time passed, no Job created.
- **Diagnosis**: Controller manager logs.
- **Root Cause**: `concurrencyPolicy: Forbid` and previous job stuck.
- **Solution**: Fix stuck job or change policy to `Allow`/`Replace`.

---

## 7. Advanced / Miscellaneous

### 38. ETCD Database Full
- **Symptoms**: API Server rejects writes, "etcdserver: mvcc: database space exceeded".
- **Solution**: Defrag etcd (`etcdctl defrag`).

### 39. Custom Resource Definition (CRD) Missing
- **Symptoms**: Cannot create custom resource.
- **Solution**: Install required CRD.

### 40. Webhook Timeout
- **Symptoms**: `kubectl apply` times out.
- **Root Cause**: Validating/Mutating Admission Webhook down.
- **Solution**: Delete broken Webhook configuration or fix webhook service.

### 41. Ingress Class Mismatch
- **Symptoms**: Ingress created but no Address assigned.
- **Root Cause**: Missing `ingressClassName`.
- **Solution**: Specify correct class (e.g., `nginx`).

### 42. Zombie Processes (Reaping)
- **Symptoms**: PID exhaustion inside container.
- **Solution**: Use `tini` as init process (Entrypoint).

### 43. Ephemeral Storage Exhaustion
- **Symptoms**: Pod evicted.
- **Root Cause**: App writing too much to `/tmp` or logs (overlay fs).
- **Solution**: Use `emptyDir` with `sizeLimit` or mount PVC.

### 44. Too Many Open Files
- **Symptoms**: App crash "Too many open files".
- **Solution**: Increase `ulimit` (nofile) in Node/Container.

### 45. IPVS Connection Reset
- **Symptoms**: Intermittent connection resets.
- **Solution**: Tune `sysctl` connection tracking settings.

### 46. ARP Cache Overflow
- **Symptoms**: Network unreachable on large clusters.
- **Solution**: Increase GC threshold for ARP entries in kernel.

### 47. CPU Throttling (CFS Quota)
- **Symptoms**: App slow despite low CPU usage.
- **Solution**: Disable CFS Quota or increase CPU limits appropriately.

### 48. PreStop Hook Failed
- **Symptoms**: Pod stuck terminating.
- **Solution**: Fix PreStop script logic.

### 49. Sidecar Startup Order
- **Symptoms**: Main app fails because Proxy/DB sidecar not ready.
- **Solution**: Use Kubernetes 1.29+ SidecarContainer feature or startup scripts.

### 50. ConfigMap Immutable
- **Symptoms**: Cannot update ConfigMap.
- **Root Cause**: `immutable: true` set.
- **Solution**: Delete and recreate ConfigMap.