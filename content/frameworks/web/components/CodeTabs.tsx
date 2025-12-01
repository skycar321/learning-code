"use client";

import { useState } from "react";
import { Prism as SyntaxHighlighter } from "react-syntax-highlighter";
import { vscDarkPlus } from "react-syntax-highlighter/dist/cjs/styles/prism";
import { CodeSection } from "@/types/learning";

interface CodeTabsProps {
  code: CodeSection[];
}

export default function CodeTabs({ code }: CodeTabsProps) {
  const [activeTab, setActiveTab] = useState<"bad" | "good">("bad");

  const badCode = code.find((c) => c.type === "bad");
  const goodCode = code.find((c) => c.type === "good");

  // Bad/Good 코드가 모두 있는 경우에만 탭 표시
  const hasBothCodes = badCode && goodCode;

  if (!hasBothCodes) {
    // 하나만 있으면 그냥 표시
    const singleCode = badCode || goodCode;
    if (!singleCode) return null;

    return (
      <div className="rounded-lg overflow-hidden border border-gray-200 dark:border-gray-700">
        <SyntaxHighlighter
          language={singleCode.language}
          style={vscDarkPlus}
          customStyle={{
            margin: 0,
            borderRadius: 0,
            fontSize: "14px",
          }}
          showLineNumbers
        >
          {singleCode.content}
        </SyntaxHighlighter>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {/* Tab Buttons */}
      <div className="flex gap-2 border-b border-gray-200 dark:border-gray-700">
        <button
          onClick={() => setActiveTab("bad")}
          className={`px-6 py-3 font-medium transition-colors relative ${
            activeTab === "bad"
              ? "text-red-600 dark:text-red-400"
              : "text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-200"
          }`}
        >
          <span className="flex items-center gap-2">
            <span className="text-xl">❌</span>
            Bad Example
          </span>
          {activeTab === "bad" && (
            <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-red-600 dark:bg-red-400" />
          )}
        </button>

        <button
          onClick={() => setActiveTab("good")}
          className={`px-6 py-3 font-medium transition-colors relative ${
            activeTab === "good"
              ? "text-green-600 dark:text-green-400"
              : "text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-200"
          }`}
        >
          <span className="flex items-center gap-2">
            <span className="text-xl">✅</span>
            Good Example
          </span>
          {activeTab === "good" && (
            <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-green-600 dark:bg-green-400" />
          )}
        </button>
      </div>

      {/* Code Display */}
      <div className="rounded-lg overflow-hidden border border-gray-200 dark:border-gray-700">
        {activeTab === "bad" && badCode && (
          <div className="relative">
            <div className="absolute top-3 right-3 z-10">
              <span className="px-3 py-1 bg-red-100 dark:bg-red-900 text-red-800 dark:text-red-200 rounded-md text-sm font-medium">
                나쁜 예
              </span>
            </div>
            <SyntaxHighlighter
              language={badCode.language}
              style={vscDarkPlus}
              customStyle={{
                margin: 0,
                borderRadius: 0,
                fontSize: "14px",
                paddingTop: "3rem",
              }}
              showLineNumbers
            >
              {badCode.content}
            </SyntaxHighlighter>
          </div>
        )}

        {activeTab === "good" && goodCode && (
          <div className="relative">
            <div className="absolute top-3 right-3 z-10">
              <span className="px-3 py-1 bg-green-100 dark:bg-green-900 text-green-800 dark:text-green-200 rounded-md text-sm font-medium">
                좋은 예
              </span>
            </div>
            <SyntaxHighlighter
              language={goodCode.language}
              style={vscDarkPlus}
              customStyle={{
                margin: 0,
                borderRadius: 0,
                fontSize: "14px",
                paddingTop: "3rem",
              }}
              showLineNumbers
            >
              {goodCode.content}
            </SyntaxHighlighter>
          </div>
        )}
      </div>

      {/* Code Explanation (선택사항) */}
      <div className="flex items-center gap-2 text-sm text-gray-600 dark:text-gray-400">
        <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
          />
        </svg>
        <span>탭을 클릭하여 코드를 비교해보세요</span>
      </div>
    </div>
  );
}
