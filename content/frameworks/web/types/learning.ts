// 학습 카테고리 인터페이스
export interface Category {
  id: string;
  name: string;
  displayName: string;
  icon?: string;
  steps: Step[];
  description?: string;
}

// 개별 학습 Step 인터페이스
export interface Step {
  id: string;
  stepNumber: number;
  title: string;
  goal: string;
  status: "완료" | "진행중" | "미학습";
  filePath: string;
  fileName: string;
  category: string;
  code?: CodeSection[];
  learningPoints?: string[];
}

// 코드 섹션 (Bad/Good/Explanation)
export interface CodeSection {
  type: "bad" | "good" | "explanation" | "full";
  content: string;
  lineNumbers?: [number, number];
  language: string;
}

// 학습 진행률
export interface Progress {
  completedSteps: string[]; // step IDs
  inProgressSteps: string[]; // step IDs
  lastAccessedStep?: string;
  lastAccessedAt?: string;
}

// 전체 학습 데이터
export interface LearningData {
  categories: Category[];
  progress: Progress;
}
