import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_config.dart';
import '../core/services/bdapps_service.dart';
import '../core/services/supabase_service.dart';

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

      if ((statusCode == 'S1000' || res['success'] == true) && refNo != null && refNo.isNotEmpty) {
        state = state.copyWith(
          isLoading: false,
          isSubscribed: false,
          phoneNumber: msisdn,
          referenceNo: refNo,
        );
        return true;
      } else if (statusCode == 'E1351') {
        // Number is already an active paying subscriber on BDapps!
        state = state.copyWith(
          isLoading: false,
          isSubscribed: false,
          errorMessage: 'ALREADY_SUBSCRIBED',
        );
        return false;
      } else {
        final detail = res['statusDetail'] as String? ?? 'OTP পাঠানো সম্ভব হয়নি';
        state = state.copyWith(isLoading: false, isSubscribed: false, errorMessage: detail);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> checkSubscriberLogin(String msisdn) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final isRegistered = await _service.checkSubscriptionStatus(msisdn);
      if (isRegistered) {
        // Confirmed: subscriber is active and registered on BDapps!
        await _saveSubscription(msisdn, true);
        await SupabaseService().upsertSubscriber(msisdn, status: 'ACTIVE');
        state = state.copyWith(
          isLoading: false,
          isSubscribed: true,
          phoneNumber: msisdn,
        );
        return true;
      } else {
        // NOT SUBSCRIBED: Access denied!
        state = state.copyWith(
          isLoading: false,
          isSubscribed: false,
          errorMessage:
              'এই নম্বরটি এখনো সাবস্ক্রাইব করা নেই! অ্যাপটি ব্যবহার করতে অনুগ্রহ করে প্রথমে "সাবস্ক্রাইব করুন" অপশন থেকে সাবস্ক্রিপশন সম্পন্ন করুন।',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSubscribed: false,
        errorMessage: 'যাচাই করতে সমস্যা হয়েছে। ইন্টারনেট কানেকশন চেক করে আবার চেষ্টা করুন।',
      );
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
        await SupabaseService().upsertSubscriber(phone, status: 'ACTIVE');
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

  Future<bool> unsubscribe({String? phoneOverride}) async {
    final phone = phoneOverride ?? state.phoneNumber;
    if (phone == null || phone.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'সাবস্ক্রিপশন বাতিল করতে মোবাইল নম্বর প্রয়োজন।',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final remoteUnsubscribed = await _service.unsubscribe(phone);
      if (!remoteUnsubscribed) {
        state = state.copyWith(
          isLoading: false,
          errorMessage:
              'বিডিঅ্যাপস আনসাবস্ক্রিপশন নিশ্চিত করেনি। অনুগ্রহ করে আবার চেষ্টা করুন অথবা STOP biggopti পাঠান।',
        );
        return false;
      }

      await SupabaseService().updateSubscriberStatus(phone, 'UNREGISTERED');
      await _clearSubscription();
      state = const SubscriptionState(
        isSubscribed: false,
        phoneNumber: null,
        isLoading: false,
      );
      return true;
    } catch (e) {
      debugPrint('[SubscriptionNotifier] Remote unsubscribe error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'আনসাবস্ক্রাইব করতে সমস্যা হয়েছে। ইন্টারনেট কানেকশন চেক করে আবার চেষ্টা করুন।',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _clearSubscription();
    state = const SubscriptionState(
      isSubscribed: false,
      phoneNumber: null,
      isLoading: false,
    );
  }

  Future<void> _clearSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_phoneKey);
      await prefs.remove(_statusKey);
      await prefs.setBool(_statusKey, false);
    } catch (_) {}
  }

  Future<void> _saveSubscription(String phone, bool isSubscribed) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_phoneKey, phone);
      await prefs.setBool(_statusKey, isSubscribed);
    } catch (_) {}
  }
}
