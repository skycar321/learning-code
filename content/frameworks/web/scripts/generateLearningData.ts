import fs from 'fs/promises';
import path from 'path';
import { parseLearningPlan, findAllLearningPlans } from '../lib/parsers/parseMarkdown';
import { parseCodeFile, extractLearningPoints } from '../lib/parsers/parseCode';
import { Category, Step } from '../types/learning';

/**
 * 빌드타임에 학습 자료 데이터 생성
 *
 * 실행: node --loader ts-node/esm scripts/generateLearningData.ts
 */

const ROOT_PATH = path.resolve(__dirname, '../..');
const OUTPUT_PATH = path.join(__dirname, '../public/learning-data.json');

async function generateLearningData() {
  console.log('🚀 학습 자료 데이터 생성 시작...\n');
  console.log(`📂 Root path: ${ROOT_PATH}`);

  // 1. 모든 카테고리 찾기
  const categoryNames = await findAllLearningPlans(ROOT_PATH);
  console.log(`\n📚 발견된 카테고리: ${categoryNames.length}개`);
  console.log(categoryNames.join(', '));

  const categories: Category[] = [];

  // 2. 각 카테고리별 데이터 수집
  for (const categoryName of categoryNames) {
    console.log(`\n⏳ ${categoryName} 처리 중...`);

    const categoryPath = path.join(ROOT_PATH, categoryName);

    // Learning plan 파싱
    const plan = await parseLearningPlan(categoryPath, categoryName);
    console.log(`  ✅ ${plan.steps.length}개 Step 발견`);

    const steps: Step[] = [];

    // 각 Step별 코드 파일 찾기 및 파싱
    for (const planStep of plan.steps) {
      const stepNumber = planStep.stepNumber;

      // Step 파일명 패턴 (Step1_*, Step2_* 등)
      const stepFiles = await findStepFile(categoryPath, stepNumber);

      if (!stepFiles) {
        console.log(`  ⚠️  Step ${stepNumber} 파일을 찾을 수 없음`);
        // 파일 없어도 메타데이터는 유지
        steps.push({
          id: `${categoryName}-step${stepNumber}`,
          stepNumber,
          title: planStep.title,
          goal: planStep.goal,
          status: planStep.status,
          filePath: `${categoryName}/Step${stepNumber}_Unknown`,
          fileName: `Step${stepNumber}_Unknown`,
          category: categoryName,
        });
        continue;
      }

      // 코드 파싱
      const codeSections = await parseCodeFile(stepFiles);
      const fileContent = await fs.readFile(stepFiles, 'utf-8');
      const learningPoints = extractLearningPoints(fileContent);

      steps.push({
        id: `${categoryName}-step${stepNumber}`,
        stepNumber,
        title: planStep.title,
        goal: planStep.goal,
        status: planStep.status,
        filePath: path.relative(ROOT_PATH, stepFiles).replace(/\\/g, '/'),
        fileName: path.basename(stepFiles),
        category: categoryName,
        code: codeSections,
        learningPoints: learningPoints.length > 0 ? learningPoints : undefined,
      });

      console.log(`  ✅ Step ${stepNumber}: ${planStep.title}`);
    }

    categories.push({
      id: categoryName,
      name: categoryName,
      displayName: plan.displayName,
      description: plan.description,
      steps,
    });
  }

  // 3. JSON 파일로 저장
  await fs.mkdir(path.dirname(OUTPUT_PATH), { recursive: true });
  await fs.writeFile(OUTPUT_PATH, JSON.stringify(categories, null, 2), 'utf-8');

  console.log(`\n✅ 데이터 생성 완료!`);
  console.log(`📁 출력 파일: ${OUTPUT_PATH}`);
  console.log(`📊 총 ${categories.length}개 카테고리, ${categories.reduce((sum, c) => sum + c.steps.length, 0)}개 Step`);
}

/**
 * Step 파일 찾기 (Step1_*, Step2_* 등)
 */
async function findStepFile(categoryPath: string, stepNumber: number): Promise<string | null> {
  try {
    const files = await fs.readdir(categoryPath);
    const stepFile = files.find(f => {
      const match = f.match(/^Step(\d+)_/);
      return match && parseInt(match[1]) === stepNumber;
    });

    if (stepFile) {
      return path.join(categoryPath, stepFile);
    }
    return null;
  } catch {
    return null;
  }
}

// 실행
generateLearningData().catch(error => {
  console.error('❌ 데이터 생성 실패:', error);
  process.exit(1);
});
