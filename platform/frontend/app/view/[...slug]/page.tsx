import React from "react";
import ReactMarkdown from "react-markdown";
import remarkGfm from "remark-gfm";
import Link from "next/link";

// Force dynamic rendering as API content changes
export const dynamic = "force-dynamic";

type ContentResponse = {
  title: string;
  content: string;
  file_type: string;
  prev?: { title: string; path: string };
  next?: { title: string; path: string };
};

async function getContent(path: string): Promise<ContentResponse | null> {
  try {
    const res = await fetch(`http://localhost:8080/api/content/${path}`, {
      cache: "no-store",
    });
    if (!res.ok) return null;
    return res.json();
  } catch (error) {
    console.error("Fetch error:", error);
    return null;
  }
}

export default async function ViewPage({ params }: { params: { slug: string[] } }) {
  const path = params.slug.join("/");
  const data = await getContent(path);

  if (!data) {
    return (
      <div className="p-10 text-center">
        <h1 className="text-2xl font-bold text-red-500">404 - Not Found</h1>
        <p className="text-slate-500 mt-2">The requested content could not be found.</p>
        <div className="mt-4 text-xs text-slate-400">Path: {path}</div>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto pb-20">
      {/* Header */}
      <header className="mb-8 border-b pb-4 dark:border-slate-800">
        <h1 className="text-3xl font-extrabold text-slate-900 dark:text-slate-100">{data.title}</h1>
        <div className="flex gap-2 mt-2 text-xs text-slate-400 font-mono">
            <span>{path}</span>
            <span>•</span>
            <span>{data.file_type}</span>
        </div>
      </header>

      {/* Content */}
      <article className="prose dark:prose-invert max-w-none">
        {data.file_type === "markdown" ? (
          <ReactMarkdown remarkPlugins={[remarkGfm]}>
            {data.content}
          </ReactMarkdown>
        ) : (
          <pre className="bg-slate-100 dark:bg-slate-900 p-4 rounded-lg overflow-x-auto">
            <code>{data.content}</code>
          </pre>
        )}
      </article>

      {/* Navigation Footer */}
      <footer className="mt-16 flex justify-between border-t pt-8 dark:border-slate-800">
        {data.prev ? (
          <Link
            href={`/view/${data.prev.path}`}
            className="flex flex-col items-start p-4 rounded-lg border border-slate-200 hover:border-blue-500 hover:bg-blue-50 dark:border-slate-800 dark:hover:bg-blue-900/20 transition-all group"
          >
            <span className="text-xs text-slate-400 group-hover:text-blue-500 mb-1">← Previous</span>
            <span className="font-semibold text-slate-700 dark:text-slate-300">{data.prev.title}</span>
          </Link>
        ) : <div />}

        {data.next ? (
          <Link
            href={`/view/${data.next.path}`}
            className="flex flex-col items-end p-4 rounded-lg border border-slate-200 hover:border-blue-500 hover:bg-blue-50 dark:border-slate-800 dark:hover:bg-blue-900/20 transition-all group"
          >
            <span className="text-xs text-slate-400 group-hover:text-blue-500 mb-1">Next →</span>
            <span className="font-semibold text-slate-700 dark:text-slate-300">{data.next.title}</span>
          </Link>
        ) : <div />}
      </footer>
    </div>
  );
}
