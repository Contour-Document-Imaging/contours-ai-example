import React from 'react';
import DocumentScannerScreen from './DocumentScannerScreen';

export default function ScanCheck() {
  return (
    <DocumentScannerScreen
      title="Check Scan"
      description="Capture the front or back side of the check."
      documentType="check"
      previews={[
        {key: 'front', label: 'Front Check', emptyLabel: 'Front preview'},
        {key: 'back', label: 'Back Check', emptyLabel: 'Back preview'},
      ]}
    />
  );
}
