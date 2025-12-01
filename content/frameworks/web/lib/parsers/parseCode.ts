import fs from 'fs/promises';
import path from 'path';

export interface CodeSection {
  type: 'bad' | 'good' | 'explanation' | 'full';
  content: string;
  lineNumbers?: [number, number];
  language: string;
}

/**
 * 코드 파일의 확장자로부터 언어 추론
 */
function getLanguageFromExtension(fileName: string): string {
  const ext = path.extname(fileName).toLowerCase();
  const languageMap: Record<string, string> = {
    '.java': 'java',
    '.js': 'javascript',
    '.ts': 'typescript',
    '.py': 'python',
    '.vue': 'vue',
    '.rs': 'rust',
    '.go': 'go',
    '.kt': 'kotlin',
    '.dart': 'dart',
  };
  return languageMap[ext] || 'text';
}

/**
 * 코드 파일 파싱 (주석 기반 섹션 분리)
 *
 * 예상 파일 구조:
 * ```java
 * public class Step1 {
 *   // === BAD EXAMPLE ===
 *   public static class BadExample {
 *     // 나쁜 코드...
 *   }
 *
 *   // === GOOD EXAMPLE ===
 *   public static class GoodExample {
 *     // 좋은 코드...
 *   }
 * }
 * ```
 */
export async function parseCodeFile(filePath: string): Promise<CodeSection[]> {
  const language = getLanguageFromExtension(filePath);

  try {
    const content = await fs.readFile(filePath, 'utf-8');
    const lines = content.split('\n');

    const sections: CodeSection[] = [];

    // Bad/Good Example 클래스 찾기
    let badStartLine = -1;
    let badEndLine = -1;
    let goodStartLine = -1;
    let goodEndLine = -1;

    // Java 파일의 경우 클래스 구조 파싱
    if (language === 'java') {
      let braceCount = 0;
      let inBadClass = false;
      let inGoodClass = false;

      for (let i = 0; i < lines.length; i++) {
        const line = lines[i];

        // BadExample 클래스 찾기
        if (/class\s+BadExample/i.test(line)) {
          badStartLine = i;
          inBadClass = true;
          braceCount = 0;
        }

        // GoodExample 클래스 찾기
        if (/class\s+GoodExample/i.test(line)) {
          goodStartLine = i;
          inGoodClass = true;
          braceCount = 0;
        }

        // 중괄호 카운팅
        for (const char of line) {
          if (char === '{') braceCount++;
          if (char === '}') braceCount--;

          // 클래스 끝 감지
          if (braceCount === 0 && inBadClass && badEndLine === -1) {
            badEndLine = i;
            inBadClass = false;
          }
          if (braceCount === 0 && inGoodClass && goodEndLine === -1) {
            goodEndLine = i;
            inGoodClass = false;
          }
        }
      }

      // Bad Example 추출
      if (badStartLine !== -1 && badEndLine !== -1) {
        sections.push({
          type: 'bad',
          content: lines.slice(badStartLine, badEndLine + 1).join('\n'),
          lineNumbers: [badStartLine + 1, badEndLine + 1],
          language,
        });
      }

      // Good Example 추출
      if (goodStartLine !== -1 && goodEndLine !== -1) {
        sections.push({
          type: 'good',
          content: lines.slice(goodStartLine, goodEndLine + 1).join('\n'),
          lineNumbers: [goodStartLine + 1, goodEndLine + 1],
          language,
        });
      }
    } else {
      // 다른 언어: 주석 기반 섹션 분리
      const badMatch = content.match(/\/\/\s*===?\s*BAD\s+EXAMPLE\s*===?([\s\S]+?)(?=\/\/\s*===?\s*GOOD|$)/i);
      const goodMatch = content.match(/\/\/\s*===?\s*GOOD\s+EXAMPLE\s*===?([\s\S]+?)(?=\/\/\s*===|$)/i);

      if (badMatch) {
        sections.push({
          type: 'bad',
          content: badMatch[1].trim(),
          language,
        });
      }

      if (goodMatch) {
        sections.push({
          type: 'good',
          content: goodMatch[1].trim(),
          language,
        });
      }
    }

    // Bad/Good 둘 다 없으면 전체 파일 반환
    if (sections.length === 0) {
      sections.push({
        type: 'full',
        content: content.trim(),
        language,
      });
    }

    return sections;
  } catch (error) {
    console.error(`Failed to parse code file ${filePath}:`, error);
    return [
      {
        type: 'full',
        content: `// Failed to load file: ${path.basename(filePath)}`,
        language,
      },
    ];
  }
}

/**
 * 학습 포인트 추출 (JavaDoc 또는 주석에서)
 */
export function extractLearningPoints(content: string): string[] {
  const points: string[] = [];

  // JavaDoc에서 학습 포인트 찾기
  const javadocMatch = content.match(/\/\*\*[\s\S]*?학습 포인트[\s\S]*?\*\//i);
  if (javadocMatch) {
    const listItems = javadocMatch[0].match(/(?:\*\s*<li>|[-*]\s+)(.+?)(?:<\/li>|$)/gi);
    if (listItems) {
      points.push(...listItems.map(item => item.replace(/<\/?li>|\*\s+|-\s+/g, '').trim()));
    }
  }

  // 단순 주석에서 학습 포인트 찾기
  const commentMatch = content.match(/\/\/\s*학습\s*포인트:?\s*\n((?:\/\/\s*.+\n?)+)/i);
  if (commentMatch) {
    const lines = commentMatch[1].split('\n');
    points.push(...lines.map(line => line.replace(/^\/\/\s*[-*]?\s*/, '').trim()).filter(Boolean));
  }

  return points.slice(0, 5); // 최대 5개
}
