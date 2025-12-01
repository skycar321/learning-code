// Step3_NavigationAndStateManagement.dart
// Flutter 내비게이션 및 상태 관리 학습을 위한 코드 예시입니다.
// 이 파일은 Flutter 앱 내에서 화면 간 이동(내비게이션)과
// 위젯의 상태를 효율적으로 관리하는 방법(setState, Provider)을 보여줍니다.
//
// Flutter 앱은 여러 화면으로 구성되며, 사용자 경험을 위해 화면 간 자연스러운 전환과
// 데이터 관리가 필수적입니다.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 상태 관리를 위해 provider 패키지 사용

void main() {
  // -----------------------------------------------------------------------------
  // 학습 포인트 3: 상태 관리 (Provider 사용)
  // - Provider는 Flutter의 상태 관리를 위한 인기 있는 패키지입니다.
  // - 위젯 트리에 데이터를 주입하여 하위 위젯들이 쉽게 접근할 수 있도록 합니다.
  // - `ChangeNotifierProvider`: 상태 변경을 알릴 수 있는 ChangeNotifier를 제공합니다.
  // -----------------------------------------------------------------------------
  runApp(
    ChangeNotifierProvider(
      create: (context) => CounterModel(), // CounterModel 인스턴스를 제공
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation & State Management',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      // -----------------------------------------------------------------------------
      // 학습 포인트 1: 내비게이션 (Navigation)
      // - `routes`: Named Routes를 정의하여 문자열 이름으로 화면을 이동할 수 있습니다.
      // - `initialRoute`: 앱이 시작될 때 처음 보여줄 화면을 지정합니다.
      // -----------------------------------------------------------------------------
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/detail': (context) => const DetailScreen(),
        '/settings': (context) => const SettingsScreen(),
        // 나쁜 예시: 모든 화면 이동에 익명 함수와 MaterialPageRoute를 반복적으로 사용하는 것.
        // - 코드 중복이 발생하고, 파라미터 전달 로직이 복잡해질 수 있습니다.
        // - Named Routes나 GoRouter, auto_route 같은 라우팅 패키지를 사용하는 것이 좋습니다.
      },
      // onGenerateRoute: (settings) {
      //   // 동적 라우팅을 처리할 때 유용 (예: /product/123)
      //   if (settings.name == '/product') {
      //     final args = settings.arguments as Map<String, dynamic>;
      //     return MaterialPageRoute(builder: (context) => ProductScreen(productId: args['id']));
      //   }
      //   return null;
      // },
    );
  }
}

// 상태 관리를 위한 모델 (Provider 사용)
class CounterModel extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
    notifyListeners(); // 상태 변경을 구독자에게 알림
  }

  void decrement() {
    _count--;
    notifyListeners();
  }
}

// -----------------------------------------------------------------------------
// 학습 포인트 2: 로컬 상태 관리 (`setState`)
// - StatefulWidget 내에서 `setState`를 호출하여 위젯의 UI를 업데이트합니다.
// - 간단한 위젯 내부의 상태 관리에 적합합니다.
// -----------------------------------------------------------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _message = '초기 메시지';

  void _updateMessage(String newMessage) {
    setState(() {
      _message = newMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Provider를 통해 CounterModel 인스턴스에 접근
    final counterModel = Provider.of<CounterModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('홈 화면'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '로컬 상태: $_message',
              style: const TextStyle(fontSize: 20),
            ),
            ElevatedButton(
              onPressed: () {
                _updateMessage('메시지 업데이트됨!');
              },
              child: const Text('로컬 상태 업데이트'),
            ),
            const SizedBox(height: 20),
            Text(
              '전역 카운터 (Provider): ${counterModel.count}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () {
                counterModel.increment();
              },
              child: const Text('카운터 증가 (Provider)'),
            ),
            ElevatedButton(
              onPressed: () {
                counterModel.decrement();
              },
              child: const Text('카운터 감소 (Provider)'),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Named Route를 사용하여 화면 이동
                Navigator.pushNamed(context, '/detail', arguments: '홈 화면에서 보낸 데이터');
              },
              child: const Text('상세 화면으로 이동'),
            ),
            ElevatedButton(
              onPressed: () {
                // 파라미터 없이 Named Route로 이동
                Navigator.pushNamed(context, '/settings');
              },
              child: const Text('설정 화면으로 이동'),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  const DetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 이전 화면에서 전달된 인자를 받습니다.
    final String? data = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('상세 화면'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              data != null ? '전달받은 데이터: $data' : '전달받은 데이터 없음',
              style: const TextStyle(fontSize: 20),
            ),
            ElevatedButton(
              onPressed: () {
                // 현재 화면을 스택에서 제거하고 이전 화면으로 돌아갑니다.
                Navigator.pop(context);
              },
              child: const Text('뒤로 가기'),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provider를 통해 CounterModel 인스턴스에 접근
    final counterModel = Provider.of<CounterModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정 화면'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '이곳은 설정 화면입니다.',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              '전역 카운터 (Provider): ${counterModel.count}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () {
                counterModel.increment();
              },
              child: const Text('카운터 증가 (Provider)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('뒤로 가기'),
            ),
          ],
        ),
      ),
    );
  }
}

/*
이 코드를 실행하려면 다음 단계를 따르세요:

1. Flutter SDK 설치 및 환경 변수 설정.
2. IDE (VS Code 또는 Android Studio)에 Flutter 및 Dart 플러그인 설치.
3. 새 Flutter 프로젝트 생성: `flutter create my_flutter_app`
4. `pubspec.yaml` 파일에 `provider` 패키지 추가:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     provider: ^6.0.5 # 최신 버전으로 업데이트될 수 있음
   ```
5. 터미널에서 `flutter pub get` 실행하여 패키지 설치.
6. 생성된 프로젝트 폴더 내의 `lib/main.dart` 파일 내용을 이 파일의 내용으로 교체.
7. 에뮬레이터 또는 실제 기기를 실행하고, IDE에서 `main.dart`를 실행하거나 터미널에서 `flutter run`.

실행 후:
- 홈 화면에서 '로컬 상태 업데이트' 버튼을 눌러 `setState` 동작 확인.
- '카운터 증가/감소 (Provider)' 버튼을 눌러 전역 상태가 업데이트되고 모든 화면에 반영되는지 확인.
- '상세 화면으로 이동' 및 '설정 화면으로 이동' 버튼을 눌러 화면 간 이동 확인.
- 상세 화면에서 뒤로 가기 버튼을 눌러 이전 화면으로 돌아오기 확인.
*/
