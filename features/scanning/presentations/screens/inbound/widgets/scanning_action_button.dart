// lib/features/inbound/widgets/scanning_action_buttons.dart
import 'package:flutter/material.dart';
import 'package:aai_scanner_epson/core/config/theme/color_constant.dart';
import 'package:aai_scanner_epson/core/widgets/app_button.dart';
import '../controllers/scanning_controller.dart';

class ScanningActionButtons extends StatelessWidget {
  final ScanningController controller;
  final VoidCallback onScanPressed;
  final VoidCallback onBackPressed;
  final VoidCallback? onUploadComplete; // New callback

  const ScanningActionButtons({
    super.key,
    required this.controller,
    required this.onScanPressed,
    required this.onBackPressed,
    this.onUploadComplete, // New parameter
  });

  // Update the action buttons to handle the new save flow:
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(
        controller.currentStep == ScanningStep.addMoreSku ? 0 : 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (controller.currentStep != ScanningStep.autoUpload &&
              controller.currentStep != ScanningStep.end &&
              controller.currentStep != ScanningStep.addMoreSku)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: AppButton(
                      label: "Scan",
                      onPressed: onScanPressed,
                      backgroundColor: AppColors.primaryRed,
                      icon: Icons.qr_code_scanner,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (controller.currentStep == ScanningStep.save)
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: AppButton(
                        label: "Save SKU", // Updated label
                        // onPressed: () async {
                        //   await controller.autoUploadToWMS();
                        //   controller.saveCurrentSku(); // Updated method
                        // },
                        onPressed: () => controller.saveCurrentSku(),
                        backgroundColor: AppColors.primaryRed,
                        icon: Icons.save,
                      ),
                    ),
                  ),
                if (controller.currentStep != ScanningStep.save)
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: AppButton(
                        label: "Back",
                        onPressed: onBackPressed,
                        backgroundColor: AppColors.backgroundGrey,
                        foregroundColor: Colors.black87,
                        icon: Icons.arrow_back,
                      ),
                    ),
                  ),
              ],
            ),
          if (controller.currentStep == ScanningStep.end)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: AppButton(
                      label: "Upload to WMS",
                      onPressed: () async {
                        await controller.autoUploadToWMS();
                        if (onUploadComplete != null) {
                          onUploadComplete!();
                        }
                      },
                      backgroundColor: AppColors.primaryRed,
                      icon: Icons.cloud_upload,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: AppButton(
                      label: "Continue",
                      onPressed: () => controller.continueScanning(),
                      backgroundColor: Colors.green,
                      icon: Icons.add,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
