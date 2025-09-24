import 'package:flutter/foundation.dart';

enum SubscriptionPlanType { free, standard, pro }

enum SubscriptionStatus { active, expired }

class SubscriptionInfo {
  final SubscriptionPlanType plan;
  final DateTime? purchaseDate;
  final SubscriptionStatus status;

  const SubscriptionInfo({
    required this.plan,
    required this.purchaseDate,
    required this.status,
  });

  factory SubscriptionInfo.initial() => SubscriptionInfo(
        plan: SubscriptionPlanType.free,
        purchaseDate: null,
        status: SubscriptionStatus.active,
      );

  Map<String, dynamic> toJson() => {
        'plan': describeEnum(plan),
        'purchaseDate': purchaseDate?.toUtc().toIso8601String(),
        'status': describeEnum(status),
      };

  factory SubscriptionInfo.fromJson(Map<dynamic, dynamic> json) {
    final String planStr = (json['plan'] as String?) ?? 'free';
    final String statusStr = (json['status'] as String?) ?? 'active';
    return SubscriptionInfo(
      plan: SubscriptionPlanType.values.firstWhere(
        (e) => describeEnum(e) == planStr,
        orElse: () => SubscriptionPlanType.free,
      ),
      purchaseDate: (json['purchaseDate'] as String?) != null
          ? DateTime.tryParse(json['purchaseDate'] as String)
          : null,
      status: SubscriptionStatus.values.firstWhere(
        (e) => describeEnum(e) == statusStr,
        orElse: () => SubscriptionStatus.active,
      ),
    );
  }
}

class CreditsInfo {
  final int remaining;
  final DateTime? lastUpdated;

  const CreditsInfo({required this.remaining, required this.lastUpdated});

  factory CreditsInfo.initial() => const CreditsInfo(remaining: 2, lastUpdated: null);

  Map<String, dynamic> toJson() => {
        'remaining': remaining,
        'lastUpdated': lastUpdated?.toUtc().toIso8601String(),
      };

  factory CreditsInfo.fromJson(Map<dynamic, dynamic> json) => CreditsInfo(
        remaining: (json['remaining'] as num?)?.toInt() ?? 0,
        lastUpdated: (json['lastUpdated'] as String?) != null
            ? DateTime.tryParse(json['lastUpdated'] as String)
            : null,
      );
}

class UserDataModel {
  final String uid;
  final String? deviceId;
  final SubscriptionInfo subscription;
  final CreditsInfo credits;

  const UserDataModel({
    required this.uid,
    this.deviceId,
    required this.subscription,
    required this.credits,
  });

  factory UserDataModel.initial(String uid, {String? deviceId}) => UserDataModel(
        uid: uid,
        deviceId: deviceId,
        subscription: SubscriptionInfo.initial(),
        credits: CreditsInfo.initial(),
      );

  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
        'subscription': subscription.toJson(),
        'credits': credits.toJson(),
      };

  factory UserDataModel.fromJson(String uid, Map<dynamic, dynamic> json) => UserDataModel(
        uid: uid,
        deviceId: json['deviceId'] as String?,
        subscription: SubscriptionInfo.fromJson((json['subscription'] as Map?)?.cast<dynamic, dynamic>() ?? {}),
        credits: CreditsInfo.fromJson((json['credits'] as Map?)?.cast<dynamic, dynamic>() ?? {}),
      );
}


