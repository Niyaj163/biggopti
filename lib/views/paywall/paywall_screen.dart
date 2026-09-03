import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_config.dart';
import '../../providers/subscription_provider.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  final _mobileController = TextEditingController(text: '01815644470');
  final _otpController = TextEditingController();
  bool _otpSent = false;

  @override
  void initState() {
    super.initState();
    final subState = ref.read(subscriptionProvider);
    if (subState.phoneNumber != null && subState.phoneNumber!.isNotEmpty) {
      _mobileController.text = subState.phoneNumber!;
    }
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    final mobile = _mobileController.text.trim();
    if (mobile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে মোবাইল নম্বর লিখুন')),
      );
      return;
    }

    final success = await ref.read(subscriptionProvider.notifier).sendOtp(mobile);

    if (!mounted) return;
    if (success) {
      final isSub = ref.read(subscriptionProvider).isSubscribed;
      if (isSub) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('আপনার নম্বরটি ইতিমধ্যে নিবন্ধিত! পরিষেবা সক্রিয় আছে।'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        setState(() => _otpSent = true);
        final hint = AppConfig.useMockBdapps ? ' (Demo PIN: 1234)' : '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('আপনার মোবাইলে একটি OTP কোড পাঠানো হয়েছে$hint')),
        );
      }
    } else {
      final error = ref.read(subscriptionProvider).errorMessage ?? 'ওটিপি পাঠাতে ব্যর্থ হয়েছে';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.danger),
      );
    }
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে ওটিপি কোড লিখুন')),
      );
      return;
    }

    final success = await ref.read(subscriptionProvider.notifier).verifyOtp(otp);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('অভিনন্দন! আপনার বিডিঅ্যাপস সাবস্ক্রিপশন সফলভাবে চালু হয়েছে।'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      final error = ref.read(subscriptionProvider).errorMessage ?? 'ভুল OTP কোড। অনুগ্রহ করে সঠিক কোড দিন।';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subState = ref.watch(subscriptionProvider);
    final isLoading = subState.isLoading;

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
            if (!subState.isSubscribed) ...[
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
                      enabled: !_otpSent && !isLoading,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'মোবাইল নম্বর',
                        hintText: '018xxxxxxxx / 016xxxxxxxx',
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
                        enabled: !isLoading,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'OTP পিন নম্বর',
                          hintText: AppConfig.useMockBdapps ? 'যেমন: 1234' : 'আপনার মোবাইলে আসা কোড',
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
                          onPressed: isLoading ? null : _handleVerifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('পাসকোড নিশ্চিত করুন'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: isLoading ? null : () => setState(() => _otpSent = false),
                          child: const Text('নম্বর পরিবর্তন করুন'),
                        ),
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleSendOtp,
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
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
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.success, width: 1.5),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 48),
                    const SizedBox(height: 8),
                    const Text(
                      'বিডিঅ্যাপস পরিষেবা সক্রিয় আছে',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'নিবন্ধিত মোবাইল নম্বর: ${subState.phoneNumber ?? ''}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
