@echo off
echo Starting Learning Platform (Rust BE + Next.js FE)...

:: Start Rust Backend in background
start "Rust Backend" cmd /k "cd platform/backend && cargo run"

:: Start Next.js Frontend
cd platform/frontend
npm run dev
