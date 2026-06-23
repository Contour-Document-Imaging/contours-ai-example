import React, {useEffect} from 'react';
import {SafeAreaView} from 'react-native-safe-area-context';
import AppNavigation from './navigation/AppNavigation';
import {StatusBar, StyleSheet} from 'react-native';
import {initialize} from 'contour-ai-sdk';

export default function App() {
  useEffect(() => {
    initialize('<CLIENT_ID>');
  }, []);

  return (
    <SafeAreaView style={styles.safeArea} edges={['top', 'bottom']}>
      <StatusBar
        translucent
        backgroundColor="transparent"
        barStyle="dark-content"
      />
      <AppNavigation />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#d8e8ef',
  },
});
