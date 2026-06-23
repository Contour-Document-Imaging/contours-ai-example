import React from 'react';
import DocumentScannerScreen from './DocumentScannerScreen';

export default function ScanID() {
  return (
    <DocumentScannerScreen
      title="ID Scan"
      description="Capture the front or back side of the ID."
      documentType="id"
      previews={[
        {key: 'front', label: 'Front ID', emptyLabel: 'Front preview'},
        {key: 'back', label: 'Back ID', emptyLabel: 'Back preview'},
      ]}
    />
  );
}
