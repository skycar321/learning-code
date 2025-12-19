```jsx
// Step11_UseEffect_GoodBad.jsx
// ENGLISH ONLY. Demonstrates common useEffect anti-patterns vs correct patterns.

import React, { useEffect, useState, useRef } from 'react';

/* ---------- BAD: Infinite loop + missing cleanup ---------- */
export function BadInfiniteLoop() {
  const [tick, setTick] = useState(0);

  useEffect(() => {
    // BUG: setState runs on every render because there is NO dependency array.
    // Each setState triggers a re-render -> effect runs again -> infinite loop.
    setTick(tick + 1);

    // BUG: event listener is added on every render but never removed,
    // causing memory leaks and duplicated handlers.
    const onResize = () => console.log('window resized');
    window.addEventListener('resize', onResize);
  }); // ← no dependency array is the core issue

  return (
    <div style={{ border: '1px solid crimson', padding: 12 }}>
      <h3>Bad: Infinite Loop & Leak</h3>
      <p>Tick: {tick}</p>
      <p>Open console and resize window; handlers pile up.</p>
    </div>
  );
}

/* ---------- BAD: Stale closure in interval ---------- */
export function BadStaleClosure() {
  const [seconds, setSeconds] = useState(0);

  useEffect(() => {
    // BUG: seconds is captured as 0 forever because the dependency array is [].
    // setSeconds(seconds + 1) always sets it back to 1, so state stops advancing.
    const id = setInterval(() => setSeconds(seconds + 1), 1000);
    // BUG: missing cleanup -> interval continues after unmount, causing leaks.
  }, []); // seconds omitted -> stale closure

  return (
    <div style={{ border: '1px solid orange', padding: 12 }}>
      <h3>Bad: Stale Closure</h3>
      <p>Seconds should increase but will stick at 1.</p>
    </div>
  );
}

/* ---------- GOOD: Proper deps, cleanup, AbortController, and fresh state ---------- */
export function GoodEffectWithAbort({ query = 'react' }) {
  const [data, setData] = useState(null);
  const [seconds, setSeconds] = useState(0);
  const intervalRef = useRef(null);

  useEffect(() => {
    const controller = new AbortController();

    // KEEP DEP ARRAY MINIMAL: only values used inside that change.
    // Fetch respects AbortController; prevents memory leak and wasted work on fast re-renders/unmounts.
    async function load() {
      try {
        const res = await fetch(`https://api.example.com/search?q=${query}`, {
          signal: controller.signal,
        });
        if (!res.ok) throw new Error('Network error');
        const json = await res.json();
        setData(json);
      } catch (err) {
        // AbortError is expected during cleanup; ignore it.
        if (err.name !== 'AbortError') console.error(err);
      }
    }

    load();

    // Proper interval with functional update avoids stale closure.
    intervalRef.current = setInterval(() => {
      setSeconds((prev) => prev + 1); // functional form reads the latest state
    }, 1000);

    // CLEANUP: abort fetch, clear interval, remove listener if added.
    return () => {
      controller.abort(); // prevents setState on unmounted component and unnecessary network
      clearInterval(intervalRef.current);
      window.removeEventListener('resize', onResize);
    };
  }, [query]); // only rerun when query changes

  // Example of adding/removing listeners correctly.
  useEffect(() => {
    const onResize = () => console.log('resize handled once');
    window.addEventListener('resize', onResize);
    return () => window.removeEventListener('resize', onResize);
  }, []); // listener added once, cleaned up on unmount

  return (
    <div style={{ border: '1px solid green', padding: 12 }}>
      <h3>Good: Controlled Effect</h3>
      <p>Query: {query}</p>
      <p>Seconds alive: {seconds}</p>
      <pre style={{ background: '#f4f4f4', padding: 8 }}>
        {data ? JSON.stringify(data, null, 2) : 'Loading...'}
      </pre>
    </div>
  );
}

export default {
  BadInfiniteLoop,
  BadStaleClosure,
  GoodEffectWithAbort,
};
```
