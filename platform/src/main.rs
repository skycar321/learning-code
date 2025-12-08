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
use tower_http::services::ServeDir; // 정적 파일(이미지, CSS 등) 서빙을 위해 추가

// ========================================================================================
// 애플리케이션 상태 관리 (State Management)
// ========================================================================================

/// 애플리케이션 전역에서 공유되는 상태(State)입니다.
/// 여기서는 콘텐츠 파일들이 위치한 루트 경로(`content_root`)를 저장합니다.
/// `Clone`을 구현하여 각 요청 핸들러로 복사될 수 있게 합니다.
#[derive(Clone)]
struct AppState {
    content_root: PathBuf,
}

// ========================================================================================
// 데이터 모델 (Data Models) - 네비게이션 구조
// ========================================================================================

/// 파일 정보를 담는 구조체입니다.
/// `name`: 파일 시스템상의 실제 파일명 (예: "Step1_Intro.md")
/// `title`: 화면에 표시될 제목 (예: "Step1 Intro")
#[derive(Clone, Debug)]
struct FileMeta {
    name: String,
    title: String,
}

/// 서브 카테고리 정보를 담는 구조체입니다.
/// 예: "Spring Boot" 카테고리 하위의 "Step1", "Step2" 등의 파일들을 포함합니다.
#[derive(Clone, Debug)]
struct SubCategory {
    name: String,
    files: Vec<FileMeta>,
}

/// 최상위 카테고리 정보를 담는 구조체입니다.
/// 예: "Frameworks", "Languages" 등 폴더명을 기반으로 생성됩니다.
#[derive(Clone, Debug)]
struct Category {
    name: String,
    subcategories: Vec<SubCategory>,
}

/// 이전/다음 글 이동을 위한 링크 구조체입니다.
#[derive(Clone, Debug)]
struct FileLink {
    title: String,
    url: String,
}

// ========================================================================================
// 템플릿 (Askama Templates) - HTML 렌더링
// ========================================================================================

/// 메인 페이지(index.html) 렌더링을 위한 템플릿 데이터입니다.
/// 사이드바 네비게이션을 구성하기 위해 카테고리 목록(`categories`)을 전달합니다.
#[derive(Template)]
#[template(path = "index.html")]
struct IndexTemplate {
    categories: Vec<Category>,
}

/// 상세 내용 페이지(content.html) 렌더링을 위한 템플릿 데이터입니다.
#[derive(Template)]
#[template(path = "content.html")]
struct ContentTemplate {
    categories: Vec<Category>,      // 사이드바 네비게이션용
    current_category: String,       // 현재 보고 있는 카테고리 (Breadcrumb용)
    subcategory: String,            // 현재 보고 있는 서브카테고리
    title: String,                  // 글 제목
    html_content: String,           // 마크다운이 변환된 HTML 본문
    prev_file: Option<FileLink>,    // 이전 글 링크 (없을 수 있음)
    next_file: Option<FileLink>,    // 다음 글 링크 (없을 수 있음)
    hero_image: Option<String>,     // 히어로 이미지 URL (없을 수 있음)
}

// ========================================================================================
// 메인 함수 (Entry Point)
// ========================================================================================

#[tokio::main]
async fn main() {
    // 1. 로깅 초기화
    // `RUST_LOG` 환경변수에 따라 로그 레벨이 결정됩니다.
    tracing_subscriber::fmt::init();

    // 2. 콘텐츠 루트 경로 설정
    // 환경변수 `CONTENT_ROOT`가 설정되어 있으면 그것을 사용하고,
    // 없으면 기본값으로 상위 폴더의 "../content"를 사용합니다.
    let content_path = std::env::var("CONTENT_ROOT").unwrap_or_else(|_| "../content".to_string());
    
    // 3. 공유 상태(State) 생성
    // `Arc` (Atomic Reference Counting)를 사용하여 멀티 스레드 환경에서 안전하게 상태를 공유합니다.
    let state = Arc::new(AppState {
        content_root: PathBuf::from(content_path),
    });

    // 4. 라우터 설정 (URL 매핑)
    // - `/`: 메인 페이지 (index_handler)
    // - `/view/...`: 상세 내용 페이지 (content_handler)
    // - `/static`: 정적 파일 (이미지, CSS) 서빙
    let app = Router::new()
        .route("/", get(index_handler))
        .route("/view/:category/:subcategory/:file", get(content_handler))
        .nest_service("/static", ServeDir::new("static")) // 정적 파일 서빙 미들웨어
        .layer(TraceLayer::new_for_http()) // HTTP 요청 로깅 미들웨어 추가
        .with_state(state); // 핸들러들에게 상태 주입

    // 5. 서버 시작
    // 0.0.0.0:3000 포트에서 리스닝합니다. (외부 접속 허용)
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    println!("Listening on http://0.0.0.0:3000");
    axum::serve(listener, app).await.unwrap();
}

// ========================================================================================
// 헬퍼 함수 (Helpers)
// ========================================================================================

/// 파일 시스템을 스캔하여 네비게이션 구조(카테고리 트리)를 생성합니다.
/// 
/// [구조]
/// Root
/// ├── Category (폴더)
/// │   ├── SubCategory (폴더)
/// │   │   ├── File1.md
/// │   │   └── File2.rs
/// │   └── FileDirectlyUnderCategory.md (-> "General" 서브카테고리로 자동 분류)
fn build_navigation(root: &Path) -> Vec<Category> {
    let mut categories = Vec::new();
    
    // 1. 루트 디렉토리 읽기
    if let Ok(entries) = fs::read_dir(root) {
        for entry in entries.flatten() {
            let path = entry.path();
            
            // 폴더인 경우만 카테고리로 취급 (예: frameworks, languages)
            if path.is_dir() {
                let cat_name = path.file_name().unwrap().to_string_lossy().to_string();
                let mut subcategories = Vec::new();

                // 2-A. 카테고리 바로 아래에 있는 파일 처리 (Direct Files)
                // 예: content/process/Guide.md -> "General" 서브카테고리로 묶음
                let mut direct_files = Vec::new();
                if let Ok(sub_entries) = fs::read_dir(&path) {
                    for sub_entry in sub_entries.flatten() {
                        let sub_path = sub_entry.path();
                        if sub_path.is_file() {
                            // 지원하는 파일 확장자만 목록에 추가
                            if let Some(ext) = sub_path.extension() {
                                if ext == "md" || ext == "java" || ext == "rs" || ext == "py" || ext == "js" || ext == "ts" {
                                    let name = sub_path.file_name().unwrap().to_string_lossy().to_string();
                                    // 제목 포맷팅: 확장자 제거 및 언더바를 공백으로 변환
                                    let title = name.rsplit_once('.').map(|(n, _)| n).unwrap_or(&name).replace('_', " ");
                                    direct_files.push(FileMeta { name, title });
                                }
                            }
                        }
                    }
                }
                // 직접 포함된 파일이 있다면 "General" 서브카테고리 생성
                if !direct_files.is_empty() {
                    // 파일명 기준 정렬 (Step1, Step2 순서 보장)
                    direct_files.sort_by(|a, b| alphanumeric_sort::compare_str(&a.name, &b.name));
                    subcategories.push(SubCategory { name: "General".to_string(), files: direct_files });
                }

                // 2-B. 서브 디렉토리 처리 (Subcategories)
                // 예: content/frameworks/springboot
                if let Ok(sub_entries) = fs::read_dir(&path) {
                    for sub_entry in sub_entries.flatten() {
                        let sub_path = sub_entry.path();
                        if sub_path.is_dir() {
                            let sub_name = sub_path.file_name().unwrap().to_string_lossy().to_string();
                            let mut files = Vec::new();

                            // 3. 최종 파일 스캔
                            if let Ok(file_entries) = fs::read_dir(&sub_path) {
                                for file_entry in file_entries.flatten() {
                                    let file_path = file_entry.path();
                                    if file_path.is_file() {
                                        let name = file_path.file_name().unwrap().to_string_lossy().to_string();
                                        let title = name.rsplit_once('.').map(|(n, _)| n).unwrap_or(&name)
                                            .replace('_', " ");
                                        
                                        files.push(FileMeta { name, title });
                                    }
                                }
                            }
                            // 파일명 기준 자연 정렬 (Alphanumeric Sort)
                            files.sort_by(|a, b| alphanumeric_sort::compare_str(&a.name, &b.name));

                            if !files.is_empty() {
                                subcategories.push(SubCategory { name: sub_name, files });
                            }
                        }
                    }
                }
                
                // 서브카테고리 정렬: "General"을 맨 위로, 나머지는 알파벳순
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
    // 카테고리 이름 기준 정렬
    categories.sort_by(|a, b| a.name.cmp(&b.name));
    categories
}

// ========================================================================================
// 요청 핸들러 (Request Handlers)
// ========================================================================================

/// 메인 페이지(/) 요청을 처리합니다.
async fn index_handler(State(state): State<Arc<AppState>>) -> impl IntoResponse {
    // 최신 파일 목록을 스캔하여 네비게이션 생성
    let categories = build_navigation(&state.content_root);
    let template = IndexTemplate { categories };
    HtmlTemplate(template)
}

/// 상세 내용 페이지(/view/...) 요청을 처리합니다.
async fn content_handler(
    State(state): State<Arc<AppState>>,
    // URL 경로 파라미터 추출: /view/:category/:subcategory/:file
    UrlPath((category, subcategory, file)): UrlPath<(String, String, String)>,
) -> impl IntoResponse {
    
    // [보안 중요] 경로 탐색(Path Traversal) 공격 방지
    // URL에 "..", "/", "\" 문자가 포함되어 있으면 상위 디렉토리로 이동하여 시스템 파일을 읽을 위험이 있습니다.
    // 이를 방지하기 위해 해당 문자가 포함된 요청은 즉시 차단합니다.
    // 역슬래시는 문자 리터럴에서 이스케이프가 필요하므로 '\\' 로 표기합니다.
    if category.contains("..") || category.contains('/') || category.contains('\\') ||
       subcategory.contains("..") || subcategory.contains('/') || subcategory.contains('\\') ||
       file.contains("..") || file.contains('/') || file.contains('\\') {
        return HtmlTemplate(ContentTemplate {
            categories: vec![],
            current_category: "".to_string(),
            subcategory: "".to_string(),
            title: "Invalid Path".to_string(),
            html_content: "<h1>Invalid Path: Security Warning</h1>".to_string(),
            prev_file: None,
            next_file: None,
            hero_image: None,
        });
    }

    // 사이드바 네비게이션 빌드
    let categories = build_navigation(&state.content_root);
    
    // [네비게이션 로직] 이전/다음 글 찾기
    // 트리 구조인 카테고리를 평탄화(Flat List)하여 현재 파일의 인덱스를 찾습니다.
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

    // 현재 파일의 위치 탐색
    let current_pos = flat_files.iter().position(|(c, s, f, _)| 
        *c == category && *s == subcategory && *f == file
    );

    // 이전/다음 링크 생성
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
    
    // [파일 경로 매핑]
    // "General" 서브카테고리는 실제로는 상위 폴더에 있는 파일입니다.
    // 예: /view/process/General/Guide.md -> 실제 경로: content/process/Guide.md
    let file_path = if subcategory == "General" {
        state.content_root.join(&category).join(&file)
    } else {
        state.content_root.join(&category).join(&subcategory).join(&file)
    };

    // 파일 읽기 및 HTML 변환
    let (title, html_content) = if file_path.exists() && file_path.is_file() {
        match fs::read_to_string(&file_path) {
            Ok(content) => {
                let title = file.rsplit_once('.').map(|(n, _)| n).unwrap_or(&file).replace('_', " ");
                
                // 마크다운(.md) 파일인 경우 -> HTML로 렌더링
                if file.ends_with(".md") {
                    let mut options = Options::empty();
                    options.insert(Options::ENABLE_TABLES); // 표 지원
                    options.insert(Options::ENABLE_STRIKETHROUGH); // 취소선 지원
                    options.insert(Options::ENABLE_TASKLISTS); // 체크리스트 지원
                    
                    let parser = Parser::new_ext(&content, options);
                    let mut html_output = String::new();
                    html::push_html(&mut html_output, parser);
                    
                    // [보안] XSS 방지를 위해 HTML 살균(Sanitization)
                    // ammonia 라이브러리를 사용하여 위험한 스크립트 태그 등을 제거합니다.
                    let clean_html = ammonia::clean(&html_output);
                    (title, clean_html)
                } else {
                    // 소스코드 파일(.rs, .java 등)인 경우 -> 코드 블록으로 감싸서 표시
                    // html_escape를 사용하여 특수문자(<, >, &)를 이스케이프 처리합니다.
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

    // [Hero Image 로직]
    // 카테고리별 히어로 이미지 매핑
    let hero_image = if category == "process" {
        Some("/static/images/process/sdlc_hero.svg".to_string())
    } else {
        None
    };

    let template = ContentTemplate {
        categories,
        current_category: category,
        subcategory,
        title,
        html_content,
        prev_file,
        next_file,
        hero_image,
    };
    HtmlTemplate(template)
}


// ========================================================================================
// Askama 템플릿 연동 보일러플레이트
// ========================================================================================

/// Askama 템플릿을 Axum 응답으로 변환하기 위한 래퍼 구조체입니다.
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

// ========================================================================================
// 단위 테스트 (Unit Tests)
// ========================================================================================

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
        // 테스트 환경 구성: 임시 디렉토리에 가상의 콘텐츠 구조 생성
        // content/
        //   DevOps/
        //     Docker/
        //       Step1.md
        //   Process/ (서브폴더 없음, 직접 파일 존재)
        //     Guide.md
        let temp_dir = TempDir::new().unwrap();
        let root = temp_dir.path();

        create_dummy_content(root, "DevOps/Docker/Step1.md");
        create_dummy_content(root, "Process/Guide.md");

        // 실행: 네비게이션 빌드
        let categories = build_navigation(root);

        // 검증
        assert_eq!(categories.len(), 2);
        
        // 1. DevOps 카테고리 검증
        let devops = categories.iter().find(|c| c.name == "DevOps").unwrap();
        assert_eq!(devops.subcategories[0].name, "Docker");
        assert_eq!(devops.subcategories[0].files[0].name, "Step1.md");
        
        // 2. Process 카테고리 검증 ("General" 자동 생성 확인)
        let process = categories.iter().find(|c| c.name == "Process").unwrap();
        assert_eq!(process.subcategories[0].name, "General"); // "General"로 묶였는지 확인
        assert_eq!(process.subcategories[0].files[0].name, "Guide.md");
    }
}
