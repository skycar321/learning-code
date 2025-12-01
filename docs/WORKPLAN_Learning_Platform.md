# WORKPLAN: Learning Code 웹 플랫폼 구현

> **프로젝트**: Learning Code Interactive Web Platform
> **작성일**: 2025-11-30
> **총 예상 기간**: 3주 (120시간)

---

## Phase 1: 프로젝트 초기화 및 파일 파싱 (1주, 40시간)

### 1.1 Next.js 프로젝트 생성
**우선순위**: P0 (필수)
**예상 시간**: 2시간

**작업 내용**:
- [ ] `npx create-next-app@latest learning-code-web --app --typescript --tailwind --eslint`
- [ ] ShadCN UI 초기화: `npx shadcn@latest init`
- [ ] 폴더 구조 설정:
  ```
  app/
  ├── layout.tsx
  ├── page.tsx
  ├── [category]/[step]/page.tsx
  components/
  ├── Sidebar.tsx
  ├── CodeViewer.tsx
  ├── ProgressTracker.tsx
  lib/
  ├── parsers/
  │   ├── parseMarkdown.ts
  │   ├── parseCode.ts
  stores/
  └── progressStore.ts
  ```

---

### 1.2 학습 자료 파일 파싱 시스템
**우선순위**: P0
**예상 시간**: 8시간

**Task 1.2.1**: Markdown 파서 구현 (4h)
```typescript
// lib/parsers/parseMarkdown.ts
interface LearningPlan {
  category: string;
  steps: StepMeta[];
}

export async function parseLearningPlan(filePath: string): Promise<LearningPlan> {
  // learning_plan.md 파일에서 테이블 파싱
  // 정규식으로 | Step 1 | ... | 완료 | 추출
}
```

**Task 1.2.2**: 코드 파일 파서 구현 (4h)
```typescript
// lib/parsers/parseCode.ts
interface CodeSection {
  type: 'bad' | 'good' | 'explanation';
  content: string;
  lineNumbers: [number, number];
}

export function parseCodeFile(content: string): CodeSection[] {
  // 주석 기반 섹션 분리
  // "=== BAD EXAMPLE ===" 탐지
}
```

---

### 1.3 데이터 수집 스크립트
**우선순위**: P0
**예상 시간**: 6시간

**Task 1.3.1**: 빌드타임 데이터 생성 (3h)
```typescript
// scripts/generateLearningData.ts
import fs from 'fs/promises';
import path from 'path';

async function generateData() {
  const categories = ['java', 'python', 'vue3', 'springboot', ...];
  const data = {};

  for (const cat of categories) {
    const planPath = `../${cat}/${cat}_learning_plan.md`;
    data[cat] = await parseLearningPlan(planPath);

    // Step 파일들 파싱
    for (const step of data[cat].steps) {
      const codePath = `../${cat}/${step.fileName}`;
      step.code = await parseCodeFile(codePath);
    }
  }

  await fs.writeFile('public/learning-data.json', JSON.stringify(data));
}
```

**Task 1.3.2**: 타입 정의 (2h)
```typescript
// types/learning.ts
export interface Category {
  name: string;
  icon: string;
  steps: Step[];
}

export interface Step {
  id: string;
  stepNumber: number;
  title: string;
  goal: string;
  status: 'pending' | 'in-progress' | 'completed';
  filePath: string;
  code: CodeSection[];
  comparisons?: string[]; // 비교 학습 파일 경로
}
```

**Task 1.3.3**: 데이터 검증 (1h)
- 모든 파일 파싱 성공 여부 확인
- 누락된 파일 리포트

---

### 1.4 레이아웃 및 네비게이션
**우선순위**: P0
**예상 시간**: 12시간

**Task 1.4.1**: 사이드바 컴포넌트 (6h)
```tsx
// components/Sidebar.tsx
import { ScrollArea } from '@/components/ui/scroll-area';
import { Collapsible } from '@/components/ui/collapsible';

export function Sidebar({ categories }: { categories: Category[] }) {
  return (
    <aside className="w-64 border-r">
      <ScrollArea className="h-screen">
        {categories.map(cat => (
          <CategoryTree key={cat.name} category={cat} />
        ))}
      </ScrollArea>
    </aside>
  );
}
```

**Task 1.4.2**: 레이아웃 구조 (4h)
```tsx
// app/layout.tsx
export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <Header />
        <div className="flex">
          <Sidebar />
          <main className="flex-1">{children}</main>
        </div>
      </body>
    </html>
  );
}
```

**Task 1.4.3**: 다이나믹 라우팅 (2h)
```tsx
// app/[category]/[step]/page.tsx
export async function generateStaticParams() {
  // 모든 category/step 조합 생성
}

export default function StepPage({ params }) {
  const stepData = getStepData(params.category, params.step);
  return <StepContent data={stepData} />;
}
```

---

### 1.5 코드 뷰어 컴포넌트
**우선순위**: P0
**예상 시간**: 8시간

**Task 1.5.1**: Syntax Highlighting (4h)
```tsx
// components/CodeViewer.tsx
import { Prism as SyntaxHighlighter } from 'react-syntax-highlighter';
import { vscDarkPlus } from 'react-syntax-highlighter/dist/cjs/styles/prism';

export function CodeViewer({ code, language }: { code: string, language: string }) {
  return (
    <SyntaxHighlighter language={language} style={vscDarkPlus}>
      {code}
    </SyntaxHighlighter>
  );
}
```

**Task 1.5.2**: Bad/Good 탭 전환 (2h)
```tsx
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';

<Tabs defaultValue="bad">
  <TabsList>
    <TabsTrigger value="bad">❌ Bad Example</TabsTrigger>
    <TabsTrigger value="good">✅ Good Example</TabsTrigger>
  </TabsList>
  <TabsContent value="bad">
    <CodeViewer code={badCode} language="java" />
  </TabsContent>
  <TabsContent value="good">
    <CodeViewer code={goodCode} language="java" />
  </TabsContent>
</Tabs>
```

**Task 1.5.3**: 학습 포인트 하이라이트 (2h)
```tsx
<Alert className="mt-4">
  <Lightbulb className="h-4 w-4" />
  <AlertTitle>학습 포인트</AlertTitle>
  <AlertDescription>
    {step.learningPoints.map(point => <li key={point}>{point}</li>)}
  </AlertDescription>
</Alert>
```

---

### 1.6 진행률 추적 시스템
**우선순위**: P1
**예상 시간**: 4시간

**Task 1.6.1**: Zustand Store 생성 (2h)
```typescript
// stores/progressStore.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface ProgressState {
  completedSteps: Set<string>;
  markComplete: (stepId: string) => void;
  getProgress: (category: string) => number;
}

export const useProgress = create<ProgressState>()(
  persist(
    (set, get) => ({
      completedSteps: new Set(),
      markComplete: (stepId) => set((state) => ({
        completedSteps: state.completedSteps.add(stepId)
      })),
      getProgress: (category) => {
        // 계산 로직
      }
    }),
    { name: 'learning-progress' }
  )
);
```

**Task 1.6.2**: Progress Bar 컴포넌트 (2h)
```tsx
// components/ProgressTracker.tsx
import { Progress } from '@/components/ui/progress';

export function ProgressTracker({ category }: { category: string }) {
  const progress = useProgress(state => state.getProgress(category));
  return (
    <div className="p-4">
      <p className="text-sm mb-2">전체 진행률</p>
      <Progress value={progress} className="h-2" />
      <p className="text-xs text-muted-foreground mt-1">{progress}% 완료</p>
    </div>
  );
}
```

---

## Phase 2: 코드 실행 환경 구축 (1주, 40시간)

### 2.1 Monaco Editor 통합
**우선순위**: P0
**예상 시간**: 6시간

**Task 2.1.1**: Monaco 설치 및 설정 (3h)
```bash
npm install @monaco-editor/react
```

```tsx
// components/CodeEditor.tsx
import Editor from '@monaco-editor/react';

export function CodeEditor({ initialCode, language }) {
  const [code, setCode] = useState(initialCode);

  return (
    <Editor
      height="400px"
      language={language}
      value={code}
      onChange={(value) => setCode(value || '')}
      theme="vs-dark"
      options={{
        minimap: { enabled: false },
        fontSize: 14,
      }}
    />
  );
}
```

**Task 2.1.2**: 코드 리셋 기능 (1h)
```tsx
<Button onClick={() => setCode(initialCode)}>
  <RotateCcw className="mr-2 h-4 w-4" /> 리셋
</Button>
```

**Task 2.1.3**: 테마 전환 (2h)
```tsx
const theme = useTheme();
<Editor theme={theme === 'dark' ? 'vs-dark' : 'vs-light'} />
```

---

### 2.2 JavaScript/TypeScript 실행
**우선순위**: P0
**예상 시간**: 8시간

**Task 2.2.1**: Web Worker 샌드박스 (5h)
```typescript
// lib/executor/jsExecutor.ts
export function executeJS(code: string): Promise<string> {
  return new Promise((resolve, reject) => {
    const worker = new Worker('/workers/jsWorker.js');

    worker.postMessage({ code });
    worker.onmessage = (e) => {
      resolve(e.data.output);
      worker.terminate();
    };

    setTimeout(() => {
      worker.terminate();
      reject('Timeout');
    }, 5000);
  });
}
```

**Task 2.2.2**: 콘솔 출력 캡처 (2h)
```javascript
// public/workers/jsWorker.js
self.onmessage = function(e) {
  const logs = [];
  const console = {
    log: (...args) => logs.push(args.join(' '))
  };

  try {
    eval(e.data.code);
    self.postMessage({ output: logs.join('\n') });
  } catch (err) {
    self.postMessage({ error: err.message });
  }
};
```

**Task 2.2.3**: 에러 핸들링 UI (1h)
```tsx
{error && (
  <Alert variant="destructive">
    <AlertCircle className="h-4 w-4" />
    <AlertTitle>실행 오류</AlertTitle>
    <AlertDescription>{error}</AlertDescription>
  </Alert>
)}
```

---

### 2.3 Python 실행 (Pyodide)
**우선순위**: P1
**예상 시간**: 12시간

**Task 2.3.1**: Pyodide 로딩 (4h)
```typescript
// lib/executor/pythonExecutor.ts
let pyodide: any = null;

export async function loadPyodide() {
  if (!pyodide) {
    pyodide = await (window as any).loadPyodide();
  }
  return pyodide;
}

export async function executePython(code: string): Promise<string> {
  const py = await loadPyodide();

  try {
    await py.runPythonAsync(code);
    return py.globals.get('output') || 'Done';
  } catch (err) {
    throw new Error(err.message);
  }
}
```

**Task 2.3.2**: CDN 스크립트 로드 (2h)
```tsx
// app/layout.tsx
<Script src="https://cdn.jsdelivr.net/pyodide/v0.24.1/full/pyodide.js" />
```

**Task 2.3.3**: 로딩 UI (2h)
```tsx
{isLoading && (
  <div className="flex items-center gap-2">
    <Loader2 className="h-4 w-4 animate-spin" />
    <span>Python 환경 로딩 중...</span>
  </div>
)}
```

**Task 2.3.4**: stdout 리다이렉션 (4h)
```python
# Pyodide에서 print() 캡처
import sys
from io import StringIO

sys.stdout = StringIO()
# 사용자 코드 실행
output = sys.stdout.getvalue()
```

---

### 2.4 통합 실행 컴포넌트
**우선순위**: P0
**예상 시간**: 6시간

**Task 2.4.1**: 언어 감지 및 실행 (3h)
```tsx
// components/CodeExecutor.tsx
export function CodeExecutor({ code, language }: Props) {
  const [output, setOutput] = useState('');
  const [isRunning, setIsRunning] = useState(false);

  const handleRun = async () => {
    setIsRunning(true);
    try {
      let result = '';
      if (language === 'javascript') {
        result = await executeJS(code);
      } else if (language === 'python') {
        result = await executePython(code);
      }
      setOutput(result);
    } catch (err) {
      setOutput(`Error: ${err.message}`);
    } finally {
      setIsRunning(false);
    }
  };

  return (
    <div>
      <Button onClick={handleRun} disabled={isRunning}>
        {isRunning ? <Loader2 className="animate-spin" /> : <Play />}
        실행
      </Button>
      <pre className="mt-4 p-4 bg-muted rounded">{output}</pre>
    </div>
  );
}
```

**Task 2.4.2**: 실행 결과 포맷팅 (2h)
```tsx
import { Tabs } from '@/components/ui/tabs';

<Tabs defaultValue="output">
  <TabsList>
    <TabsTrigger value="output">출력</TabsTrigger>
    <TabsTrigger value="logs">로그</TabsTrigger>
  </TabsList>
  <TabsContent value="output">
    <CodeViewer code={output} language="text" />
  </TabsContent>
</Tabs>
```

**Task 2.4.3**: 테스트 (1h)
- JavaScript 예제 10개 실행 검증
- Python 예제 5개 실행 검증

---

### 2.5 Java 실행 (선택사항)
**우선순위**: P2
**예상 시간**: 8시간

**Option A**: Judge0 API 연동 (4h)
```typescript
// lib/executor/javaExecutor.ts
export async function executeJava(code: string): Promise<string> {
  const response = await fetch('https://judge0-ce.p.rapidapi.com/submissions', {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      'X-RapidAPI-Key': process.env.NEXT_PUBLIC_JUDGE0_KEY!,
    },
    body: JSON.stringify({
      source_code: code,
      language_id: 62, // Java
    }),
  });

  // 결과 폴링...
}
```

**Option B**: 실행 불가 안내 (1h)
```tsx
{language === 'java' && (
  <Alert>
    <Info className="h-4 w-4" />
    <AlertDescription>
      Java 코드는 브라우저에서 직접 실행할 수 없습니다.
      로컬 환경에서 실행해주세요.
    </AlertDescription>
  </Alert>
)}
```

---

## Phase 3: 고급 기능 및 최적화 (1주, 40시간)

### 3.1 검색 기능
**우선순위**: P1
**예상 시간**: 8시간

**Task 3.1.1**: Fuse.js 통합 (4h)
```typescript
// lib/search.ts
import Fuse from 'fuse.js';

export function searchSteps(query: string, allSteps: Step[]) {
  const fuse = new Fuse(allSteps, {
    keys: ['title', 'goal', 'category'],
    threshold: 0.3,
  });

  return fuse.search(query);
}
```

**Task 3.1.2**: 검색 UI (4h)
```tsx
// components/SearchBar.tsx
import { Command, CommandInput, CommandList, CommandItem } from '@/components/ui/command';

export function SearchBar() {
  const [query, setQuery] = useState('');
  const results = searchSteps(query, allSteps);

  return (
    <Command>
      <CommandInput placeholder="검색..." value={query} onChange={setQuery} />
      <CommandList>
        {results.map(result => (
          <CommandItem key={result.item.id} onSelect={() => navigate(result.item)}>
            {result.item.title}
          </CommandItem>
        ))}
      </CommandList>
    </Command>
  );
}
```

---

### 3.2 다크모드
**우선순위**: P1
**예상 시간**: 4시간

**Task 3.2.1**: next-themes 설정 (2h)
```tsx
// app/layout.tsx
import { ThemeProvider } from 'next-themes';

<ThemeProvider attribute="class" defaultTheme="dark">
  {children}
</ThemeProvider>
```

**Task 3.2.2**: 토글 버튼 (2h)
```tsx
// components/ThemeToggle.tsx
import { useTheme } from 'next-themes';
import { Moon, Sun } from 'lucide-react';

export function ThemeToggle() {
  const { theme, setTheme } = useTheme();

  return (
    <Button onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}>
      {theme === 'dark' ? <Sun /> : <Moon />}
    </Button>
  );
}
```

---

### 3.3 반응형 디자인
**우선순위**: P1
**예상 시간**: 8시간

**Task 3.3.1**: 모바일 사이드바 (4h)
```tsx
// components/MobileSidebar.tsx
import { Sheet, SheetContent, SheetTrigger } from '@/components/ui/sheet';

export function MobileSidebar() {
  return (
    <Sheet>
      <SheetTrigger asChild>
        <Button variant="ghost" className="md:hidden">
          <Menu className="h-5 w-5" />
        </Button>
      </SheetTrigger>
      <SheetContent side="left">
        <Sidebar />
      </SheetContent>
    </Sheet>
  );
}
```

**Task 3.3.2**: 브레이크포인트 조정 (2h)
```tsx
<div className="hidden md:block w-64">
  <Sidebar />
</div>
<div className="md:hidden">
  <MobileSidebar />
</div>
```

**Task 3.3.3**: 모바일 테스트 (2h)
- Chrome DevTools 반응형 모드
- 실제 모바일 디바이스 테스트

---

### 3.4 학습 이력 시각화
**우선순위**: P2
**예상 시간**: 8시간

**Task 3.4.1**: 타임라인 컴포넌트 (5h)
```tsx
// components/LearningTimeline.tsx
import { format } from 'date-fns';

export function LearningTimeline({ history }: { history: HistoryEntry[] }) {
  return (
    <div className="space-y-4">
      {history.map(entry => (
        <div key={entry.id} className="flex gap-4">
          <div className="flex flex-col items-center">
            <div className="w-2 h-2 bg-primary rounded-full" />
            <div className="w-px h-full bg-border" />
          </div>
          <div>
            <p className="font-medium">{entry.stepTitle}</p>
            <p className="text-sm text-muted-foreground">
              {format(entry.completedAt, 'yyyy-MM-dd HH:mm')}
            </p>
          </div>
        </div>
      ))}
    </div>
  );
}
```

**Task 3.4.2**: 통계 대시보드 (3h)
```tsx
// app/dashboard/page.tsx
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';

export default function Dashboard() {
  const stats = useProgress(state => state.getStats());

  return (
    <div className="grid grid-cols-3 gap-4">
      <Card>
        <CardHeader>
          <CardTitle>완료한 Step</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-4xl font-bold">{stats.completedSteps}</p>
        </CardContent>
      </Card>
      {/* 추가 통계... */}
    </div>
  );
}
```

---

### 3.5 성능 최적화
**우선순위**: P1
**예상 시간**: 6시간

**Task 3.5.1**: 이미지 최적화 (1h)
```tsx
import Image from 'next/image';
<Image src="/logo.png" width={200} height={50} alt="Logo" />
```

**Task 3.5.2**: 코드 스플리팅 (2h)
```tsx
import dynamic from 'next/dynamic';

const CodeEditor = dynamic(() => import('@/components/CodeEditor'), {
  loading: () => <Skeleton className="h-96" />,
  ssr: false,
});
```

**Task 3.5.3**: 번들 분석 (1h)
```bash
npm install @next/bundle-analyzer
```

**Task 3.5.4**: Lighthouse 점수 개선 (2h)
- 목표: Performance 90+, Accessibility 100, SEO 100

---

### 3.6 배포
**우선순위**: P0
**예상 시간**: 4시간

**Task 3.6.1**: Vercel 배포 (2h)
```bash
vercel --prod
```

**Task 3.6.2**: 환경변수 설정 (1h)
```env
NEXT_PUBLIC_JUDGE0_KEY=...
```

**Task 3.6.3**: 도메인 연결 (선택, 1h)
```
learning-code.vercel.app → custom domain
```

---

### 3.7 문서화
**우선순위**: P1
**예상 시간**: 2시간

**Task 3.7.1**: README.md 작성
```markdown
# Learning Code Web Platform

## 로컬 실행
\`\`\`bash
npm install
npm run dev
\`\`\`

## 학습 자료 추가 방법
1. `learning-code/{category}/` 폴더에 Step 파일 추가
2. `{category}_learning_plan.md` 업데이트
3. `npm run generate-data` 실행
```

**Task 3.7.2**: 사용자 가이드 페이지 (선택)

---

## 우선순위 요약

| Priority | Tasks | Total Hours |
|----------|-------|-------------|
| P0 (필수) | 프로젝트 초기화, 파일 파싱, 레이아웃, 코드 뷰어, JS 실행, 배포 | 80h |
| P1 (중요) | 진행률 추적, Python 실행, 검색, 다크모드, 반응형, 최적화 | 32h |
| P2 (선택) | Java 실행, 학습 이력 시각화 | 16h |

---

## 체크리스트

### Week 1 완료 기준
- [ ] Next.js 프로젝트 실행 가능
- [ ] 모든 학습 자료 파일 파싱 성공
- [ ] 사이드바에서 카테고리/Step 선택 가능
- [ ] 선택한 Step의 코드 문법 하이라이팅 표시
- [ ] Bad/Good 탭 전환 동작
- [ ] LocalStorage에 진행률 저장

### Week 2 완료 기준
- [ ] Monaco Editor로 코드 편집 가능
- [ ] JavaScript 코드 실행 및 결과 출력
- [ ] Python 코드 실행 (Pyodide)
- [ ] 에러 발생 시 메시지 표시
- [ ] 코드 리셋 기능 동작

### Week 3 완료 기준
- [ ] 검색 기능 동작
- [ ] 다크모드 전환 가능
- [ ] 모바일에서 정상 동작
- [ ] Vercel 배포 완료
- [ ] README.md 작성
