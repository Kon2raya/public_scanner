// lib/features/inbound/widgets/scanning_step_widgets.dart
import 'package:aai_scanner_epson/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:aai_scanner_epson/core/config/theme/color_constant.dart';
import 'package:aai_scanner_epson/core/models/receiving_item.dart';
import '../controllers/scanning_controller.dart';
import 'manual_input_widget.dart';
import 'data_card_widget.dart';

class ScanningStepWidgets extends StatelessWidget {
  final ScanningController controller;
  final TextEditingController manualInputCtrl;
  final String rcvNumber;
  final List<ReceivingItem> items;
  final VoidCallback onScanPressed;
  final Function(String) onManualInput; // Make sure this is Function(String)

  const ScanningStepWidgets({
    super.key,
    required this.controller,
    required this.manualInputCtrl,
    required this.rcvNumber,
    required this.items,
    required this.onScanPressed,
    required this.onManualInput,
  });

  @override
  Widget build(BuildContext context) {
    switch (controller.currentStep) {
      case ScanningStep.scanPalletId:
        return _buildScanPalletWidget();
      case ScanningStep.scanSkuPerPallet:
        return _buildScanSkuWidget();
      case ScanningStep.scanBoxLabel:
        return _buildScanBoxWidget();
      case ScanningStep.scanSerialNumber:
        return _buildScanSerialWidget();
      case ScanningStep.save:
        return _buildSaveWidget();
      case ScanningStep.addMoreSku: // New case
        return _buildAddMoreSkuWidget();
      case ScanningStep.autoUpload:
        return _buildUploadWidget();
      case ScanningStep.end:
        return _buildEndWidget();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAddMoreSkuWidget() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add_box, size: 64, color: AppColors.primaryRed),
          const SizedBox(height: 16),

          // Current pallet summary
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pallet: ${controller.currentPalletId ?? 'N/A'}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryRed,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("SKUs Added: ${controller.currentPalletSkuCount}"),
                  const SizedBox(height: 12),
                  const Text(
                    "Items in this pallet:",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  ...controller.currentPalletItems.asMap().entries.map((entry) {
                    final item = entry.value;
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: item['isSerialized']
                                  ? Colors.orange
                                  : Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                "${entry.key + 1}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "SKU: ${item['sku']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Qty: ${item['quantity']} • ${item['isSerialized'] ? 'Serialized' : 'Non-Serialized'}",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Action buttons
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 48,
                child: AppButton(
                  label: "Add More SKU to This Pallet",
                  onPressed: () => controller.addMoreSkuToPallet(),
                  // onPressed: () async {
                  //   await controller.autoUploadToWMS();
                  //   controller.addMoreSkuToPallet();
                  // },
                  backgroundColor: AppColors.primaryRed,
                  icon: Icons.add,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: AppButton(
                  label:
                      "Finalize Pallet (${controller.currentPalletSkuCount} SKUs)",
                  onPressed: () async {
                    await controller.finalizePallet();
                    controller.endScanning();
                  },
                  backgroundColor: Colors.green,
                  icon: Icons.check_circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // In your scanning_step_widget.dart, make sure all widgets have proper constraints:

  Widget _buildScanPalletWidget() {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inventory, size: 64, color: AppColors.primaryRed),
          const SizedBox(height: 16),
          const Text(
            "Scan or enter pallet ID",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          if (controller.currentPalletId != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Current Pallet ID:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.currentPalletId!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          ManualInputWidget(
            controller: manualInputCtrl,
            hint: "Enter Pallet ID",
            onSubmit: onManualInput,
            readOnly: true,
          ),
        ],
      ),
    );
  }

  // Apply mainAxisSize: MainAxisSize.min to all Column widgets in your step widgets

  Widget _buildScanSkuWidget() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.qr_code, size: 64, color: AppColors.primaryRed),
          const SizedBox(height: 16),
          Text(
            controller.currentPalletSkuCount == 0
                ? "Scan or enter first SKU"
                : "Scan or enter additional SKU (${controller.currentPalletSkuCount} added)",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Show current pallet info
          if (controller.currentPalletId != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: AppColors.primaryRed.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory, color: AppColors.primaryRed),
                  const SizedBox(width: 8),
                  Text("Pallet: ${controller.currentPalletId}"),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (controller.scannedSku != null) ...[
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "SKU: ${controller.scannedSku!}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text("Quantity: ${controller.scannedQuantity ?? 0}"),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: controller.isCurrentItemSerialized
                            ? Colors.orange.withValues(alpha: 0.2)
                            : Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            controller.isCurrentItemSerialized
                                ? Icons.list_alt_sharp
                                : Icons.inventory,
                            size: 16,
                            color: controller.isCurrentItemSerialized
                                ? Colors.orange
                                : Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            controller.isCurrentItemSerialized
                                ? "Serialized"
                                : "Non-Serialized",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: controller.isCurrentItemSerialized
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          ManualInputWidget(
            controller: manualInputCtrl,
            hint: "Enter SKU",
            onSubmit: onManualInput,
            readOnly: false,
          ),
        ],
      ),
    );
  }

  Widget _buildScanBoxWidget() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.label, size: 64, color: AppColors.primaryRed),
          const SizedBox(height: 16),
          const Text(
            "Scan or enter box label",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            "For non-serialized items/rework",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          if (controller.scannedBoxLabel != null)
            DataCardWidget(
              title: "Box Label",
              content: controller.scannedBoxLabel!,
            ),
          const SizedBox(height: 16),
          ManualInputWidget(
            controller: manualInputCtrl,
            hint: "Enter Box Label",
            onSubmit: onManualInput,
            readOnly: false,
          ),
        ],
      ),
    );
  }

  // In scanning_step_widget.dart, update the serial scanning widget:

  Widget _buildScanSerialWidget() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.list_alt_sharp,
            size: 64,
            color: AppColors.primaryRed,
          ),
          const SizedBox(height: 16),

          // Progress indicator
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    "Serial Numbers Progress",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value:
                        controller.scannedQuantity != null &&
                            controller.scannedQuantity! > 0
                        ? controller.scannedSerialNumbers.length /
                              controller.scannedQuantity!
                        : 0.0,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryRed,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${controller.scannedSerialNumbers.length} of ${controller.scannedQuantity ?? 0} scanned",
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Display scanned serial numbers
          if (controller.scannedSerialNumbers.isNotEmpty) ...[
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Scanned Serial Numbers:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...controller.scannedSerialNumbers.asMap().entries.map((
                      entry,
                    ) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  "${entry.key + 1}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Input for next serial (only if not complete)
          if (!controller.allSerialsScanned) ...[
            Text(
              "Scan Serial ${controller.scannedSerialNumbers.length + 1} of ${controller.scannedQuantity}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryRed,
              ),
            ),
            const SizedBox(height: 16),
            ManualInputWidget(
              controller: manualInputCtrl,
              hint:
                  "Enter Serial Number ${controller.scannedSerialNumbers.length + 1}",
              onSubmit: onManualInput,
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.green),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "All serial numbers scanned successfully!",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSaveWidget() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.save, size: 64, color: AppColors.primaryRed),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Review Data:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildDataRow("RCV Number", rcvNumber),
                  _buildDataRow(
                    "Pallet ID",
                    controller.scannedPalletId ?? 'N/A',
                  ),
                  _buildDataRow("SKU", controller.scannedSku ?? 'N/A'),
                  _buildDataRow(
                    "Quantity",
                    controller.scannedQuantity?.toString() ?? 'N/A',
                  ),
                  _buildDataRow(
                    "Item Type",
                    controller.isCurrentItemSerialized
                        ? "Serialized"
                        : "Non-Serialized",
                  ),
                  if (controller.isCurrentItemSerialized) ...[
                    const SizedBox(height: 8),
                    const Text(
                      "Serial Numbers:",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    ...controller.scannedSerialNumbers.asMap().entries.map((
                      entry,
                    ) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 16, top: 2),
                        child: Text("${entry.key + 1}. ${entry.value}"),
                      );
                    }),
                  ] else
                    _buildDataRow(
                      "Box Label",
                      controller.scannedBoxLabel ?? 'N/A',
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadWidget() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: AppColors.primaryRed),
        SizedBox(height: 16),
        Text("Uploading to WMS..."),
      ],
    );
  }

  Widget _buildEndWidget() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            "Item Scanned Successfully!",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text("Total items processed: ${controller.scannedData.length}"),
          const SizedBox(height: 20),
          // Continue scanning button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: AppButton(
              label: "Continue",
              onPressed: () => controller.continueScanning(),
              backgroundColor: AppColors.primaryRed,
              icon: Icons.add,
            ),
          ),
          // ... rest of your summary display
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
