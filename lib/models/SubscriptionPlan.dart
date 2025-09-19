/// Data model representing a subscription plan option in the UI.
class SubscriptionPlan {
  /// Unique product identifier used for purchase flow and selection.
  final String id;

  /// Display title, e.g., "Standard" or "Pro".
  final String title;

  /// Monthly credits included with the plan.
  final int creditsPerMonth;

  /// Price string for display, e.g., "\$4.99/mo".
  final String priceLabel;

  /// Whether this plan should show a POPULAR badge.
  final bool isPopular;

  /// Bullet list of feature strings shown beneath the title/price.
  final List<String> features;

  const SubscriptionPlan({
    required this.id,
    required this.title,
    required this.creditsPerMonth,
    required this.priceLabel,
    required this.isPopular,
    required this.features,
  });
}