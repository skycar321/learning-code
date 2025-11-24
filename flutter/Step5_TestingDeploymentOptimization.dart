// Step5_TestingDeploymentOptimization.dart
// Flutter 테스트, 배포 및 성능 최적화 학습을 위한 코드 예시입니다.
// 이 파일은 Flutter 애플리케이션의 품질을 보장하기 위한 테스트(단위, 위젯, 통합) 방법과
// 앱 아이콘/스플래시 화면 설정, 그리고 성능 최적화의 기본 개념을 다룹니다.
//
// 안정적인 앱을 제공하고 사용자 경험을 향상시키기 위해서는 철저한 테스트와
// 효율적인 배포, 그리고 지속적인 성능 관리가 필수적입니다.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart'; // Flutter 테스트 프레임워크

// -----------------------------------------------------------------------------
// 학습 포인트 1: 테스트 (Testing)
// - Flutter는 다양한 유형의 테스트를 지원합니다:
//   - 유닛 테스트 (Unit Test): 단일 함수, 메서드 또는 클래스를 테스트.
//   - 위젯 테스트 (Widget Test): 단일 위젯 또는 작은 위젯 트리(UI)가 예상대로 렌더링되고 동작하는지 테스트.
//   - 통합 테스트 (Integration Test): 앱의 큰 부분 또는 전체 앱이 시나리오에 따라 예상대로 동작하는지 테스트.
// -----------------------------------------------------------------------------

// 예시 위젯: 간단한 카운터 위젯
class MyCounterWidget extends StatefulWidget {
  const MyCounterWidget({Key? key}) : super(key: key);

  @override
  State<MyCounterWidget> createState() => _MyCounterWidgetState();
}

class _MyCounterWidgetState extends State<MyCounterWidget> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('카운터 앱')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('카운트 값:'),
              Text(
                '$_counter',
                key: const Key('counterText'), // 테스트를 위한 Key 추가
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    key: const Key('decrementButton'), // 테스트를 위한 Key 추가
                    onPressed: _decrementCounter,
                    heroTag: 'decrement', // Hero 애니메이션 충돌 방지
                    child: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: 20),
                  FloatingActionButton(
                    key: const Key('incrementButton'), // 테스트를 위한 Key 추가
                    onPressed: _incrementCounter,
                    heroTag: 'increment', // Hero 애니메이션 충돌 방지
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 위젯 테스트 (Widget Test) 예시: MyCounterWidgetTest
// - `testWidgets` 함수를 사용하여 위젯을 테스트합니다.
// - `tester` 객체를 사용하여 위젯을 렌더링하고, 사용자 이벤트를 시뮬레이션하며, 위젯을 찾습니다.
// -----------------------------------------------------------------------------
void main() {
  group('MyCounterWidget', () {
    testWidgets('카운터 초기 값은 0이어야 합니다.', (WidgetTester tester) async {
      // 위젯을 렌더링합니다.
      await tester.pumpWidget(const MyCounterWidget());

      // '0'이라는 텍스트를 가진 위젯을 찾습니다.
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing); // '1'이라는 텍스트는 없어야 합니다.
    });

    testWidgets('증가 버튼을 탭하면 카운터가 증가해야 합니다.', (WidgetTester tester) async {
      await tester.pumpWidget(const MyCounterWidget());

      // 카운트 텍스트 위젯을 찾습니다.
      final counterTextFinder = find.byKey(const Key('counterText'));
      expect(counterTextFinder, findsOneWidget);
      expect((tester.widget(counterTextFinder) as Text).data, '0');

      // 증가 버튼을 찾아서 탭합니다.
      await tester.tap(find.byKey(const Key('incrementButton')));
      await tester.pump(); // 위젯을 다시 빌드하여 변경된 상태를 반영합니다.

      // 카운터 텍스트가 '1'로 변경되었는지 확인합니다.
      expect((tester.widget(counterTextFinder) as Text).data, '1');
      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('감소 버튼을 탭하면 카운터가 감소해야 합니다.', (WidgetTester tester) async {
      await tester.pumpWidget(const MyCounterWidget());

      // 증가 버튼을 두 번 탭하여 카운터를 '2'로 만듭니다.
      await tester.tap(find.byKey(const Key('incrementButton')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('incrementButton')));
      await tester.pump();
      expect((tester.widget(find.byKey(const Key('counterText'))) as Text).data, '2');

      // 감소 버튼을 탭합니다.
      await tester.tap(find.byKey(const Key('decrementButton')));
      await tester.pump(); // 위젯을 다시 빌드합니다.

      // 카운터 텍스트가 '1'로 변경되었는지 확인합니다.
      expect((tester.widget(find.byKey(const Key('counterText'))) as Text).data, '1');
      expect(find.text('2'), findsNothing);
      expect(find.text('1'), findsOneWidget);
    });

    // 나쁜 예시: 너무 많은 로직을 한 테스트 케이스에 넣는 것.
    // - 테스트는 단일 책임 원칙(Single Responsibility Principle)을 따라야 합니다.
    // - 각 테스트는 하나의 특정 시나리오만 검증해야 합니다.
    // @testWidgets('모든 버튼과 초기 상태 테스트', (WidgetTester tester) async {
    //   await tester.pumpWidget(const MyCounterWidget());
    //   expect(find.text('0'), findsOneWidget);
    //   await tester.tap(find.byIcon(Icons.add));
    //   await tester.pump();
    //   expect(find.text('1'), findsOneWidget);
    //   await tester.tap(find.byIcon(Icons.remove));
    //   await tester.pump();
    //   expect(find.text('0'), findsOneWidget);
    // });
  });
}

// -----------------------------------------------------------------------------
// 학습 포인트 2: 디버깅 (Debugging) - Dart DevTools
// - Dart DevTools는 Flutter 앱의 UI 레이아웃, 성능, 메모리, 네트워크 등을
//   시각적으로 분석하고 디버깅할 수 있는 강력한 도구입니다.
// - 사용법: `flutter run` 후 터미널에 출력되는 DevTools URL로 접속하거나,
//   IDE에서 "Open DevTools" 기능을 사용합니다.
// - 주요 기능:
//   - Widget Inspector: 위젯 트리 및 속성 확인.
//   - Performance: 프레임 렌더링 시간, CPU/GPU 사용량.
//   - Memory: 메모리 사용량 및 누수 감지.
//   - Network: 네트워크 요청 확인.
//   - Logging: 앱 로그 확인.
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// 학습 포인트 3: 성능 최적화 (Performance Optimization)
// - 불필요한 위젯 재빌드 방지: `const` 위젯 사용, `setState` 범위 최소화,
//   `ChangeNotifierProvider` 등 상태 관리 솔루션으로 위젯 리빌드 최소화.
// - 이미지 최적화: 적절한 해상도 이미지 사용, `CachedNetworkImage` 패키지 활용,
//   메모리 캐싱, 이미지 로드 우선순위 지정.
// - 빌드 모드: `flutter run --release`로 릴리즈 모드 빌드 시 성능 최적화 자동 적용.
// - 프로파일링: Dart DevTools의 Performance 탭을 사용하여 병목 현상 식별.
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// 학습 포인트 4: 앱 아이콘 및 스플래시 화면 설정 (App Icon & Splash Screen)
// - 앱 아이콘: `flutter_launcher_icons` 패키지 사용 또는 플랫폼별 설정.
//   - `android/app/src/main/res/mipmap-*` 에 아이콘 이미지 배치.
//   - `ios/Runner/Assets.xcassets/AppIcon.appiconset` 에 아이콘 이미지 배치.
// - 스플래시 화면: `flutter_native_splash` 패키지 사용 또는 플랫폼별 설정.
//   - Android: `android/app/src/main/res/drawable/launch_background.xml` 및 `styles.xml`
//   - iOS: `ios/Runner/Base.lproj/LaunchScreen.storyboard`
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// 학습 포인트 5: 앱 스토어 배포 (Deploying to App Stores)
// - Android (Google Play Store):
//   - `android/app/build.gradle`에서 버전 코드 및 버전 이름 설정.
//   - 앱 서명 키 생성 및 `key.properties` 설정.
//   - `flutter build appbundle --release` (Google Play Store 업로드용).
//   - Google Play Console에 앱 등록 및 AAB 파일 업로드.
// - iOS (Apple App Store):
//   - Xcode를 사용하여 프로젝트 설정 (버전, 빌드 번호, 앱 아이콘 등).
//   - 앱 서명 및 프로비저닝 프로파일 설정.
//   - `flutter build ipa --release` (Apple App Store Connect 업로드용).
//   - App Store Connect에 앱 등록 및 IPA 파일 업로드.
// - 웹 및 데스크톱 앱 배포:
//   - `flutter build web`, `flutter build windows` 등의 명령어를 사용하여 빌드.
//   - 생성된 파일을 웹 서버나 배포 플랫폼에 업로드.
// -----------------------------------------------------------------------------


/*
이 코드를 테스트하려면:

1. `pubspec.yaml`에 `flutter_test`가 `dev_dependencies`에 포함되어 있는지 확인:
   ```yaml
   dev_dependencies:
     flutter_test:
       sdk: flutter
     flutter_lints: ^2.0.0
   ```
2. 프로젝트 루트 폴더에 `test/widget_test.dart` 파일을 생성하고
   해당 파일의 내용을 이 파일의 `main` 함수부터 끝까지 (위젯 테스트 코드 부분) 복사.
3. 터미널에서 `flutter test test/widget_test.dart`를 실행하거나, IDE에서 테스트를 실행합니다.

학습 시점:
- `MyCounterWidget`을 통해 StatefulWidget의 동작과 `setState`를 통한 UI 업데이트를 이해합니다.
- `main` 함수 내의 `group` 및 `testWidgets` 블록을 통해 위젯 테스트의 기본 구조와
  `tester` 객체의 사용법(`pumpWidget`, `tap`, `find.text`, `find.byKey` 등)을 익힙니다.
- `flutter build`, `flutter run --release`, `flutter doctor` 등 빌드 및 배포 관련
  Flutter CLI 명령어를 직접 사용해보는 것이 중요합니다.
- Dart DevTools를 활용하여 앱의 성능을 직접 프로파일링하고 디버깅하는 연습을 합니다.
*/
