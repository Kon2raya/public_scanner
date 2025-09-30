// lib/features/inbound/screens/scanning_screen.dart
import 'package:aai_scanner_epson/core/config/theme/color_constant.dart';
import 'package:aai_scanner_epson/core/widgets/app_button.dart';
import 'package:aai_scanner_epson/features/scanning/presentations/screens/inbound/controllers/scanning_controller.dart';
import 'package:aai_scanner_epson/features/scanning/presentations/screens/inbound/widgets/scanner_overlay_widget.dart';
import 'package:aai_scanner_epson/features/scanning/presentations/screens/inbound/widgets/scanning_action_button.dart';
import 'package:aai_scanner_epson/features/scanning/presentations/screens/inbound/widgets/scanning_dialogs.dart';
import 'package:aai_scanner_epson/features/scanning/presentations/screens/inbound/widgets/scanning_step_indicator.dart';
import 'package:aai_scanner_epson/features/scanning/presentations/screens/inbound/widgets/scanning_step_widget.dart';
import 'package:flutter/material.dart';
import 'package:aai_scanner_epson/core/models/receiving_item.dart';
import 'package:aai_scanner_epson/core/widgets/app_scaffold.dart';

class ScanningScreen extends StatefulWidget {
  final String rcvNumber;
  final List<ReceivingItem> items;
  final Function(List<Map<String, dynamic>>)? onScanComplete; // New parameter

  const ScanningScreen({
    super.key,
    required this.rcvNumber,
    required this.items,
    this.onScanComplete, // New parameter
  });

  @override
  State<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen> {
  late ScanningController controller;
  final TextEditingController manualInputCtrl = TextEditingController();
  bool showScanner = false;

  @override
  void initState() {
    super.initState();
    controller = ScanningController();
    controller.startScanning(widget.rcvNumber, widget.items);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return Stack(
          children: [
            // In your scanning_screen.dart, update the AppScaffold call:
            AppScaffold(
              title: 'Scanning - ${widget.rcvNumber}',
              enableBodyScrolling: false, // ✅ Disable automatic scrolling
              body: Column(
                children: [
                  // Step indicator - fixed height
                  ScanningStepIndicator(controller: controller),
                  // Content area - flexible
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ScanningStepWidgets(
                        controller: controller,
                        manualInputCtrl: manualInputCtrl,
                        rcvNumber: widget.rcvNumber,
                        items: widget.items,
                        onScanPressed: () => setState(() => showScanner = true),
                        onManualInput:
                            _handleManualInput, // This now matches the expected signature
                      ),
                    ),
                  ),

                  // Action buttons - fixed at bottom
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: ScanningActionButtons(
                        controller: controller,
                        onScanPressed: () => setState(() => showScanner = true),
                        onBackPressed: () => _handleBackPressed(),
                        onUploadComplete: () =>
                            _handleUploadComplete(), // New callback
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (showScanner)
              ScannerOverlayWidget(
                onDetected: _handleScannedData,
                onClose: () => setState(() => showScanner = false),
              ),
          ],
        );
      },
    );
  }

  // In scanning_screen.dart, update the _handleScannedData method:
  void _handleBackPressed() {
    // Check if we can go back to a previous step
    if (controller.canGoToPreviousStep()) {
      controller.goToPreviousStep();
    } else {
      // No previous step available, go back to inbound entry screen
      Navigator.pop(context);
    }
  }

  void _handleScannedData(String data) {
    setState(() => showScanner = false); // Close scanner first
    switch (controller.currentStep) {
      case ScanningStep.scanPalletId:
        controller.scanPalletId(data);
        break;
      case ScanningStep.scanSkuPerPallet:
        if (_isValidSku(data)) {
          _showQuantityDialog(data);
        } else {
          _showSkuNotFoundDialog(data);
        }
        break;
      case ScanningStep.scanBoxLabel:
        controller.scanBoxLabel(data);
        break;
      case ScanningStep.scanSerialNumber:
        _handleSerialNumberInput(data);
        break;
      default:
        break;
    }
  }

  Future<void> _handleSerialNumberInput(String serialNumber) async {
    final error = await controller.validateAndAddSerialNumber(
      serialNumber,
    ); // ✅
    if (error != null) {
      _showSerialErrorDialog(error);
    } else {
      manualInputCtrl.clear(); // ✅ Clear on success
    }
  }

  void _showSerialErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text("Invalid"),
          ],
        ),
        content: Text(error),
        actions: [
          SizedBox(
            height: 40,
            child: AppButton(
              label: "OK",
              onPressed: () => Navigator.pop(context),
              backgroundColor: AppColors.primaryRed,
            ),
          ),
        ],
      ),
    );
  }

  void _handleManualInput(String data) {
    // Put scanned data into the appropriate text field based on current step
    switch (controller.currentStep) {
      case ScanningStep.scanPalletId:
        manualInputCtrl.text =
            data; // Puts scanned value in pallet ID text field
        break;
      case ScanningStep.scanSkuPerPallet:
        manualInputCtrl.text = data; // Puts scanned value in SKU text field
        break;
      case ScanningStep.scanBoxLabel:
        manualInputCtrl.text =
            data; // Puts scanned value in box label text field
        break;
      case ScanningStep.scanSerialNumber:
        manualInputCtrl.text =
            data; // Puts scanned value in serial number text field
        break;
      default:
        break;
    }

    // Then process the data
    _processManualInput(data);
  }

  // Add a new method to process the manual input:
  void _processManualInput(String data) {
    if (data.trim().isEmpty) return;
    switch (controller.currentStep) {
      case ScanningStep.scanPalletId:
        controller.scanPalletId(data);
        manualInputCtrl.clear();
        break;
      case ScanningStep.scanSkuPerPallet:
        if (_isValidSku(data)) {
          _showQuantityDialog(data);
        } else {
          _showSkuNotFoundDialog(data);
        }
        break;
      case ScanningStep.scanBoxLabel:
        controller.scanBoxLabel(data);
        manualInputCtrl.clear();
        break;
      case ScanningStep.scanSerialNumber:
        _handleSerialNumberInput(data);
        break;
      default:
        break;
    }
  }

  void _handleUploadComplete() {
    // Pass scanned data back when upload is complete
    if (widget.onScanComplete != null && controller.scannedData.isNotEmpty) {
      widget.onScanComplete!(controller.scannedData);
    }
    Navigator.pop(context);
  }

  bool _isValidSku(String sku) {
    return widget.items.any(
      (item) => item.itemCode.toLowerCase() == sku.toLowerCase(),
    );
  }

  void _showSkuNotFoundDialog(String sku) {
    showDialog(
      context: context,
      builder: (context) =>
          SkuNotFoundDialog(sku: sku, availableItems: widget.items),
    );
  }

  void _showQuantityDialog(String sku) {
    showDialog(
      context: context,
      builder: (context) => QuantityInputDialog(
        sku: sku,
        onConfirm: (quantity) => controller.scanSkuAndQuantity(sku, quantity),
      ),
    );
  }

  @override
  void dispose() {
    manualInputCtrl.dispose();
    super.dispose();
  }
}
