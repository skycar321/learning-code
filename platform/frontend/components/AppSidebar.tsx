"use client";

import { useEffect, useState, useMemo } from "react";
import { useRouter } from "next/navigation";
import { cn } from "@/lib/utils";

// API Response Types (DTO)
type FileMeta = {
  name: string;
  title: string;
  path: string; // "frameworks/General/Overview.md"
};

type SubCategory = {
  name: string;
  files: FileMeta[];
};

type Category = {
  name: string;
  subcategories: SubCategory[];
};

type TreeResponse = Category[];

/**
 * [Sidebar Component]
 * Rust API (/api/tree)에서 파일 구조를 받아와 트리 형태로 렌더링합니다.
 */
export default function AppSidebar() {
  const [data, setData] = useState<TreeResponse>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const router = useRouter();

  // 1. Fetch Tree Data on Mount
  useEffect(() => {
    const controller = new AbortController();

    const load = async () => {
      setLoading(true);
      setError(null);
      try {
        const res = await fetch("http://localhost:8080/api/tree", { 
            signal: controller.signal,
            headers: { 'Accept': 'application/json' }
        });
        
        if (!res.ok) throw new Error(`Request failed: ${res.status}`);
        
        const json: TreeResponse = await res.json();
        setData(json ?? []);
      } catch (err: any) {
        if (err.name !== "AbortError") {
            console.error("Sidebar load error:", err);
            setError(err.message || "Failed to load sidebar");
        }
      } finally {
        setLoading(false);
      }
    };

    load();
    return () => controller.abort();
  }, []);

  const handleFileClick = (file: FileMeta) => {
    // Navigate to /view/[...path]
    // path from API: "category/subcategory/filename"
    router.push(`/view/${file.path}`);
  };

  if (loading) {
    return (
      <aside className="w-64 shrink-0 border-r bg-slate-50 text-slate-800 p-4">
        <div className="text-sm text-slate-500 animate-pulse">Loading tree...</div>
      </aside>
    );
  }

  if (error) {
    return (
      <aside className="w-64 shrink-0 border-r bg-red-50 text-red-800 p-4">
        <div className="text-sm font-bold">Error</div>
        <div className="text-xs">{error}</div>
      </aside>
    );
  }

  return (
    <aside className="w-72 shrink-0 border-r bg-white dark:bg-slate-900 text-slate-900 dark:text-slate-100 overflow-y-auto h-screen sticky top-0">
      <div className="p-4 font-bold text-lg border-b dark:border-slate-800 flex items-center gap-2">
        <span>📚 Platform</span>
      </div>
      
      <nav className="p-2 space-y-4">
        {data.length === 0 ? (
          <p className="px-4 text-sm text-slate-500">No content available.</p>
        ) : (
          <ul className="space-y-1">
            {data.map((cat) => (
              <CategoryItem key={cat.name} node={cat} onFileClick={handleFileClick} />
            ))}
          </ul>
        )}
      </nav>
    </aside>
  );
}

// ----------------------------------------------------------------------
// Sub-components for recursive rendering
// ----------------------------------------------------------------------

function CategoryItem({ node, onFileClick }: { node: Category; onFileClick: (f: FileMeta) => void }) {
  const [isOpen, setIsOpen] = useState(true); // Default open

  return (
    <li>
      <button 
        onClick={() => setIsOpen(!isOpen)}
        className="flex items-center w-full px-2 py-1.5 text-xs font-bold text-slate-500 uppercase tracking-wider hover:bg-slate-100 dark:hover:bg-slate-800 rounded mb-1"
      >
        <span className={cn("mr-2 transition-transform", isOpen ? "rotate-90" : "")}>▶</span>
        {node.name}
      </button>

      {isOpen && (
        <ul className="pl-2 space-y-2 border-l border-slate-100 dark:border-slate-800 ml-3">
          {node.subcategories.map((sub) => (
            <SubCategoryItem key={sub.name} node={sub} onFileClick={onFileClick} />
          ))}
        </ul>
      )}
    </li>
  );
}

function SubCategoryItem({ node, onFileClick }: { node: SubCategory; onFileClick: (f: FileMeta) => void }) {
    const [isOpen, setIsOpen] = useState(false); // Subcategories closed by default

    return (
        <li>
            <button 
                onClick={() => setIsOpen(!isOpen)}
                className="flex items-center w-full px-2 py-1 text-sm font-medium text-slate-700 dark:text-slate-300 hover:text-blue-600 dark:hover:text-blue-400 rounded transition-colors"
            >
                <span className="mr-2 text-slate-400">{isOpen ? "📂" : "📁"}</span>
                {node.name}
            </button>

            {isOpen && (
                <ul className="pl-4 mt-1 space-y-0.5">
                    {node.files.map((file) => (
                        <li key={file.path}>
                            <button
                                onClick={() => onFileClick(file)}
                                className="w-full text-left px-2 py-1 text-[13px] text-slate-600 dark:text-slate-400 hover:bg-blue-50 dark:hover:bg-blue-900/20 hover:text-blue-600 dark:hover:text-blue-300 rounded truncate"
                                title={file.title}
                            >
                                📄 {file.title}
                            </button>
                        </li>
                    ))}
                </ul>
            )}
        </li>
    );
}