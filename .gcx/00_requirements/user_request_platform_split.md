# User Request: Platform Architecture Split (Next.js + Rust)
**Date**: 2025-12-16
**Protocol**: GCX v3.5

## Goals
1. **Architecture Split**: Separate existing `platform/` into:
   - `platform/backend` (Rust): Serve JSON API only.
   - `platform/frontend` (Next.js): UI rendering with Sidebar navigation.
2. **Design**: Modern UI based on `@ui-sample` (or best practice dashboard).
   - Sidebar: Tree view of learning contents.
   - Main: Markdown content rendering.
3. **Quality**: Detailed Korean comments for beginners.

## Roles
- **Claude Opus**: Architect (API Schema, Component Structure).
- **Codex Max**: Implementation (Rust Refactoring, React Components).
- **Gemini**: Translation & Integration.
