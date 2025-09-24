import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class CreditsBadge extends StatelessWidget {
  final int? credits;
  const CreditsBadge({super.key, this.credits});

  @override
  Widget build(BuildContext context) {
    final fromProvider = context.watch<UserProvider?>();
    final value = credits ?? (fromProvider?.remainingCredits ?? 0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars_rounded, size: 18, color: Colors.white),
          const SizedBox(width: 6),
          Text('$value', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}


