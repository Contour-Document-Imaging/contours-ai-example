import 'package:contouraisdk/contouraisdk.dart';
import 'package:contouraisdk/contouraisdk_contours_model.dart';
import 'package:flutter/foundation.dart';

import 'scannerTypes.dart';

const String contourClientId = '<CLIENT_ID>';

//----------------------------------------------------------------
// Initializes the native Contour SDK with the configured client id.
//----------------------------------------------------------------
void initializeScannerSdk() {
  Contouraisdk.initialize(contourClientId);
}

//----------------------------------------------------------------
// Returns the SDK scan settings for the selected document type.
//----------------------------------------------------------------
DocumentSdkConfig getDocumentSdkConfig(DocumentType documentType) {
  switch (documentType) {
    case DocumentType.check:
      return const DocumentSdkConfig(
        documentType: 'check',
        captureType: 'both',
        enableMultipleCapturing: false,
        capturingSides: [CapturingSide.front, CapturingSide.back],
      );
    case DocumentType.id:
      return const DocumentSdkConfig(
        documentType: 'id',
        captureType: 'both',
        enableMultipleCapturing: false,
        capturingSides: [CapturingSide.front, CapturingSide.back],
      );
    case DocumentType.passport:
      return const DocumentSdkConfig(
        documentType: 'passport',
        captureType: 'both',
        enableMultipleCapturing: false,
        capturingSides: [CapturingSide.front],
      );
    case DocumentType.selfie:
      return const DocumentSdkConfig(
        documentType: 'Selfie',
      );
  }
}

//----------------------------------------------------------------
// Builds the SDK request model for the selected document and side.
//----------------------------------------------------------------
ContoursModel buildContoursModel(
  DocumentSdkConfig config,
  CapturingSide? capturingSide,
) {
  return ContoursModel(
    clientID: contourClientId,
    type: config.documentType,
    captureSide: capturingSide?.value,
    captureType: config.captureType,
    enableMultipleCapturing: config.enableMultipleCapturing,
  );
}

class ScannerController extends ChangeNotifier {
  //---------------------------------------------------------------------
  // Registers SDK callbacks and owns scanner image state for the screen.
  //---------------------------------------------------------------------
  ScannerController() {
    Contouraisdk.registerCallbacks(
      _onDataReceived,
      _onEventCaptured,
      _onContourClosed,
      _onSelfieCaptured,
    );
  }

  final Map<DocumentType, DocumentImageState> _imageStateByDocument = {};
  DocumentType _activeDocumentType = DocumentType.check;

  DocumentType get activeDocumentType => _activeDocumentType;
  DocumentConfig get config => DocumentConfig(
        ui: getDocumentUiConfig(_activeDocumentType),
        sdk: getDocumentSdkConfig(_activeDocumentType),
      );

  // Switches the active document tab and refreshes dependent UI state.
  void setActiveDocumentType(DocumentType documentType) {
    if (_activeDocumentType == documentType) {
      return;
    }

    _activeDocumentType = documentType;
    notifyListeners();
  }

  //----------------------------------------------------------------
  // Starts the SDK flow for the requested capture side.
  //----------------------------------------------------------------
  Future<void> startScan(CapturingSide capturingSide) async {
    final configuredSides = config.sdk.capturingSides;
    final contourCapturingSide =
        configuredSides == null || configuredSides.isEmpty
            ? null
            : configuredSides.contains(capturingSide)
                ? capturingSide
                : configuredSides.first;
    try {
      await Contouraisdk.startContour(
        buildContoursModel(config.sdk, contourCapturingSide),
      );
    } catch (error) {
      rethrow;
    }
  }

  //----------------------------------------------------------------
  // Returns the current preview image uri for the requested side.
  //----------------------------------------------------------------
  String getImageUri(CapturingSide capturingSide) {
    final currentImages = _imageStateByDocument[_activeDocumentType];
    if (capturingSide == CapturingSide.back) {
      return currentImages?.back ?? '';
    }
    return currentImages?.front ?? '';
  }

  //----------------------------------------------------------------
  // Stores the latest front/back preview images for a document type.
  //----------------------------------------------------------------
  void _updateDocumentImages(
    DocumentType documentType, {
    String? front,
    String? back,
  }) {
    final currentState =
        _imageStateByDocument[documentType] ?? const DocumentImageState();
    _imageStateByDocument[documentType] = currentState.copyWith(
      front: front,
      back: back,
    );
    notifyListeners();
  }

  //----------------------------------------------------------------
  // Handles standard capture callbacks from the SDK.
  //----------------------------------------------------------------
  void _onDataReceived(Map<String, String> data) {
    final croppedFrontUri = data['croppedFrontUri'] ?? data['frontUri'];
    final croppedRearUri = data['croppedRearUri'] ?? data['rearUri'];
    final hasFrontImage =
        croppedFrontUri != null && croppedFrontUri.isNotEmpty;
    final hasRearImage = croppedRearUri != null && croppedRearUri.isNotEmpty;
    final isDuplicateFrontAndRear =
        hasFrontImage && hasRearImage && croppedFrontUri == croppedRearUri;

    if (hasFrontImage) {
      _updateDocumentImages(_activeDocumentType, front: croppedFrontUri);
    }

    if (hasRearImage && !isDuplicateFrontAndRear) {
      _updateDocumentImages(_activeDocumentType, back: croppedRearUri);
    }
  }

  //----------------------------------------------------------------
  // Handles selfie capture callbacks from the SDK.
  //----------------------------------------------------------------
  void _onSelfieCaptured(String? capturedSelfie) {
    if (capturedSelfie == null || capturedSelfie.isEmpty) {
      return;
    }

    _updateDocumentImages(DocumentType.selfie, front: capturedSelfie);
  }

  //----------------------------------------------------------------
  // Logs generic SDK events for debugging.
  //----------------------------------------------------------------
  void _onEventCaptured(String data) {
    debugPrint(data);
  }

  //----------------------------------------------------------------
  // Handles close events from the SDK.
  //----------------------------------------------------------------
  void _onContourClosed() {}
}
