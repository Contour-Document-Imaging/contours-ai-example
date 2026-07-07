export type CapturingSide = 'front' | 'back' | 'frontFaceOnly';

export type DocumentType = 'check' | 'id' | 'passport' | 'selfie';

export type ScanItem = {
  label: string;
  emptyLabel: string;
  statusLabel: string;
};

export type DocumentUiConfig = {
  title: string;
  description: string;
  selfie?: boolean;
  items: ScanItem[];
};

export type DocumentSdkConfig = {
  documentType?: string;
  captureType?: 'both';
  enableMultipleCapturing?: boolean;
  capturingSides?: CapturingSide[];
};

export type DocumentConfig = {
  ui: DocumentUiConfig;
  sdk: DocumentSdkConfig;
};

export type ContourCaptureEvent = {
  croppedFrontUri?: string;
  croppedRearUri?: string;
};

export type SelfieCaptureEvent = {
  selfieUri?: string;
};

export type DocumentImageState = {
  front: string;
  back: string;
};
