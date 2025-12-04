use axum::{
    extract::{Path as UrlPath, State},
    response::{Html, IntoResponse, Response},
    routing::get,
    Router,
};
use askama::Template;
use std::{
    sync::Arc,
    path::{PathBuf, Path},
    fs,
};
use pulldown_cmark::{Parser, Options, html};
use tower_http::trace::TraceLayer;

#[derive(Clone)]
struct AppState {
    content_root: PathBuf,
}

#[derive(Clone, Debug)]
struct FileMeta {
    name: String,
    title: String,
}

#[derive(Clone, Debug)]
struct SubCategory {
    name: String,
    files: Vec<FileMeta>,
}

#[derive(Clone, Debug)]
struct Category {
    name: String,
    subcategories: Vec<SubCategory>,
}

#[derive(Clone, Debug)]
struct FileLink {
    title: String,
    url: String,
}

// Templates
#[derive(Template)]
#[template(path = "index.html")]
struct IndexTemplate {
    categories: Vec<Category>,
}

#[derive(Template)]
#[template(path = "content.html")]
struct ContentTemplate {
    categories: Vec<Category>,
    current_category: String,
    subcategory: String,
    title: String,
    html_content: String,
    prev_file: Option<FileLink>,
    next_file: Option<FileLink>,
}

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt::init();

    let content_path = std::env::var("CONTENT_ROOT").unwrap_or_else(|_| "../content".to_string());
    let state = Arc::new(AppState {
        content_root: PathBuf::from(content_path),
    });

    let app = Router::new()
        .route("/", get(index_handler))
        .route("/view/:category/:subcategory/:file", get(content_handler))
        .layer(TraceLayer::new_for_http())
        .with_state(state);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    println!("Listening on http://0.0.0.0:3000");
    axum::serve(listener, app).await.unwrap();
}

// Helpers
fn build_navigation(root: &Path) -> Vec<Category> {
    let mut categories = Vec::new();
    
    if let Ok(entries) = fs::read_dir(root) {
        for entry in entries.flatten() {
            let path = entry.path();
            if path.is_dir() {
                let cat_name = path.file_name().unwrap().to_string_lossy().to_string();
                let mut subcategories = Vec::new();

                if let Ok(sub_entries) = fs::read_dir(&path) {
                    for sub_entry in sub_entries.flatten() {
                        let sub_path = sub_entry.path();
                        if sub_path.is_dir() {
                            let sub_name = sub_path.file_name().unwrap().to_string_lossy().to_string();
                            let mut files = Vec::new();

                            if let Ok(file_entries) = fs::read_dir(&sub_path) {
                                for file_entry in file_entries.flatten() {
                                    let file_path = file_entry.path();
                                    if file_path.is_file() {
                                        let name = file_path.file_name().unwrap().to_string_lossy().to_string();
                                        // Simple title logic: remove extension, replace _ with space
                                        let title = name.rsplit_once('.').map(|(n, _)| n).unwrap_or(&name)
                                            .replace('_', " ");
                                        
                                        files.push(FileMeta { name, title });
                                    }
                                }
                            }
                            // Sort files by name (often they have numbers like Step1, Step2)
                            files.sort_by(|a, b| alphanumeric_sort::compare_str(&a.name, &b.name));

                            if !files.is_empty() {
                                subcategories.push(SubCategory { name: sub_name, files });
                            }
                        }
                    }
                }
                subcategories.sort_by(|a, b| a.name.cmp(&b.name));
                
                if !subcategories.is_empty() {
                    categories.push(Category { name: cat_name, subcategories });
                }
            }
        }
    }
    categories.sort_by(|a, b| a.name.cmp(&b.name));
    categories
}

// Handlers
async fn index_handler(State(state): State<Arc<AppState>>) -> impl IntoResponse {
    let categories = build_navigation(&state.content_root);
    let template = IndexTemplate { categories };
    HtmlTemplate(template)
}

async fn content_handler(
    State(state): State<Arc<AppState>>,
    UrlPath((category, subcategory, file)): UrlPath<(String, String, String)>,
) -> impl IntoResponse {
    // Security: Prevent path traversal
    if category.contains("..") || category.contains('/') || category.contains('\\') ||
       subcategory.contains("..") || subcategory.contains('/') || subcategory.contains('\\') ||
       file.contains("..") || file.contains('/') || file.contains('\\') {
        return HtmlTemplate(ContentTemplate {
            categories: vec![],
            current_category: "".to_string(),
            subcategory: "".to_string(),
            title: "Invalid Path".to_string(),
            html_content: "<h1>Invalid Path</h1>".to_string(),
            prev_file: None,
            next_file: None,
        });
    }

    let categories = build_navigation(&state.content_root);
    
    // Build flat list for navigation
    let mut flat_files = Vec::new();
    for cat in &categories {
        for sub in &cat.subcategories {
            for f in &sub.files {
                flat_files.push((
                    cat.name.clone(),
                    sub.name.clone(),
                    f.name.clone(),
                    f.title.clone()
                ));
            }
        }
    }

    // Find current index
    let current_pos = flat_files.iter().position(|(c, s, f, _)| 
        *c == category && *s == subcategory && *f == file
    );

    let (prev_file, next_file) = if let Some(idx) = current_pos {
        let prev = if idx > 0 {
            let (c, s, f, t) = &flat_files[idx - 1];
            Some(FileLink {
                title: t.clone(),
                url: format!("/view/{}/{}/{}", c, s, f),
            })
        } else {
            None
        };

        let next = if idx < flat_files.len() - 1 {
            let (c, s, f, t) = &flat_files[idx + 1];
            Some(FileLink {
                title: t.clone(),
                url: format!("/view/{}/{}/{}", c, s, f),
            })
        } else {
            None
        };
        (prev, next)
    } else {
        (None, None)
    };
    
    let file_path = state.content_root.join(&category).join(&subcategory).join(&file);

    let (title, html_content) = if file_path.exists() && file_path.is_file() {
        match fs::read_to_string(&file_path) {
            Ok(content) => {
                let title = file.rsplit_once('.').map(|(n, _)| n).unwrap_or(&file).replace('_', " ");
                
                if file.ends_with(".md") {
                    let mut options = Options::empty();
                    options.insert(Options::ENABLE_TABLES);
                    options.insert(Options::ENABLE_STRIKETHROUGH);
                    options.insert(Options::ENABLE_TASKLISTS);
                    
                    let parser = Parser::new_ext(&content, options);
                    let mut html_output = String::new();
                    html::push_html(&mut html_output, parser);
                    (title, html_output)
                } else {
                    // Render code files wrapped in code block
                    let ext = file.rsplit_once('.').map(|(_, e)| e).unwrap_or("text");
                    let html_output = format!(
                        "<pre><code class=\"language-{}\">{}</code></pre>", 
                        ext, 
                        html_escape::encode_text(&content)
                    );
                    (title, html_output)
                }
            },
            Err(_) => ("Error".to_string(), "<p>Failed to read file.</p>".to_string()),
        }
    } else {
        ("Not Found".to_string(), "<h1>404 - File Not Found</h1>".to_string())
    };

    let template = ContentTemplate {
        categories,
        current_category: category,
        subcategory,
        title,
        html_content,
        prev_file,
        next_file,
    };
    HtmlTemplate(template)
}


// ... (existing code)

// Template Boilerplate
struct HtmlTemplate<T>(T);

impl<T> IntoResponse for HtmlTemplate<T>
where
    T: Template,
{
    fn into_response(self) -> Response {
        match self.0.render() {
            Ok(html) => Html(html).into_response(),
            Err(err) => (
                axum::http::StatusCode::INTERNAL_SERVER_ERROR,
                format!("Template error: {}", err),
            )
                .into_response(),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs::{self, File};
    use std::io::Write;
    use tempfile::TempDir;

    fn create_dummy_content(dir: &Path, path: &str) {
        let full_path = dir.join(path);
        if let Some(parent) = full_path.parent() {
            fs::create_dir_all(parent).unwrap();
        }
        let mut file = File::create(full_path).unwrap();
        writeln!(file, "# Dummy Content").unwrap();
    }

    #[test]
    fn test_build_navigation() {
        // Setup: Create a temp directory with a mock structure
        // content/
        //   DevOps/
        //     Docker/
        //       Step1.md
        //       Step2.md
        //   Languages/
        //     Rust/
        //       Step1_Intro.md
        let temp_dir = TempDir::new().unwrap();
        let root = temp_dir.path();

        create_dummy_content(root, "DevOps/Docker/Step1.md");
        create_dummy_content(root, "DevOps/Docker/Step2.md");
        create_dummy_content(root, "Languages/Rust/Step1_Intro.md");

        // Act
        let categories = build_navigation(root);

        // Assert
        assert_eq!(categories.len(), 2);
        
        // Check DevOps
        let devops = &categories[0];
        assert_eq!(devops.name, "DevOps");
        assert_eq!(devops.subcategories.len(), 1);
        assert_eq!(devops.subcategories[0].name, "Docker");
        assert_eq!(devops.subcategories[0].files.len(), 2);
        assert_eq!(devops.subcategories[0].files[0].name, "Step1.md");
        
        // Check Languages
        let languages = &categories[1];
        assert_eq!(languages.name, "Languages");
        assert_eq!(languages.subcategories[0].name, "Rust");
        assert_eq!(languages.subcategories[0].files[0].title, "Step1 Intro"); // Check title formatting
    }

    #[test]
    fn test_alphanumeric_sorting() {
        let temp_dir = TempDir::new().unwrap();
        let root = temp_dir.path();

        create_dummy_content(root, "Cat/Sub/Step1.md");
        create_dummy_content(root, "Cat/Sub/Step10.md");
        create_dummy_content(root, "Cat/Sub/Step2.md");

        let categories = build_navigation(root);
        let files = &categories[0].subcategories[0].files;

        // Expect: Step1, Step2, Step10 (Natural Sort)
        // Note: Our implementation uses `alphanumeric_sort` crate
        assert_eq!(files[0].name, "Step1.md");
        assert_eq!(files[1].name, "Step2.md");
        assert_eq!(files[2].name, "Step10.md");
    }
}
