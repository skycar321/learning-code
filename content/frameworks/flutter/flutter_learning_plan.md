# Flutter 학습 계획

## 개요 (Overview)
Flutter는 Google에서 개발한 오픈소스 UI 소프트웨어 개발 키트(SDK)로, 단일 코드베이스로 iOS, Android, 웹, 데스크톱용 네이티브 컴파일 애플리케이션을 구축할 수 있습니다. Dart 언어를 사용하며, 반응형(reactive) 프로그래밍 모델과 빠른 개발 속도를 특징으로 합니다. 이 학습 계획은 Flutter의 기본 개념부터 위젯, 레이아웃, 상태 관리, 데이터 페칭, 그리고 실제 앱 배포까지 다루어, 아름답고 성능 좋은 크로스 플랫폼 애플리케이션을 개발하는 역량을 키우는 것을 목표로 합니다.

## 학습 목표 (Learning Objectives)
*   Flutter 및 Dart의 핵심 개념 이해
*   위젯(Widget)을 사용하여 유연하고 반응적인 UI 구축
*   상태 관리, 내비게이션, 데이터 페칭 등 앱 기능 구현
*   네이티브 기능 연동 및 디버깅, 성능 최적화
*   다양한 플랫폼에 앱 배포

## 학습 내용 (Learning Content)

### 1단계: Flutter 및 Dart 기본 개념 (Flutter & Dart Basics)
*   Flutter 소개 (Introduction to Flutter) - 장점, 아키텍처 (Layered Architecture)
*   Dart 언어 기초 (Dart Language Basics) - 변수, 자료형, 함수, 클래스
*   개발 환경 설정 (Development Environment Setup) - Android Studio/VS Code, Flutter SDK
*   새 Flutter 프로젝트 생성 및 실행 (Creating & Running a New Flutter Project)
*   Hot Reload 및 Hot Restart 이해

### 2단계: 위젯 및 레이아웃 (Widgets & Layout)
*   모든 것이 위젯 (Everything is a Widget) - Stateless vs Stateful Widgets
*   기본 위젯 (Core Widgets) - `Text`, `Image`, `Icon`, `Button`, `Container`
*   레이아웃 위젯 (Layout Widgets) - `Row`, `Column`, `Stack`, `Expanded`, `Flexible`
*   스크롤 가능한 위젯 (Scrollable Widgets) - `ListView`, `GridView`
*   Material Design 및 Cupertino 위젯 (Material Design & Cupertino Widgets)
*   테마(Themes) 및 스타일링 (Theming & Styling)

### 3단계: 내비게이션 및 상태 관리 (Navigation & State Management)
*   내비게이션 (Navigation) - `Navigator.push`, `Navigator.pop`, Named Routes
*   상태 관리 (State Management)
    *   `setState`를 이용한 로컬 상태 관리
    *   `Provider`, `Bloc/Cubit`, `Riverpod`, `GetX` 등 상태 관리 솔루션
*   데이터 페칭 (Data Fetching) - `http` 패키지, `FutureBuilder`
*   비동기 프로그래밍 (Asynchronous Programming) - `async`, `await`, `Future`, `Stream`

### 4단계: 네이티브 기능 및 고급 UI (Native Features & Advanced UI)
*   패키지 및 플러그인 사용 (Using Packages & Plugins)
*   네이티브 기능 연동 (Integrating Native Features) - `MethodChannel`
*   폼(Forms) 처리 및 유효성 검사 (Form Handling & Validation)
*   제스처(Gestures) 감지 (Gesture Detection)
*   커스텀 위젯 만들기 (Building Custom Widgets)
*   애니메이션 (Animations) - `AnimationController`, `Tween`, Hero Animations

### 5단계: 테스트, 배포 및 성능 최적화 (Testing, Deployment & Performance Optimization)
*   테스트 (Testing) - 유닛 테스트, 위젯 테스트, 통합 테스트
*   디버깅 (Debugging) - Dart DevTools
*   성능 최적화 (Performance Optimization) - 위젯 재빌드 방지, 이미지 최적화
*   앱 아이콘 및 스플래시 화면 설정 (App Icon & Splash Screen Configuration)
*   앱 스토어 배포 (Deploying to App Stores) - Google Play Store, Apple App Store
*   웹 및 데스크톱 앱 배포 (Deploying Web & Desktop Apps)

## 예상 학습 시간 (Estimated Learning Time)
*   각 단계별 4-8시간 (총 20-40시간)

## 실습 과제 (Practical Exercises)
*   간단한 계산기 또는 할 일 목록 앱 개발 (Develop a simple calculator or to-do list app)
*   API에서 데이터를 가져와 ListView로 표시하는 앱 구축 (Build an app that fetches data from API & displays in ListView)
*   상태 관리 라이브러리를 사용하여 복잡한 앱 상태 관리 (Manage complex app state with a state management library)
*   카메라 또는 갤러리 접근 기능 구현 (Implement camera or gallery access)
*   Flutter 앱을 iOS 및 Android 시뮬레이터 또는 실제 기기에서 실행 및 테스트 (Run & test Flutter app on simulators/real devices)

## 참고 자료 (References)
*   Flutter 공식 문서 (Flutter Official Documentation)
*   Dart 공식 문서 (Dart Official Documentation)
*   Flutter Apprentice by Vince Varghese, Mike Katz, Kevin Moore, Brian Salaz
*   Learning Flutter by Eric Windmill
