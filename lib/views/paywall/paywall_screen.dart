import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/bdapps_service.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final _mobileController = TextEditingController(text: '01800000000');
  final _otpController = TextEditingController();
  final BdappsService _bdappsService = BdappsServiceMock(); // Mock service for pitch demo

  bool _isLoading = false;
  bool _otpSent = false;
  String? _referenceNo;
  bool _isSubscribed = false;

  Future<void> _handleSendOtp() async {
    setState(() => _isLoading = true);
    final res = await _bdappsService.sendOtp(_mobileController.text);
    setState(() => _isLoading = false);

    if (res['statusCode'] == 'S1000') {
      setState(() {
        _otpSent = true;
        _referenceNo = res['referenceNo'];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('আপনার মোবাইলে একটি OTP পিন পাঠানো হয়েছে (Demo PIN: 1234)')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['statusDetail'] ?? 'ওটিপি পাঠাতে ব্যর্থ হয়েছে')),
        );
      }
    }
  }

  Future<void> _handleVerifyOtp() async {
    if (_referenceNo == null) return;
    setState(() => _isLoading = true);
    final success =
        await _bdappsService.verifyOtp(_referenceNo!, _otpController.text);
    setState(() => _isLoading = false);

    if (success) {
      setState(() {
        _isSubscribed = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('অভিনন্দন! আপনার বিডিঅ্যাপস সাবস্ক্রিপশন সফলভাবে চালু হয়েছে।'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ভুল OTP কোড। সঠিক পিন দিন (Demo: 1234)'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BDapps SMS সাবস্ক্রিপশন'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Header Hero Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Icon(Icons.mark_email_read_rounded,
                      size: 54, color: AppColors.secondary),
                  SizedBox(height: 12),
                  Text(
                    'ডাটা ছাড়াই এসএমএস ডাইজেস্ট!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'ইন্টারনেট সংযোগ না থাকলেও প্রতিটি জরুরি সরকারি ও ব্যাংক সার্কুলারের ডেডলাইন আপনার মোবাইলে এসএমএস আকারে পৌঁছে যাবে।',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppColors.secondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Features Checklist
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                children: [
                  _FeatureRow(text: 'প্রতিদিন সকাল ৮টায় নোটিশ ডাইজেস্ট SMS'),
                  _FeatureRow(text: 'বিসিএস ও ব্যাংক সার্কুলারের ডেডলাইন রিমাইন্ডার'),
                  _FeatureRow(text: 'অফলাইন উপযোগী (ডাটা বা ৩জি/৪জি ছাড়াই কাজ করে)'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // BDapps CaaS OTP Activation Box
            if (!_isSubscribed) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'রবি ও এয়ারটেল গ্রাহকদের জন্য (CaaS Billing)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'মোবাইল নম্বর',
                        prefixIcon: const Icon(Icons.phone_android_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_otpSent) ...[
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'OTP পিন নম্বর',
                          hintText: 'যেমন: 1234',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleVerifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('পাসকোড নিশ্চিত করুন'),
                        ),
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSendOtp,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('সাবস্ক্রাইব করুন (২.৭৮ টাকা/দিন)'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ] else ...[
              // Active Status
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.success, width: 1.5),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 48),
                    SizedBox(height: 8),
                    Text(
                      'বিডিঅ্যাপস পরিষেবা সক্রিয় আছে',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),
            // BDapps Mandatory Compliance Pricing Text
            const Text(
              '2.78 tk/day including VAT+SD+SC (for Robi and Airtel Users only)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;
  const _FeatureRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
