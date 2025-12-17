use axum::{
    extract::{Path as UrlPath, State},
    response::{IntoResponse, Json},
    routing::get,
    Router,
};
use std::{
    sync::Arc,
    path::{PathBuf, Path},
    fs,
};
use tower_http::cors::{CorsLayer, Any};
use tower_http::trace::TraceLayer;
use tower_http::services::ServeDir;
use serde::{Serialize, Deserialize};

// ========================================================================================
// State Management
// ========================================================================================

#[derive(Clone)]
struct AppState {
    content_root: PathBuf,
}

// ========================================================================================
// Data Models (JSON DTOs)
// ========================================================================================

#[derive(Clone, Debug, Serialize, Deserialize)]
struct FileMeta {
    name: String,
    title: String,
    path: String, // Full relative path for API calls
}

#[derive(Clone, Debug, Serialize, Deserialize)]
struct SubCategory {
    name: String,
    files: Vec<FileMeta>,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
struct Category {
    name: String,
    subcategories: Vec<SubCategory>,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
struct ContentResponse {
    title: String,
    content: String, // Raw Markdown or Code text
    file_type: String, // "markdown" or "code"
    prev: Option<FileMeta>,
    next: Option<FileMeta>,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
struct ErrorResponse {
    error: String,
}

// ========================================================================================
// Entry Point
// ========================================================================================

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt::init();

    let content_path = std::env::var("CONTENT_ROOT").unwrap_or_else(|_| "../content".to_string());
    
    let state = Arc::new(AppState {
        content_root: PathBuf::from(content_path),
    });

    // CORS Configuration: Allow All for Dev (Restrict in Prod)
    let cors = CorsLayer::new()
        .allow_origin(Any)
        .allow_methods(Any)
        .allow_headers(Any);

    let app = Router::new()
        .route("/api/tree", get(api_tree_handler))
        .route("/api/content/*path", get(api_content_handler)) // Wildcard for path
        .nest_service("/static", ServeDir::new("static"))
        .layer(cors)
        .layer(TraceLayer::new_for_http())
        .with_state(state);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:8080").await.unwrap();
    println!("Backend API listening on http://0.0.0.0:8080");
    axum::serve(listener, app).await.unwrap();
}

// ========================================================================================
// Helpers
// ========================================================================================

fn build_navigation(root: &Path) -> Vec<Category> {
    let mut categories = Vec::new();

    if let Ok(entries) = fs::read_dir(root) {
        for entry in entries.flatten() {
            let path = entry.path();

            if path.is_dir() {
                let cat_name = path.file_name().unwrap().to_string_lossy().to_string();
                
                // Skip hidden folders (e.g., .git, .gcx)
                if cat_name.starts_with('.') { continue; }

                let mut subcategories = Vec::new();

                // 1. Files directly under Category -> "General"
                let mut direct_files = Vec::new();
                if let Ok(sub_entries) = fs::read_dir(&path) {
                    for sub_entry in sub_entries.flatten() {
                        let sub_path = sub_entry.path();
                        if sub_path.is_file() {
                            if is_valid_ext(&sub_path) {
                                let name = sub_path.file_name().unwrap().to_string_lossy().to_string();
                                let title = format_title(&name);
                                let rel_path = format!("{}/General/{}", cat_name, name); // Logic mapping
                                direct_files.push(FileMeta { name, title, path: rel_path });
                            }
                        }
                    }
                }
                if !direct_files.is_empty() {
                    direct_files.sort_by(|a, b| alphanumeric_sort::compare_str(&a.name, &b.name));
                    subcategories.push(SubCategory { name: "General".to_string(), files: direct_files });
                }

                // 2. Subdirectories
                if let Ok(sub_entries) = fs::read_dir(&path) {
                    for sub_entry in sub_entries.flatten() {
                        let sub_path = sub_entry.path();
                        if sub_path.is_dir() {
                            let sub_name = sub_path.file_name().unwrap().to_string_lossy().to_string();
                            if sub_name.starts_with('.') { continue; }

                            let mut files = Vec::new();
                            if let Ok(file_entries) = fs::read_dir(&sub_path) {
                                for file_entry in file_entries.flatten() {
                                    let file_path = file_entry.path();
                                    if file_path.is_file() && is_valid_ext(&file_path) {
                                        let name = file_path.file_name().unwrap().to_string_lossy().to_string();
                                        let title = format_title(&name);
                                        let rel_path = format!("{}/{}/{}", cat_name, sub_name, name);
                                        files.push(FileMeta { name, title, path: rel_path });
                                    }
                                }
                            }
                            files.sort_by(|a, b| alphanumeric_sort::compare_str(&a.name, &b.name));
                            if !files.is_empty() {
                                subcategories.push(SubCategory { name: sub_name, files });
                            }
                        }
                    }
                }

                subcategories.sort_by(|a, b| {
                    if a.name == "General" { std::cmp::Ordering::Less }
                    else if b.name == "General" { std::cmp::Ordering::Greater }
                    else { a.name.cmp(&b.name) }
                });

                if !subcategories.is_empty() {
                    categories.push(Category { name: cat_name, subcategories });
                }
            }
        }
    }
    categories.sort_by(|a, b| a.name.cmp(&b.name));
    categories
}

fn is_valid_ext(path: &Path) -> bool {
    if let Some(ext) = path.extension() {
        let ext_str = ext.to_string_lossy();
        matches!(ext_str.as_ref(), "md" | "rs" | "java" | "py" | "js" | "ts" | "go" | "kt" | "sh" | "yaml" | "yml" | "json" | "toml")
    } else {
        false
    }
}

fn format_title(name: &str) -> String {
    name.rsplit_once('.')
        .map(|(n, _)| n)
        .unwrap_or(name)
        .replace('_', " ")
}

// ========================================================================================
// Handlers
// ========================================================================================

async fn api_tree_handler(State(state): State<Arc<AppState>>) -> Json<Vec<Category>> {
    let categories = build_navigation(&state.content_root);
    Json(categories)
}

async fn api_content_handler(
    State(state): State<Arc<AppState>>,
    UrlPath(path_str): UrlPath<String>,
) -> impl IntoResponse {
    // path_str e.g., "frameworks/springboot/Step1.md"
    
    // Security Check: Prevent traversal
    if path_str.contains("..") || path_str.contains('\\') {
        return Json(ContentResponse {
            title: "Security Error".to_string(),
            content: "Invalid path".to_string(),
            file_type: "error".to_string(),
            prev: None,
            next: None,
        }).into_response();
    }

    // Construct real path
    // Need to handle "General" logic manually if path has 2 segments (category/file)
    // But frontend will send what we gave in tree. 
    // In build_navigation:
    //   Direct file: "category/General/file"
    //   Subdir file: "category/subcategory/file"
    
    let parts: Vec<&str> = path_str.split('/').collect();
    let file_path = if parts.len() == 3 && parts[1] == "General" {
        state.content_root.join(parts[0]).join(parts[2]) // content/category/file
    } else {
        state.content_root.join(&path_str) // content/category/subcategory/file
    };

    if file_path.exists() && file_path.is_file() {
        match fs::read_to_string(&file_path) {
            Ok(content) => {
                let file_name = file_path.file_name().unwrap().to_string_lossy();
                let title = format_title(&file_name);
                let file_type = if file_name.ends_with(".md") { "markdown" } else { "code" };

                // Navigation Logic (Prev/Next) - Simplified: Rebuild tree & search
                // For performance, this should be cached or optimized in real prod
                let categories = build_navigation(&state.content_root);
                let mut flat_files = Vec::new();
                for cat in &categories {
                    for sub in &cat.subcategories {
                        for f in &sub.files {
                            flat_files.push(f.clone());
                        }
                    }
                }
                
                let current_idx = flat_files.iter().position(|f| f.path == path_str);
                let (prev, next) = if let Some(idx) = current_idx {
                    (
                        if idx > 0 { Some(flat_files[idx - 1].clone()) } else { None },
                        if idx < flat_files.len() - 1 { Some(flat_files[idx + 1].clone()) } else { None }
                    )
                } else {
                    (None, None)
                };

                Json(ContentResponse {
                    title,
                    content,
                    file_type: file_type.to_string(),
                    prev,
                    next,
                }).into_response()
            }
            Err(e) => (
                axum::http::StatusCode::INTERNAL_SERVER_ERROR,
                format!("Failed to read file: {}", e),
            ).into_response()
        }
    } else {
        (
            axum::http::StatusCode::NOT_FOUND,
            "File not found",
        ).into_response()
    }
}