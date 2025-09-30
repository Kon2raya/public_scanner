// lib/features/inbound/widgets/manual_input_widget.dart
import 'package:flutter/material.dart';

class ManualInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Function(String)
  onSubmit; // Change from VoidCallback to Function(String)
  final bool readOnly; // Add this parameter

  const ManualInputWidget({
    super.key,
    required this.controller,
    required this.hint,
    required this.onSubmit,
    this.readOnly = true, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: TextField(
              controller: controller,
              readOnly: readOnly, // Add this line
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (value) =>
                  onSubmit(value), // Pass the value to onSubmit
            ),
          ),
        ),
        // const SizedBox(width: 8),
        // SizedBox(
        //   height: 48,
        //   child: AppButton(
        //     label: "Enter",
        //     onPressed: () =>
        //         onSubmit(controller.text), // ✅ Fixed: pass controller.text
        //     backgroundColor: AppColors.primaryRed,
        //     icon: Icons.keyboard,
        //   ),
        // ),
      ],
    );
  }
}
