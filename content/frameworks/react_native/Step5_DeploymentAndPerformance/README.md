# Step5: React Native 배포 및 성능 최적화

이 디렉토리는 React Native 애플리케이션의 테스트, 앱 스토어 배포, 그리고 성능 최적화 방법을 학습하기 위한 개념적인 설명입니다.

## 학습 목표

-   React Native 앱 테스트 전략 (유닛, 위젯, 통합 테스트) 이해
-   성능 최적화 기법 (렌더링 최적화, 이미지 최적화)
-   iOS 및 Android 앱 스토어 배포 과정 이해
-   OTA (Over-The-Air) 업데이트 개념 (CodePush)

## 프로젝트 구조

```
react_native/Step5_DeploymentAndPerformance/
└── README.md
```

## 파일 설명

-   **`README.md`**: (이 파일 자체)
    -   이 단계는 주로 개념적이며, 실제 코드를 포함하기보다는 전략과 절차에 대한 설명을 제공합니다.

## 학습 내용

### 1. 테스트 (Testing)

*   **유닛 테스트 (Unit Test)**:
    -   단일 함수, 메서드 또는 컴포넌트의 비즈니스 로직을 격리하여 테스트합니다.
    -   Jest와 같은 JavaScript 테스트 프레임워크를 사용합니다.
    -   예: 특정 함수가 올바른 값을 반환하는지, 상태 변경 로직이 예상대로 동작하는지 확인.
*   **컴포넌트/스냅샷 테스트 (Component/Snapshot Test)**:
    -   React Native 컴포넌트가 예상대로 렌더링되고 특정 prop에 대해 올바른 출력을 생성하는지 테스트합니다.
    -   Jest와 React Test Renderer를 사용하여 컴포넌트의 UI 구조 스냅샷을 찍고, 변경 사항을 추적합니다.
*   **통합 테스트 (Integration Test)**:
    -   여러 컴포넌트 또는 모듈이 함께 작동하는 방식을 테스트합니다.
    -   React Native Testing Library를 사용하면 사용자 관점에서 컴포넌트와 상호 작용하는 테스트를 작성할 수 있습니다.
*   **엔드-투-엔드(E2E) 테스트**:
    -   앱 전체의 사용자 시나리오를 실제 기기 또는 시뮬레이터에서 테스트합니다.
    -   Detox, Appium과 같은 도구를 사용합니다.
*   **나쁜 예시**: 테스트 코드를 작성하지 않거나, 수동 테스트에만 의존하여 앱의 품질을 보장하려 하는 것.
    -   오류를 조기에 발견하기 어렵고, 코드 변경 시 예상치 못한 버그가 발생할 확률이 높습니다.

### 2. 성능 최적화 (Performance Optimization)

*   **렌더링 최적화**:
    -   **불필요한 리렌더링 방지**: `React.memo`, `useCallback`, `useMemo` 훅을 사용하여 컴포넌트의 불필요한 리렌더링을 줄입니다.
    -   **`FlatList` / `SectionList` 사용**: 대규모 리스트를 렌더링할 때 `ScrollView` 안에 `map` 대신 `FlatList`를 사용하여 성능을 최적화합니다.
*   **이미지 최적화**:
    -   적절한 해상도 이미지 사용: 디바이스의 해상도에 맞는 이미지를 제공하여 메모리 사용량을 줄입니다.
    -   `fast-image` 또는 `react-native-cached-image`: 이미지 캐싱을 통해 네트워크 요청을 줄이고 로딩 속도를 향상시킵니다.
    -   WebP와 같은 최신 이미지 포맷 고려.
*   **메모리 최적화**:
    -   불필요한 객체 생성 방지: `useEffect`의 의존성 배열을 올바르게 사용하여 불필요한 함수 재생성 등을 방지합니다.
    -   메모리 누수 방지: 컴포넌트가 언마운트될 때 타이머, 이벤트 리스너 등의 리소스를 정리합니다.
*   **번들 사이즈 최적화**:
    -   Code Splitting: 필요한 코드만 로드하여 초기 로드 시간을 단축합니다.
    -   불필요한 라이브러리 제거, 트리 쉐이킹(Tree Shaking) 활용.
*   **나쁜 예시**: 성능 프로파일링 없이 최적화를 시도하거나, 모든 컴포넌트에 `React.memo`를 남용하는 것.
    -   프로파일링 도구(React Native Debugger, Flipper)를 사용하여 병목 현상을 정확히 식별한 후, 필요한 부분에만 최적화를 적용해야 합니다.

### 3. 앱 스토어 배포 (Deploying to App Stores)

*   **iOS (Apple App Store)**:
    -   **Xcode 사용**: `.ipa` 파일을 빌드하고 App Store Connect에 제출.
    -   **프로비저닝 프로파일 및 인증서**: 개발자 계정 설정, 앱 ID, 인증서, 프로비저닝 프로파일 관리.
    -   **버전 관리**: `Info.plist`에서 버전(`CFBundleShortVersionString`) 및 빌드 번호(`CFBundleVersion`) 설정.
    -   **`App Store Connect`**: 앱 정보 등록, 스크린샷, 가격 설정, 심사 제출.
*   **Android (Google Play Store)**:
    -   **Android Studio 사용**: `.aab` (Android App Bundle) 또는 `.apk` 파일을 빌드하고 Google Play Console에 제출.
    -   **키스토어(Keystore) 생성 및 서명**: 앱을 출시하기 위해 서명 키를 생성하고 앱에 서명. (보안 관리 중요!)
    -   **버전 관리**: `android/app/build.gradle`에서 `versionCode` 및 `versionName` 설정.
    -   **`Google Play Console`**: 앱 정보 등록, 스크린샷, 가격 설정, 출시 트랙(내부 테스트, 공개 테스트, 프로덕션) 관리.
*   **나쁜 예시**: 앱 서명 키를 분실하거나, 출시 전 필요한 정보를 제대로 확인하지 않아 앱 심사에서 거절당하는 것.
    -   앱 스토어 배포 전에 모든 필수 정보를 확인하고, 각 플랫폼의 가이드라인을 준수해야 합니다.

### 4. OTA (Over-The-Air) 업데이트 (CodePush)

*   **개념**: Microsoft의 CodePush와 같은 서비스를 사용하면 JavaScript 코드 변경 사항(React Native 앱의 번들)을 앱 스토어 재심사 없이 사용자 기기에 직접 배포할 수 있습니다.
*   **사용 시나리오**: 버그 수정, UI 변경, 기능 추가 등 JavaScript 코드 레벨의 업데이트.
*   **한계**: 네이티브 모듈(Java/Kotlin, Swift/Objective-C) 변경 사항은 OTA 업데이트로 배포할 수 없으며, 앱 스토어를 통해 앱 자체를 업데이트해야 합니다.
*   **나쁜 예시**: 모든 업데이트를 OTA로 배포하려 하거나, 네이티브 코드 변경 사항을 OTA로 배포하려 하는 것.
    -   OTA 업데이트의 장점과 한계를 명확히 이해하고 적절히 사용해야 합니다.

## 실습 가이드 (Practical Guide)
-   이 단계는 실제 코드 작성보다는 이론적 이해와 개념 파악에 중점을 둡니다.
-   Jest, React Native Testing Library 등을 사용하여 간단한 컴포넌트 테스트를 작성해봅니다.
-   React Native Debugger 또는 Flipper와 같은 디버깅 도구를 사용하여 앱의 성능을 프로파일링하고 불필요한 렌더링을 찾아봅니다.
-   iOS 및 Android 개발자 계정을 설정하고, 각 앱 스토어에 앱을 제출하는 과정을 간략하게 시뮬레이션해봅니다.

## 나쁜 예시와 좋은 예시 (개념)

`README.md` 내의 설명을 참조하여, React Native 앱 배포 및 성능 최적화 시 흔히 범할 수 있는 실수와 올바른 모범 사례를 이해하세요. 앱의 품질과 사용자 경험을 보장하기 위해서는 체계적인 테스트, 지속적인 성능 모니터링, 그리고 효율적인 배포 전략이 필수적입니다.
