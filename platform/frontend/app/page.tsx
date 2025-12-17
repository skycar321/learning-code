export default function HomePage() {
  return (
    <div className="flex flex-col items-center justify-center min-h-[60vh] text-center space-y-6">
      <div className="p-6 bg-blue-50 dark:bg-blue-900/20 rounded-full animate-bounce">
        <span className="text-4xl">🚀</span>
      </div>
      
      <h1 className="text-4xl font-extrabold text-slate-900 dark:text-slate-100 tracking-tight">
        Welcome to Learning Platform
      </h1>
      
      <p className="text-lg text-slate-600 dark:text-slate-400 max-w-lg">
        Select a topic from the sidebar to start learning.
        <br />
        Powered by <strong>Rust Backend</strong> & <strong>Next.js Frontend</strong>.
      </p>

      <div className="flex gap-4 pt-4">
        <a href="/view/frameworks/General/Overview.md" className="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-medium transition-colors shadow-lg shadow-blue-500/20">
          Get Started
        </a>
        <a href="https://github.com/your-repo" target="_blank" className="px-6 py-2.5 border border-slate-200 dark:border-slate-700 hover:bg-slate-50 dark:hover:bg-slate-800 rounded-lg font-medium transition-colors">
          GitHub
        </a>
      </div>
    </div>
  );
}
