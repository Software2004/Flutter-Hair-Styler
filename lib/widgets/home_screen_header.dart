import 'package:flutter/material.dart';
import '../widgets/credits_badge.dart';

class HomeScreenHeader extends StatelessWidget {
  const HomeScreenHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: ClipRRect(
              child: Image.asset('assets/images/ic_launcher-playstore.png'),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'AI Hair Styler',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          const CreditsBadge(credits: 179),
        ],
      ),
    );
  }
}


