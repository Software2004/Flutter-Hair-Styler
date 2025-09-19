import 'package:flutter/material.dart';

import '../models/SubscriptionPlan.dart';
import '../models/credit_pack.dart';
import '../widgets/CreditPackCard.dart';
import '../widgets/PlanCard.dart';
import '../widgets/primary_button.dart';

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
    // Stub: integrate with in_app_purchase here.
    // For now, just log the selected product id to console.
    debugPrint('Proceed to purchase: $_selectedProductId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade Plan'),surfaceTintColor: Colors.transparent,),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCurrentPlanCard(context),
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
        child: PrimaryButton(
          label: _selectedProductId == 'plan_pro'
              ? 'Upgrade to Pro'
              : 'Continue',
          onPressed: () {
            _selectedProductId != null ? _handleUpgrade : null;
          },
        ),
      ),
    );
  }

  Widget _buildCurrentPlanCard(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current Plan', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentTierLabel,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              Text(
                '$_currentCredits Credits',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
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
                final double fraction = _monthlyCreditsCap == 0
                    ? 0
                    : (_currentCredits / _monthlyCreditsCap).clamp(0.0, 1.0);
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
            'You have $_currentCredits of $_monthlyCreditsCap credits remaining this month.\nSign up for unlimited access!',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionTiers(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subscription Tiers',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Column(
          children: _plans
              .map(
                (plan) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Credit Packs',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'One-time purchase for extra styles.',
          style: Theme.of(context).textTheme.bodyMedium,
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
