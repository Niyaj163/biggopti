import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_config.dart';
import '../core/services/bdapps_service.dart';

class SubscriptionState {
  final bool isSubscribed;
  final String? phoneNumber;
  final bool isLoading;
  final String? errorMessage;
  final String? referenceNo;

  const SubscriptionState({
    this.isSubscribed = false,
    this.phoneNumber,
    this.isLoading = false,
    this.errorMessage,
    this.referenceNo,
  });

  SubscriptionState copyWith({
    bool? isSubscribed,
    String? phoneNumber,
    bool? isLoading,
    String? errorMessage,
    String? referenceNo,
  }) {
    return SubscriptionState(
      isSubscribed: isSubscribed ?? this.isSubscribed,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      referenceNo: referenceNo ?? this.referenceNo,
    );
  }
}

final bdappsServiceProvider = Provider<BdappsService>((ref) {
  if (AppConfig.useMockBdapps) {
    return BdappsServiceMock();
  }
  return BdappsServiceReal();
});

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  final bdappsService = ref.watch(bdappsServiceProvider);
  return SubscriptionNotifier(bdappsService);
});

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final BdappsService _service;
  static const String _phoneKey = 'bdapps_subscribed_phone';
  static const String _statusKey = 'bdapps_subscribed_status';

  SubscriptionNotifier(this._service) : super(const SubscriptionState()) {
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPhone = prefs.getString(_phoneKey);
      final isSub = prefs.getBool(_statusKey) ?? false;
      if (savedPhone != null && savedPhone.isNotEmpty) {
        state = state.copyWith(isSubscribed: isSub, phoneNumber: savedPhone);
      }
    } catch (_) {}
  }

  Future<bool> sendOtp(String msisdn) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await _service.sendOtp(msisdn);
      final statusCode = res['statusCode'] as String?;
      final refNo = res['referenceNo'] as String?;

      if (statusCode == 'S1000' && refNo != null) {
        state = state.copyWith(
          isLoading: false,
          phoneNumber: msisdn,
          referenceNo: refNo,
        );
        return true;
      } else if (statusCode == 'E1351') {
        // Already registered
        await _saveSubscription(msisdn, true);
        state = state.copyWith(
          isLoading: false,
          isSubscribed: true,
          phoneNumber: msisdn,
        );
        return true;
      } else {
        final detail = res['statusDetail'] as String? ?? 'OTP পাঠানো সম্ভব হয়নি';
        state = state.copyWith(isLoading: false, errorMessage: detail);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> verifyOtp(String otpCode) async {
    final refNo = state.referenceNo ?? 'REF_DEFAULT';
    final phone = state.phoneNumber ?? '';
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final success = await _service.verifyOtp(refNo, otpCode);
      if (success) {
        await _saveSubscription(phone, true);
        state = state.copyWith(isLoading: false, isSubscribed: true);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'ভুল OTP কোড। অনুগ্রহ করে সঠিক কোড দিন।',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> unsubscribe() async {
    final phone = state.phoneNumber;
    if (phone == null || phone.isEmpty) return false;

    state = state.copyWith(isLoading: true);
    try {
      final success = await _service.unsubscribe(phone);
      if (success) {
        await _saveSubscription(phone, false);
        state = const SubscriptionState();
        return true;
      }
    } catch (e) {
      debugPrint('[SubscriptionNotifier] Unsubscribe error: $e');
    }
    state = state.copyWith(isLoading: false);
    return false;
  }

  Future<void> _saveSubscription(String phone, bool isSubscribed) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_phoneKey, phone);
      await prefs.setBool(_statusKey, isSubscribed);
    } catch (_) {}
  }
}
