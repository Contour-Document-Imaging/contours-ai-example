import {useCallback, useEffect, useRef, useState} from 'react';
import {AppState, AppStateStatus} from 'react-native';
import {
  ContourModel,
  onContourClosed,
  onEventCaptured,
  onSelfieCaptured,
  startContour,
} from 'contour-ai-sdk';

const CLIENT_ID = '<CLIENT_ID>';

export type PreviewSide = 'front' | 'back' | 'frontFaceOnly';

export type DocumentType = 'check' | 'id' | 'passport' | 'selfie';

export type ScanItem = {
  documentCaptureSide: PreviewSide;
  label: string;
  emptyLabel: string;
  statusLabel: string;
};

export type DocumentConfig = {
  title: string;
  description: string;
  documentType: string;
  captureType: 'both';
  enableMultipleCapturing: boolean;
  selfie?: boolean;
  items: ScanItem[];
};

type ContourCaptureEvent = {
  croppedFrontUri?: string;
  croppedRearUri?: string;
};

type SelfieCaptureEvent = {
  selfieUri?: string;
};

export function getDocumentConfig(documentType: DocumentType): DocumentConfig {
  switch (documentType) {
    case 'check':
      return {
        title: 'Check Scan',
        description: 'Capture the front or back side of the check.',
        documentType: 'check',
        captureType: 'both',
        enableMultipleCapturing: false,
        items: [
          {
            documentCaptureSide: 'front',
            label: 'Front Check',
            emptyLabel: 'Front preview',
            statusLabel: 'front',
          },
          {
            documentCaptureSide: 'back',
            label: 'Back Check',
            emptyLabel: 'Back preview',
            statusLabel: 'back',
          },
        ],
      };
    case 'id':
      return {
        title: 'ID Scan',
        description: 'Capture the front and back side of the ID.',
        documentType: 'id',
        captureType: 'both',
        enableMultipleCapturing: false,
        items: [
          {
            documentCaptureSide: 'front',
            label: 'Front ID',
            emptyLabel: 'Front preview',
            statusLabel: 'front',
          },
          {
            documentCaptureSide: 'back',
            label: 'Back ID',
            emptyLabel: 'Back preview',
            statusLabel: 'back',
          },
        ],
      };
    case 'passport':
      return {
        title: 'Passport Scan',
        description: 'Capture the passport front face only.',
        documentType: 'passport',
        captureType: 'both',
        enableMultipleCapturing: false,
        items: [
          {
            documentCaptureSide: 'front',
            label: 'Passport',
            emptyLabel: 'Passport preview',
            statusLabel: 'front face',
          },
        ],
      };
    case 'selfie':
      return {
        title: 'Take Selfie.',
        description: 'Capture your selfie.',
        documentType: 'Selfie',
        captureType: 'both',
        enableMultipleCapturing: false,
        selfie: true,
        items: [
          {
            documentCaptureSide: 'front',
            label: 'Selfie',
            emptyLabel: 'Selfie preview',
            statusLabel: 'face capture',
          },
        ],
      };
  }
}

export function useContourScanner(config: DocumentConfig) {
  const [frontImageUri, setFrontImageUri] = useState('');
  const [backImageUri, setBackImageUri] = useState('');
  const [statusMessage, setStatusMessage] = useState('Preparing scanner...');
  const scanInProgressRef = useRef(false);
  const appStateRef = useRef(AppState.currentState);

  const updateStatus = useCallback((message: string) => {
    setStatusMessage(message);
  }, []);

  const handleContourClosed = useCallback(() => {
    scanInProgressRef.current = false;
    updateStatus('Scanner closed. Tap a preview to scan again.');
  }, [updateStatus]);

  const onCaptured = useCallback(
    (event: ContourCaptureEvent) => {
      const croppedFrontUri = event.croppedFrontUri;
      const croppedRearUri = event.croppedRearUri;

      if (croppedFrontUri) {
        setFrontImageUri(croppedFrontUri);
      }

      if (croppedRearUri) {
        setBackImageUri(croppedRearUri);
      }

      if (croppedFrontUri || croppedRearUri) {
        scanInProgressRef.current = false;
        updateStatus('Preview captured. Tap it to scan again.');
      }
    },
    [updateStatus],
  );

  const registerScannerCallbacks = useCallback(() => {
    onContourClosed(() => {
      handleContourClosed();
    });

    onEventCaptured((eventCaptured: string) => {
      console.log(eventCaptured);
    });

    onSelfieCaptured((selfieCapture: SelfieCaptureEvent) => {
      const selfieUri = selfieCapture.selfieUri;
      if (selfieUri) {
        setFrontImageUri(selfieUri);
        scanInProgressRef.current = false;
        updateStatus('Selfie captured. Tap it to scan again.');
      }
    });
  }, [handleContourClosed, updateStatus]);

  useEffect(() => {
    updateStatus('Tap a preview to start scanning.');
    registerScannerCallbacks();

    const subscription = AppState.addEventListener(
      'change',
      (nextAppState: AppStateStatus) => {
        const previousAppState = appStateRef.current;
        appStateRef.current = nextAppState;

        if (
          scanInProgressRef.current &&
          previousAppState.match(/inactive|background/) &&
          nextAppState === 'active'
        ) {
          handleContourClosed();
        }
      },
    );

    return () => {
      subscription.remove();
    };
  }, [handleContourClosed, registerScannerCallbacks, updateStatus]);

  const startSDK = useCallback(
    (capturingSide: PreviewSide) => {
      const selectedPreview = config.items.find(
        item => item.documentCaptureSide === capturingSide,
      );

      if (!selectedPreview) {
        updateStatus('Unable to open scanner.');
        return;
      }

      scanInProgressRef.current = true;
      updateStatus('Opening scanner...');
      registerScannerCallbacks();

      const contoursModel: ContourModel = {
        clientId: CLIENT_ID,
        captureType: config.captureType,
        enableMultipleCapturing: config.enableMultipleCapturing,
        type: config.documentType,
        capturingSide,
      };

      startContour(contoursModel, onCaptured);
    },
    [config, onCaptured, registerScannerCallbacks, updateStatus],
  );

  const getImageUri = useCallback(
    (side: PreviewSide) => (side === 'back' ? backImageUri : frontImageUri),
    [backImageUri, frontImageUri],
  );

  return {
    getImageUri,
    startSDK,
    statusMessage,
  };
}
