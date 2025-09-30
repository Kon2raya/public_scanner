// lib/features/inbound/widgets/receiving_items_widget.dart
import 'package:aai_scanner_epson/features/scanning/presentations/screens/inbound/scanning_screen.dart';
import 'package:flutter/material.dart';
import 'package:aai_scanner_epson/core/config/theme/color_constant.dart';
import 'package:aai_scanner_epson/core/models/receiving_item.dart';
import 'package:aai_scanner_epson/core/widgets/app_button.dart';

class ReceivingItemsWidget extends StatelessWidget {
  final List<ReceivingItem> items;
  final bool isLoaded;
  final String? rcvNumber;
  final Function(List<Map<String, dynamic>>)? onItemsScanned; // New parameter

  const ReceivingItemsWidget({
    super.key,
    required this.items,
    required this.isLoaded,
    this.rcvNumber,
    this.onItemsScanned, // New parameter
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!isLoaded) {
          return SizedBox(
            height: constraints.maxHeight,
            child: Column(
              children: [
                const Expanded(
                  child: Center(
                    child: Text(
                      'Please retrieve receiving information first',
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

        if (items.isEmpty) {
          return SizedBox(
            height: constraints.maxHeight,
            child: Column(
              children: [
                const Expanded(
                  child: Center(
                    child: Text(
                      'No items available',
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
              Expanded(
                child: ListView.builder(
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
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(item.itemDescripion),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            item.invUom,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryRed,
                            ),
                          ),
                        ),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: item.isSerialized == 1
                                ? Colors.orange.withValues(alpha: 0.2)
                                : Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Icon(
                            item.isSerialized == 1
                                ? Icons.list_alt_sharp
                                : Icons.inventory,
                            color: item.isSerialized == 1
                                ? Colors.orange
                                : Colors.green,
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
                    '${items.length} items available for scanning',
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
              label: "Start Scanning Process",
              onPressed: isLoaded ? () => _navigateToScanning(context) : null,
              backgroundColor: AppColors.primaryRed,
              icon: Icons.qr_code_scanner,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToScanning(BuildContext context) {
    if (rcvNumber == null || rcvNumber!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receiving number is required for scanning'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanningScreen(
          rcvNumber: rcvNumber!,
          items: items,
          onScanComplete: (scannedData) {
            // New callback
            if (onItemsScanned != null) {
              onItemsScanned!(scannedData);
            }
          },
        ),
      ),
    );
  }
}
