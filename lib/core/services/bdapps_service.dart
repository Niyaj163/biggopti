import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  @override
  Future<bool> checkSubscriptionStatus(String msisdn) async {
    try {
      final url = Uri.parse('${ApiConstants.bdappsBaseUrl}/check_subscription.php');
      final res = await _client.post(url, body: {'user_mobile': msisdn});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['subscriptionStatus'] == 'REGISTERED';
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
      final res = await _client.post(url, body: {'user_mobile': msisdn});
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint('[BdappsServiceReal] Send OTP error: $e');
    }
    return {"statusCode": "FAILED", "statusDetail": "Network Error"};
  }

  @override
  Future<bool> verifyOtp(String referenceNo, String otpCode) async {
    try {
      final url = Uri.parse('${ApiConstants.bdappsBaseUrl}/verify_otp.php');
      final res = await _client.post(url, body: {'Otp': otpCode, 'referenceNo': referenceNo});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['statusCode'] == 'S1000';
      }
    } catch (e) {
      debugPrint('[BdappsServiceReal] Verify OTP error: $e');
    }
    return false;
  }

  @override
  Future<bool> unsubscribe(String msisdn) async {
    try {
      final url = Uri.parse('${ApiConstants.bdappsBaseUrl}/unsubscribe.php');
      final res = await _client.post(url, body: {'user_mobile': msisdn});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['statusCode'] == 'S1000' || data['success'] == true;
      }
    } catch (e) {
      debugPrint('[BdappsServiceReal] Unsubscribe error: $e');
    }
    return false;
  }
}
