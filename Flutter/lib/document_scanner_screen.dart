import 'dart:io';

import 'package:contouraisdk/contouraisdk.dart';
import 'package:contouraisdk/contouraisdk_contours_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String _clientId = '<CLIENT_ID>';

class DocumentScannerScreen extends StatefulWidget {
  const DocumentScannerScreen({super.key});

  @override
  State<DocumentScannerScreen> createState() => _DocumentScannerScreenState();
}

class _DocumentScannerScreenState extends State<DocumentScannerScreen> {
  final Map<DocumentType, Map<String, String>> _previewState = {
    for (final type in DocumentType.values) type: <String, String>{},
  };

  DocumentType _activeDocument = DocumentType.check;
  DocumentType? _activeCaptureDocument;
  String? _activeCaptureSide;
  String _statusMessage = 'Ready to scan check.';

  @override
  void initState() {
    super.initState();
    Contouraisdk.registerCallbacks(
      _onDataReceived,
      _onEventCaptured,
      _onContourClosed,
      _onSelfieCaptured,
    );
  }

  Future<void> _startScan(String side) async {
    final config = _activeDocument.config;
    setState(() {
      _activeCaptureDocument = _activeDocument;
      _activeCaptureSide = side;
      _statusMessage = 'Opening ${_labelForStatus(config, side)}...';
    });

    try {
      final contoursModel = ContoursModel(
        clientID: _clientId,
        type: config.sdkType,
        captureSide: side,
        captureType: 'both',
        enableMultipleCapturing: false,
      );
      await Contouraisdk.startContour(contoursModel);
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _statusMessage = error.message ?? 'Unable to open the scan SDK.';
      });
    }
  }

  void _onDataReceived(Map<String, String> data) {
    final document = _activeCaptureDocument ?? _activeDocument;
    final state = _previewState[document]!;
    final frontUri = data['croppedFrontUri'] ?? data['frontUri'];
    final backUri = data['croppedRearUri'] ?? data['rearUri'];

    if (!mounted) {
      return;
    }

    setState(() {
      if (frontUri != null && frontUri.isNotEmpty) {
        state['front'] = frontUri;
      }
      if (backUri != null && backUri.isNotEmpty) {
        state['back'] = backUri;
      }
      _statusMessage = _formatCaptureResult(
        document,
        _activeCaptureSide,
        frontUri,
        backUri,
      );
    });
  }

  void _onSelfieCaptured(String? capturedSelfie) {
    if (!mounted || capturedSelfie == null || capturedSelfie.isEmpty) {
      return;
    }

    setState(() {
      _previewState[DocumentType.selfie]!['front'] = capturedSelfie;
      if (_activeDocument == DocumentType.selfie) {
        _statusMessage = 'Selfie completed.';
      }
    });
  }

  void _onEventCaptured(String data) {
    if (!mounted) {
      return;
    }
    setState(() {
      _statusMessage = 'Contour SDK event received.';
    });
  }

  void _onContourClosed() {
    if (!mounted) {
      return;
    }

    final document = _activeCaptureDocument ?? _activeDocument;
    final preview = _previewState[document]!;
    final hasImage = (preview['front']?.isNotEmpty ?? false) ||
        (preview['back']?.isNotEmpty ?? false);

    setState(() {
      if (!hasImage) {
        _statusMessage = '${document.displayName} scan closed.';
      }
      _activeCaptureDocument = null;
      _activeCaptureSide = null;
    });
  }

  String _formatCaptureResult(
    DocumentType document,
    String? captureSide,
    String? frontUri,
    String? backUri,
  ) {
    final hasFront = frontUri != null && frontUri.isNotEmpty;
    final hasBack = backUri != null && backUri.isNotEmpty;

    if (hasFront && hasBack) {
      return '${document.displayName} front and back scan completed.';
    }
    if (hasBack) {
      return '${document.displayName} back scan completed.';
    }
    if (hasFront) {
      return '${_labelForStatus(document.config, captureSide ?? document.config.sides.first.sdkSide)} completed.';
    }
    return 'Scan completed.';
  }

  String _labelForStatus(DocumentConfig config, String side) {
    final sideConfig = config.sides.firstWhere(
      (item) => item.sdkSide == side,
      orElse: () => config.sides.first,
    );
    return sideConfig.actionLabel.replaceFirst('Scan ', '').toLowerCase();
  }

  void _setActiveDocument(DocumentType document) {
    if (_activeDocument == document) {
      return;
    }

    setState(() {
      _activeDocument = document;
      _statusMessage = 'Ready to scan ${document.displayName.toLowerCase()}.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = _activeDocument.config;
    final previews = _previewState[_activeDocument]!;

    return Scaffold(
      backgroundColor: const Color(0xFFD8E8EF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      decoration: BoxDecoration(
                        color: const Color(0xF7FFFCF8),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0x1F2F4757)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x29183642),
                            blurRadius: 30,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Identity Verification',
                            style: TextStyle(
                              color: Color(0xFF0F766E),
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Powered by Flutter',
                            style: TextStyle(
                              color: Color(0xFF5F7782),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            config.title,
                            style: const TextStyle(
                              color: Color(0xFF183642),
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            config.description,
                            style: const TextStyle(
                              color: Color(0xFF5F7782),
                              fontSize: 15,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _statusMessage,
                            style: const TextStyle(
                              color: Color(0xFF5F7782),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 18),
                          if (config.sides.length == 1)
                            _PreviewTile(
                              label: config.sides.first.previewLabel,
                              imagePath:
                                  previews[config.sides.first.documentSide] ?? '',
                              square: _activeDocument == DocumentType.selfie,
                              onTap: () =>
                                  _startScan(config.sides.first.sdkSide),
                            )
                          else
                            Column(
                              children: [
                                _PreviewTile(
                                  label: config.sides[0].previewLabel,
                                  imagePath:
                                      previews[config.sides[0].documentSide] ??
                                          '',
                                  onTap: () =>
                                      _startScan(config.sides[0].sdkSide),
                                ),
                                const SizedBox(height: 12),
                                _PreviewTile(
                                  label: config.sides[1].previewLabel,
                                  imagePath:
                                      previews[config.sides[1].documentSide] ??
                                          '',
                                  onTap: () =>
                                      _startScan(config.sides[1].sdkSide),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xEBFFFFFF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0x242F4757)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x2E183642),
                            blurRadius: 48,
                            offset: Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: DocumentType.values.map((document) {
                            final isActive = document == _activeDocument;
                            return Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: FilledButton(
                                  onPressed: () => _setActiveDocument(document),
                                  style: FilledButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: isActive
                                        ? const Color(0xFF183642)
                                        : Colors.transparent,
                                    foregroundColor: isActive
                                        ? Colors.white
                                        : const Color(0xFF5F7782),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Text(
                                    document.tabLabel,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({
    required this.label,
    required this.imagePath,
    required this.onTap,
    this.square = false,
  });

  final String label;
  final String imagePath;
  final bool square;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final previewBox = Container(
      width: square ? 180 : double.infinity,
      height: square ? 180 : 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x24183642)),
        color: const Color(0xF6FFFFFF),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: imagePath.isNotEmpty
          ? Image.file(
              File(imagePath),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return _PreviewPlaceholder(label: label);
              },
            )
          : _PreviewPlaceholder(label: label),
    );

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF183642),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          if (square)
            Align(
              alignment: Alignment.centerLeft,
              child: previewBox,
            )
          else
            previewBox,
        ],
      ),
    );
  }
}

class _PreviewPlaceholder extends StatelessWidget {
  const _PreviewPlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF5F7782),
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
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

  DocumentConfig get config {
    switch (this) {
      case DocumentType.check:
        return const DocumentConfig(
          title: 'Check Scan',
          description: 'Capture the front or back side of the check.',
          sdkType: 'check',
          sides: [
            DocumentSide(
              sdkSide: 'front',
              documentSide: 'front',
              previewLabel: 'Front Check',
              actionLabel: 'Scan Front',
            ),
            DocumentSide(
              sdkSide: 'back',
              documentSide: 'back',
              previewLabel: 'Back Check',
              actionLabel: 'Scan Back',
            ),
          ],
        );
      case DocumentType.id:
        return const DocumentConfig(
          title: 'ID Scan',
          description: 'Capture the front and back side of the ID.',
          sdkType: 'id',
          sides: [
            DocumentSide(
              sdkSide: 'front',
              documentSide: 'front',
              previewLabel: 'Front ID',
              actionLabel: 'Scan Front',
            ),
            DocumentSide(
              sdkSide: 'back',
              documentSide: 'back',
              previewLabel: 'Back ID',
              actionLabel: 'Scan Back',
            ),
          ],
        );
      case DocumentType.passport:
        return const DocumentConfig(
          title: 'Passport Scan',
          description: 'Capture the passport front face only.',
          sdkType: 'passport',
          sides: [
            DocumentSide(
              sdkSide: 'frontFaceOnly',
              documentSide: 'front',
              previewLabel: 'Passport Front Face',
              actionLabel: 'Scan Front Face',
            ),
          ],
        );
      case DocumentType.selfie:
        return const DocumentConfig(
          title: 'Take Selfie',
          description: 'Capture your selfie',
          sdkType: 'Selfie',
          sides: [
            DocumentSide(
              sdkSide: 'front',
              documentSide: 'front',
              previewLabel: 'User Selfie',
              actionLabel: 'Capture Face',
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
    required this.sdkType,
    required this.sides,
  });

  final String title;
  final String description;
  final String sdkType;
  final List<DocumentSide> sides;
}

class DocumentSide {
  const DocumentSide({
    required this.sdkSide,
    required this.documentSide,
    required this.previewLabel,
    required this.actionLabel,
  });

  final String sdkSide;
  final String documentSide;
  final String previewLabel;
  final String actionLabel;
}
