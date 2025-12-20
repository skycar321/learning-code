// react_native/Step2_UIComponentsAndStyling/App.js
// React Native 학습 계획 - 2단계: UI 컴포넌트 및 스타일링
// 이 파일은 React Native의 사용자 입력 컴포넌트(`TextInput`, `Button`),
// 리스트 렌더링 컴포넌트(`FlatList`), 그리고 플랫폼별 스타일링(`Platform` 모듈)을
// 학습하기 위한 예제입니다.
//
// React Native는 플랫폼 고유의 UI 컴포넌트와 유연한 스타일링 시스템을 제공하여
// 다양한 기기와 운영체제에서 일관된 사용자 경험을 제공할 수 있도록 돕습니다.

import React, { useState } from 'react';
import {
  StyleSheet,
  Text,
  View,
  TextInput,
  Button,
  FlatList,
  Platform, // 플랫폼 모듈 임포트
  SafeAreaView,
  TouchableOpacity, // Button 대신 터치 이벤트를 처리하는 컴포넌트
} from 'react-native';

// -----------------------------------------------------------------------------
// 학습 포인트 1: 사용자 입력 컴포넌트 (`TextInput`, `Button`, `TouchableOpacity`)
// - `TextInput`: 사용자로부터 텍스트 입력을 받는 컴포넌트.
//   - `onChangeText`: 텍스트 변경 시 호출.
//   - `value`: 현재 입력된 텍스트.
//   - `placeholder`: 입력 힌트.
// - `Button`: 간단한 버튼 컴포넌트. 스타일링이 제한적.
// - `TouchableOpacity`: `Button`보다 스타일링에 더 유연하며, 터치 시 투명도 변화 효과.
// -----------------------------------------------------------------------------
const App = () => {
  const [inputText, setInputText] = useState('');
  const [items, setItems] = useState([
    { id: '1', text: 'Item 1' },
    { id: '2', text: 'Item 2' },
    { id: '3', text: 'Item 3' },
  ]);

  const addItem = () => {
    if (inputText.trim()) { // 입력값이 비어있지 않은 경우
      setItems(prevItems => [
        ...prevItems,
        { id: Math.random().toString(), text: inputText.trim() },
      ]);
      setInputText(''); // 입력 필드 초기화
    }
  };

  const deleteItem = (id) => {
    setItems(prevItems => prevItems.filter(item => item.id !== id));
  };

  // -----------------------------------------------------------------------------
  // 학습 포인트 2: 리스트 렌더링 (`FlatList`)
  // - 대규모 데이터 리스트를 효율적으로 렌더링하는 컴포넌트.
  // - `data`: 렌더링할 데이터 배열.
  // - `renderItem`: 각 항목을 렌더링하는 함수.
  // - `keyExtractor`: 각 항목의 고유 키를 추출하는 함수 (성능 최적화 및 오류 방지).
  // - `SectionList`: 섹션별로 데이터를 그룹화하여 렌더링할 때 사용 (개념적).
  // -----------------------------------------------------------------------------
  const renderItem = ({ item }) => (
    <View style={styles.listItem}>
      <Text style={styles.listItemText}>{item.text}</Text>
      <TouchableOpacity onPress={() => deleteItem(item.id)} style={styles.deleteButton}>
        <Text style={styles.deleteButtonText}>삭제</Text>
      </TouchableOpacity>
      {/* 나쁜 예시: `FlatList` 대신 `ScrollView` 안에 `map()`을 사용하여
        - 대규모 리스트를 렌더링하는 것.
        - 모든 항목을 한 번에 렌더링하므로 메모리 사용량이 많아지고 성능이 저하됩니다.
        - `FlatList`는 화면에 보이는 항목만 렌더링하여 성능을 최적화합니다. */}
    </View>
  );

  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.container}>
        <Text style={styles.title}>UI 컴포넌트 및 스타일링</Text>

        <TextInput
          style={styles.input}
          placeholder="새 항목을 입력하세요."
          onChangeText={setInputText}
          value={inputText}
        />
        <Button title="항목 추가" onPress={addItem} />

        <FlatList
          data={items}
          renderItem={renderItem}
          keyExtractor={item => item.id}
          style={styles.flatList}
        />

        {/* -----------------------------------------------------------------------------
        학습 포인트 3: 플랫폼별 스타일링 (`Platform` 모듈)
        - `Platform.OS`: 현재 실행 중인 OS를 문자열로 반환 (ios, android, web 등).
        - `Platform.select()`: OS에 따라 다른 값을 반환.
        ----------------------------------------------------------------------------- */}
        <View style={styles.platformSpecificBox}>
          <Text style={styles.platformSpecificText}>
            현재 플랫폼: {Platform.OS}
          </Text>
          {/* 나쁜 예시: 플랫폼별 스타일링을 위해 `if/else` 문을 반복적으로 사용하는 것.
            - 코드가 지저분해지고 가독성이 떨어집니다.
            - `Platform.select()`를 사용하여 더 간결하게 처리해야 합니다.
            - {Platform.OS === 'ios' ? <Text>iOS only</Text> : <Text>Android only</Text>} */}
        </View>

        {/* -----------------------------------------------------------------------------
        학습 포인트 4: 외부 UI 라이브러리 (개념)
        - `React Native Elements`, `NativeBase`, `Shoutem UI` 등 다양한 UI 라이브러리가 있습니다.
        - 미리 만들어진 컴포넌트들을 사용하여 개발 속도를 높일 수 있습니다.
        ----------------------------------------------------------------------------- */}
        <Text style={styles.externalLibInfo}>
          외부 UI 라이브러리를 사용하여 더 풍부한 컴포넌트를 만들 수 있습니다. (예: React Native Elements)
        </Text>
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
    paddingTop: Platform.OS === 'android' ? 30 : 0, // Android에서 상단 패딩 추가
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'flex-start',
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
    color: '#333',
  },
  input: {
    width: '90%',
    borderColor: '#ccc',
    borderWidth: 1,
    padding: 10,
    marginBottom: 10,
    borderRadius: 5,
  },
  flatList: {
    width: '100%',
    marginTop: 20,
  },
  listItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 15,
    backgroundColor: '#f9f9f9',
    borderBottomWidth: 1,
    borderBottomColor: '#eee',
  },
  listItemText: {
    fontSize: 18,
  },
  deleteButton: {
    backgroundColor: 'red',
    padding: 8,
    borderRadius: 5,
  },
  deleteButtonText: {
    color: 'white',
    fontSize: 14,
  },
  platformSpecificBox: {
    marginTop: 30,
    padding: 15,
    backgroundColor: Platform.select({
      ios: '#ADD8E6', // iOS 파란색
      android: '#90EE90', // Android 초록색
      default: '#FFD700', // 기타 노란색
    }),
    borderRadius: 10,
  },
  platformSpecificText: {
    fontSize: 16,
    color: '#333',
    fontWeight: 'bold',
  },
  externalLibInfo: {
    marginTop: 20,
    fontSize: 14,
    textAlign: 'center',
    color: '#888',
  },
});

export default App;

/*
이 코드를 실행하려면:

1. React Native 프로젝트 생성 (Expo CLI 또는 React Native CLI 사용).
   - `expo init react-native-ui-app` 또는 `npx react-native init react-native-ui-app`
2. `App.js` 파일 내용을 이 파일의 내용으로 교체.
3. 프로젝트 실행:
   - Expo CLI: `npm start`
   - React Native CLI: `npm run ios` 또는 `npm run android`
4. 시뮬레이터 또는 실제 기기에서 앱을 확인.
   - 텍스트 입력 후 '항목 추가' 버튼을 눌러 리스트에 추가.
   - 각 항목의 '삭제' 버튼을 눌러 리스트에서 제거.
   - 플랫폼별 스타일링이 어떻게 적용되는지 확인.
*/
