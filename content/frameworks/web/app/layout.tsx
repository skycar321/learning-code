import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Learning Code - 인터랙티브 학습 플랫폼",
  description: "Java, Python, Vue, Spring Boot 등 다양한 프로그래밍 언어와 프레임워크를 학습하는 인터랙티브 웹 플랫폼",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ko">
      <body className="antialiased">
        {children}
      </body>
    </html>
  );
}
