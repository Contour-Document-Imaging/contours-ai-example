import 'package:contouraisdk/contouraisdk_contours_model.dart';

const String contourClientId = '<CLIENT_ID>';

ContoursModel buildContoursModel(DocumentConfig config, ScanItem item) {
  return ContoursModel(
    clientID: contourClientId,
    type: config.documentType,
    captureSide: item.documentSide,
    captureType: 'both',
    enableMultipleCapturing: false,
  );
}

String previewKey(ScanItem item) {
  return item.documentSide == 'back' ? 'back' : 'front';
}

class ScanItem {
  const ScanItem({
    required this.documentSide,
    required this.label,
    required this.statusLabel,
  });

  final String documentSide;
  final String label;
  final String statusLabel;
}

enum DocumentType {
  check,
  id,
  passport,
  selfie;

  String get tabLabel {
    switch (this) {
      case DocumentType.check:
        return 'Check';
      case DocumentType.id:
        return 'ID';
      case DocumentType.passport:
        return 'Passport';
      case DocumentType.selfie:
        return 'Selfie';
    }
  }

  String get displayName {
    switch (this) {
      case DocumentType.id:
        return 'ID';
      case DocumentType.check:
        return 'Check';
      case DocumentType.passport:
        return 'Passport';
      case DocumentType.selfie:
        return 'Selfie';
    }
  }

  String get initialStatusMessage {
    return 'Ready to scan ${displayName.toLowerCase()}.';
  }

  DocumentConfig get config {
    switch (this) {
      case DocumentType.check:
        return const DocumentConfig(
          title: 'Check Scan',
          description: 'Capture the front or back side of the check.',
          documentType: 'check',
          items: [
            ScanItem(
              documentSide: 'front',
              label: 'Front Check',
              statusLabel: 'front',
            ),
            ScanItem(
              documentSide: 'back',
              label: 'Back Check',
              statusLabel: 'back',
            ),
          ],
        );
      case DocumentType.id:
        return const DocumentConfig(
          title: 'ID Scan',
          description: 'Capture the front and back side of the ID.',
          documentType: 'id',
          items: [
            ScanItem(
              documentSide: 'front',
              label: 'Front ID',
              statusLabel: 'front',
            ),
            ScanItem(
              documentSide: 'back',
              label: 'Back ID',
              statusLabel: 'back',
            ),
          ],
        );
      case DocumentType.passport:
        return const DocumentConfig(
          title: 'Passport Scan',
          description: 'Capture the passport front face only.',
          documentType: 'passport',
          items: [
            ScanItem(
              documentSide: 'frontFaceOnly',
              label: 'Passport Front Face',
              statusLabel: 'front face',
            ),
          ],
        );
      case DocumentType.selfie:
        return const DocumentConfig(
          title: 'Take Selfie',
          description: 'Capture your selfie',
          documentType: 'Selfie',
          items: [
            ScanItem(
              documentSide: 'front',
              label: 'User Selfie',
              statusLabel: 'face capture',
            ),
          ],
        );
    }
  }
}

class DocumentConfig {
  const DocumentConfig({
    required this.title,
    required this.description,
    required this.documentType,
    required this.items,
  });

  final String title;
  final String description;
  final String documentType;
  final List<ScanItem> items;
}
