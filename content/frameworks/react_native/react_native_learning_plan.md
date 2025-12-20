# React Native 학습 계획

## 개요 (Overview)
React Native는 Facebook에서 개발한 오픈소스 모바일 애플리케이션 프레임워크로, JavaScript와 React를 사용하여 iOS 및 Android 앱을 동시에 개발할 수 있도록 합니다. '한 번 배우면 어디에서든 개발한다(Learn once, write anywhere)'는 철학을 기반으로 웹 개발 경험이 있는 개발자들이 쉽게 모바일 앱 개발에 접근할 수 있도록 돕습니다. 이 학습 계획은 React Native의 기본 개념부터 컴포넌트, 내비게이션, 상태 관리, 그리고 실제 앱 배포까지 다루어, 크로스 플랫폼 모바일 앱 개발 역량을 키우는 것을 목표로 합니다.

## 학습 목표 (Learning Objectives)
*   React Native의 핵심 개념 및 개발 환경 설정
*   기본 및 고급 컴포넌트를 사용하여 UI 구축
*   내비게이션, 상태 관리, 데이터 페칭 등 앱 기능 구현
*   네이티브 모듈 연동 및 디버깅, 성능 최적화
*   iOS 및 Android 플랫폼에 앱 배포

## 학습 내용 (Learning Content)

### 1단계: React Native 기본 개념 및 개발 환경 (React Native Basics & Environment)
*   React Native 소개 (Introduction to React Native) - 장점, 한계
*   개발 환경 설정 (Development Environment Setup) - Expo CLI 또는 React Native CLI
*   프로젝트 생성 및 실행 (Project Creation & Running) - `npx react-native init`, `expo start`
*   기본 컴포넌트 이해 (Understanding Core Components) - `View`, `Text`, `Image`, `StyleSheet`
*   Flexbox를 이용한 레이아웃 (Layout with Flexbox)

### 2단계: UI 컴포넌트 및 스타일링 (UI Components & Styling)
*   사용자 입력 컴포넌트 (User Input Components) - `TextInput`, `Button`, `TouchableOpacity`
*   리스트 렌더링 (List Rendering) - `FlatList`, `SectionList`
*   플랫폼별 스타일링 (Platform-Specific Styling) - `Platform` 모듈
*   외부 라이브러리 사용 (Using External Libraries) - UI 라이브러리 (e.g., React Native Elements, NativeBase)
*   애니메이션 (Animations) - `Animated` API

### 3단계: 내비게이션 및 상태 관리 (Navigation & State Management)
*   내비게이션 (Navigation) - React Navigation 라이브러리
    *   Stack Navigator, Tab Navigator, Drawer Navigator
*   앱 상태 관리 (App State Management)
    *   `useState`, `useContext`를 이용한 로컬 상태 관리
    *   Redux, Zustand, Recoil 등 전역 상태 관리 라이브러리
*   데이터 페칭 (Data Fetching) - `fetch` API, Axios

### 4단계: 네이티브 모듈 및 API 연동 (Native Modules & API Integration)
*   React Native Debugger 활용 (Utilizing React Native Debugger)
*   기기 API 접근 (Accessing Device APIs) - 카메라, 갤러리, 위치 정보 등
*   네이티브 모듈 연동 (Integrating Native Modules) - Swift/Objective-C, Java/Kotlin
*   푸시 알림 구현 (Implementing Push Notifications) - Firebase Messaging
*   인증 및 권한 관리 (Authentication & Permissions)

### 5단계: 배포 및 성능 최적화 (Deployment & Performance Optimization)
*   빌드 및 번들링 (Building & Bundling) - Metro Bundler
*   성능 최적화 (Performance Optimization) - Re-renders 방지, 이미지 최적화
*   테스트 (Testing) - Jest, React Testing Library for React Native
*   앱 스토어 배포 (Deploying to App Stores) - Google Play Store, Apple App Store
*   CodePush를 이용한 OTA 업데이트 (OTA Updates with CodePush)

## 예상 학습 시간 (Estimated Learning Time)
*   각 단계별 4-8시간 (총 20-40시간)

## 실습 과제 (Practical Exercises)
*   간단한 투두리스트 또는 날씨 앱 구축 (Build a simple ToDo List or Weather app)
*   React Navigation을 이용한 여러 화면 구성 (Implement multiple screens with React Navigation)
*   외부 API에서 데이터를 가져와 화면에 표시 (Fetch data from an external API and display it)
*   카메라 또는 갤러리 접근 기능 구현 (Implement camera or gallery access)
*   Expo 또는 React Native CLI를 통해 실제 기기에서 앱 실행 및 테스트 (Run & test the app on a real device)

## 참고 자료 (References)
*   React Native 공식 문서 (React Native Official Documentation)
*   React Navigation 공식 문서 (React Navigation Official Documentation)
*   Learning React Native by Bonnie Eisenman
*   React Native Cookbook by Jonathan Blanc, Javier Alejandro Velasquez Garcia
