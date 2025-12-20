# Step 10: Flutter 트러블슈팅 가이드 (Troubleshooting Guide)

Flutter 앱 개발 중(Android/iOS) 자주 마주치는 오류 Top 50을 정리했습니다. 에러 메시지(`RenderFlex...` 등)로 검색(`Ctrl+F`)하여 해결책을 찾으세요.

## 1. UI & Layout Errors (레이아웃)

### 1-1. `RenderFlex overflowed by ... pixels` (Yellow/Black striped bar)
- **원인**: Row/Column 안의 위젯이 화면 영역을 벗어남.
- **해결**:
  - `Expanded` 또는 `Flexible`로 감싸서 남은 공간만 차지하게 함.
  - 스크롤이 필요하면 `SingleChildScrollView` 또는 `ListView`로 감쌈.

### 1-2. `VerticalViewport was given unbounded height`
- **원인**: `Column` 안에 `ListView`를 넣을 때 높이 제한이 없어서 무한대 높이를 가지려 함.
- **해결**: `ListView`를 `Expanded`로 감싸거나 `shrinkWrap: true` 설정.

### 1-3. `Incorrect use of ParentDataWidget`
- **원인**: `Expanded`나 `Positioned`는 `Row`, `Column`, `Stack`의 **직계 자식**이어야 하는데, 다른 위젯이 끼어 있음.
- **해결**: 위젯 트리 구조 확인. `Expanded` 바로 위에 `Row`/`Column`이 있는지 확인.

### 1-4. `BoxConstraints forces an infinite width/height`
- **원인**: 부모가 무한대 크기를 허용하는데 자식도 무한대로 커지려 함.
- **해결**: 크기가 명시된 컨테이너로 감싸거나 제약 조건(`Constraints`) 확인.

### 1-5. `No Material widget found`
- **원인**: `Text`나 `InkWell` 같은 위젯은 상위 트리에 `Material` 위젯이 필요함.
- **해결**: `Scaffold` 또는 `Material` 위젯으로 감싸기.

### 1-6. `Scaffold.of() called with a context that does not contain a Scaffold`
- **원인**: `Scaffold`를 생성한 바로 그 `build` 메소드의 `context`로 `Scaffold.of()`를 호출함.
- **해결**: `Builder` 위젯으로 감싸서 새로운 `context`를 얻거나, 하위 위젯으로 분리.

### 1-7. Image Asset not loading
- **원인**: `pubspec.yaml`에 assets 등록 누락 또는 경로 오타.
- **해결**: 들여쓰기(2칸) 주의하여 등록하고 `flutter pub get`.

### 1-8. Keyboard covers text input
- **원인**: 키보드가 올라올 때 화면이 가려짐.
- **해결**: `Scaffold(resizeToAvoidBottomInset: true)` (기본값) 확인. `SingleChildScrollView`로 감싸기.

### 1-9. `RenderBox was not laid out`
- **원인**: 레이아웃 과정에서 크기가 결정되지 않음.
- **해결**: 부모 위젯이 크기 제약을 주는지 확인.

### 1-10. Font loading issues
- **원인**: 폰트 파일 경로 또는 `pubspec.yaml` family 이름 불일치.
- **해결**: 폰트 설정 재확인.

---

## 2. State Management & Logic (상태 관리)

### 2-1. `setState() called after dispose()`
- **원인**: 화면이 닫혔는데(dispose) 비동기 작업(API 호출 등)이 끝나고 `setState`를 호출함.
- **해결**: `if (mounted) { setState(() { ... }); }` 체크 추가.

### 2-2. `ProviderNotFoundException`
- **원인**: 위젯 트리 상위에 해당 Provider가 없음.
- **해결**: `MultiProvider`를 최상위(`runApp` 내부 또는 `MaterialApp` 위)로 이동.

### 2-3. `Future already completed`
- **원인**: `Completer`를 두 번 완료(complete) 시키려 함.
- **해결**: 로직 흐름 확인.

### 2-4. `Null check operator used on a null value`
- **원인**: `!` 연산자를 썼는데 변수가 `null`임.
- **해결**: `if (value != null)` 체크 또는 `?.` 연산자 사용.

### 2-5. `Concurrent modification during iteration`
- **원인**: 리스트를 반복문(for)으로 돌면서 요소를 삭제/추가함.
- **해결**: 리스트 복사본으로 반복하거나 `removeWhere` 사용.

### 2-6. Async function returns `Future<dynamic>`
- **원인**: 반환 타입 미지정.
- **해결**: `Future<void>`, `Future<String>` 등 타입 명시.

### 2-7. BloC/Cubit event ignored
- **원인**: 상태가 변경되지 않음 (Equatable props 미구현으로 같은 객체로 인식).
- **해결**: `Equatable` 패키지 사용 또는 `props` 오버라이드.

### 2-8. Riverpod `ProviderScope` missing
- **원인**: `runApp`에서 `ProviderScope`로 감싸지 않음.
- **해결**: `runApp(ProviderScope(child: MyApp()));`.

### 2-9. `LateInitializationError: Field ... has not been initialized`
- **원인**: `late` 변수를 초기화 전에 사용함.
- **해결**: 생성자나 `initState`에서 초기화 보장.

### 2-10. Infinite Loop in `build`
- **원인**: `build` 메소드 안에서 `setState`나 `notifyListeners`를 호출.
- **해결**: 상태 변경은 이벤트 핸들러나 `useEffect` 등에서 수행.

---

## 3. Build & Platform (빌드 및 플랫폼)

### 3-1. `Gradle build failed` / `Gradle task assembleDebug failed`
- **원인**: Android 설정 오류, 의존성 충돌, 네트워크 문제.
- **해결**:
  - `flutter clean` && `flutter pub get`.
  - `android/build.gradle`의 Kotlin/Gradle 버전 확인.

### 3-2. `CocoaPods not installed` / `pod install failed`
- **원인**: iOS 의존성 관리자 문제. (M1/M2 맥 문제 포함).
- **해결**:
  - `cd ios` && `rm -rf Pods Podfile.lock` && `pod install --repo-update`.
  - M1 맥: `sudo arch -x86_64 gem install ffi` 등 아키텍처 호환성 확인.

### 3-3. `MissingPluginException`
- **원인**: 네이티브 플러그인 코드가 앱에 등록되지 않음 (앱 실행 중 패키지 추가 시).
- **해결**: 앱 완전히 종료 후 다시 실행 (`flutter run` 재시작).

### 3-4. `PlatformException` (Channel Error)
- **원인**: 네이티브(Android/iOS) 코드에서 에러 발생.
- **해결**: 에러 메시지 상세 확인 (권한 부족, 설정 누락 등).

### 3-5. `minSdkVersion` error (Android)
- **원인**: 라이브러리가 더 높은 Android 버전을 요구함.
- **해결**: `android/app/build.gradle`에서 `minSdkVersion` 상향 (보통 21 이상).

### 3-6. iOS Deployment Target mismatch
- **원인**: `Podfile`의 타겟 버전이 라이브러리 요구사항보다 낮음.
- **해결**: `ios/Podfile` 상단 `platform :ios, '11.0'` 등으로 수정.

### 3-7. `ERR_CLEARTEXT_NOT_PERMITTED` (Android)
- **원인**: HTTP(비암호화) 요청 차단.
- **해결**: HTTPS 사용 권장. 개발용이면 `AndroidManifest.xml`에 `android:usesCleartextTraffic="true"` 추가.

### 3-8. iOS Info.plist Permission Crash
- **원인**: 카메라, 위치 등 권한 요청 설명(`NSCameraUsageDescription` 등) 누락.
- **해결**: `ios/Runner/Info.plist`에 키-값 추가.

### 3-9. `Version solving failed` (Pub get)
- **원인**: 패키지 간 버전 충돌.
- **해결**: `pubspec.yaml` 버전 조정 또는 `flutter pub upgrade`.

### 3-10. AndroidX incompatibility
- **원인**: 구형 라이브러리 사용.
- **해결**: `gradle.properties`에 `android.useAndroidX=true` 확인.

---

## 🔍 Good vs Bad Troubleshooting Habits

### ❌ Bad Practice
- **`flutter clean` 무한 반복**: 문제 원인 파악 없이 클린만 반복하는 것은 시간 낭비. 에러 로그를 읽어야 함.
- **네이티브 코드 무시**: `android/`나 `ios/` 폴더 설정을 무서워해서 건드리지 않음. (플러그인 사용 시 필수).
- **`Container` 중첩**: 레이아웃 문제를 해결하려고 의미 없는 컨테이너를 계속 감쌈.

### ✅ Good Practice
- **DevTools 활용**: `Flutter Inspector`로 레이아웃 오버플로우 원인 위젯을 시각적으로 찾기.
- **문서 확인**: `pub.dev`의 패키지 문서에서 `Android Setup` / `iOS Setup` 섹션을 반드시 정독.
- **기기 테스트**: 에뮬레이터뿐만 아니라 실기기(Real Device)에서도 테스트 (특히 카메라/위치 기능).
