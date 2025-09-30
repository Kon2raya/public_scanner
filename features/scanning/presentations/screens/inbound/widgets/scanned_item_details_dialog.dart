// lib/features/inbound/widgets/scanned_item_details_dialog.dart
import 'package:flutter/material.dart';
import 'package:aai_scanner_epson/core/config/theme/color_constant.dart';
import 'package:aai_scanner_epson/core/widgets/app_button.dart';

class ScannedItemDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> item;
  final int itemNumber;
  final String? rcvNumber; // Add this parameter
  final String? palletId; // Add this parameter

  const ScannedItemDetailsDialog({
    super.key,
    required this.item,
    required this.itemNumber,
    required this.rcvNumber, // Add this parameter
    required this.palletId, // Add this parameter
  });

  @override
  Widget build(BuildContext context) {
    final bool isSerialized = item['isSerialized'] ?? false;
    final List<String>? serialNumbers = item['serialNumbers']?.cast<String>();
    final DateTime timestamp = DateTime.parse(
      item['timestamp'] ?? DateTime.now().toIso8601String(),
    );

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.primaryRed,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSerialized ? Icons.list_alt_sharp : Icons.inventory,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Scanned Item #$itemNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information
                    _buildSectionTitle("Basic Information"),
                    _buildInfoCard([
                      _buildInfoRow("RCV Number", rcvNumber ?? 'N/A'),
                      _buildInfoRow("Pallet ID", palletId ?? 'N/A'),
                      _buildInfoRow("SKU", item['sku'] ?? 'N/A'),
                      _buildInfoRow(
                        "Quantity",
                        item['quantity']?.toString() ?? 'N/A',
                      ),
                      _buildInfoRow(
                        "Item Type",
                        isSerialized ? "Serialized" : "Non-Serialized",
                      ),
                    ]),

                    const SizedBox(height: 16),

                    // Conditional Information
                    if (isSerialized &&
                        serialNumbers != null &&
                        serialNumbers.isNotEmpty) ...[
                      _buildSectionTitle(
                        "Serial Numbers (${serialNumbers.length})",
                      ),
                      _buildSerialNumbersCard(serialNumbers),
                    ] else if (!isSerialized) ...[
                      _buildSectionTitle("Rework Information"),
                      _buildInfoCard([
                        _buildInfoRow("Box Label", item['boxLabel'] ?? 'N/A'),
                      ]),
                    ],

                    const SizedBox(height: 16),

                    // Timestamp
                    _buildSectionTitle("Scan Information"),
                    _buildInfoCard([
                      _buildInfoRow(
                        "Scanned At",
                        _formatFullTimestamp(timestamp),
                      ),
                    ]),
                  ],
                ),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: AppButton(
                        label: "Close",
                        onPressed: () => Navigator.pop(context),
                        backgroundColor: AppColors.backgroundGrey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: AppButton(
                        label: "Export",
                        onPressed: () => _exportDetails(),
                        backgroundColor: AppColors.primaryRed,
                        icon: Icons.file_download,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryRed,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      color: Colors.grey.shade100,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildSerialNumbersCard(List<String> serialNumbers) {
    return Card(
      color: Colors.grey.shade100,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: serialNumbers.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed,
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatFullTimestamp(DateTime timestamp) {
    return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }

  void _exportDetails() {
    // Implement export functionality here
    // For now, just show a message
    // print("Export functionality not implemented yet");
  }
}
