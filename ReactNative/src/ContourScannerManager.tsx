import {useCallback, useEffect, useRef, useState} from 'react';
import {AppState, AppStateStatus} from 'react-native';
import {
  ContourModel,
  onContourClosed,
  onEventCaptured,
  onSelfieCaptured,
  startContour,
} from 'contour-ai-sdk';
import {
  CapturingSide,
  ContourCaptureEvent,
  DocumentConfig,
  DocumentImageState,
  DocumentType,
  SelfieCaptureEvent,
} from './ScannerTypes';
import {getDocumentUiConfig} from './view';

export const CLIENT_ID = '<CLIENT_ID>';

export function getDocumentSdkConfig(
  documentType: DocumentType,
): DocumentConfig['sdk'] {
  switch (documentType) {
    case 'check':
      return {
        documentType: 'check',
        captureType: 'both',
        enableMultipleCapturing: false,
        capturingSides: ['front', 'back'],
      };
    case 'id':
      return {
        documentType: 'id',
        captureType: 'both',
        enableMultipleCapturing: false,
        capturingSides: ['front', 'back'],
      };
    case 'passport':
      return {
        documentType: 'passport',
        captureType: 'both',
        enableMultipleCapturing: false,
        capturingSides: ['front'],
      };
    case 'selfie':
      return {
        documentType: 'Selfie',
        capturingSides: ['front'],
      };
  }
}

export function getDocumentConfig(documentType: DocumentType): DocumentConfig {
  return {
    ui: getDocumentUiConfig(documentType),
    sdk: getDocumentSdkConfig(documentType),
  };
}

export function withDefaultDocumentConfig(
  config: DocumentConfig,
): DocumentConfig {
  return {
    ...config,
    sdk: {
      ...config.sdk,
      capturingSides:
        config.sdk.capturingSides ??
        config.ui.items.map(() => 'front'),
    },
  };
}

export function useContourScanner(config: DocumentConfig) {
  const [imageUrisByDocument, setImageUrisByDocument] = useState<
    Record<string, DocumentImageState>
  >({});
  const scanInProgressRef = useRef(false);
  const appStateRef = useRef(AppState.currentState);
  const currentDocumentType = config.sdk.documentType ?? 'check';

  const updateDocumentImages = useCallback(
    (documentType: string, nextState: Partial<DocumentImageState>) => {
      setImageUrisByDocument(previousState => ({
        ...previousState,
        [documentType]: {
          front: previousState[documentType]?.front ?? '',
          back: previousState[documentType]?.back ?? '',
          ...nextState,
        },
      }));
    },
    [],
  );

  const handleContourClosed = useCallback(() => {
    scanInProgressRef.current = false;
  }, []);

  const onCaptured = useCallback(
    (event: ContourCaptureEvent) => {
      const croppedFrontUri = event.croppedFrontUri;
      const croppedRearUri = event.croppedRearUri;

      if (croppedFrontUri) {
        updateDocumentImages(currentDocumentType, {front: croppedFrontUri});
      }

      if (croppedRearUri) {
        updateDocumentImages(currentDocumentType, {back: croppedRearUri});
      }

      if (croppedFrontUri || croppedRearUri) {
        scanInProgressRef.current = false;
      }
    },
    [currentDocumentType, updateDocumentImages],
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
        updateDocumentImages(currentDocumentType, {front: selfieUri});
        scanInProgressRef.current = false;
      }
    });
  }, [currentDocumentType, handleContourClosed, updateDocumentImages]);

  useEffect(() => {
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
  }, [handleContourClosed, registerScannerCallbacks]);

  const startSDK = useCallback(
    (capturingSide: CapturingSide) => {
      const hasSelectedPreview =
        config.sdk.capturingSides?.includes(capturingSide) ?? false;

      if (!hasSelectedPreview) {
        return;
      }

      scanInProgressRef.current = true;
      registerScannerCallbacks();

      const contoursModel: ContourModel = {
        clientId: CLIENT_ID,
        captureType: config.sdk.captureType ?? 'both',
        enableMultipleCapturing:
          config.sdk.enableMultipleCapturing ?? false,
        type: config.sdk.documentType ?? 'check',
        capturingSide,
      };

      startContour(contoursModel, onCaptured);
    },
    [config, onCaptured, registerScannerCallbacks],
  );

  const getImageUri = useCallback(
    (capturingSide: CapturingSide) => {
      const currentImages = imageUrisByDocument[currentDocumentType];

      if (capturingSide === 'back') {
        return currentImages?.back ?? '';
      }

      return currentImages?.front ?? '';
    },
    [currentDocumentType, imageUrisByDocument],
  );

  return {
    getImageUri,
    startSDK,
  };
}

export type {CapturingSide, DocumentConfig, DocumentType} from './ScannerTypes';
