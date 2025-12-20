# User Request: Add Airflow Learning Content

**Date**: 2025-12-12
**Requester**: User
**Project**: Learning Platform Content Expansion
**Protocol Version**: GCX v3.1

## Original Request
"gcx프로토콜 사용. 클로드코드는 opus모델사용. codex는 max 5.1 ehigh 사용 . 이프로젝트에 air flow도 학습내용에 추가하고싶어. 최대한 자세히 작성해줘"

## Clarified Requirements
1.  **Objective**: Add a comprehensive learning module for **Apache Airflow** to the `content/devops/` directory.
2.  **Depth**: "As detailed as possible" - This implies covering basics, installation, DAG creation, operators, scheduling, monitoring, and potentially advanced topics like KubernetesExecutor or scaling.
3.  **Structure**: Follow the existing repository pattern:
    *   `airflow_learning_plan.md`: Curriculum overview.
    *   `Step1_...`: Introduction & Basics.
    *   `Step2_...`: Installation & Setup.
    *   `Step3_...`: Core Concepts (DAGs, Operators).
    *   `Step4_...`: Advanced Features.
    *   `Step5_...`: Operations & Best Practices.
4.  **Models**:
    *   Claude: Opus (for high-quality explanations and curriculum design).
    *   Codex: Max 5.1 ehigh (for accurate code examples, docker-compose files, and DAG scripts).
5.  **Protocol**: GCX v3.1 (Strict file-based handoff, multi-stage verification).

## Functional Requirements (Content)
- [ ] **Introduction**: What is Airflow, Architecture (Scheduler, Webserver, Worker, DB).
- [ ] **Setup**: Docker Compose setup for local development.
- [ ] **Core**: Writing DAGs (Python), Operators (Bash, Python, etc.), Scheduling (Cron presets).
- [ ] **Advanced**: XComs, Variables, Connections, Sensors, Hooks.
- [ ] **Executor Modes**: Sequential, Local, Celery, Kubernetes (Conceptual/Config).
- [ ] **Best Practices**: Idempotency, dynamic DAG generation, testing DAGs.

## Non-Functional Requirements
- **Format**: Markdown (`.md`) for guides, Python (`.py`) for DAG examples, YAML for config.
- **Language**: Korean (Instruction/Explanation), English (Code/Technical Terms).
- **Quality**: High-quality, verified code examples.

## Scope
**In Scope**:
- Airflow Core Concepts
- Local Development Setup
- Standard Operators
- Best Practices

**Out of Scope** (unless requested later):
- Cloud-managed Airflow specific details (MWAA, Cloud Composer) - *General concepts will be covered, but vendor-specific setup might be secondary unless "detailed" implies this too.* (Will stick to Open Source Airflow first).
