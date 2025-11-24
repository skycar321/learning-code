# Step1: React Native 기본 개념 및 개발 환경

이 디렉토리는 React Native의 기본 개념, 핵심 컴포넌트, Flexbox 레이아웃, 그리고 개발 환경 설정 방법을 학습하기 위한 예제 코드입니다.

## 학습 목표

-   React Native 핵심 컴포넌트 (`View`, `Text`, `Image`, `StyleSheet`, `SafeAreaView`) 이해
-   Flexbox를 이용한 레이아웃 구성
-   React Native 개발 환경 설정 (Expo CLI 또는 React Native CLI)
-   프로젝트 생성 및 시뮬레이터/실제 기기에서 앱 실행

## 프로젝트 구조

```
react_native/Step1_ReactNativeBasics/
├── App.js                    # 메인 애플리케이션 파일
└── README.md
```

## 파일 설명

-   **`App.js`**:
    -   **핵심 컴포넌트**:
        -   `View`: 웹의 `div`와 유사한 가장 기본적인 컨테이너 컴포넌트.
        -   `Text`: 텍스트를 표시하는 컴포넌트. 모든 텍스트는 `Text` 컴포넌트 내부에 있어야 합니다.
        -   `Image`: 이미지를 표시하는 컴포넌트. 로컬(`require`) 또는 네트워크(`uri`) 이미지를 사용합니다.
        -   `StyleSheet`: 웹의 CSS와 유사하게 컴포넌트에 스타일을 적용하는 데 사용됩니다. `StyleSheet.create()`를 사용하여 스타일 객체를 생성하면 성능 및 가독성 향상에 도움이 됩니다.
        -   `SafeAreaView`: iOS에서 노치나 하단 인디케이터 영역을 피해 콘텐츠를 렌더링하는 데 사용됩니다.
    -   **Flexbox 레이아웃**: `flex`, `flexDirection`, `justifyContent`, `alignItems` 등의 스타일 속성을 사용하여 컴포넌트들을 유연하게 배치합니다. React Native의 모든 레이아웃은 Flexbox를 기반으로 합니다.

## 설정 및 실행 방법

`react_native/Step1_ReactNativeBasics` 디렉토리에서 터미널을 열고 다음 명령어를 실행합니다.

1.  **Node.js, npm (또는 yarn) 설치**:
    -   React Native 개발을 위한 필수 도구입니다.

2.  **React Native CLI 또는 Expo CLI 설치**:
    -   **Expo CLI (추천, 더 쉬운 시작)**: `npm install -g expo-cli`
    -   **React Native CLI**: `npm install -g react-native-cli`

3.  **새 React Native 프로젝트 생성**:
    -   **Expo CLI**:
        ```bash
        expo init react-native-basics-app
        # 'blank' 템플릿 선택
        cd react-native-basics-app
        ```
    -   **React Native CLI**:
        ```bash
        npx react-native init react-native-basics-app
        cd react-native-basics-app
        ```
    -   프로젝트 생성 후 `App.js` 파일이 생성됩니다.

4.  **`App.js` 파일 교체**:
    -   생성된 프로젝트의 `App.js` 파일 내용을 이 디렉토리의 `App.js` 파일 내용으로 교체합니다.

5.  **프로젝트 실행**:
    -   **Expo CLI**:
        ```bash
        npm start
        ```
        -   브라우저에서 Expo Dev Tools가 열리면, iOS 시뮬레이터, Android 에뮬레이터 또는 실제 기기에서 앱을 실행할 수 있는 옵션이 제공됩니다.
    -   **React Native CLI**:
        -   **iOS (macOS에서만 가능, Xcode 설치 필수)**:
            ```bash
            npm run ios
            ```
        -   **Android (Android Studio 및 SDK 설치 필수)**:
            ```bash
            npm run android
            ```
    -   앱이 시뮬레이터 또는 실제 기기에서 실행되면, "React Native 기본 개념" 제목과 Flexbox를 이용한 레이아웃이 표시되는 것을 확인할 수 있습니다.

## 나쁜 예시와 좋은 예시 (개념)

`App.js` 파일 내의 주석을 참조하여, React Native 개발 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 특히 웹 개발과의 차이점을 이해하고, React Native에서 제공하는 컴포넌트와 스타일링 방식을 올바르게 사용하는 것이 중요합니다.
