// react_native/Step1_ReactNativeBasics/App.js
// React Native 학습 계획 - 1단계: React Native 기본 개념 및 개발 환경
// 이 파일은 React Native 애플리케이션의 메인 엔트리 포인트인 `App.js`입니다.
// React Native의 핵심 컴포넌트(`View`, `Text`, `Image`, `StyleSheet`)와
// Flexbox를 이용한 레이아웃 구성 방법을 보여줍니다.
//
// React Native는 JavaScript와 React를 사용하여 iOS 및 Android 앱을 동시에 개발할 수 있게 합니다.

import React from 'react';
import { StyleSheet, Text, View, Image, SafeAreaView } from 'react-native'; // 핵심 컴포넌트 임포트

// -----------------------------------------------------------------------------
// 학습 포인트 1: `View` 컴포넌트
// - UI를 구성하는 가장 기본적인 컨테이너 컴포넌트입니다.
// - 웹의 `div`와 유사하며, 레이아웃, 스타일링, 터치 핸들링 등 다양한 용도로 사용됩니다.
// - `SafeAreaView`: iOS에서 노치(notch)나 하단 인디케이터 영역을 피해 콘텐츠를 렌더링.
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// 학습 포인트 2: `Text` 컴포넌트
// - 텍스트를 표시하는 컴포넌트입니다.
// - React Native에서는 웹처럼 일반 `Text`를 `View` 내부에 직접 작성할 수 없습니다.
//   모든 텍스트는 `Text` 컴포넌트 내부에 있어야 합니다.
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// 학습 포인트 3: `Image` 컴포넌트
// - 이미지를 표시하는 컴포넌트입니다.
// - 로컬 이미지(require) 또는 네트워크 이미지({uri: '...'})를 사용할 수 있습니다.
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// 학습 포인트 4: `StyleSheet`를 이용한 스타일링
// - 웹의 CSS와 유사하게 컴포넌트에 스타일을 적용합니다.
// - `StyleSheet.create()`를 사용하여 스타일 객체를 생성하면 성능 최적화에 도움이 됩니다.
// - React Native의 스타일은 Flexbox를 기반으로 합니다.
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// 학습 포인트 5: Flexbox를 이용한 레이아웃
// - React Native의 모든 레이아웃은 Flexbox를 기반으로 합니다.
// - `flexDirection` (기본값: 'column'), `justifyContent`, `alignItems` 등을 사용합니다.
// -----------------------------------------------------------------------------

const App = () => {
  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.container}>
        <Text style={styles.title}>React Native 기본 개념</Text>

        <View style={styles.boxContainer}>
          <View style={styles.box}>
            <Text style={styles.boxText}>Box 1</Text>
          </View>
          <View style={[styles.box, styles.box2]}>
            <Text style={styles.boxText}>Box 2</Text>
          </View>
          <View style={styles.box}>
            <Text style={styles.boxText}>Box 3</Text>
          </View>
        </View>

        <Image
          source={{ uri: 'https://reactnative.dev/img/tiny_logo.png' }} // 네트워크 이미지
          style={styles.logo}
          accessibilityLabel="React Native 로고" // 접근성 향상
        />
        {/* 나쁜 예시: 웹처럼 일반 `img` 태그나 `<p>` 태그를 사용하는 것.
          - React Native는 웹 기술을 사용하지만, 웹의 DOM 컴포넌트를 직접 사용하지 않습니다.
          - 항상 React Native에서 제공하는 컴포넌트를 사용해야 합니다. */}
        <Text style={styles.description}>
          `View`, `Text`, `Image` 컴포넌트와 Flexbox 레이아웃을 사용한 예시입니다.
        </Text>

        <View style={styles.flexContainer}>
          <Text style={styles.flexItem}>Item A</Text>
          <Text style={styles.flexItem}>Item B</Text>
          <Text style={styles.flexItem}>Item C</Text>
        </View>
        {/* 나쁜 예시: 모든 스타일을 인라인으로 작성하는 것.
          - 코드 가독성을 해치고, 스타일의 재사용성을 떨어뜨립니다.
          - `StyleSheet.create()`를 사용하여 스타일을 분리하는 것이 좋습니다.
          - <Text style={{ fontSize: 16, color: 'blue' }}>인라인 스타일</Text> */}

      </View>
    </SafeAreaView>
  );
};

// -----------------------------------------------------------------------------
// 학습 포인트 6: `StyleSheet.create()`를 이용한 스타일 객체 생성
// - 스타일을 한 곳에 모아 관리하고, 가독성을 높입니다.
// - React Native는 CSS의 모든 속성을 지원하지 않으며, 특정 속성은 이름이 다를 수 있습니다.
// -----------------------------------------------------------------------------
const styles = StyleSheet.create({
  safeArea: {
    flex: 1, // 화면 전체를 차지하도록 설정
    backgroundColor: '#f5f5f5',
  },
  container: {
    flex: 1, // Flexbox 아이템으로, 사용 가능한 공간을 모두 차지
    backgroundColor: '#fff',
    alignItems: 'center', // 주축(수직)의 중앙에 정렬 (flexDirection이 column이므로)
    justifyContent: 'center', // 교차축(수평)의 중앙에 정렬
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
    color: '#333',
  },
  boxContainer: {
    flexDirection: 'row', // 주축을 수평으로 변경
    justifyContent: 'space-around', // 아이템들 사이에 균일한 공간 분배
    alignItems: 'center',
    width: '100%',
    marginBottom: 20,
  },
  box: {
    width: 80,
    height: 80,
    backgroundColor: '#61dafb',
    justifyContent: 'center',
    alignItems: 'center',
    borderRadius: 8,
  },
  box2: {
    backgroundColor: '#ffc107',
  },
  boxText: {
    color: '#fff',
    fontWeight: 'bold',
  },
  logo: {
    width: 60,
    height: 60,
    marginBottom: 20,
  },
  description: {
    fontSize: 16,
    textAlign: 'center',
    color: '#666',
    marginHorizontal: 10,
  },
  flexContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    width: '80%',
    marginTop: 30,
    padding: 10,
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 5,
  },
  flexItem: {
    backgroundColor: '#e0e0e0',
    padding: 8,
    borderRadius: 5,
  },
});

export default App;

/*
이 코드를 실행하려면:

1. Node.js, npm (또는 yarn) 설치.
2. React Native CLI 또는 Expo CLI 설치:
   - Expo CLI (추천, 더 쉬운 시작): `npm install -g expo-cli`
   - React Native CLI: `npm install -g react-native-cli`
3. 새 React Native 프로젝트 생성:
   - Expo CLI: `expo init react-native-basics-app` (blank 템플릿 선택)
   - React Native CLI: `npx react-native init react-native-basics-app`
4. `react-native-basics-app/App.js` 파일 내용을 이 파일의 내용으로 교체.
5. 터미널에서 프로젝트 디렉토리로 이동.
6. 프로젝트 실행:
   - Expo CLI: `npm start` (브라우저에서 Expo Dev Tools 열림, iOS/Android 시뮬레이터 또는 실제 기기에서 앱 실행)
   - React Native CLI:
     - iOS: `npm run ios` (macOS에서 Xcode 설치 필수)
     - Android: `npm run android` (Android Studio 및 SDK 설치 필수)
*/
