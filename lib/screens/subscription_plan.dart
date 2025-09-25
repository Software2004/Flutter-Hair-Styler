import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/SubscriptionPlan.dart';
import '../models/credit_pack.dart';
import '../models/user_data.dart';
import '../providers/user_provider.dart';
import '../widgets/CreditPackCard.dart';
import '../widgets/PlanCard.dart';
import '../widgets/primary_button.dart';
import 'login_screen.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Manage Subscription screen implementing selection logic and responsive layout.
class ManageSubscriptionScreen extends StatefulWidget {
  const ManageSubscriptionScreen({super.key});

  @override
  State<ManageSubscriptionScreen> createState() =>
      _ManageSubscriptionScreenState();
}

class _ManageSubscriptionScreenState extends State<ManageSubscriptionScreen> {
  /// Tracks the currently selected product id (plan or credit pack).
  String? _selectedProductId;

  // Sample user data for header display (could be injected/loaded in real app)
  final String _currentTierLabel = 'Free User';
  final int _currentCredits = 178;
  final int _monthlyCreditsCap = 2;

  late final List<SubscriptionPlan> _plans = <SubscriptionPlan>[
    SubscriptionPlan(
      id: 'plan_standard',
      title: 'Standard',
      creditsPerMonth: 10,
      priceLabel: '\$4.99/mo',
      isPopular: false,
      features: const <String>['No watermark', 'Ad-free experience'],
    ),
    SubscriptionPlan(
      id: 'plan_pro',
      title: 'Pro',
      creditsPerMonth: 25,
      priceLabel: '\$9.99/mo',
      isPopular: true,
      features: const <String>[
        'No watermark',
        'Ad-free experience',
        'Early access to new styles',
      ],
    ),
  ];

  late final List<CreditPack> _creditPacks = <CreditPack>[
    const CreditPack(id: 'credits_10', creditAmount: 10, priceLabel: '\$2.99'),
    const CreditPack(id: 'credits_50', creditAmount: 50, priceLabel: '\$12.99'),
  ];

  void _handleSelect(String productId) {
    setState(() {
      _selectedProductId = productId;
    });
  }

  void _handleUpgrade() {
    if (_selectedProductId == null) {
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushNamed(context, LoginScreen.routeName).then((_) {
        if (mounted) setState(() {});
      }).catchError((e, s) {
        FirebaseCrashlytics.instance.recordError(e, s, reason: 'Navigate to login from subscription failed');
      });
      return;
    }
    // Stub purchase flow start
    try {
      debugPrint('Proceed to purchase: $_selectedProductId for user ${user.uid}');
      // TODO: Query products and start purchase using in_app_purchase
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'Start purchase flow failed');
    }
  }

  String _ctaLabel(BuildContext context) {
    final String? id = _selectedProductId;
    if (id == null) {
      return 'Select a plan or credits';
    }
    final plan = _plans.where((p) => p.id == id).cast<SubscriptionPlan?>().firstWhere((p) => p != null, orElse: () => null);
    if (plan != null) {
      return plan.id == 'plan_pro' ? 'Upgrade to Pro' : 'Upgrade to ${plan.title}';
    }
    final pack = _creditPacks.where((c) => c.id == id).cast<CreditPack?>().firstWhere((c) => c != null, orElse: () => null);
    if (pack != null) {
      return 'Buy ${pack.creditAmount} Credits';
    }
    return 'Continue';
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final plan = context.select<UserProvider, SubscriptionPlanType>((p) => p.plan);
    final remainingCredits = context.select<UserProvider, int>((p) => p.remainingCredits);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          plan == SubscriptionPlanType.pro ? 'Manage Plan' : 'Upgrade Plan',
          style: textTheme.titleMedium
        ),
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCurrentPlanCard(context, plan, remainingCredits),
              const SizedBox(height: 16),
              _buildSubscriptionTiers(context),
              const SizedBox(height: 16),
              _buildCreditPacks(context),
              const SizedBox(height: 88), // Spacer for bottom button
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: PrimaryButton(
            key: ValueKey<String>(_ctaLabel(context)),
            label: _ctaLabel(context),
            onPressed: (){
              _selectedProductId == null ? null : _handleUpgrade;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPlanCard(BuildContext context, SubscriptionPlanType planType, int remaining) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    String planLabel() {
      switch (planType) {
        case SubscriptionPlanType.free:
          return 'Free User';
        case SubscriptionPlanType.standard:
          return 'Standard';
        case SubscriptionPlanType.pro:
          return 'Pro';
      }
    }

    int monthlyCap() {
      switch (planType) {
        case SubscriptionPlanType.free:
          return 2;
        case SubscriptionPlanType.standard:
          return 10;
        case SubscriptionPlanType.pro:
          return 25;
      }
    }

    final int cap = monthlyCap();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent, width: 0),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Plan',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      planLabel(),
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w500, // Further reduced weight
                        fontSize: (textTheme.headlineSmall?.fontSize ?? 24) - 4,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              Text(
                '$remaining Credits',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500, // Further reduced weight
                  fontSize: (textTheme.titleMedium?.fontSize ?? 16) - 4,
                ),
              ),
            ],
          ),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.centerLeft,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double fraction = cap == 0
                    ? 0
                    : (remaining / cap).clamp(0.0, 1.0);
                return FractionallySizedBox(
                  widthFactor: fraction,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'You have $remaining of $cap credits remaining this month.\nSign up for unlimited access!',
            style: textTheme.bodySmall?.copyWith(
              fontSize: (textTheme.bodySmall?.fontSize ?? 12) - 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionTiers(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Subscription Tiers',
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Boost your creations with credit bundles.',
          style: textTheme.bodyMedium?.copyWith(
            fontSize: (textTheme.bodyMedium?.fontSize ?? 14) - 2,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: _plans
              .map(
                (plan) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: PlanCard(
                    plan: plan,
                    isSelected: _selectedProductId == plan.id,
                    onTap: () => _handleSelect(plan.id),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildCreditPacks(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Credit Packs',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500, // Further reduced weight
            fontSize: (textTheme.titleLarge?.fontSize ?? 22) - 4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'One-time purchase for extra styles.',
          style: textTheme.bodyMedium?.copyWith(
            fontSize: (textTheme.bodyMedium?.fontSize ?? 14) - 2,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _creditPacks.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final CreditPack pack = _creditPacks[index];
              return CreditPackCard(
                creditPack: pack,
                isSelected: _selectedProductId == pack.id,
                onTap: () => _handleSelect(pack.id),
              );
            },
          ),
        ),
      ],
    );
  }
}
