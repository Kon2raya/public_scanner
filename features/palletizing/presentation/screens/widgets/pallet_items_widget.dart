// lib/features/palletizing/presentation/screens/widgets/pallet_items_widget.dart
import 'package:aai_scanner_epson/core/config/theme/color_constant.dart';
import 'package:aai_scanner_epson/core/models/pallet.dart';
import 'package:aai_scanner_epson/core/widgets/app_button.dart';
import 'package:aai_scanner_epson/features/palletizing/presentation/screens/palltizing_scanning_screen.dart';
import 'package:flutter/material.dart';

class PalletItemsWidget extends StatelessWidget {
  final List<PalletItem> items;
  final bool isLoaded;
  final String? palletId;
  final void Function(List<Map<String, dynamic>>) onItemsScanned;
  final VoidCallback onCompletePallet;
  final void Function(int) onDeleteItem;

  const PalletItemsWidget({
    super.key,
    required this.items,
    required this.isLoaded,
    required this.palletId,
    required this.onItemsScanned,
    required this.onCompletePallet,
    required this.onDeleteItem,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!isLoaded || palletId == null) {
          return SizedBox(
            height: constraints.maxHeight,
            child: Column(
              children: [
                const Expanded(
                  child: Center(
                    child: Text(
                      'Please create a pallet first',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                _buildScanButton(context),
              ],
            ),
          );
        }

        return SizedBox(
          height: constraints.maxHeight,
          child: Column(
            children: [
              if (items.isNotEmpty) _buildSummaryCard(),
              Expanded(
                child: items.isEmpty
                    ? const Center(
                        child: Text(
                          'No items added yet\nStart scanning to add items',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Card(
                            color: Colors.grey.shade100,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: ListTile(
                              title: Text(
                                item.itemCode,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (item.description != null)
                                    Text(item.description!),
                                  Text('Quantity: ${item.quantity}'),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    _showDeleteDialog(context, index),
                              ),
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryRed.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Icon(
                                  Icons.inventory,
                                  color: AppColors.primaryRed,
                                  size: 20,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              _buildScanButton(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard() {
    final totalQty = items.fold<int>(0, (sum, item) => sum + item.quantity);

    return Card(
      color: Colors.blue.shade50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Text(
                  'Total Items',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  '${items.length}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const Text(
                  'Total Quantity',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalQty',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (items.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${items.length} items in this pallet',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            height: 48,
            child: AppButton(
              label: "Start Scanning Items",
              onPressed: isLoaded ? () => _navigateToScanning(context) : null,
              backgroundColor: AppColors.primaryRed,
              icon: Icons.qr_code_scanner,
            ),
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onCompletePallet,
                icon: const Icon(Icons.check_circle),
                label: const Text('Complete Pallet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Remove this item from pallet?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDeleteItem(index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _navigateToScanning(BuildContext context) {
    if (palletId == null || palletId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pallet ID is required for scanning'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PalletizingScanningScreen(
          palletId: palletId!,
          onScanComplete: (scannedData) {
            onItemsScanned(scannedData);
          },
        ),
      ),
    );
  }
}
