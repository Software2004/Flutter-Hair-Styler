import 'package:flutter/material.dart';
import 'package:flutter_hair_styler/theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool expanded;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expanded = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white))
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22),
              const SizedBox(width: 10),
              Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white)),
            ],
          );

    final button = ElevatedButton(onPressed: onPressed, child: child);
    if (!expanded) return button;
    return SizedBox(width: double.infinity, height: 52, child: button);
  }
}
