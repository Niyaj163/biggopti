import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

abstract class BdappsService {
  Future<bool> checkSubscriptionStatus(String msisdn);
  Future<Map<String, dynamic>> sendOtp(String msisdn);
  Future<bool> verifyOtp(String referenceNo, String otpCode);
  Future<bool> unsubscribe(String msisdn);
}

/// Mock Implementation for Local Testing & Pitch Demo Safety
class BdappsServiceMock implements BdappsService {
  @override
  Future<bool> checkSubscriptionStatus(String msisdn) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true; // Default subscribed for demo
  }

  @override
  Future<Map<String, dynamic>> sendOtp(String msisdn) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return {
      "statusCode": "S1000",
      "statusDetail": "OTP sent to $msisdn successfully.",
      "referenceNo": "REF_MOCK_998877",
    };
  }

  @override
  Future<bool> verifyOtp(String referenceNo, String otpCode) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return otpCode == "1234" || otpCode == "123456";
  }

  @override
  Future<bool> unsubscribe(String msisdn) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }
}

/// Live Real Implementation Calling cPanel PHP Gateway
class BdappsServiceReal implements BdappsService {
  final http.Client _client = http.Client();
  static const Map<String, String> _formHeaders = {
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  Map<String, dynamic>? _decodeJsonMap(String body) {
    final clean = body.replaceFirst('\uFEFF', '').trim();
    final decoded = jsonDecode(clean);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return null;
  }

  String _normalizeSubscriptionStatus(dynamic status) {
    final value = status?.toString();
    if (value == null) {
      return '';
    }
    return value.trim().replaceAll('.', '').toUpperCase();
  }

  Future<String?> _fetchSubscriptionStatus(String msisdn) async {
    final url = Uri.parse('${ApiConstants.bdappsBaseUrl}/check_subscription.php');
    final res = await _client.post(
      url,
      headers: _formHeaders,
      body: {'user_mobile': msisdn},
    );
    if (res.statusCode != 200) {
      return null;
    }

    final data = _decodeJsonMap(res.body);
    if (data == null) {
      return null;
    }

    return _normalizeSubscriptionStatus(data['subscriptionStatus']);
  }

  @override
  Future<bool> checkSubscriptionStatus(String msisdn) async {
    try {
      final status = await _fetchSubscriptionStatus(msisdn);
      if (status == 'REGISTERED') return true;

      final otpRes = await sendOtp(msisdn);
      if (otpRes['statusCode'] == 'E1351') {
        return true;
      }
    } catch (e) {
      debugPrint('[BdappsServiceReal] Check error: $e');
    }
    return false;
  }

  @override
  Future<Map<String, dynamic>> sendOtp(String msisdn) async {
    try {
      final url = Uri.parse('${ApiConstants.bdappsBaseUrl}/send_otp.php');
      final res = await _client.post(
        url,
        headers: _formHeaders,
        body: {'user_mobile': msisdn},
      );
      if (res.statusCode == 200) {
        final data = _decodeJsonMap(res.body);
        if (data != null) {
          return data;
        }
      }
    } catch (e) {
      debugPrint('[BdappsServiceReal] Send OTP error: $e');
    }
    return {
      "statusCode": "FAILED",
      "statusDetail": "নেটওয়ার্ক ত্রুটি। ইন্টারনেট সংযোগ যাচাই করুন।",
    };
  }

  @override
  Future<bool> verifyOtp(String referenceNo, String otpCode) async {
    try {
      final url = Uri.parse('${ApiConstants.bdappsBaseUrl}/verify_otp.php');
      final res = await _client.post(
        url,
        headers: _formHeaders,
        body: {'Otp': otpCode, 'referenceNo': referenceNo},
      );
      if (res.statusCode == 200) {
        final data = _decodeJsonMap(res.body);
        if (data == null) {
          return false;
        }
        return data['statusCode'] == 'S1000' ||
            _normalizeSubscriptionStatus(data['subscriptionStatus']) == 'REGISTERED';
      }
    } catch (e) {
      debugPrint('[BdappsServiceReal] Verify error: $e');
    }
    return false;
  }

  @override
  Future<bool> unsubscribe(String msisdn) async {
    try {
      final url = Uri.parse('${ApiConstants.bdappsBaseUrl}/unsubscribe.php');
      final res = await _client.post(
        url,
        headers: _formHeaders,
        body: {'user_mobile': msisdn},
      );
      final data = _decodeJsonMap(res.body);
      if (data == null) {
        return false;
      }

      final gatewayConfirmed = res.statusCode == 200 &&
          data['success'] == true &&
          _normalizeSubscriptionStatus(data['subscriptionStatus']) == 'UNREGISTERED';
      if (!gatewayConfirmed) {
        debugPrint('[BdappsServiceReal] Unsubscribe rejected: $data');
        return false;
      }

      final verifiedStatus = await _fetchSubscriptionStatus(msisdn);
      return verifiedStatus == 'UNREGISTERED';
    } catch (e) {
      debugPrint('[BdappsServiceReal] Unsubscribe error: $e');
    }
    return false;
  }
}
