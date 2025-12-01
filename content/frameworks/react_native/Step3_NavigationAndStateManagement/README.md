# Step3: React Native 내비게이션 및 상태 관리

이 디렉토리는 React Native 애플리케이션에서 화면 간 이동(내비게이션)과 컴포넌트의 상태를 효율적으로 관리하는 방법을 학습하기 위한 예제 코드입니다.

## 학습 목표

-   `React Navigation` 라이브러리를 이용한 Stack Navigator 구현
-   `useState`를 이용한 컴포넌트 로컬 상태 관리
-   `Context API`를 이용한 전역 상태 관리 (개념 및 구현)
-   화면 간 파라미터 전달 및 이전 화면으로 돌아가기

## 프로젝트 구조

```
react_native/Step3_NavigationAndStateManagement/
├── App.js                    # 메인 애플리케이션 파일 (내비게이션 및 상태 관리 예제 포함)
└── README.md
```

## 파일 설명

-   **`App.js`**:
    -   **내비게이션**:
        -   `NavigationContainer`: React Navigation을 위한 최상위 컨테이너.
        -   `createNativeStackNavigator`: Stack 형태의 내비게이션을 생성하는 훅. `HomeScreen`, `DetailsScreen`, `SettingsScreen`을 스택 화면으로 등록합니다.
        -   `navigation.navigate('ScreenName', { params })`: 다른 화면으로 이동하고 파라미터를 전달합니다.
        -   `navigation.goBack()`: 이전 화면으로 돌아갑니다.
    -   **로컬 상태 관리 (`useState`)**: `HomeScreen`에서 `localMessage` 상태를 `useState` 훅을 사용하여 관리하고, '메시지 변경' 버튼을 통해 업데이트합니다.
    -   **전역 상태 관리 (`Context API`)**: `CounterContext`를 `createContext`로 생성하고, `CounterProvider`를 통해 `count`, `increment`, `decrement` 함수를 하위 컴포넌트에 제공합니다. `HomeScreen`과 `SettingsScreen`에서 `useContext` 훅을 사용하여 전역 카운터 상태에 접근하고 변경합니다.

-   **`HomeScreen`**: 로컬 상태와 전역 카운터 상태를 표시하고, 버튼을 통해 `DetailsScreen` 및 `SettingsScreen`으로 이동합니다.
-   **`DetailsScreen`**: `route.params`를 통해 `HomeScreen`에서 전달된 파라미터(`itemId`, `otherParam`)를 받아 표시하고, '뒤로 가기' 버튼을 제공합니다.
-   **`SettingsScreen`**: 전역 카운터 상태를 표시하고, '카운터 증가' 버튼을 통해 전역 상태를 변경합니다.

## 설정 및 실행 방법

`react_native/Step3_NavigationAndStateManagement` 디렉토리에서 터미널을 열고 다음 명령어를 실행합니다.

1.  **React Native 프로젝트 생성**:
    -   `expo init react-native-navigation-app` (Expo CLI) 또는 `npx react-native init react-native-navigation-app` (React Native CLI)
    -   `cd react-native-navigation-app`

2.  **`react-navigation` 라이브러리 설치**:
    -   **Expo CLI 프로젝트**:
        ```bash
        npm install @react-navigation/native @react-navigation/native-stack
        expo install react-native-screens react-native-safe-area-context
        ```
    -   **React Native CLI 프로젝트**:
        ```bash
        npm install @react-navigation/native @react-navigation/native-stack
        npm install react-native-screens react-native-safe-area-context
        # iOS의 경우 Pods 설치: cd ios && pod install && cd ..
        ```
    -   (자세한 설치 가이드는 React Navigation 공식 문서 참조)

3.  **`App.js` 파일 교체**:
    -   생성된 프로젝트의 `App.js` 파일 내용을 이 디렉토리의 `App.js` 파일 내용으로 교체합니다.

4.  **프로젝트 실행**:
    -   **Expo CLI**: `npm start`
    -   **React Native CLI**: `npm run ios` 또는 `npm run android`
    -   앱이 시뮬레이터 또는 실제 기기에서 실행되면, 여러 화면과 상태 관리 기능을 테스트할 수 있습니다.

5.  **기능 테스트**:
    -   '메시지 변경' 버튼을 눌러 `HomeScreen`의 로컬 상태가 변경되는 것을 확인합니다.
    -   '카운터 증가/감소' 버튼을 눌러 전역 카운터(`Context API`)가 변경되고, `HomeScreen`과 `SettingsScreen` 모두에서 변경된 값이 동기화되는 것을 확인합니다.
    -   '상세 화면으로 이동', '설정 화면으로 이동' 버튼을 눌러 화면 간 이동과 파라미터 전달이 잘 되는지 확인합니다.

## 나쁜 예시와 좋은 예시 (개념)

`App.js` 파일 내의 주석을 참조하여, React Native 내비게이션 및 상태 관리 사용 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. `React Navigation`과 `Context API` (또는 Redux, Zustand 등)를 이용하여 앱의 복잡한 상태와 화면 흐름을 구조적으로 관리하는 것이 중요합니다.
