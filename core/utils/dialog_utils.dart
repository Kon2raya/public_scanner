import 'package:aai_scanner_epson/core/config/theme/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:aai_scanner_epson/core/widgets/app_button.dart';

class DialogUtils {
  static Future<bool?> showCustomDialog({
    required BuildContext context,
    required String message,
    String title = 'Notice',
    bool success = false,
    bool warning = false,
    List<DialogAction>? actions,
    IconData? icon,
  }) {
    final Color headerColor = success
        ? AppColors.successGreen
        : warning
        ? AppColors.warningOrange
        : AppColors.primaryRed;

    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        title: Row(
          children: [
            if (icon != null) Icon(icon, color: headerColor),
            if (icon != null) const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: headerColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: actions != null && actions.isNotEmpty
            ? actions
                  .map(
                    (action) => AppButton(
                      label: action.label,
                      onPressed: () {
                        Navigator.of(context).pop(action.returnValue);
                      },
                      backgroundColor: action.color ?? AppColors.successGreen,
                    ),
                  )
                  .toList()
            : [
                AppButton(
                  label: "OK",
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
      ),
    );
  }
}

class DialogAction {
  final String label;
  final bool returnValue;
  final Color? color;

  DialogAction({required this.label, required this.returnValue, this.color});
}
