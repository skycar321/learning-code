import { sampleCategories } from "@/lib/sampleData";
import CategoryCard from "@/components/CategoryCard";

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 dark:from-gray-900 dark:to-gray-800">
      {/* Header */}
      <header className="border-b bg-white/80 dark:bg-gray-900/80 backdrop-blur-sm">
        <div className="container mx-auto px-4 py-6">
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
            Learning Code
          </h1>
          <p className="text-gray-600 dark:text-gray-300 mt-1">
            인터랙티브 프로그래밍 학습 플랫폼
          </p>
        </div>
      </header>

      {/* Main Content */}
      <main className="container mx-auto px-4 py-12">
        <div className="max-w-4xl mx-auto">
          {/* Welcome Section */}
          <div className="text-center mb-12">
            <h2 className="text-4xl font-bold text-gray-900 dark:text-white mb-4">
              Good vs Bad Practice
            </h2>
            <p className="text-xl text-gray-600 dark:text-gray-300">
              코드 비교를 통한 체계적인 학습 경험
            </p>
          </div>

          {/* Categories Grid */}
          <div className="grid md:grid-cols-2 gap-6 mb-12">
            {sampleCategories.map((category) => (
              <CategoryCard key={category.id} category={category} />
            ))}
          </div>

          {/* Features */}
          <div className="grid md:grid-cols-3 gap-6">
            <div className="text-center p-6 bg-white/50 dark:bg-gray-800/50 rounded-lg">
              <div className="text-4xl mb-3">📚</div>
              <h3 className="font-bold text-gray-900 dark:text-white mb-2">구조화된 학습</h3>
              <p className="text-sm text-gray-600 dark:text-gray-400">
                Step별 체계적인 학습 경로
              </p>
            </div>
            <div className="text-center p-6 bg-white/50 dark:bg-gray-800/50 rounded-lg">
              <div className="text-4xl mb-3">🔄</div>
              <h3 className="font-bold text-gray-900 dark:text-white mb-2">코드 비교</h3>
              <p className="text-sm text-gray-600 dark:text-gray-400">
                Bad vs Good 패턴 비교
              </p>
            </div>
            <div className="text-center p-6 bg-white/50 dark:bg-gray-800/50 rounded-lg">
              <div className="text-4xl mb-3">▶️</div>
              <h3 className="font-bold text-gray-900 dark:text-white mb-2">코드 실행</h3>
              <p className="text-sm text-gray-600 dark:text-gray-400">
                브라우저에서 직접 실행
              </p>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
