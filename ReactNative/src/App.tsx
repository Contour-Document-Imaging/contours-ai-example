import React, {useEffect, useMemo, useState} from 'react';
import {SafeAreaView, StatusBar, StyleSheet} from 'react-native';
import {initialize} from 'contour-ai-sdk';
import ViewScreen from './view';
import {
  CLIENT_ID,
  DocumentType,
  getDocumentConfig,
  useContourScanner,
} from './ContourScannerManager';

export default function App() {
  const [activeDocumentType, setActiveDocumentType] =
    useState<DocumentType>('check');

  useEffect(() => {
    initialize(CLIENT_ID);
  }, []);

  const config = useMemo(
    () => getDocumentConfig(activeDocumentType),
    [activeDocumentType],
  );
  const {getImageUri, startSDK} = useContourScanner(config);

  return (
    <SafeAreaView style={styles.safeArea}>
      <StatusBar
        backgroundColor="#d8e8ef"
        barStyle="dark-content"
      />
      <ViewScreen
        activeDocumentType={activeDocumentType}
        config={config}
        getImageUri={getImageUri}
        onSelectDocumentType={setActiveDocumentType}
        onStartScan={startSDK}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#d8e8ef',
  },
});
