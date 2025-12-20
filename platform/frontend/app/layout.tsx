import "./globals.css";
import type { Metadata } from "next";
import { Inter } from "next/font/google";
import AppSidebar from "@/components/AppSidebar";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Learning Platform",
  description: "DevOps, Backend, Frontend Learning Hub",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={`${inter.className} bg-white dark:bg-slate-950 flex min-h-screen`}>
        {/* Left Sidebar (Fixed) */}
        <AppSidebar />
        
        {/* Main Content (Scrollable) */}
        <main className="flex-1 flex flex-col min-w-0 overflow-hidden">
            <div className="flex-1 overflow-y-auto p-8">
                {children}
            </div>
        </main>
      </body>
    </html>
  );
}