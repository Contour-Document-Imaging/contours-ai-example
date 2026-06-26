import React from 'react';
import DocumentScannerScreen from './DocumentScannerScreen';

export default function SelfieCapture() {
  return (
    <DocumentScannerScreen
      title="Take Selfie."
      description="Capture your selfie."
      documentType="Selfie"
      selfie
      previews={[{key: 'front', label: 'Selfie', emptyLabel: 'Selfie preview'}]}
    />
  );
}
