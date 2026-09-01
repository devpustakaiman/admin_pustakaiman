import 'package:flutter/material.dart';

class AppToast {
  AppToast._();

  static void showSuccess(BuildContext context, String message) {
    show(context, message: message, isError: false);
  }

  static void showError(BuildContext context, String message) {
    show(context, message: message, isError: true);
  }

  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    const rightMargin = 24.0;
    const snackBarWidth = 350.0;
    final leftMargin = (screenWidth - snackBarWidth - rightMargin).clamp(0.0, double.infinity);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: EdgeInsets.only(
          bottom: 24,
          right: rightMargin,
          left: leftMargin > 0 ? leftMargin : 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
      ),
    );
  }
}
