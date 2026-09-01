import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';

class TriStateFilterButton extends StatelessWidget {
  final bool? value;
  final String label;
  final String? activeLabel;
  final String? inactiveLabel;
  final IconData icon;
  final ValueChanged<bool?> onChanged;

  const TriStateFilterButton({
    super.key,
    required this.value,
    required this.label,
    this.activeLabel,
    this.inactiveLabel,
    required this.icon,
    required this.onChanged,
  });

  void _cycleState() {
    if (value == null) {
      onChanged(true);
    } else if (value == true) {
      onChanged(false);
    } else {
      onChanged(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData stateIcon;
    Color iconColor;
    String displayText;

    if (value == true) {
      backgroundColor = const Color(0xFFE6F4EA); // Soft green/teal
      borderColor = const Color(0xFF34A853);
      textColor = const Color(0xFF137333);
      stateIcon = LucideIcons.check;
      iconColor = const Color(0xFF137333);
      displayText = activeLabel ?? label;
    } else if (value == false) {
      backgroundColor = const Color(0xFFFCE8E6); // Soft red
      borderColor = const Color(0xFFEA4335);
      textColor = const Color(0xFFC5221F);
      stateIcon = LucideIcons.x;
      iconColor = const Color(0xFFC5221F);
      displayText = inactiveLabel ?? 'Non-$label';
    } else {
      backgroundColor = Colors.white; // Neutral light gray/white
      borderColor = AppTheme.borderColor;
      textColor = AppTheme.textPrimary;
      stateIcon = icon;
      iconColor = AppTheme.textSecondary;
      displayText = label;
    }

    return InkWell(
      onTap: _cycleState,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(stateIcon, size: 16, color: iconColor),
            const SizedBox(width: 8),
            Text(
              displayText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
