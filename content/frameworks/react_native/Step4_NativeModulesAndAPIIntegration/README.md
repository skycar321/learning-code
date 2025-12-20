# Step4: React Native 네이티브 모듈 및 API 연동

이 디렉토리는 React Native 애플리케이션에서 네이티브 모듈(카메라/갤러리 접근)을 연동하고, 푸시 알림과 같은 외부 API를 통합하는 개념을 학습하기 위한 예제 코드입니다.

## 학습 목표

-   `react-native-image-picker`를 이용한 카메라/갤러리 접근 구현
-   `NativeModules`를 이용한 네이티브 코드 연동 개념 이해
-   푸시 알림 구현(`Firebase Cloud Messaging`, `Expo Notifications`) 개념
-   인증 및 권한 관리의 중요성 이해

## 프로젝트 구조

```
react_native/Step4_NativeModulesAndAPIIntegration/
├── App.js                    # 네이티브 모듈 및 API 연동 예제
└── README.md
```

## 파일 설명

-   **`App.js`**:
    -   **`react-native-image-picker`**:
        -   `launchImageLibrary`: 기기의 갤러리에서 이미지를 선택하는 기능을 제공합니다.
        -   `launchCamera`: 기기의 카메라를 사용하여 사진을 촬영하는 기능을 제공합니다.
        -   선택된 이미지의 URI를 `useState` 훅을 통해 `selectedImage` 상태에 저장하고, `Image` 컴포넌트로 화면에 표시합니다.
    -   **네이티브 모듈 (`NativeModules`)**:
        -   `NativeModules` 객체를 통해 JavaScript 코드에서 플랫폼 고유의 네이티브 모듈에 접근할 수 있습니다.
        -   예제에서는 `BatteryManager`라는 가상의 네이티브 모듈을 가정하고 `getBatteryLevel()` 메서드를 호출하여 배터리 레벨을 가져오는 시나리오를 보여줍니다. (실제 네이티브 코드는 `README.md`의 주석에 예시로 제공됩니다.)
    -   **푸시 알림**: 푸시 알림 구현을 위한 `sendPushNotification` 함수를 정의하여 푸시 알림의 개념을 설명합니다. (실제 구현은 외부 서비스 연동 필요)
    -   **권한 관리**: 카메라, 갤러리 접근과 같은 기기 API 사용 시 사용자 동의(권한)가 필요함을 설명합니다.

## 설정 및 실행 방법

`react_native/Step4_NativeModulesAndAPIIntegration` 디렉토리에서 터미널을 열고 다음 명령어를 실행합니다.

1.  **React Native 프로젝트 생성**:
    -   `expo init react-native-native-app` (Expo CLI) 또는 `npx react-native init react-native-native-app` (React Native CLI)
    -   `cd react-native-native-app`

2.  **`react-native-image-picker` 라이브러리 설치**:
    ```bash
    npm install react-native-image-picker
    # 또는 yarn add react-native-image-picker
    ```
    -   React Native CLI 프로젝트의 경우, `react-native-image-picker` 공식 문서에 따라 iOS(`cd ios && pod install`) 및 Android(`AndroidManifest.xml` 권한 추가)에 추가적인 네이티브 설정을 수행해야 합니다.

3.  **`App.js` 파일 교체**:
    -   생성된 프로젝트의 `App.js` 파일 내용을 이 디렉토리의 `App.js` 파일 내용으로 교체합니다.

4.  **프로젝트 실행**:
    -   **Expo CLI**: `npm start`
    -   **React Native CLI**: `npm run ios` 또는 `npm run android`
    -   앱이 시뮬레이터 또는 실제 기기에서 실행되면, 카메라/갤러리 접근 및 배터리 레벨 표시 기능(네이티브 모듈 구현 시)을 테스트할 수 있습니다.

5.  **기능 테스트**:
    -   '갤러리에서 이미지 선택' 버튼을 눌러 기기의 갤러리에서 이미지를 선택하고 앱에 표시되는지 확인합니다.
    -   '카메라로 사진 촬영' 버튼을 눌러 카메라 앱을 실행하고 사진을 찍어 앱에 표시되는지 확인합니다. (실제 기기 또는 에뮬레이터에서만 가능)
    -   '배터리 레벨' 텍스트에 기기의 배터리 잔량이 표시되는지 확인합니다. (네이티브 모듈이 구현되어야 함)

## 네이티브 모듈(`BatteryManager`) 구현 (React Native CLI 프로젝트만)

`App.js` 파일의 주석에 iOS(Swift) 및 Android(Java)용 네이티브 모듈 구현 예시가 포함되어 있습니다. React Native CLI 프로젝트에서 `NativeModules.BatteryManager`를 사용하려면 해당 가이드에 따라 네이티브 코드를 직접 작성하고 연결해야 합니다. Expo 프로젝트에서는 `expo-battery`와 같은 Expo API를 사용하면 됩니다.

## 나쁜 예시와 좋은 예시 (개념)

`App.js` 파일 내의 주석을 참조하여, React Native에서 네이티브 모듈 및 API 연동 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 기기 API 접근 시 권한 관리는 필수이며, 네이티브 모듈 호출 시에는 비동기 패턴을 따르고 에러 처리를 명확히 해야 합니다.
