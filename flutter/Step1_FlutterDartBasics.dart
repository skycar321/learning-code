// Step1_FlutterDartBasics.dart
// Flutter 및 Dart 기본 개념 학습을 위한 코드 예시입니다.
// 이 파일은 Dart 언어의 기본적인 문법과 Flutter 프로젝트의 주요 구성 요소를 이해하는 데 중점을 둡니다.
//
// Flutter는 Dart 언어를 사용하여 크로스 플랫폼 애플리케이션을 개발하는 강력한 프레임워크입니다.
// Dart의 문법적 특성을 이해하는 것은 Flutter 개발의 기초가 됩니다.

// -----------------------------------------------------------------------------
// 학습 포인트 1: Dart 언어 기초 (변수, 자료형, 함수, 클래스)
// -----------------------------------------------------------------------------

// 1.1. 변수 선언 및 자료형
void dartBasics() {
  // `var`: 타입 추론. 초기 값에 따라 타입이 결정됩니다.
  var name = 'Flutter'; // String
  var year = 2017;      // int
  var antennaDiameter = 3.7; // double
  var flybyObjects = ['Jupiter', 'Saturn', 'Uranus', 'Neptune']; // List<String>
  var image = {           // Map<String, String>
    'tags': ['saturn'],
    'url': '//path/to/saturn.jpg'
  };
  var isLaunched = true; // bool

  // `String`, `int`, `double`, `bool`, `List`, `Map` 등 명시적 타입 선언도 가능합니다.
  String message = 'Hello, Dart!';
  int count = 10;
  List<String> fruits = ['Apple', 'Banana'];

  // `final`과 `const`:
  // `final`: 런타임에 값이 한 번 할당되면 변경할 수 없습니다. (초기화 시점이 런타임)
  final DateTime now = DateTime.now();
  // `const`: 컴파일 시점에 값이 결정되어야 합니다. (상수)
  const double PI = 3.141592;

  print('Dart Basics Example:');
  print('Name: $name, Year: $year, PI: $PI');
  print('Flyby objects: $flybyObjects');
  print('Current time: $now');

  // 나쁜 예시: `var`를 남용하여 코드의 가독성을 해치거나, `dynamic`을 과도하게 사용하는 것.
  // `dynamic`은 모든 타입을 허용하지만, 런타임 오류 가능성이 높아집니다.
  dynamic badExample = 'This is a string';
  badExample = 123; // 런타임에 타입 변경 가능
  // print(badExample.length); // 이 시점에서는 int이므로 오류 발생 가능성이 높음
  print('Bad dynamic example: $badExample');
}

// 1.2. 함수 (Functions)
// Dart의 모든 함수는 객체입니다.
int add(int a, int b) {
  return a + b;
}

// 화살표 함수 (Arrow function): 한 줄짜리 함수에 유용
int subtract(int a, int b) => a - b;

// 명명된 파라미터 (Named parameters): `required` 또는 기본값 설정 가능
void greet({required String name, String greeting = 'Hello'}) {
  print('$greeting, $name!');
}

// 옵셔널 위치 파라미터 (Optional positional parameters): `[]` 안에 선언
void printInfo(String title, [String? author, int? year]) {
  print('Title: $title');
  if (author != null) print('Author: $author');
  if (year != null) print('Year: $year');
}

// 1.3. 클래스 (Classes) 및 객체 지향 프로그래밍
class Spaceship {
  String name;
  DateTime? launchDate; // Nullable type (Dart 2.12부터)

  // 생성자
  Spaceship(this.name, this.launchDate);

  // 명명된 생성자 (Named constructor)
  Spaceship.unlaunched(String name) : this(name, null);

  // Getter
  int? get launchYear => launchDate?.year; // Null-safe operator `?.`

  // 메서드
  void describe() {
    print('Spaceship: $name');
    if (launchDate != null) {
      print('Launched on: $launchDate');
    } else {
      print('Status: Unlaunched');
    }
  }

  // 나쁜 예시: 모든 필드를 public으로 선언하여 캡슐화를 지키지 않는 것.
  // Dart에서는 `_` (언더스코어)로 시작하는 변수나 메서드는 private처럼 동작합니다 (파일 스코프).
  // class BadSpaceship {
  //   String badName; // public
  // }
}

// -----------------------------------------------------------------------------
// 학습 포인트 2: 새 Flutter 프로젝트 생성 및 실행 (개념)
// - `flutter create <project_name>`: 새 Flutter 프로젝트를 생성합니다.
// - `flutter run`: 에뮬레이터 또는 실제 기기에서 앱을 실행합니다.
// - `main.dart` 파일이 앱의 시작점입니다.
// -----------------------------------------------------------------------------

// main 함수: Flutter 앱의 진입점
import 'package:flutter/material.dart';

void main() {
  // Dart 언어 기초 함수 호출
  dartBasics();
  print('Sum of 5 and 3: ${add(5, 3)}');
  greet(name: 'Alice');
  printInfo('The Dart Programming Language', 'Google', 2011);

  // 클래스 및 객체 예시
  var voyager = Spaceship('Voyager I', DateTime(1977, 9, 5));
  voyager.describe();
  var enterprise = Spaceship.unlaunched('Enterprise');
  enterprise.describe();
  print('Voyager launch year: ${voyager.launchYear}');

  // Flutter 앱 실행
  runApp(const MyApp());
}

// -----------------------------------------------------------------------------
// 학습 포인트 3: Hot Reload 및 Hot Restart 이해 (개념)
// - Hot Reload: 코드 변경 사항을 앱의 상태를 유지한 채로 빠르게 반영합니다. (개발 생산성 향상)
// - Hot Restart: 앱의 상태를 포함하여 모든 것을 초기화하고 앱을 다시 시작합니다. (새로운 데이터 로드 등)
// - `flutter run` 상태에서 `r` 키를 누르면 Hot Reload, `R` 키를 누르면 Hot Restart가 실행됩니다.
// -----------------------------------------------------------------------------

// Flutter 앱의 최상위 위젯
// `StatelessWidget`: 상태가 없는 위젯. 위젯 빌드 후 변경되지 않는 정보를 표시할 때 사용.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Dart Basics',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Dart Basics Home Page'),
    );
  }
}

// `StatefulWidget`: 상태를 가질 수 있는 위젯. 사용자의 상호작용 등에 따라 UI가 변경될 때 사용.
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    // `setState`를 호출하여 위젯의 상태가 변경되었음을 Flutter 프레임워크에 알립니다.
    // Flutter는 이 위젯의 `build` 메서드를 다시 호출하여 UI를 업데이트합니다.
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            // 나쁜 예시: 너무 많은 위젯을 한 번에 리빌드하는 것
            // - `setState`의 범위가 너무 넓으면 불필요한 위젯까지 리빌드되어 성능 저하를 유발할 수 있습니다.
            // - 변경되는 부분만 `setState`로 감싸거나, 상태 관리 솔루션을 사용하여 최적화해야 합니다.
            // Text('Another unrelated widget: ${DateTime.now()}'), // 불필요하게 계속 리빌드되는 예시
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/*
이 코드를 실행하려면 다음 단계를 따르세요:

1. Flutter SDK 설치 및 환경 변수 설정.
2. IDE (VS Code 또는 Android Studio)에 Flutter 및 Dart 플러그인 설치.
3. 새 Flutter 프로젝트 생성: `flutter create my_first_app`
4. 생성된 프로젝트 폴더 내의 `lib/main.dart` 파일 내용을 이 파일의 내용으로 교체.
5. 에뮬레이터 또는 실제 기기를 실행하고, IDE에서 `main.dart`를 실행하거나 터미널에서 `flutter run`.

실행 후, 앱에서 + 버튼을 누르면 숫자가 증가하고, Hot Reload와 Hot Restart를 시도해보세요.
콘솔에는 Dart 기본 문법 예제 결과가 출력될 것입니다.
*/