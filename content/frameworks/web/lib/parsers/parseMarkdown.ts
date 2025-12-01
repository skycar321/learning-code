import fs from 'fs/promises';
import path from 'path';

export interface LearningPlanRow {
  stepNumber: number;
  title: string;
  goal: string;
  status: '완료' | '진행중' | '미학습';
}

export interface LearningPlan {
  category: string;
  displayName: string;
  description: string;
  steps: LearningPlanRow[];
}

/**
 * learning_plan.md 파일을 파싱하여 학습 계획 정보 추출
 *
 * 파일 구조 예시:
 * ```
 * # 실무 Java 코드 학습 계획
 *
 * | 단계 | 주제 | 학습 목표 | 상태 |
 * | Step 1 | 변수와 상수 | ... | 완료 |
 * ```
 */
export async function parseLearningPlan(
  categoryPath: string,
  categoryName: string
): Promise<LearningPlan> {
  const planFilePath = path.join(categoryPath, `${categoryName}_learning_plan.md`);

  try {
    const content = await fs.readFile(planFilePath, 'utf-8');

    // 제목 추출 (첫 번째 # 헤더)
    const titleMatch = content.match(/^#\s+(.+)$/m);
    const displayName = titleMatch ? titleMatch[1].replace(/학습 계획|코드 학습|학습/g, '').trim() : categoryName;

    // 설명 추출 (첫 문단)
    const descMatch = content.match(/(?:^|\n\n)([가-힣].+?(?:\.|!|\?))\s*(?:\n|$)/);
    const description = descMatch ? descMatch[1].substring(0, 100) : `${categoryName} 학습`;

    // 테이블 파싱
    const steps: LearningPlanRow[] = [];
    const tableRegex = /\|\s*\*?\*?Step\s+(\d+)\*?\*?\s*\|\s*\*?\*?(.+?)\*?\*?\s*\|\s*(.+?)\s*\|\s*(완료|진행중|미학습)\s*\|/gi;

    let match;
    while ((match = tableRegex.exec(content)) !== null) {
      steps.push({
        stepNumber: parseInt(match[1]),
        title: match[2].trim(),
        goal: match[3].trim(),
        status: match[4].trim() as '완료' | '진행중' | '미학습',
      });
    }

    return {
      category: categoryName,
      displayName,
      description,
      steps,
    };
  } catch (error) {
    console.error(`Failed to parse learning plan for ${categoryName}:`, error);
    return {
      category: categoryName,
      displayName: categoryName,
      description: `${categoryName} 학습`,
      steps: [],
    };
  }
}

/**
 * 지정된 디렉토리에서 모든 learning_plan.md 파일 찾기
 */
export async function findAllLearningPlans(rootPath: string): Promise<string[]> {
  const categories: string[] = [];

  try {
    const entries = await fs.readdir(rootPath, { withFileTypes: true });

    for (const entry of entries) {
      if (entry.isDirectory()) {
        const categoryName = entry.name;
        const planPath = path.join(rootPath, categoryName, `${categoryName}_learning_plan.md`);

        try {
          await fs.access(planPath);
          categories.push(categoryName);
        } catch {
          // learning_plan.md 없는 폴더는 스킵
        }
      }
    }

    return categories.sort();
  } catch (error) {
    console.error('Failed to find learning plans:', error);
    return [];
  }
}
