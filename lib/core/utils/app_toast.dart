import 'dart:math' as math;
import 'package:flutter/material.dart';

void showAdminToast(
  BuildContext context, {
  required String message,
  bool isSuccess = true,
}) {
  final screenWidth = MediaQuery.of(context).size.width;
  const snackBarWidth = 320.0;
  const rightMargin = 24.0;
  final leftMargin = math.max(0.0, screenWidth - snackBarWidth - rightMargin);

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(bottom: 24, right: rightMargin, left: leftMargin > 0 ? leftMargin : 24),
      backgroundColor: isSuccess ? const Color(0xFF0F172A) : const Color(0xFFEF4444),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      content: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle_outline : Icons.error_outline,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}

class AppToast {
  AppToast._();

  static void showSuccess(BuildContext context, String message) {
    showAdminToast(context, message: message, isSuccess: true);
  }

  static void showError(BuildContext context, String message) {
    showAdminToast(context, message: message, isSuccess: false);
  }

  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    showAdminToast(context, message: message, isSuccess: !isError);
  }
}

