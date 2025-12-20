// react_native/Step3_NavigationAndStateManagement/App.js
// React Native 학습 계획 - 3단계: 내비게이션 및 상태 관리
// 이 파일은 React Native 애플리케이션에서 화면 간 이동(내비게이션)과
// 컴포넌트의 상태를 효율적으로 관리하는 방법(useState, 전역 상태 관리 개념)을 보여줍니다.
//
// React Native 앱은 여러 화면으로 구성되며, 사용자 경험을 위해 화면 간 자연스러운 전환과
// 데이터 관리가 필수적입니다.

import React, { useState, createContext, useContext } from 'react';
import { Button, StyleSheet, Text, View, SafeAreaView } from 'react-native';
import { NavigationContainer } from '@react-navigation/native'; // React Navigation 컨테이너
import { createNativeStackNavigator } from '@react-navigation/native-stack'; // Stack Navigator

// -----------------------------------------------------------------------------
// 학습 포인트 1: 내비게이션 (React Navigation 라이브러리)
// - `React Navigation`은 React Native 앱에서 화면 간 이동을 관리하는 데 널리 사용됩니다.
// - `NavigationContainer`: 모든 내비게이터를 감싸는 최상위 컴포넌트.
// - `createNativeStackNavigator`: Stack 형태의 내비게이션을 구현하는 훅.
//   - 화면을 스택처럼 쌓고, 이전 화면으로 돌아가거나 새 화면으로 이동.
// -----------------------------------------------------------------------------
const Stack = createNativeStackNavigator(); // Stack Navigator 생성

// -----------------------------------------------------------------------------
// 학습 포인트 2: Context API를 이용한 전역 상태 관리 (개념)
// - `createContext`: Context 객체 생성.
// - `useContext`: Context 값을 구독하는 훅.
// - `Provider`: Context를 사용하는 모든 컴포넌트에 Context 값을 제공하는 컴포넌트.
// - Redux, Zustand 등 더 강력한 전역 상태 관리 라이브러리의 개념도 이해해야 합니다.
// -----------------------------------------------------------------------------
const CounterContext = createContext(null);

// 카운터 값을 관리하는 Context Provider
const CounterProvider = ({ children }) => {
  const [count, setCount] = useState(0);

  const increment = () => setCount(prev => prev + 1);
  const decrement = () => setCount(prev => prev - 1);

  return (
    <CounterContext.Provider value={{ count, increment, decrement }}>
      {children}
    </CounterContext.Provider>
  );
};

// -----------------------------------------------------------------------------
// 화면 컴포넌트 1: HomeScreen
// - `useState`를 이용한 로컬 상태 관리.
// - `navigation.navigate()`를 이용한 화면 이동.
// - `useContext`를 이용한 전역 상태 접근.
// -----------------------------------------------------------------------------
function HomeScreen({ navigation }) {
  const [localMessage, setLocalMessage] = useState('HomeScreen 로컬 메시지');
  const { count, increment, decrement } = useContext(CounterContext); // 전역 상태 접근

  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.screenContainer}>
        <Text style={styles.title}>홈 화면</Text>

        <Text style={styles.text}>로컬 상태: {localMessage}</Text>
        <Button title="메시지 변경" onPress={() => setLocalMessage('메시지 변경됨!')} />

        <Text style={styles.text}>전역 카운터 (Context): {count}</Text>
        <Button title="카운터 증가" onPress={increment} />
        <Button title="카운터 감소" onPress={decrement} />

        <Button
          title="상세 화면으로 이동"
          onPress={() => navigation.navigate('Details', { itemId: 86, otherParam: 'Anything you want here' })}
        />
        <Button
          title="설정 화면으로 이동"
          onPress={() => navigation.navigate('Settings')}
        />
        {/* 나쁜 예시: `navigation.navigate()` 대신 모든 화면 이동에 `Alert`를 사용하는 것.
          - Alert는 사용자에게 메시지를 전달할 때 사용되며, 화면 이동에는 적합하지 않습니다.
          - 내비게이션 라이브러리를 사용하여 일관되고 자연스러운 화면 전환을 구현해야 합니다. */}
      </View>
    </SafeAreaView>
  );
}

// -----------------------------------------------------------------------------
// 화면 컴포넌트 2: DetailsScreen
// - `route.params`를 이용한 이전 화면에서 전달된 파라미터 받기.
// - `navigation.goBack()` 또는 `navigation.pop()`을 이용한 이전 화면으로 돌아가기.
// -----------------------------------------------------------------------------
function DetailsScreen({ route, navigation }) {
  const { itemId, otherParam } = route.params; // 이전 화면에서 전달된 파라미터 받기

  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.screenContainer}>
        <Text style={styles.title}>상세 화면</Text>
        <Text style={styles.text}>Item ID: {JSON.stringify(itemId)}</Text>
        <Text style={styles.text}>Other Param: {JSON.stringify(otherParam)}</Text>
        <Button title="홈으로 돌아가기" onPress={() => navigation.navigate('Home')} />
        <Button title="뒤로 가기" onPress={() => navigation.goBack()} />
      </View>
    </SafeAreaView>
  );
}

// -----------------------------------------------------------------------------
// 화면 컴포넌트 3: SettingsScreen
// - 전역 상태(`CounterContext`)에 접근하여 상태를 표시하고 변경.
// -----------------------------------------------------------------------------
function SettingsScreen({ navigation }) {
  const { count, increment } = useContext(CounterContext);

  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.screenContainer}>
        <Text style={styles.title}>설정 화면</Text>
        <Text style={styles.text}>현재 카운터 값: {count}</Text>
        <Button title="카운터 증가 (설정 화면)" onPress={increment} />
        <Button title="뒤로 가기" onPress={() => navigation.goBack()} />
      </View>
    </SafeAreaView>
  );
}


const AppContainer = () => {
  return (
    <CounterProvider>
      <NavigationContainer>
        <Stack.Navigator initialRouteName="Home">
          <Stack.Screen name="Home" component={HomeScreen} options={{ title: '개요' }} />
          <Stack.Screen name="Details" component={DetailsScreen} options={{ title: '상세 정보' }} />
          <Stack.Screen name="Settings" component={SettingsScreen} options={{ title: '앱 설정' }} />
        </Stack.Navigator>
      </NavigationContainer>
    </CounterProvider>
  );
};

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  screenContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
    color: '#333',
  },
  text: {
    fontSize: 18,
    marginBottom: 10,
    color: '#555',
  },
});

export default AppContainer;

/*
이 코드를 실행하려면:

1. React Native 프로젝트 생성 (Expo CLI 또는 React Native CLI 사용).
   - `expo init react-native-navigation-app` 또는 `npx react-native init react-native-navigation-app`
2. `react-navigation` 라이브러리 설치 (프로젝트 디렉토리에서):
   - `npm install @react-navigation/native @react-navigation/native-stack`
   - `expo install react-native-screens react-native-safe-area-context` (Expo 프로젝트만)
   - `npm install react-native-screens react-native-safe-area-context` (React Native CLI 프로젝트만)
3. `App.js` 파일 내용을 이 파일의 내용으로 교체.
4. 프로젝트 실행:
   - Expo CLI: `npm start`
   - React Native CLI: `npm run ios` 또는 `npm run android`
5. 시뮬레이터 또는 실제 기기에서 앱을 확인.
   - '메시지 변경' 버튼을 눌러 로컬 상태 변경 확인.
   - '카운터 증가/감소' 버튼을 눌러 전역 카운터 변경 확인 (다른 화면에서도 카운터가 동기화되는지 확인).
   - '상세 화면으로 이동', '설정 화면으로 이동' 버튼을 눌러 화면 간 이동 확인.
*/
