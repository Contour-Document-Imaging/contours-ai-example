import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'contourScannerManager.dart';
import 'scannerTypes.dart';

class DocumentScannerScreen extends StatefulWidget {
  const DocumentScannerScreen({super.key});

  @override
  State<DocumentScannerScreen> createState() => _DocumentScannerScreenState();
}

class _DocumentScannerScreenState extends State<DocumentScannerScreen> {
  late final ScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScannerController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return ViewScreen(
          activeDocumentType: _controller.activeDocumentType,
          config: _controller.config,
          getImageUri: _controller.getImageUri,
          onSelectDocumentType: _controller.setActiveDocumentType,
          onStartScan: (capturingSide) async {
            try {
              await _controller.startScan(capturingSide);
            } on PlatformException catch (error) {
              debugPrint(error.message ?? 'Unable to open the scan SDK.');
            }
          },
        );
      },
    );
  }
}

class ViewScreen extends StatelessWidget {
  const ViewScreen({
    super.key,
    required this.activeDocumentType,
    required this.config,
    required this.getImageUri,
    required this.onSelectDocumentType,
    required this.onStartScan,
  });

  final DocumentType activeDocumentType;
  final DocumentConfig config;
  final String Function(CapturingSide capturingSide) getImageUri;
  final void Function(DocumentType documentType) onSelectDocumentType;
  final Future<void> Function(CapturingSide capturingSide) onStartScan;

  @override
  Widget build(BuildContext context) {
    final firstCapturingSide = getPreviewCapturingSide(activeDocumentType, 0);
    final secondCapturingSide = getPreviewCapturingSide(activeDocumentType, 1);

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
                          Text(
                            config.ui.title,
                            style: const TextStyle(
                              color: Color(0xFF183642),
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            poweredByText,
                            style: TextStyle(
                              color: Color(0xFF5F7782),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            config.ui.description,
                            style: const TextStyle(
                              color: Color(0xFF5F7782),
                              fontSize: 15,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 18),
                          if (config.ui.items.length == 1)
                            _PreviewTile(
                              label: config.ui.items.first.label,
                              emptyLabel: config.ui.items.first.emptyLabel,
                              imagePath: getImageUri(firstCapturingSide),
                              square: config.ui.selfie,
                              onTap: () => onStartScan(firstCapturingSide),
                            )
                          else
                            Column(
                              children: [
                                _PreviewTile(
                                  label: config.ui.items[0].label,
                                  emptyLabel: config.ui.items[0].emptyLabel,
                                  imagePath: getImageUri(firstCapturingSide),
                                  onTap: () => onStartScan(firstCapturingSide),
                                ),
                                const SizedBox(height: 12),
                                _PreviewTile(
                                  label: config.ui.items[1].label,
                                  emptyLabel: config.ui.items[1].emptyLabel,
                                  imagePath: getImageUri(secondCapturingSide),
                                  onTap: () => onStartScan(secondCapturingSide),
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
                          children: DocumentType.values.map((documentType) {
                            final isActive = documentType == activeDocumentType;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: FilledButton(
                                  onPressed: () => onSelectDocumentType(documentType),
                                  style: FilledButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: isActive
                                        ? const Color(0xFF183642)
                                        : Colors.transparent,
                                    foregroundColor: isActive
                                        ? Colors.white
                                        : const Color(0xFF5F7782),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Text(
                                    documentType.tabLabel,
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
    required this.emptyLabel,
    required this.imagePath,
    required this.onTap,
    this.square = false,
  });

  final String label;
  final String emptyLabel;
  final String imagePath;
  final bool square;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final previewBox = Container(
      width: square ? 220 : double.infinity,
      height: 220,
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
                return _PreviewPlaceholder(label: emptyLabel);
              },
            )
          : _PreviewPlaceholder(label: emptyLabel),
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
