// lib/features/palletizing/presentation/screens/palletizing_scanning_screen.dart
import 'package:flutter/material.dart';
import 'package:aai_scanner_epson/core/config/theme/color_constant.dart';
import 'package:aai_scanner_epson/core/widgets/app_scaffold.dart';
import 'package:aai_scanner_epson/core/widgets/app_button.dart';

class PalletizingScanningScreen extends StatefulWidget {
  final String palletId;
  final Function(List<Map<String, dynamic>>) onScanComplete;

  const PalletizingScanningScreen({
    super.key,
    required this.palletId,
    required this.onScanComplete,
  });

  @override
  State<PalletizingScanningScreen> createState() =>
      _PalletizingScanningScreenState();
}

class _PalletizingScanningScreenState extends State<PalletizingScanningScreen> {
  final TextEditingController itemCodeController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  final List<Map<String, dynamic>> scannedItems = [];
  bool isProcessing = false;

  @override
  void dispose() {
    itemCodeController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  void _addItem() {
    if (itemCodeController.text.isEmpty || quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter item code and quantity'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final quantity = int.tryParse(quantityController.text) ?? 0;
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quantity must be greater than 0'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newItem = {
      'itemCode': itemCodeController.text,
      'quantity': quantity,
      'scannedAt': DateTime.now().toIso8601String(),
    };

    setState(() {
      scannedItems.add(newItem);
    });

    itemCodeController.clear();
    quantityController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item added successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteItem(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Remove this item from the list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                scannedItems.removeAt(index);
              });
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

  void _saveAndReturn() {
    if (scannedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.onScanComplete(scannedItems);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Scan Items',
      body: Column(
        children: [
          // Header Card
          Card(
            color: Colors.blue.shade50,
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pallet ID',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.palletId,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Items Scanned: ${scannedItems.length}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          // Input Form
          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Add Item',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: itemCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Item Code',
                      hintText: 'Scan or enter item code',
                      prefixIcon: Icon(Icons.qr_code),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addItem(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      hintText: 'Enter quantity',
                      prefixIcon: Icon(Icons.numbers),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addItem(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: AppButton(
                      label: 'Add Item',
                      icon: Icons.add,
                      onPressed: _addItem,
                      backgroundColor: AppColors.primaryRed,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Items List
          Expanded(
            child: scannedItems.isEmpty
                ? const Center(
                    child: Text(
                      'No items added yet\nScan items to begin',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: scannedItems.length,
                    itemBuilder: (context, index) {
                      final item = scannedItems[index];
                      return Card(
                        color: Colors.grey.shade100,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryRed,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            item['itemCode'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Quantity: ${item['quantity']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteItem(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Save Button
          Container(
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
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: scannedItems.isEmpty ? null : _saveAndReturn,
                icon: const Icon(Icons.save),
                label: const Text('Save Items'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
