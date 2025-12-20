// react_native/Step4_NativeModulesAndAPIIntegration/App.js
// React Native 학습 계획 - 4단계: 네이티브 모듈 및 API 연동
// 이 파일은 React Native 애플리케이션에서 네이티브 모듈(카메라/갤러리 접근)을 연동하고,
// 푸시 알림과 같은 외부 API를 통합하는 개념을 학습하기 위한 예제입니다.
//
// React Native는 JavaScript로 모바일 앱을 개발하지만, 특정 기능(예: 카메라, GPS, 배터리)은
// 플랫폼 고유의 네이티브 코드를 사용해야 합니다.

import React, { useState, useEffect } from 'react';
import {
  Button,
  StyleSheet,
  Text,
  View,
  SafeAreaView,
  Image,
  NativeModules, // 네이티브 모듈 임포트
  Platform,
  Alert, // 알림
} from 'react-native';
import { launchImageLibrary, launchCamera } from 'react-native-image-picker'; // 이미지 피커 라이브러리

// -----------------------------------------------------------------------------
// 학습 포인트 1: `react-native-image-picker`를 이용한 카메라/갤러리 접근
// - React Native의 핵심 기능 중 하나는 기기의 하드웨어 API에 접근하는 것입니다.
// - `react-native-image-picker`와 같은 커뮤니티 라이브러리는 카메라, 갤러리 접근을 추상화하여
//   JavaScript 코드에서 쉽게 사용할 수 있도록 돕습니다.
// -----------------------------------------------------------------------------
const App = () => {
  const [selectedImage, setSelectedImage] = useState(null);
  const [batteryLevel, setBatteryLevel] = useState('가져오는 중...');

  const selectImage = () => {
    // 갤러리에서 이미지 선택 옵션
    const options = {
      mediaType: 'photo',
      includeBase64: false,
    };

    launchImageLibrary(options, (response) => {
      if (response.didCancel) {
        console.log('User cancelled image picker');
      } else if (response.errorMessage) {
        console.log('ImagePicker Error: ', response.errorMessage);
        Alert.alert('에러', `이미지 선택 중 에러: ${response.errorMessage}`);
      } else if (response.assets && response.assets.length > 0) {
        setSelectedImage(response.assets[0].uri);
      }
    });
  };

  const takePhoto = () => {
    // 카메라로 사진 촬영 옵션
    const options = {
      mediaType: 'photo',
      includeBase64: false,
    };

    launchCamera(options, (response) => {
      if (response.didCancel) {
        console.log('User cancelled camera');
      } else if (response.errorMessage) {
        console.log('Camera Error: ', response.errorMessage);
        Alert.alert('에러', `카메라 사용 중 에러: ${response.errorMessage}`);
      } else if (response.assets && response.assets.length > 0) {
        setSelectedImage(response.assets[0].uri);
      }
    });
  };

  // -----------------------------------------------------------------------------
  // 학습 포인트 2: 네이티브 모듈 연동 (`NativeModules`)
  // - JavaScript에서 직접 네이티브 코드를 호출할 때 사용합니다.
  // - iOS (Swift/Objective-C) 또는 Android (Java/Kotlin) 코드를 작성해야 합니다.
  // - 예시: 배터리 레벨 가져오기 (가상의 Native Module)
  // -----------------------------------------------------------------------------
  const { BatteryManager } = NativeModules; // 가상의 Native Module (실제 구현 필요)

  useEffect(() => {
    // 실제 Native Module이 구현되어 있다고 가정
    if (BatteryManager && BatteryManager.getBatteryLevel) {
      // 나쁜 예시: Native Module 호출 시 에러 처리를 하지 않거나,
      // - 비동기 호출인데 동기적으로 처리하려 하는 것.
      // - Native Module은 비동기적으로 동작할 수 있으므로 Promise 패턴으로 처리해야 합니다.
      BatteryManager.getBatteryLevel()
        .then(level => {
          setBatteryLevel(`${level * 100}%`);
        })
        .catch(error => {
          console.error('Failed to get battery level:', error);
          setBatteryLevel('가져오기 실패');
        });
    } else {
      setBatteryLevel('Native BatteryManager 없음 (시뮬레이터/구현 필요)');
    }
  }, []);

  // -----------------------------------------------------------------------------
  // 학습 포인트 3: 푸시 알림 구현 (개념)
  // - Firebase Cloud Messaging (FCM) 또는 Expo Notifications와 같은 서비스를 사용하여 구현.
  // - 기기 토큰 발급, 메시지 전송, 알림 수신 및 처리 로직 필요.
  // -----------------------------------------------------------------------------
  const sendPushNotification = () => {
    Alert.alert('푸시 알림', '푸시 알림이 전송되었습니다! (실제로는 서버에서 전송)');
    // 실제 푸시 알림 로직은 서버와 연동하여 구현해야 합니다.
  };

  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.container}>
        <Text style={styles.title}>네이티브 모듈 및 API 연동</Text>

        <View style={styles.buttonContainer}>
          <Button title="갤러리에서 이미지 선택" onPress={selectImage} />
          <View style={{ width: 10 }} />
          <Button title="카메라로 사진 촬영" onPress={takePhoto} />
        </View>

        {selectedImage && (
          <Image source={{ uri: selectedImage }} style={styles.imagePreview} />
        )}

        <Text style={styles.infoText}>배터리 레벨: {batteryLevel}</Text>
        <Button title="푸시 알림 보내기 (개념)" onPress={sendPushNotification} />

        {/* 나쁜 예시: 인증 및 권한 관리 없이 기기의 민감한 API에 접근하는 것.
          - 카메라, 위치 정보 등은 사용자 동의(권한)가 필요합니다.
          - `react-native-permissions`와 같은 라이브러리를 사용하여 권한을 요청하고 확인해야 합니다. */}
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
    paddingTop: Platform.OS === 'android' ? 30 : 0,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
    color: '#333',
  },
  buttonContainer: {
    flexDirection: 'row',
    marginBottom: 20,
  },
  imagePreview: {
    width: 200,
    height: 200,
    resizeMode: 'contain',
    marginTop: 20,
    borderColor: '#ccc',
    borderWidth: 1,
  },
  infoText: {
    fontSize: 18,
    marginVertical: 20,
    color: '#555',
  },
});

export default App;

/*
이 코드를 실행하려면:

1. React Native 프로젝트 생성 (Expo CLI 또는 React Native CLI 사용).
   - `expo init react-native-native-app` 또는 `npx react-native init react-native-native-app`
2. `react-native-image-picker` 라이브러리 설치:
   - `npm install react-native-image-picker`
   - React Native CLI 프로젝트의 경우, 추가적인 네이티브 설정이 필요할 수 있습니다.
     (iOS: `cd ios && pod install`, Android: `AndroidManifest.xml`에 권한 추가 등)
     자세한 내용은 `react-native-image-picker` 공식 문서 참조.
3. `App.js` 파일 내용을 이 파일의 내용으로 교체.
4. 프로젝트 실행:
   - Expo CLI: `npm start` (Expo Go 앱에서 실행)
   - React Native CLI: `npm run ios` 또는 `npm run android`
5. 시뮬레이터 또는 실제 기기에서 앱을 확인.
   - '갤러리에서 이미지 선택' 및 '카메라로 사진 촬영' 버튼을 눌러 이미지 선택 기능 테스트.
     (카메라 사용은 실제 기기나 에뮬레이터에서만 가능)
   - '배터리 레벨' 텍스트가 표시되는 것을 확인 (Native Module이 구현되어야 함).

**네이티브 모듈 (`BatteryManager`) 구현 (React Native CLI 프로젝트에만 해당):**
- 이 예시는 `NativeModules.BatteryManager`가 존재한다고 가정합니다.
- 실제 React Native CLI 프로젝트에서 이 기능을 구현하려면 iOS (Swift/Objective-C)와
  Android (Java/Kotlin)에 각각 네이티브 코드를 작성해야 합니다.

  **iOS (`ios/YourProjectName/BatteryManager.swift` 및 `YourProjectName-Bridging-Header.h`에 연결):**
  - Swift 파일:
    ```swift
    // BatteryManager.swift
    import Foundation
    import UIKit

    @objc(BatteryManager)
    class BatteryManager: NSObject {

      @objc
      func getBatteryLevel(_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        if device.batteryState == .unknown {
          reject("UNAVAILABLE", "Battery level not determinable.", nil)
        } else {
          resolve(device.batteryLevel * 100)
        }
      }

      @objc
      static func requiresMainQueueSetup() -> Bool {
        return true
      }
    }
    ```
  - Header 파일 (Objective-C Bridge):
    ```objectivec
    // YourProjectName-Bridging-Header.h
    #import "React/RCTBridgeModule.h"
    #import "React/RCTEventEmitter.h"
    ```
  - 그리고 `info.plist`에 `Privacy - Camera Usage Description`, `Privacy - Photo Library Usage Description` 추가.

  **Android (`android/app/src/main/java/com/yourprojectname/BatteryManagerModule.java`):**
  - Java 파일:
    ```java
    // BatteryManagerModule.java
    package com.yourprojectname; // 본인 프로젝트 패키지명

    import android.content.Intent;
    import android.content.IntentFilter;
    import android.os.BatteryManager;
    import android.os.Build;

    import com.facebook.react.bridge.NativeModule;
    import com.facebook.react.bridge.Promise;
    import com.facebook.react.bridge.ReactApplicationContext;
    import com.facebook.react.bridge.ReactContextBaseJavaModule;
    import com.facebook.react.bridge.ReactMethod;

    import javax.annotation.Nonnull;

    public class BatteryManagerModule extends ReactContextBaseJavaModule {

        BatteryManagerModule(@Nonnull ReactApplicationContext reactContext) {
            super(reactContext);
        }

        @Nonnull
        @Override
        public String getName() {
            return "BatteryManager"; // JavaScript에서 사용할 모듈 이름
        }

        @ReactMethod
        public void getBatteryLevel(Promise promise) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                BatteryManager batteryManager = (BatteryManager) getReactApplicationContext().getSystemService(ReactApplicationContext.BATTERY_SERVICE);
                int batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);
                promise.resolve(batteryLevel);
            } else {
                IntentFilter ifilter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);
                Intent batteryStatus = getReactApplicationContext().registerReceiver(null, ifilter);
                int level = batteryStatus.getIntExtra(BatteryManager.EXTRA_LEVEL, -1);
                int scale = batteryStatus.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
                float batteryPct = level / (float)scale;
                promise.resolve((int)(batteryPct * 100));
            }
        }
    }
    ```
  - 패키지 등록 (`android/app/src/main/java/com/yourprojectname/MyAppPackage.java`):
    ```java
    // MyAppPackage.java
    package com.yourprojectname; // 본인 프로젝트 패키지명

    import com.facebook.react.ReactPackage;
    import com.facebook.react.bridge.NativeModule;
    import com.facebook.react.bridge.ReactApplicationContext;
    import com.facebook.react.uimanager.ViewManager;

    import java.util.ArrayList;
    import java.util.Collections;
    import java.util.List;

    public class MyAppPackage implements ReactPackage {

        @Override
        public List<ViewManager> createViewManagers(ReactApplicationContext reactContext) {
            return Collections.emptyList();
        }

        @Override
        public List<NativeModule> createNativeModules(
                                ReactApplicationContext reactContext) {
            List<NativeModule> modules = new ArrayList<>();
            modules.add(new BatteryManagerModule(reactContext)); // 여기에 모듈 추가
            return modules;
        }
    }
    ```
  - 메인 애플리케이션 파일에 패키지 등록 (`android/app/src/main/java/com/yourprojectname/MainActivity.java`):
    ```java
    // MainActivity.java
    package com.yourprojectname; // 본인 프로젝트 패키지명

    import com.facebook.react.ReactActivity;
    import com.facebook.react.ReactActivityDelegate;
    import com.facebook.react.ReactRootView;
    import com.yourprojectname.MyAppPackage; // 임포트

    public class MainActivity extends ReactActivity {
        // ...
        @Override
        protected List<ReactPackage> getPackages() {
            List<ReactPackage> packages = new PackageList(this).getPackages();
            packages.add(new MyAppPackage()); // 여기에 패키지 추가
            return packages;
        }
        // ...
    }
    ```
  - 그리고 `AndroidManifest.xml`에 권한 추가: `<uses-permission android:name="android.permission.CAMERA" />`, `<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />`, `<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />` 등.
*/
