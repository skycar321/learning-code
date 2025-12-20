I've created a comprehensive **Technical Requirements Document (TRD)** for splitting your monolithic Rust application into a modern Rust Backend API + Next.js Frontend architecture. The document is ready to be written to `TRD_Platform_Split.md`.

## 📋 Document Overview

The TRD contains **12 major sections** covering:

### 🎯 Core Architecture
1. **Executive Summary** - Migration objectives and benefits
2. **Current Architecture Analysis** - Deep dive into existing Rust/Axum monolith
3. **Target Architecture** - Microservices design with tech stack

### 🔧 Technical Specifications
4. **API Design** - 4 RESTful endpoints with complete schemas:
   - `GET /api/tree` - Navigation structure
   - `GET /api/content/:category/:subcategory/:file` - Content with metadata
   - `GET /api/search` - Full-text search (future)
   - `GET /api/health` - Health check

5. **Frontend Design** - Next.js 14 App Router structure:
   - Complete file structure
   - 10+ React components with code examples
   - Server vs Client Component strategy
   - TypeScript types and API client

6. **Data Flow & State Management** - Hybrid rendering strategy (SSR + SSG)

### 🚀 Implementation
7. **Migration Strategy** - 5-phase rollout plan (4 weeks)
8. **Performance & Security** - Caching, XSS prevention, CORS, rate limiting
9. **Testing Strategy** - Unit, integration, E2E tests for both stacks
10. **Deployment Architecture** - Docker Compose + Cloud deployment options

### 📚 Reference
11. **Appendix** - Dependencies, environment variables, size estimates
12. **Next Steps** - Action items

## ✨ Key Highlights

### API Schema Example
```json
{
  "categories": [
    {
      "name": "frameworks",
      "displayName": "Frameworks",
      "subcategories": [...]
    }
  ]
}
```

### Component Architecture
- **Sidebar**: Collapsible categories with search
- **Content Page**: SSG with dynamic metadata
- **Markdown Renderer**: Prism.js syntax highlighting

### Performance Targets
- TTFB < 200ms
- LCP < 2.5s
- Lighthouse > 90

Would you like me to:
1. **Write the document** to the file system?
2. **Modify any section** before saving?
3. **Create additional diagrams** or code examples?
