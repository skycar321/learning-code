import { getStepById, getCategoryById } from "@/lib/sampleData";
import { notFound } from "next/navigation";
import Link from "next/link";
import CodeTabs from "@/components/CodeTabs";
import CompleteButton from "@/components/CompleteButton";

interface PageProps {
  params: Promise<{
    category: string;
    stepNumber: string;
  }>;
}

export default async function StepPage({ params }: PageProps) {
  const { category: categoryId, stepNumber } = await params;
  const stepNum = parseInt(stepNumber);

  const category = getCategoryById(categoryId);
  const step = getStepById(categoryId, stepNum);

  if (!step || !category) {
    notFound();
  }

  // 이전/다음 Step 찾기
  const currentIndex = category.steps.findIndex(s => s.stepNumber === stepNum);
  const prevStep = currentIndex > 0 ? category.steps[currentIndex - 1] : null;
  const nextStep = currentIndex < category.steps.length - 1 ? category.steps[currentIndex + 1] : null;

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      {/* Header */}
      <header className="border-b bg-white dark:bg-gray-800 sticky top-0 z-10">
        <div className="container mx-auto px-4 py-4">
          <div className="flex items-center gap-4">
            <Link
              href={`/learn/${categoryId}`}
              className="text-blue-600 hover:text-blue-700 dark:text-blue-400"
            >
              ← {category.displayName}
            </Link>
            <div className="flex-1">
              <h1 className="text-xl font-bold text-gray-900 dark:text-white">
                Step {step.stepNumber}: {step.title}
              </h1>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <div className="container mx-auto px-4 py-8">
        <div className="max-w-5xl mx-auto space-y-6">
          {/* Step Info */}
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
            <div className="flex items-start justify-between mb-4">
              <div>
                <div className="flex items-center gap-3 mb-2">
                  <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
                    {step.title}
                  </h2>
                  <span
                    className={`px-3 py-1 rounded-full text-sm font-medium ${
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
                <p className="text-gray-600 dark:text-gray-400">
                  <strong>학습 목표:</strong> {step.goal}
                </p>
              </div>
            </div>
          </div>

          {/* Code Comparison */}
          {step.code && step.code.length > 0 && (
            <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
              <h3 className="text-lg font-bold text-gray-900 dark:text-white mb-4">
                코드 비교
              </h3>
              <CodeTabs code={step.code} />
            </div>
          )}

          {/* Learning Points */}
          {step.learningPoints && step.learningPoints.length > 0 && (
            <div className="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg p-6">
              <h3 className="text-lg font-bold text-blue-900 dark:text-blue-100 mb-4 flex items-center gap-2">
                <span className="text-2xl">💡</span>
                학습 포인트
              </h3>
              <ul className="space-y-2">
                {step.learningPoints.map((point, index) => (
                  <li
                    key={index}
                    className="text-blue-800 dark:text-blue-200 flex gap-2"
                  >
                    <span className="flex-shrink-0">•</span>
                    <span>{point}</span>
                  </li>
                ))}
              </ul>
            </div>
          )}

          {/* Complete Button */}
          <div className="flex justify-center">
            <CompleteButton stepId={step.id} />
          </div>

          {/* Navigation */}
          <div className="flex justify-between items-center pt-6 border-t border-gray-200 dark:border-gray-700">
            <div>
              {prevStep ? (
                <Link
                  href={`/learn/${categoryId}/step/${prevStep.stepNumber}`}
                  className="inline-flex items-center gap-2 px-4 py-2 bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 rounded-lg transition-colors"
                >
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                  </svg>
                  <div className="text-left">
                    <div className="text-xs text-gray-500 dark:text-gray-400">이전</div>
                    <div className="font-medium text-gray-900 dark:text-white">
                      Step {prevStep.stepNumber}
                    </div>
                  </div>
                </Link>
              ) : (
                <div />
              )}
            </div>

            <div>
              {nextStep ? (
                <Link
                  href={`/learn/${categoryId}/step/${nextStep.stepNumber}`}
                  className="inline-flex items-center gap-2 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors"
                >
                  <div className="text-right">
                    <div className="text-xs text-blue-100">다음</div>
                    <div className="font-medium">
                      Step {nextStep.stepNumber}
                    </div>
                  </div>
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                  </svg>
                </Link>
              ) : (
                <Link
                  href={`/learn/${categoryId}`}
                  className="inline-flex items-center gap-2 px-4 py-2 bg-green-600 hover:bg-green-700 text-white rounded-lg transition-colors"
                >
                  <span>완료! 목록으로</span>
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                  </svg>
                </Link>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
