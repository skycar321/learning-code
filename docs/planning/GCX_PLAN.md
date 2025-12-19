# GCX Project Plan: Learning Platform Optimization

**Date**: 2025-12-04
**Author**: Gemini (Planner)
**Status**: Phase 3: Content Expansion
**Target**: `learning-code` Project

---

## 1. Current State Analysis
*   **Critical Issue**: The `docs/` directory appears to be empty (Data Loss/Sync Error). `LEARNING_PROGRESS.md` and other planning documents are missing.
*   **Platform (Rust)**:
    *   Functional Axum server.
    *   Modern UI with Tailwind CSS (CDN).
    *   Basic client-side search implemented in `base.html`.
    *   Missing: Dark mode toggle, Server-side search, Testing, SEO metadata.
*   **Content**:
    *   Structured in `content/{category}/{subcategory}/{step}.md`.
    *   Needs a comprehensive audit to identify empty or skeleton files.

## 2. Strategic Roadmap

### Phase 1: Restoration & Foundation (Completed)
*   **Goal**: Restore planning documents and map the current content state.
*   **Tasks**:
    1.  **[Completed]** Re-create `docs/LEARNING_PROGRESS.md` by scanning `content/` directory.
    2.  **[Completed]** Create `docs/planning/TRD.md` (Technical Requirement Doc) for the Platform.
    3.  **[Completed]** Audit `content/` for incomplete learning plans.

### Phase 2: Platform Engineering (Rust/Axum) (Completed)
*   **Goal**: Enhance the reading experience and maintainability.
*   **Tasks**:
    1.  **[Completed]** UI: Implement **Dark Mode** toggle (System preference is currently ignored/default light).
    2.  **[Completed]** Nav: Add "Previous/Next" navigation buttons in `content.html`.
    3.  **[Completed]** Search: Optimize search (Client-side shortcut `Cmd+K` added).
    4.  **[Completed]** Quality: Add unit tests for `main.rs` (Router logic, Template rendering).

### Phase 3: Content Expansion (In Progress)
*   **Goal**: Fill the gaps in the learning curriculum.
*   **Findings**: Scan completed. No empty (<50b) markdown files found. Most code files are populated. Small files identified are mostly assets or config files.
*   **Tasks**:
    1.  **[Completed]** Identify "Step" files that are 0 bytes or contain only TODOs.
    2.  **[In Progress]** Generate missing content using Gemini (Builder).
        *   **[Completed]** Expanded `tools/swagger` (Steps 2-4 + Advanced Guide).

---

## 3. Immediate Action Plan (Next Steps)

1.  **Verification & Next Topic**:
    *   User to verify Swagger content.
    *   Select next topic for expansion (e.g., `frameworks/springbatch` or `devops/argocd`).

## 4. Architecture Notes (GCX)
*   **Builder**: Gemini (Content Gen, HTML/CSS, Rust Logic).
*   **Auditor**: Codex (Review Rust code, Verify Content correctness).
*   **Orchestrator**: Claude (Manage the timeline).
