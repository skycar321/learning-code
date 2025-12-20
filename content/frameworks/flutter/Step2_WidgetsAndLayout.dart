// Step2_WidgetsAndLayout.dart
// Flutter 위젯 및 레이아웃 학습을 위한 코드 예시입니다.
// 이 파일은 Flutter의 "모든 것이 위젯"이라는 개념을 바탕으로,
// StatelessWidget과 StatefulWidget, 그리고 다양한 기본 및 레이아웃 위젯을
// 사용하여 유연하고 반응적인 UI를 구축하는 방법을 보여줍니다.
//
// Flutter UI는 위젯 트리의 조합으로 구성되며, 위젯의 속성(property)을 통해
// UI의 모양과 동작을 제어합니다.

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Widgets & Layout',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const WidgetLayoutHomePage(),
    );
  }
}

class WidgetLayoutHomePage extends StatelessWidget {
  const WidgetLayoutHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Widgets & Layout'),
      ),
      body: SingleChildScrollView( // 내용이 화면을 넘어갈 경우 스크롤 가능하게 함
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // -----------------------------------------------------------------------------
              // 학습 포인트 1: 모든 것이 위젯 (Everything is a Widget)
              // - Flutter의 UI는 Text, Image, Button 등 모든 시각적 요소가 위젯입니다.
              // - 레이아웃을 구성하는 Row, Column, Container 등도 위젯입니다.
              // - StatelessWidget: 빌드 시점에 상태가 결정되고 변경되지 않는 위젯 (예: Text, Icon).
              // - StatefulWidget: 내부 상태를 가질 수 있고, 상태 변경 시 UI를 다시 그리는 위젯 (예: Checkbox, Slider).
              // -----------------------------------------------------------------------------
              const Text(
                '1. 기본 위젯 (Core Widgets)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // 1.1. Text 위젯: 텍스트를 표시
              const Text(
                '안녕하세요, Flutter!',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),

              // 1.2. Image 위젯: 이미지를 표시 (Asset, Network, File 등)
              // 네트워크 이미지 (권장: `CachedNetworkImage` 패키지 사용)
              Image.network(
                'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 10),

              // 1.3. Icon 위젯: Material Design 아이콘 표시
              const Icon(
                Icons.favorite,
                color: Colors.red,
                size: 40,
              ),
              const SizedBox(height: 10),

              // 1.4. Button 위젯: 사용자 상호작용을 위한 버튼
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ElevatedButton 클릭!')),
                  );
                },
                child: const Text('클릭하세요!'),
              ),
              const SizedBox(height: 20),

              // -----------------------------------------------------------------------------
              // 학습 포인트 2: 레이아웃 위젯 (Layout Widgets)
              // - 여러 위젯을 특정 규칙에 따라 배치하는 데 사용됩니다.
              // - 주로 Row, Column, Stack이 널리 사용됩니다.
              // -----------------------------------------------------------------------------
              const Text(
                '2. 레이아웃 위젯 (Layout Widgets)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // 2.1. Row 위젯: 위젯들을 가로로 배치
              // 나쁜 예시: Row 안에 너무 많은 컨텐츠를 넣어 화면 오버플로우 발생 (스크롤 불가)
              // - 해결책: SingleChildScrollView, ListView, Expanded, Flexible 등을 사용하여 유연하게 처리
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround, // 주축(가로) 정렬
                crossAxisAlignment: CrossAxisAlignment.center,  // 교차축(세로) 정렬
                children: const <Widget>[
                  Icon(Icons.star, color: Colors.amber),
                  Text('아이템 1'),
                  Text('아이템 2'),
                  Icon(Icons.star, color: Colors.amber),
                ],
              ),
              const SizedBox(height: 10),

              // 2.2. Column 위젯: 위젯들을 세로로 배치
              Column(
                mainAxisAlignment: MainAxisAlignment.start, // 주축(세로) 정렬
                crossAxisAlignment: CrossAxisAlignment.start, // 교차축(가로) 정렬
                children: const <Widget>[
                  Text('첫 번째 줄'),
                  Text('두 번째 줄', style: TextStyle(fontSize: 16)),
                  Text('세 번째 줄', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),

              // 2.3. Container 위젯: 레이아웃, 스타일링, 정렬 등 다양한 용도로 사용되는 만능 위젯
              Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[100],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  '이것은 Container 위젯입니다.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),

              // 2.4. Expanded & Flexible 위젯: Row, Column, Flex 위젯의 자식 요소에게 공간을 할당
              // - Expanded: 남은 공간을 모두 차지하려고 합니다.
              // - Flexible: 남은 공간 내에서 자식의 크기만큼만 차지하거나, flex 값을 이용해 비율로 차지합니다.
              Row(
                children: [
                  Container(
                    color: Colors.red,
                    height: 50,
                    width: 50,
                  ),
                  Expanded( // 남은 공간을 모두 차지
                    child: Container(
                      color: Colors.green,
                      height: 50,
                      child: const Center(child: Text('Expanded')),
                    ),
                  ),
                  Flexible( // 남은 공간 내에서 자신의 콘텐츠 크기만큼 차지 (flex를 주면 비율)
                    flex: 1, // 비율 (Expanded와 비슷하게 동작)
                    child: Container(
                      color: Colors.blue,
                      height: 50,
                      child: const Center(child: Text('Flexible')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2.5. Stack 위젯: 위젯들을 겹쳐서 배치 (Z-index와 유사)
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    width: 150,
                    height: 150,
                    color: Colors.purple,
                  ),
                  Positioned( // Stack 내에서 자식 위젯의 위치를 정확하게 지정
                    top: 20,
                    left: 20,
                    child: Container(
                      width: 100,
                      height: 100,
                      color: Colors.orange,
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: const Text(
                      '겹치기',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // -----------------------------------------------------------------------------
              // 학습 포인트 3: 스크롤 가능한 위젯 (Scrollable Widgets)
              // - 내용이 화면보다 길어질 때 스크롤 기능을 제공합니다.
              // - ListView, GridView, CustomScrollView 등이 있습니다.
              // -----------------------------------------------------------------------------
              const Text(
                '3. 스크롤 가능한 위젯 (Scrollable Widgets)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // 3.1. ListView: 가장 일반적인 스크롤 가능한 목록
              // `shrinkWrap`과 `physics`는 SingleChildScrollView 안에 ListView를 넣을 때 유용
              SizedBox( // ListView가 무한정 커지는 것을 방지하기 위해 높이 제한
                height: 150,
                child: ListView.builder(
                  shrinkWrap: true, // 부모 위젯의 크기에 맞게 목록 크기 조정
                  physics: const NeverScrollableScrollPhysics(), // SingleChildScrollView와 충돌 방지
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: ListTile(
                        leading: Icon(Icons.check_circle),
                        title: Text('리스트 아이템 ${index + 1}'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // 3.2. GridView: 그리드 형태의 스크롤 가능한 목록
              SizedBox(
                height: 150,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 한 줄에 3개의 아이템
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return Container(
                      color: Colors.amber[100 * (index % 9)],
                      alignment: Alignment.center,
                      child: Text('Grid ${index + 1}'),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // -----------------------------------------------------------------------------
              // 학습 포인트 4: Material Design 및 Cupertino 위젯, 테마 (Themes)
              // - `MaterialApp`: 안드로이드 Material Design 가이드라인을 따르는 앱을 위한 최상위 위젯.
              // - `CupertinoApp`: iOS 휴먼 인터페이스 가이드라인을 따르는 앱을 위한 최상위 위젯.
              // - `ThemeData`: 앱 전체의 색상, 폰트, 위젯 스타일 등을 정의합니다.
              // -----------------------------------------------------------------------------
              const Text(
                '4. 테마 및 Material/Cupertino 위젯',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // 이미 MaterialApp에서 primarySwatch를 설정하여 앱 전체 테마를 적용했습니다.
              // Cupertino (iOS 스타일) 위젯은 직접 MaterialApp 내에서 사용할 수 있습니다.
              // 예: CupertinoButton, CupertinoAlertDialog 등
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Text('Material Design Example:'),
                    Switch(
                      value: true,
                      onChanged: (bool value) {},
                      activeColor: Theme.of(context).primaryColor, // 테마 색상 활용
                    ),
                    const SizedBox(height: 10),
                    const Text('Cupertino Design Example:'),
                    // CupertinoButton(
                    //   child: const Text('Cupertino Button'),
                    //   onPressed: () {
                    //     ScaffoldMessenger.of(context).showSnackBar(
                    //       const SnackBar(content: Text('CupertinoButton 클릭!')),
                    //     );
                    //   },
                    // ),
                    // 주의: Cupertino 위젯은 iOS 환경에서 더 자연스럽게 보입니다.
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 나쁜 예시: 복잡한 UI를 하나의 build 메서드에 모두 작성
              // - 가독성이 떨어지고, 특정 부분만 변경되어도 전체 위젯이 리빌드될 수 있어 성능에 좋지 않습니다.
              // - 해결책: UI를 작은 위젯들로 분리하고 재사용 가능하도록 구성해야 합니다.
              // build(context) { return Column( ... 수백 줄의 코드 ... ); }
            ],
          ),
        ),
      ),
    );
  }
}

/*
이 코드를 실행하려면 다음 단계를 따르세요:

1. Flutter SDK 설치 및 환경 변수 설정.
2. IDE (VS Code 또는 Android Studio)에 Flutter 및 Dart 플러그인 설치.
3. 새 Flutter 프로젝트 생성: `flutter create my_flutter_layout_app`
4. 생성된 프로젝트 폴더 내의 `lib/main.dart` 파일 내용을 이 파일의 내용으로 교체.
5. 에뮬레이터 또는 실제 기기를 실행하고, IDE에서 `main.dart`를 실행하거나 터미널에서 `flutter run`.

실행 후, 앱에서 다양한 위젯과 레이아웃이 어떻게 구성되는지 확인하고
SingleChildScrollView를 통해 전체 콘텐츠를 스크롤할 수 있는지 확인하세요.
*/
