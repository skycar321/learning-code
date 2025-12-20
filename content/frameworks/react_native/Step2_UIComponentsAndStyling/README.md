# Step2: React Native UI 컴포넌트 및 스타일링

이 디렉토리는 React Native의 사용자 인터페이스(UI) 컴포넌트와 스타일링 기법을 학습하기 위한 예제 코드입니다.

## 학습 목표

-   사용자 입력 컴포넌트 (`TextInput`, `Button`, `TouchableOpacity`) 활용
-   리스트 렌더링 (`FlatList`)을 이용한 대규모 데이터 효율적 표시
-   `Platform` 모듈을 이용한 플랫폼별 스타일링
-   외부 UI 라이브러리의 개념 이해 및 활용 시나리오

## 프로젝트 구조

```
react_native/Step2_UIComponentsAndStyling/
├── App.js                    # UI 컴포넌트 및 스타일링 예제
└── README.md
```

## 파일 설명

-   **`App.js`**:
    -   **사용자 입력 컴포넌트**:
        -   `TextInput`: `onChangeText`와 `value` 프롭을 이용하여 사용자 입력을 제어합니다. `placeholder`로 힌트를 제공합니다.
        -   `Button`: 기본적인 버튼 컴포넌트입니다.
        -   `TouchableOpacity`: `Button`보다 스타일링이 더 자유롭고 터치 시 투명도 변화 효과를 제공하는 컴포넌트입니다.
    -   **리스트 렌더링 (`FlatList`)**:
        -   `data`: 렌더링할 항목 배열을 받습니다.
        -   `renderItem`: 각 항목을 렌더링하는 함수를 정의합니다.
        -   `keyExtractor`: 각 항목의 고유 키를 추출하는 함수로, 리스트 렌더링 성능 최적화에 필수적입니다.
        -   입력된 텍스트를 `FlatList`에 추가하고 삭제하는 간단한 투두리스트 기능을 구현하여 `TextInput`과 `FlatList`의 연동을 보여줍니다.
    -   **플랫폼별 스타일링 (`Platform` 모듈)**:
        -   `Platform.OS`를 통해 현재 실행 중인 OS(`ios`, `android` 등)를 식별하고, `Platform.select()` 메서드를 사용하여 플랫폼에 따라 다른 스타일을 적용하는 예시를 보여줍니다.
    -   **외부 UI 라이브러리**: `React Native Elements`, `NativeBase`와 같은 외부 라이브러리를 사용하면 미리 만들어진 컴포넌트들을 활용하여 개발 속도를 높일 수 있음을 설명합니다.

## 설정 및 실행 방법

`react_native/Step2_UIComponentsAndStyling` 디렉토리에서 터미널을 열고 다음 명령어를 실행합니다.

1.  **React Native 프로젝트 생성**:
    -   `expo init react-native-ui-app` 또는 `npx react-native init react-native-ui-app`
    -   `cd react-native-ui-app`

2.  **`App.js` 파일 교체**:
    -   생성된 프로젝트의 `App.js` 파일 내용을 이 디렉토리의 `App.js` 파일 내용으로 교체합니다.

3.  **프로젝트 실행**:
    -   **Expo CLI**:
        ```bash
        npm start
        ```
    -   **React Native CLI**:
        ```bash
        npm run ios
        # 또는 npm run android
        ```
    -   앱이 시뮬레이터 또는 실제 기기에서 실행되면, UI 컴포넌트의 동작과 스타일링이 적용된 화면을 확인할 수 있습니다.

4.  **기능 테스트**:
    -   `TextInput`에 텍스트를 입력하고 '항목 추가' 버튼을 눌러 `FlatList`에 항목이 추가되는 것을 확인합니다.
    -   각 항목 옆의 '삭제' 버튼을 눌러 항목이 제거되는 것을 확인합니다.
    -   플랫폼별 스타일링(`platformSpecificBox`)이 iOS와 Android에서 다르게 적용되는 것을 확인합니다 (두 플랫폼에서 모두 실행해보면).

## 나쁜 예시와 좋은 예시 (개념)

`App.js` 파일 내의 주석을 참조하여, React Native UI 컴포넌트 및 스타일링 사용 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 특히 `FlatList`를 이용한 대규모 리스트의 효율적인 렌더링과 `Platform` 모듈을 이용한 플랫폼별 스타일링은 중요한 모바일 앱 개발 기술입니다.
