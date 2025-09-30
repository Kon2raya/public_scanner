// lib/features/scanning/presentations/screens/inbound/widgets/scanning_step_indicator.dart
import 'package:flutter/material.dart';
import 'package:aai_scanner_epson/core/config/theme/color_constant.dart';
import '../controllers/scanning_controller.dart';

class ScanningStepIndicator extends StatelessWidget {
  final ScanningController controller;

  const ScanningStepIndicator({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Remove any infinite width constraints
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppColors.primaryRed.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Important: prevent infinite height
        children: [
          Text(
            _getStepTitle(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryRed,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getStepDescription(),
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (controller.currentStep) {
      case ScanningStep.scanPalletId:
        return "Step 1: Scan Pallet ID";
      case ScanningStep.scanSkuPerPallet:
        return controller.currentPalletSkuCount == 0
            ? "Step 2: Scan First SKU & Input Quantity"
            : "Step 2: Scan Additional SKU & Input Quantity";
      case ScanningStep.scanBoxLabel:
        return "Step 3: Scan Box Label (Non-Serialized)";
      case ScanningStep.scanSerialNumber:
        return "Step 3: Scan Serial Number (Serialized)";
      case ScanningStep.save:
        return "Step 4: Save SKU Data";
      case ScanningStep.addMoreSku:
        return "Add More SKUs or Finalize Pallet";
      case ScanningStep.autoUpload:
        return "Auto Upload to WMS";
      case ScanningStep.end:
        return "Scanning Complete";
      default:
        return "Scanning";
    }
  }

  String _getStepDescription() {
    switch (controller.currentStep) {
      case ScanningStep.scanPalletId:
        return "Scan the pallet ID barcode";
      case ScanningStep.scanSkuPerPallet:
        return controller.currentPalletSkuCount == 0
            ? "Scan first SKU barcode and input quantity"
            : "Scan additional SKU barcode and input quantity (${controller.currentPalletSkuCount} SKUs already added)";
      case ScanningStep.scanBoxLabel:
        return "Scan box label (For non-serialized items/rework)";
      case ScanningStep.scanSerialNumber:
        return "Scan the serial number (For serialized items)";
      case ScanningStep.save:
        return "Review and save the current SKU data";
      case ScanningStep.addMoreSku:
        return "Choose to add more SKUs to this pallet or finalize";
      case ScanningStep.autoUpload:
        return "Uploading data to WMS system...";
      case ScanningStep.end:
        return "All items have been processed";
      default:
        return "";
    }
  }
}
