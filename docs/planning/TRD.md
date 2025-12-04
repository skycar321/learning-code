# Platform Enhancement TRD

**Date**: 2025-12-04
**Author**: Gemini (Planner)
**Target**: `platform` (Rust/Axum Engine)
**Status**: Approved

## 1. Overview
This document defines the technical requirements for upgrading the `learning-code` platform to improve user experience and navigation.

## 2. Requirements

### 2.1 Dark Mode Support
*   **Goal**: Allow users to switch between Light and Dark themes.
*   **Tech**: Tailwind CSS (Class strategy), LocalStorage.
*   **Implementation**:
    *   Add `darkMode: 'class'` to Tailwind config in `base.html`.
    *   Add a Toggle Button in the Sidebar or Header.
    *   Persist preference in `localStorage('theme')`.
    *   Apply `dark:bg-slate-900`, `dark:text-slate-200` classes globally.

### 2.2 Sequential Navigation
*   **Goal**: "Previous" and "Next" buttons at the bottom of each content page.
*   **Tech**: Rust (`main.rs`), Askama (`content.html`).
*   **Logic**:
    *   Flatten the `categories -> subcategories -> files` structure.
    *   Identify current file index `i`.
    *   Resolve `i-1` and `i+1` as Next/Prev links.
    *   Pass `Option<FileMeta>` for prev/next to the template.

### 2.3 Search Optimization (Client-Side)
*   **Goal**: Improve the current sidebar search.
*   **Tech**: Vanilla JS (`base.html`).
*   **Features**:
    *   Keyboard Shortcut: `Ctrl+K` / `Cmd+K` to focus search.
    *   Highlight matching text (optional).
    *   Persist search term (optional).

## 3. Architecture Changes

### `src/main.rs`
*   **Struct Update**:
    ```rust
    struct ContentTemplate {
        // ... existing fields
        prev_file: Option<FileLink>, // New
        next_file: Option<FileLink>, // New
    }
    
    struct FileLink {
        title: String,
        url: String,
    }
    ```
*   **Logic Update**:
    *   Modify `content_handler` to calculate neighbors. This might require caching the file list or rebuilding it efficiently. Given the small size, rebuilding or a shared state lookup is acceptable.

### `templates/base.html`
*   **Script**: Add Tailwind config and Theme toggle logic.
*   **UI**: Update colors to support `dark:` prefix.

### `templates/content.html`
*   **UI**: Add Bottom Navigation Bar (Prev/Next buttons).

## 4. Verification Plan
*   **Manual Test**: Toggle theme, Navigate through steps 1->2->3.
*   **Automated**: Unit test `build_navigation` ordering (if logic is extracted).
