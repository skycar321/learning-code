# PROJECT REORGANIZATION & RUST PLATFORM PLAN

## 1. Project Structure Reorganization
Current flat structure creates clutter. We will move learning materials into a structured `content` directory.

### New Directory Layout
```text
learning-code/
├── content/                     # [NEW] All learning materials
│   ├── languages/
│   │   ├── java/
│   │   ├── python/
│   │   ├── rust/
│   │   └── ... (golang, kotlin, javascript, typescript)
│   ├── infrastructure/
│   │   ├── docker/
│   │   ├── kubernetes/
│   │   └── ... (aws, azure, argocd, jenkins, linux_command, nginx, git_cli)
│   ├── frameworks/
│   │   ├── springboot/
│   │   ├── react/
│   │   └── ... (vue2, vue3, nextjs, nestjs, flutter, springbatch)
│   └── tools/
│       ├── gradle/
│       ├── maven/
│       └── ... (postgresql, swagger, webpack)
├── platform/                    # [NEW] Rust Web Application
│   ├── src/
│   ├── Cargo.toml
│   ├── assets/
│   └── templates/
├── scripts/                     # Maintenance scripts (python scripts move here)
└── README.md
```

## 2. Rust Web Platform Architecture

### Goal
Render the markdown content from the `content/` directory in a web interface with a sidebar navigation.

### Tech Stack
- **Language:** Rust
- **Web Framework:** **Axum** (High performance, ergonomic, modular)
- **Template Engine:** **Askama** (Type-safe, compiled Jinja-like templates)
- **Markdown Parser:** **pulldown-cmark** (Fast Markdown rendering)
- **Styling:** Tailwind CSS (served as static asset or via CDN for simplicity)
- **Interaction:** **HTMX** (For SPA-like navigation without complex JS)

### Feature Requirements
1.  **Sidebar Navigation:** Dynamically reads the `content/` directory structure to build the category tree.
2.  **Content Rendering:** Clicking a category/topic loads the Markdown file, converts it to HTML, and displays it in the main view.
3.  **Hot Reload:** (Optional for Dev) Watch for content changes.

### Implementation Steps
1.  **Move Files:** Execute shell commands to reorganize folders into `content/...`.
2.  **Init Rust Project:** `cargo new platform`.
3.  **Dependencies:** Add `axum`, `tokio`, `askama`, `pulldown-cmark`, `serde`.
4.  **Core Logic:**
    - File system walker to build the navigation tree.
    - Handler to serve the index page with the tree.
    - Handler to read a specific MD file and render the content template.

## 3. Action Items
1.  Confirm this plan with Codex.
2.  Execute file moves.
3.  Initialize Rust project and implement basic server.
