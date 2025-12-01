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
        });
    }

    let categories = build_navigation(&state.content_root);
    
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
    };
    HtmlTemplate(template)
}


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
