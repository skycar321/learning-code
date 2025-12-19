```html
<!DOCTYPE html>
<html lang="en" class="h-full bg-white text-slate-900 dark:bg-slate-900 dark:text-slate-100">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Tailwind + Mermaid</title>

  <!-- Tailwind CDN (keep your existing setup if already present) -->
  <script src="https://cdn.tailwindcss.com"></script>

  <!-- Preserve existing dark-mode logic: set the initial class on <html> -->
  <script>
    (() => {
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
      const stored = localStorage.getItem('theme');
      const isDark = stored ? stored === 'dark' : prefersDark;
      document.documentElement.classList.toggle('dark', isDark);
    })();
  </script>

  <!-- Mermaid.js ESM (v10.x) -->
  <script type="module">
    import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@10.9.5/dist/mermaid.esm.min.mjs';

    const getMermaidTheme = () =>
      document.documentElement.classList.contains('dark') ? 'dark' : 'default';

    let currentTheme;

    const applyMermaid = () => {
      const nextTheme = getMermaidTheme();
      if (nextTheme === currentTheme) return;
      currentTheme = nextTheme;
      mermaid.initialize({ startOnLoad: true, theme: nextTheme });
      // Re-run to refresh existing diagrams when the theme flips
      mermaid.run({ querySelector: '.mermaid' });
    };

    // Initial setup
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', applyMermaid, { once: true });
    } else {
      applyMermaid();
    }

    // React to class changes on <html> (works with existing dark-mode toggles)
    const observer = new MutationObserver(applyMermaid);
    observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['class', 'data-theme'],
    });

    // Optional: listen for a custom 'themechange' event if your app emits one
    window.addEventListener('themechange', applyMermaid);
  </script>
</head>

<body class="min-h-screen">
  <div class="mx-auto max-w-3xl px-6 py-10">
    <header class="flex items-center justify-between mb-8">
      <div>
        <p class="text-sm uppercase tracking-wide text-slate-500 dark:text-slate-400">Demo</p>
        <h1 class="text-3xl font-bold">Mermaid + Tailwind</h1>
        <p class="text-slate-600 dark:text-slate-300">
          Mermaid diagrams honor the current theme (light/dark).
        </p>
      </div>
      <!-- Example toggle button (hook into your existing logic as needed) -->
      <button
        class="rounded-full border border-slate-300 px-4 py-2 text-sm text-slate-700 hover:bg-slate-100 dark:border-slate-600 dark:text-slate-100 dark:hover:bg-slate-800"
        aria-label="Toggle theme"
        onclick="
          const html = document.documentElement;
          const nowDark = !html.classList.contains('dark');
          html.classList.toggle('dark', nowDark);
          localStorage.setItem('theme', nowDark ? 'dark' : 'light');
          window.dispatchEvent(new Event('themechange'));
        "
      >
        Toggle Theme
      </button>
    </header>

    <section class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-700 dark:bg-slate-800">
      <h2 class="mb-4 text-xl font-semibold">Sample Diagram</h2>
      <div class="mermaid">
        graph TD;
          A[Start] --> B{Decision};
          B -->|Yes| C[Continue];
          B -->|No| D[Stop];
          C --> E[Finish];
          D --> E;
      </div>
    </section>
  </div>
</body>
</html>
```
