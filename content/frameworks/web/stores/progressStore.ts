import { create } from "zustand";
import { persist, createJSONStorage } from "zustand/middleware";

interface ProgressState {
  completedSteps: Set<string>; // step IDs
  toggleStepComplete: (stepId: string) => void;
  isStepCompleted: (stepId: string) => boolean;
  getCategoryProgress: (categoryId: string, totalSteps: number) => number;
  getCompletedCount: (categoryId: string) => number;
}

export const useProgressStore = create<ProgressState>()(
  persist(
    (set, get) => ({
      completedSteps: new Set<string>(),

      toggleStepComplete: (stepId: string) => {
        set((state) => {
          const newCompleted = new Set(state.completedSteps);
          if (newCompleted.has(stepId)) {
            newCompleted.delete(stepId);
          } else {
            newCompleted.add(stepId);
          }
          return { completedSteps: newCompleted };
        });
      },

      isStepCompleted: (stepId: string) => {
        return get().completedSteps.has(stepId);
      },

      getCategoryProgress: (categoryId: string, totalSteps: number) => {
        const completed = get().getCompletedCount(categoryId);
        return totalSteps > 0 ? Math.round((completed / totalSteps) * 100) : 0;
      },

      getCompletedCount: (categoryId: string) => {
        const completedSteps = get().completedSteps;
        let count = 0;
        completedSteps.forEach((stepId) => {
          if (stepId.startsWith(categoryId + "-")) {
            count++;
          }
        });
        return count;
      },
    }),
    {
      name: "learning-progress",
      storage: createJSONStorage(() => localStorage),
      // Set과 같은 비표준 타입을 직렬화/역직렬화
      partialize: (state) => ({
        completedSteps: Array.from(state.completedSteps),
      }),
      onRehydrateStorage: () => (state) => {
        if (state && Array.isArray((state as any).completedSteps)) {
          // 역직렬화 과정에서 Array를 Set으로 변환
          (state as any).completedSteps = new Set((state as any).completedSteps);
        }
      },
    }
  )
);
