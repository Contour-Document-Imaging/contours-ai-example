const String poweredByText = 'Powered by Flutter';

enum CapturingSide {
  front('front'),
  back('back'),
  frontFaceOnly('frontFaceOnly');

  const CapturingSide(this.value);
  final String value;
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
}

class PreviewItem {
  const PreviewItem({
    required this.label,
    required this.emptyLabel,
  });

  final String label;
  final String emptyLabel;
}

class DocumentUiConfig {
  const DocumentUiConfig({
    required this.title,
    required this.description,
    this.selfie = false,
    required this.items,
  });

  final String title;
  final String description;
  final bool selfie;
  final List<PreviewItem> items;
}

class DocumentSdkConfig {
  const DocumentSdkConfig({
    required this.documentType,
    this.captureType,
    this.enableMultipleCapturing = false,
    this.capturingSides,
  });

  final String documentType;
  final String? captureType;
  final bool enableMultipleCapturing;
  final List<CapturingSide>? capturingSides;
}

class DocumentConfig {
  const DocumentConfig({
    required this.ui,
    required this.sdk,
  });

  final DocumentUiConfig ui;
  final DocumentSdkConfig sdk;
}

class DocumentImageState {
  const DocumentImageState({
    this.front = '',
    this.back = '',
  });

  final String front;
  final String back;

  DocumentImageState copyWith({
    String? front,
    String? back,
  }) {
    return DocumentImageState(
      front: front ?? this.front,
      back: back ?? this.back,
    );
  }
}

CapturingSide getPreviewCapturingSide(
  DocumentType documentType,
  int index,
) {
  switch (documentType) {
    case DocumentType.check:
    case DocumentType.id:
      return index == 0 ? CapturingSide.front : CapturingSide.back;
    case DocumentType.passport:
      return CapturingSide.frontFaceOnly;
    case DocumentType.selfie:
      return CapturingSide.front;
  }
}

DocumentUiConfig getDocumentUiConfig(DocumentType documentType) {
  switch (documentType) {
    case DocumentType.check:
      return const DocumentUiConfig(
        title: 'Check Scan',
        description: 'Capture the front or back side of the check.',
        items: [
          PreviewItem(label: 'Front Check', emptyLabel: 'Front preview'),
          PreviewItem(label: 'Back Check', emptyLabel: 'Back preview'),
        ],
      );
    case DocumentType.id:
      return const DocumentUiConfig(
        title: 'ID Scan',
        description: 'Capture the front and back side of the ID.',
        items: [
          PreviewItem(label: 'Front ID', emptyLabel: 'Front preview'),
          PreviewItem(label: 'Back ID', emptyLabel: 'Back preview'),
        ],
      );
    case DocumentType.passport:
      return const DocumentUiConfig(
        title: 'Passport Scan',
        description: 'Capture the passport front.',
        items: [
          PreviewItem(
            label: 'Passport Front',
            emptyLabel: 'Passport preview',
          ),
        ],
      );
    case DocumentType.selfie:
      return const DocumentUiConfig(
        title: 'Take Selfie',
        description: 'Capture your selfie.',
        selfie: true,
        items: [
          PreviewItem(label: 'User Selfie', emptyLabel: 'Selfie preview'),
        ],
      );
  }
}
