// lib/features/inbound/widgets/scanner_overlay_widget.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerOverlayWidget extends StatefulWidget {
  final Function(String) onDetected;
  final VoidCallback onClose;

  const ScannerOverlayWidget({
    super.key,
    required this.onDetected,
    required this.onClose,
  });

  @override
  State<ScannerOverlayWidget> createState() => _ScannerOverlayWidgetState();
}

class _ScannerOverlayWidgetState extends State<ScannerOverlayWidget> {
  MobileScannerController? cameraController;
  bool _hasDetected = false; // Flag to prevent multiple detections

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      returnImage: false,
    );
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.8),
        child: Stack(
          children: [
            MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                // Immediately return if already detected
                if (_hasDetected) return;

                final code = capture.barcodes.first.rawValue;
                if (code != null && code.isNotEmpty) {
                  // Set flag immediately to prevent further detections
                  _hasDetected = true;

                  // Stop camera immediately
                  cameraController?.stop();

                  // Call detection callback and close scanner
                  widget.onDetected(code);
                  widget.onClose();
                }
              },
            ),

            // Scanner frame overlay
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // Instructions
            const Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Text(
                'Position barcode within the frame',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Close button
            Positioned(
              top: 50,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () {
                  cameraController?.stop();
                  widget.onClose();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
