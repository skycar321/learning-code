import { Category } from "@/types/learning";

// MVP를 위한 샘플 학습 데이터
export const sampleCategories: Category[] = [
  {
    id: "java",
    name: "java",
    displayName: "Java",
    description: "실무 Java 코드 학습",
    steps: [
      {
        id: "java-step1",
        stepNumber: 1,
        title: "변수와 상수",
        goal: "마법의 숫자를 지양하고 final을 사용한 상수의 중요성을 이해합니다.",
        status: "완료",
        filePath: "java/Step1_VariablesAndConstants.java",
        fileName: "Step1_VariablesAndConstants.java",
        category: "java",
        learningPoints: [
          "매직 넘버는 가독성과 유지보수성을 크게 해칩니다.",
          "상수를 사용하면 코드 자체가 문서화되어 의미를 명확히 합니다.",
          "변경 발생 시 수정 범위를 최소화할 수 있습니다."
        ],
        code: [
          {
            type: "bad",
            language: "java",
            content: `public class BadExample {
    public static void main(String[] args) {
        // 나쁜 예: 매직 넘버 사용
        int seconds = 86400; // 이게 뭘 의미하는지 알 수 없음
        System.out.println("하루는 " + seconds + "초입니다.");
    }
}`
          },
          {
            type: "good",
            language: "java",
            content: `public class GoodExample {
    // 좋은 예: 의미있는 상수로 정의
    public static final int SECONDS_PER_DAY = 86400;

    public static void main(String[] args) {
        System.out.println("하루는 " + SECONDS_PER_DAY + "초입니다.");
    }
}`
          }
        ]
      },
      {
        id: "java-step2",
        stepNumber: 2,
        title: "Null 처리",
        goal: "if (obj != null) 반복을 피하고, Optional을 사용해 안전하고 표현력 있는 코드를 작성합니다.",
        status: "진행중",
        filePath: "java/Step2_NullHandling.java",
        fileName: "Step2_NullHandling.java",
        category: "java",
        learningPoints: [
          "Optional은 null을 명시적으로 표현하여 NullPointerException을 방지합니다.",
          "함수형 프로그래밍 스타일로 null 체크 코드를 간결하게 만듭니다.",
          "orElse, orElseGet, orElseThrow 등 다양한 메서드를 활용할 수 있습니다."
        ]
      },
      {
        id: "java-step3",
        stepNumber: 3,
        title: "문자열 처리",
        goal: "반복문 안에서 + 연산자의 비효율성을 이해하고, StringBuilder를 사용합니다.",
        status: "미학습",
        filePath: "java/Step3_StringManipulation.java",
        fileName: "Step3_StringManipulation.java",
        category: "java"
      }
    ]
  },
  {
    id: "vue3",
    name: "vue3",
    displayName: "Vue 3",
    description: "Vue 3 Composition API 학습",
    steps: [
      {
        id: "vue3-step1",
        stepNumber: 1,
        title: "Composition API 기초",
        goal: "Vue 3의 Composition API 기본 개념을 이해합니다.",
        status: "완료",
        filePath: "vue3/Step1_Vue3CompositionAPI.js",
        fileName: "Step1_Vue3CompositionAPI.js",
        category: "vue3",
        learningPoints: [
          "Composition API는 로직 재사용성을 높입니다.",
          "setup() 함수에서 반응형 데이터를 정의합니다.",
          "ref와 reactive의 차이를 이해해야 합니다."
        ],
        code: [
          {
            type: "bad",
            language: "javascript",
            content: `// Bad: Options API (레거시)
export default {
  data() {
    return {
      count: 0
    }
  },
  methods: {
    increment() {
      this.count++
    }
  }
}`
          },
          {
            type: "good",
            language: "javascript",
            content: `// Good: Composition API
import { ref } from 'vue'

export default {
  setup() {
    const count = ref(0)
    const increment = () => count.value++

    return { count, increment }
  }
}`
          }
        ]
      },
      {
        id: "vue3-step2",
        stepNumber: 2,
        title: "컴포넌트 Props",
        goal: "Props를 사용한 컴포넌트 간 데이터 전달을 학습합니다.",
        status: "미학습",
        filePath: "vue3/Step2_ComponentBasicsAndProps.js",
        fileName: "Step2_ComponentBasicsAndProps.js",
        category: "vue3"
      }
    ]
  },
  {
    id: "python",
    name: "python",
    displayName: "Python",
    description: "Python Best Practices 학습",
    steps: [
      {
        id: "python-step1",
        stepNumber: 1,
        title: "리스트 컴프리헨션",
        goal: "파이썬다운(Pythonic) 코드 작성 방법을 학습합니다.",
        status: "미학습",
        filePath: "python/Step1_ListComprehension.py",
        fileName: "Step1_ListComprehension.py",
        category: "python",
        code: [
          {
            type: "bad",
            language: "python",
            content: `# Bad: 전통적인 for 루프
numbers = [1, 2, 3, 4, 5]
squares = []
for n in numbers:
    squares.append(n ** 2)
print(squares)`
          },
          {
            type: "good",
            language: "python",
            content: `# Good: 리스트 컴프리헨션
numbers = [1, 2, 3, 4, 5]
squares = [n ** 2 for n in numbers]
print(squares)`
          }
        ]
      }
    ]
  },
  {
    id: "springboot",
    name: "springboot",
    displayName: "Spring Boot",
    description: "Spring Boot 실전 학습",
    steps: [
      {
        id: "springboot-step1",
        stepNumber: 1,
        title: "의존성 주입 (DI)",
        goal: "Spring Boot의 핵심인 의존성 주입을 이해합니다.",
        status: "미학습",
        filePath: "springboot/Step1_DependencyInjection.java",
        fileName: "Step1_DependencyInjection.java",
        category: "springboot"
      }
    ]
  }
];

// 카테고리 ID로 카테고리 찾기
export function getCategoryById(id: string): Category | undefined {
  return sampleCategories.find(cat => cat.id === id);
}

// 카테고리와 Step 번호로 Step 찾기
export function getStepById(categoryId: string, stepNumber: number) {
  const category = getCategoryById(categoryId);
  return category?.steps.find(step => step.stepNumber === stepNumber);
}
