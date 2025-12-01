"use client";

import { useProgressStore } from "@/stores/progressStore";

interface CompleteButtonProps {
  stepId: string;
}

export default function CompleteButton({ stepId }: CompleteButtonProps) {
  const { isStepCompleted, toggleStepComplete } = useProgressStore();
  const isCompleted = isStepCompleted(stepId);

  return (
    <button
      onClick={() => toggleStepComplete(stepId)}
      className={`px-6 py-3 rounded-lg font-medium transition-all ${
        isCompleted
          ? "bg-green-600 hover:bg-green-700 text-white"
          : "bg-gray-200 dark:bg-gray-700 hover:bg-gray-300 dark:hover:bg-gray-600 text-gray-900 dark:text-white"
      }`}
    >
      {isCompleted ? (
        <span className="flex items-center gap-2">
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
          </svg>
          완료함
        </span>
      ) : (
        <span className="flex items-center gap-2">
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          학습 완료로 표시
        </span>
      )}
    </button>
  );
}
