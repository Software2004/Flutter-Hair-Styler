/// Data model representing a one-time purchasable credit pack.
class CreditPack {
  /// Unique product identifier used for purchase flow and selection.
  final String id;

  /// Number of credits included in this pack.
  final int creditAmount;

  /// Price label for display, e.g., "\$2.99".
  final String priceLabel;

  const CreditPack({
    required this.id,
    required this.creditAmount,
    required this.priceLabel,
  });
}