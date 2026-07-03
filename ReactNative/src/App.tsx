import React, {useEffect, useMemo, useState} from 'react';
import {StatusBar} from 'react-native';
import {initialize} from 'contour-ai-sdk';
import ViewScreen from './view';
import {
  DocumentType,
  getDocumentConfig,
  useContourScanner,
} from './scannerConfig';

export default function App() {
  const [activeDocumentType, setActiveDocumentType] =
    useState<DocumentType>('check');

  useEffect(() => {
    initialize('<CLIENT_ID>');
  }, []);

  const config = useMemo(
    () => getDocumentConfig(activeDocumentType),
    [activeDocumentType],
  );
  const {getImageUri, startSDK, statusMessage} = useContourScanner(config);

  return (
    <>
      <StatusBar
        translucent
        backgroundColor="transparent"
        barStyle="dark-content"
      />
      <ViewScreen
        activeDocumentType={activeDocumentType}
        config={config}
        getImageUri={getImageUri}
        onSelectDocumentType={setActiveDocumentType}
        onStartScan={startSDK}
        statusMessage={statusMessage}
      />
    </>
  );
}
