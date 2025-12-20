/**
 * Advanced Step 1: React Server Components (RSC)
 *
 * 이 파일은 React 18+의 Server Components 개념과 활용법을 학습합니다.
 * 서버에서 렌더링되는 컴포넌트로 번들 크기 감소와 성능 향상을 달성합니다.
 *
 * 학습 목표:
 * 1. Server Components vs Client Components 이해
 * 2. Next.js 13+ App Router에서의 활용
 * 3. 데이터 페칭 패턴
 * 4. 성능 최적화 전략
 *
 * 주의: Server Components는 Next.js 13+ 또는 다른 RSC 지원 프레임워크에서 사용해야 합니다.
 *
 * @author Learning Code Project
 */

// ============================================================
// 1. Server Components vs Client Components 개념
// ============================================================

/*
 * Server Components (서버 컴포넌트):
 * - 서버에서만 실행되고 렌더링됨
 * - JavaScript 번들에 포함되지 않음
 * - 직접 데이터베이스/파일시스템 접근 가능
 * - useState, useEffect 등 훅 사용 불가
 * - 이벤트 핸들러 사용 불가
 *
 * Client Components (클라이언트 컴포넌트):
 * - 브라우저에서 실행됨 (하이드레이션)
 * - JavaScript 번들에 포함됨
 * - useState, useEffect 등 훅 사용 가능
 * - 이벤트 핸들러, 브라우저 API 사용 가능
 * - 'use client' 디렉티브로 선언
 */

// ============================================================
// 2. 나쁜 예시: 모든 컴포넌트를 Client로 만들기
// ============================================================

// [나쁜 예시] 불필요하게 'use client' 사용
const BadClientComponent = `
// ❌ 나쁜 예시: 정적 콘텐츠인데 Client Component로 선언
'use client'  // 불필요!

import { formatDate } from '@/utils/date'

export default function ArticleCard({ article }) {
  // 상태나 이벤트 핸들러가 없음
  // 서버 컴포넌트로 충분함

  return (
    <article className="card">
      <h2>{article.title}</h2>
      <p>{article.excerpt}</p>
      <time>{formatDate(article.date)}</time>
    </article>
  )
}

/*
 * 문제점:
 * 1. 불필요하게 JavaScript 번들 크기 증가
 * 2. formatDate 유틸리티도 번들에 포함됨
 * 3. 초기 로딩 시간 증가
 */
`

// ============================================================
// 3. 좋은 예시: Server Component 활용
// ============================================================

// [좋은 예시] Server Component (기본값)
const GoodServerComponent = `
// ✅ 좋은 예시: Server Component (기본값, 'use client' 없음)
// app/articles/page.jsx

import { getArticles } from '@/lib/db'  // 직접 DB 접근!

export default async function ArticlesPage() {
  // 서버에서 직접 데이터 페칭 (API 호출 불필요)
  const articles = await getArticles()

  return (
    <main>
      <h1>Articles</h1>
      <div className="grid">
        {articles.map(article => (
          <ArticleCard key={article.id} article={article} />
        ))}
      </div>
    </main>
  )
}

// 이 컴포넌트도 Server Component
function ArticleCard({ article }) {
  return (
    <article className="card">
      <h2>{article.title}</h2>
      <p>{article.excerpt}</p>
      <time>{formatDate(article.date)}</time>
    </article>
  )
}

/*
 * 장점:
 * 1. JavaScript 번들에 포함되지 않음 (0KB)
 * 2. formatDate 유틸리티도 서버에서만 실행
 * 3. 데이터베이스 직접 접근으로 API 레이어 불필요
 * 4. 빠른 초기 로딩
 */
`

// [좋은 예시] 서버와 클라이언트 컴포넌트 조합
const MixedComponents = `
// ✅ 서버 컴포넌트에서 클라이언트 컴포넌트 사용

// app/articles/[id]/page.jsx (Server Component)
import { getArticle, getComments } from '@/lib/db'
import LikeButton from '@/components/LikeButton'  // Client Component
import CommentForm from '@/components/CommentForm'  // Client Component

export default async function ArticlePage({ params }) {
  const article = await getArticle(params.id)
  const comments = await getComments(params.id)

  return (
    <article>
      {/* 정적 콘텐츠 - 서버에서 렌더링 */}
      <h1>{article.title}</h1>
      <div dangerouslySetInnerHTML={{ __html: article.content }} />

      {/* 인터랙티브 요소 - 클라이언트 컴포넌트 */}
      <LikeButton articleId={article.id} initialLikes={article.likes} />

      {/* 댓글 목록 - 서버에서 렌더링 */}
      <section>
        <h2>Comments ({comments.length})</h2>
        {comments.map(comment => (
          <CommentCard key={comment.id} comment={comment} />
        ))}
      </section>

      {/* 댓글 폼 - 클라이언트 컴포넌트 */}
      <CommentForm articleId={article.id} />
    </article>
  )
}

// components/LikeButton.jsx (Client Component)
'use client'

import { useState, useTransition } from 'react'
import { likeArticle } from '@/actions/articles'

export default function LikeButton({ articleId, initialLikes }) {
  const [likes, setLikes] = useState(initialLikes)
  const [isPending, startTransition] = useTransition()

  const handleLike = () => {
    startTransition(async () => {
      const newLikes = await likeArticle(articleId)
      setLikes(newLikes)
    })
  }

  return (
    <button onClick={handleLike} disabled={isPending}>
      ❤️ {likes} {isPending && '...'}
    </button>
  )
}
`

// ============================================================
// 4. 데이터 페칭 패턴
// ============================================================

const DataFetchingPatterns = `
// Pattern 1: 병렬 데이터 페칭
// app/dashboard/page.jsx (Server Component)

async function getUser() {
  const res = await fetch('/api/user')
  return res.json()
}

async function getStats() {
  const res = await fetch('/api/stats')
  return res.json()
}

async function getNotifications() {
  const res = await fetch('/api/notifications')
  return res.json()
}

export default async function DashboardPage() {
  // ✅ 병렬로 데이터 페칭 (빠름)
  const [user, stats, notifications] = await Promise.all([
    getUser(),
    getStats(),
    getNotifications()
  ])

  return (
    <main>
      <UserProfile user={user} />
      <StatsCard stats={stats} />
      <NotificationList notifications={notifications} />
    </main>
  )
}

// ❌ 나쁜 예시: 순차 데이터 페칭 (느림)
// const user = await getUser()
// const stats = await getStats()  // user 완료 후 시작
// const notifications = await getNotifications()  // stats 완료 후 시작


// Pattern 2: Streaming with Suspense
// app/products/page.jsx

import { Suspense } from 'react'

export default async function ProductsPage() {
  return (
    <main>
      {/* 빠르게 로드되는 콘텐츠 */}
      <h1>Products</h1>

      {/* 느린 데이터는 Suspense로 스트리밍 */}
      <Suspense fallback={<ProductsSkeleton />}>
        <ProductList />
      </Suspense>

      <Suspense fallback={<RecommendationsSkeleton />}>
        <Recommendations />
      </Suspense>
    </main>
  )
}

// 비동기 서버 컴포넌트
async function ProductList() {
  const products = await getProducts()  // 느린 DB 쿼리

  return (
    <div className="grid">
      {products.map(product => (
        <ProductCard key={product.id} product={product} />
      ))}
    </div>
  )
}


// Pattern 3: 캐싱과 재검증
// 기본적으로 fetch는 캐싱됨

async function getCachedData() {
  // 기본: 무기한 캐싱
  const res = await fetch('/api/data')

  // 캐싱 비활성화 (항상 최신 데이터)
  const fresh = await fetch('/api/data', { cache: 'no-store' })

  // 시간 기반 재검증 (60초마다)
  const revalidated = await fetch('/api/data', {
    next: { revalidate: 60 }
  })

  return res.json()
}
`

// ============================================================
// 5. Server Actions
// ============================================================

const ServerActions = `
// Server Actions: 클라이언트에서 서버 함수 직접 호출

// actions/articles.js
'use server'

import { db } from '@/lib/db'
import { revalidatePath } from 'next/cache'

// 서버에서 실행되는 함수
export async function createArticle(formData) {
  const title = formData.get('title')
  const content = formData.get('content')

  // 직접 DB 저장
  const article = await db.article.create({
    data: { title, content }
  })

  // 캐시 무효화
  revalidatePath('/articles')

  return article
}

export async function likeArticle(articleId) {
  const article = await db.article.update({
    where: { id: articleId },
    data: { likes: { increment: 1 } }
  })

  revalidatePath(\`/articles/\${articleId}\`)

  return article.likes
}


// 클라이언트에서 Server Action 사용
// components/ArticleForm.jsx
'use client'

import { useFormStatus } from 'react-dom'
import { createArticle } from '@/actions/articles'

function SubmitButton() {
  const { pending } = useFormStatus()

  return (
    <button type="submit" disabled={pending}>
      {pending ? '저장 중...' : '저장'}
    </button>
  )
}

export default function ArticleForm() {
  return (
    <form action={createArticle}>
      <input name="title" placeholder="제목" required />
      <textarea name="content" placeholder="내용" required />
      <SubmitButton />
    </form>
  )
}


// useTransition과 함께 사용
'use client'

import { useTransition } from 'react'
import { deleteArticle } from '@/actions/articles'

export default function DeleteButton({ articleId }) {
  const [isPending, startTransition] = useTransition()

  const handleDelete = () => {
    startTransition(async () => {
      await deleteArticle(articleId)
    })
  }

  return (
    <button onClick={handleDelete} disabled={isPending}>
      {isPending ? '삭제 중...' : '삭제'}
    </button>
  )
}
`

// ============================================================
// 6. 성능 최적화 전략
// ============================================================

const PerformanceOptimization = `
// 1. 컴포넌트 분리 전략: 인터랙티브 요소만 Client로
// ✅ 좋은 예시: 최소한의 Client 컴포넌트

// app/product/[id]/page.jsx (Server)
export default async function ProductPage({ params }) {
  const product = await getProduct(params.id)

  return (
    <main>
      {/* 정적 콘텐츠 - Server */}
      <ProductImages images={product.images} />
      <ProductInfo product={product} />
      <ProductDescription description={product.description} />

      {/* 인터랙티브 - Client (최소 범위) */}
      <AddToCartButton productId={product.id} />

      {/* 정적 - Server */}
      <ProductReviews productId={product.id} />
    </main>
  )
}


// 2. Props로 데이터 전달 (번들 크기 최적화)
// ❌ 나쁜 예시: Client에서 무거운 라이브러리 import

// 'use client'
// import { marked } from 'marked'  // 번들에 포함됨!
// export function Content({ markdown }) {
//   return <div dangerouslySetInnerHTML={{ __html: marked(markdown) }} />
// }

// ✅ 좋은 예시: Server에서 변환 후 전달

// Server Component
import { marked } from 'marked'  // 서버에서만 사용

export default function Article({ markdown }) {
  const html = marked(markdown)  // 서버에서 변환

  return <div dangerouslySetInnerHTML={{ __html: html }} />
}


// 3. 동적 import로 Client 번들 최적화
'use client'

import dynamic from 'next/dynamic'

// 필요할 때만 로드
const HeavyChart = dynamic(() => import('@/components/HeavyChart'), {
  loading: () => <p>차트 로딩 중...</p>,
  ssr: false  // 클라이언트에서만 로드
})

export default function Dashboard() {
  return (
    <div>
      <h1>Dashboard</h1>
      <HeavyChart data={data} />
    </div>
  )
}


// 4. 부분 프리렌더링 (PPR) - Next.js 14+
// 정적 콘텐츠는 빌드 시, 동적 콘텐츠는 요청 시 렌더링

// next.config.js
module.exports = {
  experimental: {
    ppr: true
  }
}

// app/product/[id]/page.jsx
import { Suspense } from 'react'

export default async function ProductPage({ params }) {
  const product = await getProduct(params.id)

  return (
    <main>
      {/* 정적 셸 - 빌드 시 프리렌더링 */}
      <ProductInfo product={product} />

      {/* 동적 콘텐츠 - 요청 시 스트리밍 */}
      <Suspense fallback={<PriceSkeleton />}>
        <DynamicPrice productId={product.id} />
      </Suspense>
    </main>
  )
}
`

// ============================================================
// 학습 포인트 요약
// ============================================================

/*
 * 1. Server Components 장점:
 *    - JavaScript 번들 크기 감소 (0KB)
 *    - 직접 DB/파일 접근 가능
 *    - 빠른 초기 로딩
 *    - 민감한 데이터 서버에서만 처리
 *
 * 2. 언제 Client Component 사용?
 *    - useState, useEffect 등 훅 필요
 *    - onClick 등 이벤트 핸들러 필요
 *    - 브라우저 API 사용 (window, localStorage)
 *    - useContext 사용
 *
 * 3. 데이터 페칭 패턴:
 *    - 서버 컴포넌트에서 직접 async/await
 *    - Promise.all로 병렬 페칭
 *    - Suspense로 스트리밍
 *
 * 4. Server Actions:
 *    - 'use server' 디렉티브
 *    - form action으로 직접 호출
 *    - useTransition으로 pending 상태 관리
 *
 * 5. 성능 최적화:
 *    - Client Component 범위 최소화
 *    - 무거운 라이브러리는 서버에서 처리
 *    - dynamic import로 코드 분할
 *    - Suspense로 스트리밍
 *
 * 6. 주의사항:
 *    - Server Component에서 Client Component import 가능
 *    - Client Component에서 Server Component import 불가
 *    - Props는 직렬화 가능해야 함
 */

export {
  BadClientComponent,
  GoodServerComponent,
  MixedComponents,
  DataFetchingPatterns,
  ServerActions,
  PerformanceOptimization
}
