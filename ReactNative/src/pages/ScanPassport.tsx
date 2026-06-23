import React from 'react';
import DocumentScannerScreen from './DocumentScannerScreen';

export default function ScanPassport() {
  return (
    <DocumentScannerScreen
      title="Passport Scan"
      description="Capture the passport front face only."
      documentType="passport"
      previews={[
        {key: 'front', label: 'Passport', emptyLabel: 'Passport preview'},
      ]}
    />
  );
}
