import 'package:flutter/material.dart';
import 'package:flutter_hair_styler/theme/app_styles.dart';

class OutlinedPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool expanded;
  final IconData? icon;

  const OutlinedPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expanded = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final Widget child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22),
              const SizedBox(width: 10),
              Text(label),
            ],
          );

    final button = OutlinedButton(
      onPressed: onPressed,
      style: AppStyles.outlinedButton(context),
      child: child,
    );

    if (!expanded) return button;
    return SizedBox(width: double.infinity, height: 58, child: button);
  }
}


