import 'package:flutter/material.dart';
import '../models/user_data.dart';
import '../widgets/credits_badge.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class HomeScreenHeader extends StatelessWidget {
  const HomeScreenHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<UserProvider?>()?.plan;
    final isFree = plan == SubscriptionPlanType.free;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: ClipRRect(
              child: Image.asset('assets/images/logo.png'),
            ),
          ),
          const SizedBox(width: 10),
          Text('AI Hair Styler', style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          if (isFree)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Free', style: Theme.of(context).textTheme.labelSmall),
            ),
          const CreditsBadge(),
        ],
      ),
    );
  }
}


