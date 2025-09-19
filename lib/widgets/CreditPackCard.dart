import 'package:flutter/material.dart';

import '../models/credit_pack.dart';

/// Reusable card widget for a [CreditPack].
class CreditPackCard extends StatelessWidget {
  final CreditPack creditPack;
  final bool isSelected;
  final VoidCallback onTap;

  const CreditPackCard({
    super.key,
    required this.creditPack,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final Color backgroundColor = isSelected
        ? colorScheme.primary.withOpacity(0.08)
        : Theme.of(context).colorScheme.surface; // Changed for unselected
    final BoxBorder? border = isSelected
        ? Border.all(color: colorScheme.primary, width: 1.5)
        : Border.all(color: Colors.transparent, width: 0); // Changed for unselected

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: border,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${creditPack.creditAmount}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Credits',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
            ),
            const Spacer(),
            Text(
              creditPack.priceLabel,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}