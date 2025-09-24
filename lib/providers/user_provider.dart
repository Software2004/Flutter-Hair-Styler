import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/user_data.dart';
import '../services/user_paths.dart';

class UserProvider extends ChangeNotifier {
  UserDataModel? _data;
  StreamSubscription<DatabaseEvent>? _sub;
  StreamSubscription<User?>? _authSub;

  UserProvider() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) async {
      await _attachListener();
    });
    _attachListener();
  }

  UserDataModel? get data => _data;
  int get remainingCredits => _data?.credits.remaining ?? 0;
  SubscriptionPlanType get plan => _data?.subscription.plan ?? SubscriptionPlanType.free;

  Future<void> _attachListener() async {
    await _sub?.cancel();
    final uid = await UserPathsService.effectiveUserKey();
    _sub = UserPathsService.userRef(uid).onValue.listen((event) async {
      final snap = event.snapshot;
      if (!snap.exists) {
        // Initialize with defaults
        final deviceId = await UserPathsService.getAndroidDeviceId();
        final initial = UserDataModel.initial(uid, deviceId: deviceId);
        // Seed lastUpdated using server time
        final now = await _getServerNow();
        final seeded = UserDataModel(
          uid: initial.uid,
          deviceId: initial.deviceId,
          subscription: initial.subscription,
          credits: CreditsInfo(
            remaining: _monthlyAllowance(initial.subscription.plan),
            lastUpdated: now,
          ),
        );
        await UserPathsService.userRef(uid).set(seeded.toJson());
        _data = seeded;
        notifyListeners();
        return;
      }
      final val = snap.value as Map<dynamic, dynamic>;
      _data = UserDataModel.fromJson(uid, val);
      // Apply renewal based on server time to avoid device clock tampering
      await _applyMonthlyRenewalIfNeeded();
      notifyListeners();
    });
  }

  Future<bool> ensureCreditForGeneration() async {
    if (_data == null) return false;
    // Ensure renewal check before consuming
    await _applyMonthlyRenewalIfNeeded();
    if (_data!.credits.remaining <= 0) return false;
    // Optimistic local decrement
    _data = UserDataModel(
      uid: _data!.uid,
      deviceId: _data!.deviceId,
      subscription: _data!.subscription,
      credits: CreditsInfo(
        remaining: _data!.credits.remaining - 1,
        lastUpdated: DateTime.now().toUtc(),
      ),
    );
    notifyListeners();
    final uid = _data!.uid;
    // Server transaction to prevent race conditions
    try {
      await UserPathsService.creditsRemainingRef(uid).runTransaction((mutable) {
        final current = (mutable as num?)?.toInt() ?? 0;
        if (current <= 0) {
          return Transaction.abort();
        }
        return Transaction.success(current - 1);
      });
      return true;
    } catch (_) {
      // Rollback on failure by refreshing from server
      final snap = await UserPathsService.userRef(uid).get();
      if (snap.exists) {
        final val = snap.value as Map<dynamic, dynamic>;
        _data = UserDataModel.fromJson(uid, val);
        notifyListeners();
      }
      return false;
    }
  }

  Future<void> _applyMonthlyRenewalIfNeeded() async {
    if (_data == null) return;
    final now = await _getServerNow();
    final last = _data!.credits.lastUpdated;
    final allowance = _monthlyAllowance(_data!.subscription.plan);
    final shouldRenew = last == null || last.year != now.year || last.month != now.month;
    if (shouldRenew) {
      _data = UserDataModel(
        uid: _data!.uid,
        deviceId: _data!.deviceId,
        subscription: _data!.subscription,
        credits: CreditsInfo(remaining: allowance, lastUpdated: now),
      );
      notifyListeners();
      // Persist to server
      await UserPathsService.userRef(_data!.uid).update({
        'credits': {
          'remaining': allowance,
          'lastUpdated': now.toUtc().toIso8601String(),
        }
      });
    }
  }

  int _monthlyAllowance(SubscriptionPlanType plan) {
    switch (plan) {
      case SubscriptionPlanType.free:
        return 2;
      case SubscriptionPlanType.standard:
        return 10;
      case SubscriptionPlanType.pro:
        return 25;
    }
  }

  Future<DateTime> _getServerNow() async {
    try {
      final offsetSnap = await FirebaseDatabase.instance.ref('.info/serverTimeOffset').get();
      final offsetMs = (offsetSnap.value as num?)?.toInt() ?? 0;
      final nowMs = DateTime.now().millisecondsSinceEpoch + offsetMs;
      return DateTime.fromMillisecondsSinceEpoch(nowMs, isUtc: true);
    } catch (_) {
      // Fallback to device time if offset not available
      return DateTime.now().toUtc();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }
}


