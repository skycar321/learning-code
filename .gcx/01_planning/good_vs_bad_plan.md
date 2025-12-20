★ 인사이트 ─────────────────────────────────────
1. 기존 자료들은 기초 개념 위주이며, Troubleshooting 가이드는 문제 해결 중심
2. 'Good vs Bad' 코드 예제는 **실무 안티패턴 방지**에 초점을 맞춰야 기존 자료와 차별화됨
3. 각 기술별로 **Troubleshooting 가이드에서 언급된 문제들을 코드로 시연**하면 학습 효과 극대화
─────────────────────────────────────────────────

이제 종합적인 분석을 바탕으로 각 기술별 'Good vs Bad' 파일 주제를 제안해 드리겠습니다.

---

# Good vs Bad Code Examples - Proposed Topics

## 1. Spring Boot (Java)

### File 1: `Step16_LayeredArchitecture_GoodBad.java`
**Focus**: Architecture - Clean Layered vs Fat Controller Anti-Pattern

| Aspect | Bad Example | Good Example |
|--------|------------|--------------|
| **Structure** | Controller with business logic, direct repository calls, no service layer | Proper Controller → Service → Repository layering |
| **Issues Shown** | Violates SRP, untestable, tight coupling | Loose coupling, testable units, clear responsibilities |
| **Key Pattern** | "Fat Controller" anti-pattern | "Thin Controller, Rich Service" pattern |

### File 2: `Step17_DI_Pitfalls_GoodBad.java`  
**Focus**: Dependency Injection - Runtime Failures vs Compile-Time Safety

| Aspect | Bad Example | Good Example |
|--------|------------|--------------|
| **Pattern** | Circular dependency with `@Lazy` workaround, field injection in tests | Proper dependency design, constructor injection |
| **Issues Shown** | Hidden circular refs, `@Qualifier` misuse, null at runtime | Early failure detection, immutable dependencies |
| **Key Pattern** | "Circular Dependency Smell" | "Dependency Acyclic Graph" |

### File 3: `Step18_ExceptionStrategy_GoodBad.java`
**Focus**: Exception Handling - Stack Trace Leakage vs Secure Error Responses

| Aspect | Bad Example | Good Example |
|--------|------------|--------------|
| **Pattern** | Catching `Exception`, returning raw stack traces, no error codes | Custom exception hierarchy, `@RestControllerAdvice`, sanitized responses |
| **Issues Shown** | Security vulnerability, inconsistent API responses, swallowed exceptions | Consistent error DTO, proper logging, client-friendly messages |
| **Key Pattern** | "Pokemon Exception Handling" (catch 'em all!) | "Exception Translation Pattern" |

---

## 2. React (JavaScript/TypeScript)

### File 1: `Step11_UseEffect_GoodBad.jsx`
**Focus**: useEffect Hook - Infinite Loops & Memory Leaks vs Proper Side Effects

| Aspect | Bad Example | Good Example |
|--------|------------|--------------|
| **Pattern** | Missing dependency array, no cleanup, state in deps causing loops | Correct deps, AbortController for fetch, cleanup functions |
| **Issues Shown** | Browser freeze, memory leaks, stale closure bugs | Predictable behavior, resource cleanup, memoized callbacks |
| **Key Pattern** | "useEffect Infinite Loop" & "Memory Leak" | "Exhaustive Deps with Cleanup" |

### File 2: `Step12_PropsDrilling_GoodBad.jsx`
**Focus**: Props Drilling - Prop Chain Hell vs State Management Solutions

| Aspect | Bad Example | Good Example |
|--------|------------|--------------|
| **Pattern** | 5+ level prop passing, intermediate components with unused props | Context API, Zustand/Redux for global state, composition pattern |
| **Issues Shown** | Maintenance nightmare, tight coupling, unnecessary re-renders | Clean component boundaries, scalable state management |
| **Key Pattern** | "Props Drilling Anti-Pattern" | "Inversion of Control with Context" |

### File 3: `Step13_RenderingOptimization_GoodBad.jsx`
**Focus**: Rendering - Unnecessary Re-renders vs Performance Optimization

| Aspect | Bad Example | Good Example |
|--------|------------|--------------|
| **Pattern** | Inline object/function in props, missing `key`, large list without virtualization | `useMemo`, `useCallback`, `React.memo`, proper keys, react-window |
| **Issues Shown** | Laggy UI, dropped frames, wasted reconciliation | Smooth 60fps, optimized bundle, efficient list rendering |
| **Key Pattern** | "Render Prop Hell" & "Re-render Cascade" | "Memoization Strategy Pattern" |

---

## 3. Kubernetes (YAML)

### File 1: `Step6_ResourceManagement_GoodBad.yaml`
**Focus**: Deployment YAMLs - Resource Starvation vs Proper Resource Allocation

| Aspect | Bad Example | Good Example |
|--------|------------|--------------|
| **Pattern** | No `resources.requests/limits`, unbounded memory, missing QoS class | Proper CPU/memory limits, Guaranteed QoS, resource quotas |
| **Issues Shown** | OOMKilled, Evicted pods, noisy neighbor problem | Predictable scheduling, fair resource sharing, stable pods |
| **Key Pattern** | "Resource Amnesia" | "Resource-Aware Deployment" |

### File 2: `Step7_ProbeConfiguration_GoodBad.yaml`
**Focus**: Health Probes - Misconfigured Probes vs Production-Ready Probes

| Aspect | Bad Example | Good Example |
|--------|------------|--------------|
| **Pattern** | Wrong probe path, aggressive timeouts, missing startup probe | Correct health endpoints, tuned delays, all three probe types |
| **Issues Shown** | CrashLoopBackOff, premature traffic routing, slow startup killed | Graceful startups, accurate health status, proper traffic gating |
| **Key Pattern** | "Probe Misconfiguration" | "Progressive Health Check Pattern" |

### File 3: `Step8_SecurityContext_GoodBad.yaml`
**Focus**: Security - Root Container vs Hardened Pod Security

| Aspect | Bad Example | Good Example |
|--------|------------|--------------|
| **Pattern** | Running as root, no `securityContext`, `hostNetwork: true`, all capabilities | Non-root user, read-only fs, dropped capabilities, network policies |
| **Issues Shown** | Container escape risk, privilege escalation, compliance failures | Defense in depth, least privilege, audit-ready |
| **Key Pattern** | "Privileged Pod Anti-Pattern" | "Zero Trust Pod Security" |

---

## Summary Table

| Technology | File Name | Core Anti-Pattern | Core Best Practice |
|------------|-----------|-------------------|-------------------|
| **Spring Boot** | Step16_LayeredArchitecture_GoodBad.java | Fat Controller | Thin Controller, Rich Service |
| **Spring Boot** | Step17_DI_Pitfalls_GoodBad.java | Circular Dependency | Acyclic Dependency Graph |
| **Spring Boot** | Step18_ExceptionStrategy_GoodBad.java | Pokemon Exception Handling | Exception Translation |
| **React** | Step11_UseEffect_GoodBad.jsx | Infinite Loop & Memory Leak | Exhaustive Deps with Cleanup |
| **React** | Step12_PropsDrilling_GoodBad.jsx | Props Drilling | Context/Composition Pattern |
| **React** | Step13_RenderingOptimization_GoodBad.jsx | Re-render Cascade | Memoization Strategy |
| **Kubernetes** | Step6_ResourceManagement_GoodBad.yaml | Resource Amnesia | Resource-Aware Deployment |
| **Kubernetes** | Step7_ProbeConfiguration_GoodBad.yaml | Probe Misconfiguration | Progressive Health Check |
| **Kubernetes** | Step8_SecurityContext_GoodBad.yaml | Privileged Pod | Zero Trust Pod Security |

---

## Implementation Priority Recommendation

1. **High Priority** (직접적인 장애 유발):
   - Kubernetes: Resource Management, Probe Configuration
   - React: useEffect patterns
   - Spring Boot: Exception Strategy

2. **Medium Priority** (유지보수성/확장성):
   - Spring Boot: Layered Architecture
   - React: Props Drilling
   - Kubernetes: Security Context

3. **Foundation** (기존 자료 보완):
   - Spring Boot: DI Pitfalls (Step2 확장)
   - React: Rendering Optimization (Step10 확장)

---

이 제안이 괜찮으시다면, 어떤 기술부터 구현을 시작할지 말씀해 주세요! 🚀
