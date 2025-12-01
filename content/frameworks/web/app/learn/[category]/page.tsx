import { getCategoryById } from "@/lib/sampleData";
import Link from "next/link";
import { notFound } from "next/navigation";

interface PageProps {
  params: Promise<{
    category: string;
  }>;
}

export default async function CategoryPage({ params }: PageProps) {
  const { category: categoryId } = await params;
  const category = getCategoryById(categoryId);

  if (!category) {
    notFound();
  }

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      {/* Header */}
      <header className="border-b bg-white dark:bg-gray-800 sticky top-0 z-10">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center gap-4">
            <Link
              href="/"
              className="text-blue-600 hover:text-blue-700 dark:text-blue-400"
            >
              ← 홈으로
            </Link>
            <h1 className="text-2xl font-bold text-gray-900 dark:text-white">
              {category.displayName} 학습
            </h1>
          </div>
        </div>
      </header>

      {/* Main Layout */}
      <div className="container mx-auto px-4 py-8">
        <div className="max-w-6xl mx-auto">
          {/* Category Info */}
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6 mb-8">
            <div className="flex items-start justify-between">
              <div>
                <h2 className="text-3xl font-bold text-gray-900 dark:text-white mb-2">
                  {category.displayName}
                </h2>
                <p className="text-gray-600 dark:text-gray-400">
                  {category.description}
                </p>
              </div>
              <div className="text-5xl">
                {categoryId === "java" && "☕"}
                {categoryId === "vue3" && "💚"}
                {categoryId === "python" && "🐍"}
                {categoryId === "springboot" && "🍃"}
              </div>
            </div>
          </div>

          {/* Steps List */}
          <div className="space-y-4">
            <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-4">
              학습 Step ({category.steps.length}개)
            </h3>

            {category.steps.map((step) => (
              <Link
                key={step.id}
                href={`/learn/${categoryId}/step/${step.stepNumber}`}
                className="block"
              >
                <div className="bg-white dark:bg-gray-800 rounded-lg shadow hover:shadow-lg transition-all p-6 hover:scale-[1.02]">
                  <div className="flex items-start gap-4">
                    {/* Step Number */}
                    <div className="flex-shrink-0 w-12 h-12 bg-blue-100 dark:bg-blue-900 rounded-full flex items-center justify-center">
                      <span className="text-blue-800 dark:text-blue-200 font-bold">
                        {step.stepNumber}
                      </span>
                    </div>

                    {/* Step Info */}
                    <div className="flex-1">
                      <div className="flex items-center gap-3 mb-2">
                        <h4 className="text-lg font-bold text-gray-900 dark:text-white">
                          {step.title}
                        </h4>
                        <span
                          className={`px-3 py-1 rounded-full text-xs font-medium ${
                            step.status === "완료"
                              ? "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200"
                              : step.status === "진행중"
                              ? "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200"
                              : "bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-200"
                          }`}
                        >
                          {step.status}
                        </span>
                      </div>
                      <p className="text-gray-600 dark:text-gray-400 text-sm">
                        {step.goal}
                      </p>
                    </div>

                    {/* Arrow Icon */}
                    <div className="flex-shrink-0 text-gray-400">
                      <svg
                        className="w-6 h-6"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          strokeWidth={2}
                          d="M9 5l7 7-7 7"
                        />
                      </svg>
                    </div>
                  </div>
                </div>
              </Link>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
