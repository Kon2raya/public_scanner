// lib/features/inbound/widgets/scanning_dialogs.dart
import 'package:flutter/material.dart';
import 'package:aai_scanner_epson/core/config/theme/color_constant.dart';
import 'package:aai_scanner_epson/core/models/receiving_item.dart';
import 'package:aai_scanner_epson/core/widgets/app_button.dart';

class SkuNotFoundDialog extends StatelessWidget {
  final String sku;
  final List<ReceivingItem> availableItems;

  const SkuNotFoundDialog({
    super.key,
    required this.sku,
    required this.availableItems,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      title: const Row(
        children: [
          Icon(Icons.error, color: Colors.red),
          SizedBox(width: 8),
          Text("Not Found"),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("SKU '$sku' does not exist in this receiving."),
          const SizedBox(height: 16),
          const Text(
            "Available SKUs:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(5),
            ),
            child: ListView.builder(
              itemCount: availableItems.length,
              itemBuilder: (context, index) {
                final item = availableItems[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    item.itemCode,
                    style: const TextStyle(fontSize: 12),
                  ),
                  subtitle: Text(
                    item.itemDescripion,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
    );
  }
}

class QuantityInputDialog extends StatefulWidget {
  final String sku;
  final Function(int) onConfirm;

  const QuantityInputDialog({
    super.key,
    required this.sku,
    required this.onConfirm,
  });

  @override
  State<QuantityInputDialog> createState() => _QuantityInputDialogState();
}

class _QuantityInputDialogState extends State<QuantityInputDialog> {
  final quantityCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      title: const Text("Enter Quantity"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("SKU: ${widget.sku}"),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: TextField(
              controller: quantityCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Quantity per Pallet",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
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
                  backgroundColor: AppColors.backgroundGrey,
                  foregroundColor: const Color.fromARGB(221, 255, 255, 255),
                  icon: Icons.close,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 40,
                child: AppButton(
                  label: "Confirm",
                  onPressed: () {
                    final quantity = int.tryParse(quantityCtrl.text) ?? 0;
                    widget.onConfirm(quantity);
                    Navigator.pop(context);
                  },
                  backgroundColor: AppColors.primaryRed,
                  icon: Icons.check,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    quantityCtrl.dispose();
    super.dispose();
  }
}
