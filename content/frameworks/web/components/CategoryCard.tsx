"use client";

import Link from "next/link";
import { Category } from "@/types/learning";
import { useProgressStore } from "@/stores/progressStore";

interface CategoryCardProps {
  category: Category;
}

export default function CategoryCard({ category }: CategoryCardProps) {
  const { getCompletedCount } = useProgressStore();

  const completedSteps = getCompletedCount(category.id);
  const totalSteps = category.steps.length;
  const progress = totalSteps > 0 ? Math.round((completedSteps / totalSteps) * 100) : 0;

  const getEmoji = (id: string) => {
    const emojiMap: Record<string, string> = {
      java: "☕",
      vue3: "💚",
      python: "🐍",
      springboot: "🍃",
    };
    return emojiMap[id] || "📚";
  };

  return (
    <Link
      href={`/learn/${category.id}`}
      className="block p-6 bg-white dark:bg-gray-800 rounded-xl shadow-lg hover:shadow-xl transition-all hover:scale-105"
    >
      <div className="flex items-start justify-between mb-4">
        <div>
          <h3 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">
            {category.displayName}
          </h3>
          <p className="text-gray-600 dark:text-gray-400 text-sm">
            {category.description}
          </p>
        </div>
        <div className="text-3xl">{getEmoji(category.id)}</div>
      </div>

      {/* Progress Bar */}
      <div className="space-y-2">
        <div className="flex justify-between text-sm text-gray-600 dark:text-gray-400">
          <span>
            {completedSteps} / {totalSteps} 완료
          </span>
          <span>{progress}%</span>
        </div>
        <div className="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2">
          <div
            className="bg-blue-600 h-2 rounded-full transition-all"
            style={{ width: `${progress}%` }}
          />
        </div>
      </div>

      {/* Steps Count */}
      <div className="mt-4 flex gap-2">
        <span className="px-3 py-1 bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 rounded-full text-sm font-medium">
          {totalSteps} Steps
        </span>
        {completedSteps === totalSteps && totalSteps > 0 && (
          <span className="px-3 py-1 bg-green-100 dark:bg-green-900 text-green-800 dark:text-green-200 rounded-full text-sm font-medium">
            ✓ 완료
          </span>
        )}
      </div>
    </Link>
  );
}
