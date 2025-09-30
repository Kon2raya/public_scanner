// lib/features/inbound/widgets/scanned_items_widget.dart
import 'package:aai_scanner_epson/features/scanning/presentations/screens/inbound/widgets/scanned_item_details_dialog.dart';
import 'package:flutter/material.dart';
import 'package:aai_scanner_epson/core/config/theme/color_constant.dart';
import 'package:aai_scanner_epson/core/widgets/app_button.dart';

class ScannedItemsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> scannedItems;
  final VoidCallback onClearAll;
  final String? rcvNumber;

  const ScannedItemsWidget({
    super.key,
    required this.scannedItems,
    this.rcvNumber,
    required this.onClearAll,
  });
  @override
  Widget build(BuildContext context) {
    // AppLogger.info(scannedItems);
    if (scannedItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No pallets scanned yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Scan pallets from the Items tab to see them here',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header with count and clear button
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryRed.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: AppColors.primaryRed.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Scanned Pallets',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryRed,
                      ),
                    ),
                    Text(
                      '${scannedItems.length} pallets scanned',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              SizedBox(
                child: AppButton(
                  label: "Clear All",
                  onPressed: _showClearAllDialog(context),
                  backgroundColor: AppColors.primaryRed,
                  icon: Icons.clear_all,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 5),

        // Scanned pallets list
        Expanded(
          child: ListView.builder(
            itemCount: scannedItems.length,
            itemBuilder: (context, index) {
              final pallet = scannedItems[index];
              return _buildPalletTile(context, pallet, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPalletTile(
    BuildContext context,
    Map<String, dynamic> pallet,
    int index,
  ) {
    final String palletId = pallet['palletId'] ?? 'Unknown Pallet';
    final List<dynamic> items = pallet['items'] ?? [];
    final DateTime timestamp = DateTime.parse(
      pallet['timestamp'] ?? DateTime.now().toIso8601String(),
    );

    // Calculate totals
    int totalQuantity = 0;
    int serializedCount = 0;
    int nonSerializedCount = 0;

    for (var item in items) {
      totalQuantity += (item['quantity'] as int? ?? 0);
      if (item['isSerialized'] == true) {
        serializedCount++;
      } else {
        nonSerializedCount++;
      }
    }

    // Determine icon and color based on contents
    Color palletColor;
    IconData palletIcon;
    String contentType;

    if (serializedCount > 0 && nonSerializedCount > 0) {
      palletColor = Colors.purple;
      palletIcon = Icons.apps;
      contentType = "Mixed";
    } else if (serializedCount > 0) {
      palletColor = Colors.orange;
      palletIcon = Icons.list_alt_sharp;
      contentType = "Serialized";
    } else {
      palletColor = Colors.green;
      palletIcon = Icons.inventory;
      contentType = "Non-Serialized";
    }

    return Card(
      color: Colors.lightBlue.shade50,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: palletColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(palletIcon, color: palletColor, size: 20),
        ),
        title: Text(
          'Pallet: $palletId',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${items.length} SKUs • Total Qty: $totalQuantity'),
            Text('Type: $contentType'),
            if (serializedCount > 0 && nonSerializedCount > 0)
              Text(
                '$serializedCount Serialized • $nonSerializedCount Non-Serialized',
              ),
            Text(
              'Completed: ${_formatTimestamp(timestamp)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                '#${index + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryRed,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: () => _showPalletDetails(context, pallet, index + 1),
      ),
    );
  }

  void _showPalletDetails(
    BuildContext context,
    Map<String, dynamic> pallet,
    int palletNumber,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          _buildPalletDetailsDialog(context, pallet, palletNumber),
    );
  }

  Widget _buildPalletDetailsDialog(
    BuildContext context,
    Map<String, dynamic> pallet,
    int palletNumber,
  ) {
    final List<dynamic> items = pallet['items'] ?? [];

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
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
                  const Icon(Icons.inventory, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pallet #$palletNumber Details',
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
                    Text(
                      'Pallet ID: ${pallet['palletId'] ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Items in this Pallet (${items.length}):',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    ...items.asMap().entries.map((entry) {
                      final item = entry.value;
                      final bool isSerialized = item['isSerialized'] ?? false;

                      return Card(
                        color: Colors.grey.shade100,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          dense: true,
                          leading: Icon(
                            isSerialized
                                ? Icons.list_alt_sharp
                                : Icons.inventory,
                            color: isSerialized ? Colors.orange : Colors.green,
                          ),
                          title: Text(
                            'SKU: ${item['sku'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            'Qty: ${item['quantity'] ?? 0} • ${isSerialized ? 'Serialized' : 'Non-Serialized'}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _showItemDetails(
                              context,
                              item,
                              entry.key + 1,
                              pallet['palletId'],
                              rcvNumber,
                            );
                          },
                        ),
                      );
                    }),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showItemDetails(
    BuildContext context,
    Map<String, dynamic> item,
    int itemNumber,
    String palletId,
    String? rcvNo,
  ) {
    showDialog(
      context: context,
      builder: (context) => ScannedItemDetailsDialog(
        item: item,
        itemNumber: itemNumber,
        palletId: palletId,
        rcvNumber: rcvNo,
      ),
    );
  }

  VoidCallback _showClearAllDialog(BuildContext context) {
    return () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text("Clear All Pallets"),
            ],
          ),
          content: Text(
            "Are you sure you want to clear all ${scannedItems.length} scanned pallets? This action cannot be undone.",
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: AppButton(
                      label: "Cancel",
                      onPressed: () => Navigator.pop(context),
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: AppButton(
                      label: "Clear All",
                      onPressed: () {
                        onClearAll();
                        Navigator.pop(context);
                      },
                      backgroundColor: AppColors.primaryRed,
                      icon: Icons.delete,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    };
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')} ${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}
