
import React, { useEffect } from 'react';
import { SafeAreaProvider, SafeAreaView } from 'react-native-safe-area-context';
import AppNavigation from './navigation/AppNavigation';
import { StatusBar } from 'react-native';
import { initialize } from 'contour-ai-sdk';

export default function App() {

  useEffect(() => {
    initialize('<CLIENT_ID>');
  }, []);

  return (
   <SafeAreaView style={{ flex: 1 }} edges={['top', 'bottom']}>
    <StatusBar translucent backgroundColor="transparent" barStyle="dark-content" />
      <AppNavigation />
    </SafeAreaView>
  );
}
