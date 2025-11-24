// Step4_NativeFeaturesAndAdvancedUI.dart
// Flutter 네이티브 기능 및 고급 UI 학습을 위한 코드 예시입니다.
// 이 파일은 Flutter 앱에서 플랫폼별 네이티브 기능을 연동하는 방법(플러그인, MethodChannel)과
// 폼 처리, 제스처 감지, 애니메이션 등 고급 UI 기술을 사용하는 방법을 보여줍니다.
//
// Flutter는 대부분의 UI를 자체 렌더링하지만, 카메라, GPS, 배터리 정보 등
// 디바이스의 하드웨어 기능에 접근하려면 플랫폼별 네이티브 코드를 사용해야 합니다.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // MethodChannel을 사용하기 위해 필요
import 'package:url_launcher/url_launcher.dart'; // 외부 URL 실행 플러그인
import 'package:image_picker/image_picker.dart'; // 이미지 피커 플러그인 (예시)

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Native Features & Advanced UI',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const NativeFeaturesHomePage(),
    );
  }
}

class NativeFeaturesHomePage extends StatefulWidget {
  const NativeFeaturesHomePage({Key? key}) : super(key: key);

  @override
  State<NativeFeaturesHomePage> createState() => _NativeFeaturesHomePageState();
}

class _NativeFeaturesHomePageState extends State<NativeFeaturesHomePage> {
  // -----------------------------------------------------------------------------
  // 학습 포인트 1: 패키지 및 플러그인 사용 (Using Packages & Plugins)
  // - pub.dev에서 필요한 기능을 제공하는 패키지를 찾아 `pubspec.yaml`에 추가합니다.
  // - `url_launcher`: 외부 URL, 전화 걸기, 이메일 보내기 등
  // - `image_picker`: 갤러리 또는 카메라에서 이미지/비디오 선택
  // -----------------------------------------------------------------------------
  final ImagePicker _picker = ImagePicker();
  String? _imagePath; // 선택된 이미지 파일 경로

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // 나쁜 예시: 에러 처리 없이 `launchUrl`을 호출하여 실패 시 사용자에게 아무런 피드백도 주지 않는 것.
      // - 사용자에게 실패 원인을 알려주거나 대안을 제시해야 합니다.
      throw 'Could not launch $url';
    }
  }

  Future<void> _pickImage() async {
    // 갤러리에서 이미지 선택
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imagePath = image?.path;
    });
    if (image != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 선택됨: ${_imagePath}')),
      );
    }
  }


  // -----------------------------------------------------------------------------
  // 학습 포인트 2: 네이티브 기능 연동 (Integrating Native Features) - MethodChannel
  // - Dart 코드와 플랫폼별 네이티브 코드(Kotlin/Java for Android, Swift/Objective-C for iOS) 간의 통신 채널.
  // - Flutter에서 제공하지 않는 하드웨어 기능이나 OS 기능에 접근할 때 사용합니다.
  // -----------------------------------------------------------------------------
  static const platform = MethodChannel('com.example.app/battery'); // 채널 이름은 고유해야 함
  String _batteryLevel = '배터리 레벨을 가져올 수 없습니다.';

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      // 나쁜 예시: 네이티브 호출 시 네트워크/DB 작업 등 오래 걸리는 작업을 메인 스레드에서 직접 처리
      // - UI가 멈추거나 버벅거릴 수 있습니다. `await`를 사용하여 비동기로 처리해야 합니다.

      // invokeMethod: 네이티브 코드의 메서드를 호출
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = '배터리 레벨: $result %';
    } on PlatformException catch (e) {
      batteryLevel = "배터리 레벨을 가져오지 못함: '${e.message}'.";
    }
    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  // -----------------------------------------------------------------------------
  // 학습 포인트 3: 폼(Forms) 처리 및 유효성 검사 (Form Handling & Validation)
  // - `Form` 위젯과 `TextFormField`를 사용하여 사용자 입력을 처리하고 유효성을 검사합니다.
  // - `GlobalKey<FormState>`를 사용하여 폼의 상태를 관리합니다.
  // -----------------------------------------------------------------------------
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  void _submitForm() {
    if (_formKey.currentState!.validate()) { // 폼의 유효성 검사
      _formKey.currentState!.save(); // 폼 필드 저장
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('폼 제출됨: Email: $_email, Password: $_password')),
      );
    }
  }

  // -----------------------------------------------------------------------------
  // 학습 포인트 4: 제스처(Gestures) 감지 (Gesture Detection)
  // - `GestureDetector`: 탭, 더블 탭, 길게 누르기, 드래그 등 다양한 사용자 제스처를 감지합니다.
  // - `InkWell`: Material 위젯에서 탭 효과(splash effect)와 함께 제스처를 감지합니다.
  // -----------------------------------------------------------------------------
  String _gestureMessage = '제스처를 시도해보세요!';

  void _handleTap() {
    setState(() {
      _gestureMessage = '탭 감지됨!';
    });
  }

  void _handleLongPress() {
    setState(() {
      _gestureMessage = '길게 누르기 감지됨!';
    });
  }


  // -----------------------------------------------------------------------------
  // 학습 포인트 5: 애니메이션 (Animations) - (개념적 설명)
  // - `AnimationController`, `Tween`, `Hero` 애니메이션 등
  // - `AnimatedContainer`, `FadeTransition` 같은 암시적(Implicit) 애니메이션 위젯 사용
  // -----------------------------------------------------------------------------
  bool _showText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('네이티브 기능 및 고급 UI'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              '1. 패키지 및 플러그인',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () => _launchURL('https://flutter.dev'),
              child: const Text('Flutter 웹사이트 열기'),
            ),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('갤러리에서 이미지 선택'),
            ),
            if (_imagePath != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Image.network(_imagePath!), // File 이미지를 표시하려면 FileImage 사용
                // Image.file(File(_imagePath!)), // `dart:io`의 `File` 클래스 필요
              ),
            const SizedBox(height: 20),

            const Text(
              '2. 네이티브 기능 연동 (MethodChannel)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: _getBatteryLevel,
              child: const Text('배터리 레벨 가져오기'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(_batteryLevel, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),

            const Text(
              '3. 폼 처리 및 유효성 검사',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(labelText: '이메일'),
                    validator: (value) {
                      if (value == null || value.isEmpty || !value.contains('@')) {
                        return '유효한 이메일을 입력하세요.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _email = value!;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: '비밀번호'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 6) {
                        return '비밀번호는 6자 이상이어야 합니다.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _password = value!;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('폼 제출'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              '4. 제스처 감지',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: _handleTap,
              onLongPress: _handleLongPress,
              // 나쁜 예시: 너무 복잡한 로직이나 불필요한 위젯을 GestureDetector의 자식으로 넣는 것.
              // - GestureDetector는 이벤트 감지 역할에 충실하고, 실제 UI 로직은 콜백 함수에서 처리해야 합니다.
              child: Container(
                color: Colors.lightGreen,
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    _gestureMessage,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              '5. 애니메이션 (개념)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // Implicit Animation (암시적 애니메이션) 예시
            GestureDetector(
              onTap: () {
                setState(() {
                  _showText = !_showText;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                width: _showText ? 200 : 100,
                height: _showText ? 100 : 50,
                color: _showText ? Colors.deepOrange : Colors.blueAccent,
                alignment: _showText ? Alignment.center : Alignment.bottomCenter,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: _showText ? 1.0 : 0.0,
                  child: const Text(
                    '애니메이션 텍스트',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('FAB 클릭!')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/*
이 코드를 실행하려면 다음 단계를 따르세요:

1. Flutter SDK 설치 및 환경 변수 설정.
2. IDE (VS Code 또는 Android Studio)에 Flutter 및 Dart 플러그인 설치.
3. 새 Flutter 프로젝트 생성: `flutter create my_native_features_app`
4. `pubspec.yaml` 파일에 필요한 패키지 추가:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     url_launcher: ^6.1.10 # 외부 URL 실행
     image_picker: ^1.0.4  # 이미지/비디오 선택
   ```
5. 터미널에서 `flutter pub get` 실행하여 패키지 설치.
6. 생성된 프로젝트 폴더 내의 `lib/main.dart` 파일 내용을 이 파일의 내용으로 교체.
7. 안드로이드/iOS 에뮬레이터 또는 실제 기기에서 실행하고, IDE에서 `main.dart`를 실행하거나 터미널에서 `flutter run`.

   **MethodChannel (배터리 레벨) 테스트를 위한 네이티브 코드 추가 (선택 사항):**
   - Android (`android/app/src/main/kotlin/<your_package_name>/MainActivity.kt`):
     ```kotlin
     package com.example.my_native_features_app

     import androidx.annotation.NonNull
     import io.flutter.embedding.android.FlutterActivity
     import io.flutter.embedding.engine.FlutterEngine
     import io.flutter.plugin.common.MethodChannel
     import android.content.Context
     import android.content.ContextWrapper
     import android.content.Intent
     import android.content.IntentFilter
     import android.os.BatteryManager
     import android.os.Build.VERSION
     import android.os.Build.VERSION_CODES

     class MainActivity: FlutterActivity() {
         private val CHANNEL = "com.example.app/battery" // Flutter 코드의 채널 이름과 일치해야 함

         override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
             super.configureFlutterEngine(flutterEngine)
             MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                 call, result ->
                 if (call.method == "getBatteryLevel") {
                     val batteryLevel = getBatteryLevel()

                     if (batteryLevel != -1) {
                         result.success(batteryLevel)
                     } else {
                         result.error("UNAVAILABLE", "Battery level not available.", null)
                     }
                 } else {
                     result.notImplemented()
                 }
             }
         }

         private fun getBatteryLevel(): Int {
             val batteryLevel: Int
             if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
                 val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
                 batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
             } else {
                 val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
                 batteryLevel = intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
             }
             return batteryLevel
         }
     }
     ```
   - iOS (`ios/Runner/AppDelegate.swift`):
     ```swift
     import UIKit
     import Flutter

     @UIApplicationMain
     @objc class AppDelegate: FlutterAppDelegate {
       override func application(
         _ application: UIApplication,
         didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
       ) -> Bool {
         let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
         let batteryChannel = FlutterMethodChannel(name: "com.example.app/battery",
                                                   binaryMessenger: controller.binaryMessenger)
         batteryChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
           guard call.method == "getBatteryLevel" else {
             result(FlutterMethodNotImplemented)
             return
           }
           self?.receiveBatteryLevel(result: result)
         }

         GeneratedPluginRegistrant.register(with: self)
         return super.application(application, didFinishLaunchingWithOptions: launchOptions)
       }

       private func receiveBatteryLevel(result: FlutterResult) {
         let device = UIDevice.current
         device.isBatteryMonitoringEnabled = true
         if device.batteryState == .unknown {
           result(FlutterError(code: "UNAVAILABLE",
                               message: "Battery level not determinable.",
                               details: nil))
         } else {
           result(Int(device.batteryLevel * 100))
         }
       }
     }
     ```
*/
