import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/subscription_provider.dart';
import '../home/home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

enum AuthTab { subscribe, login }

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  AuthTab _authTab = AuthTab.subscribe;
  bool _otpStep = false;
  String _submittedMobile = '';

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String _normalizeMobile(String input) {
    String digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('880') && digits.length == 13) {
      digits = '0${digits.substring(3)}';
    } else if (digits.startsWith('88') && digits.length == 12) {
      digits = '0${digits.substring(2)}';
    }
    return digits;
  }

  bool _isValidBdMobile(String digits) {
    return RegExp(r'^01[3-9]\d{8}$').hasMatch(digits);
  }

  // 1. Subscribe Handler (New / Unregistered Users)
  Future<void> _handleSubscribe() async {
    final raw = _mobileController.text.trim();
    final normalized = _normalizeMobile(raw);

    if (!_isValidBdMobile(normalized)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('সঠিক ১১ ডিজিটের রবি বা এয়ারটেল নম্বর দিন (যেমন: 018XXXXXXXX / 016XXXXXXXX)'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    _submittedMobile = normalized;
    final success =
        await ref.read(subscriptionProvider.notifier).sendOtp(normalized);

    if (!mounted) return;

    if (success) {
      setState(() => _otpStep = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('আপনার মোবাইলে ৬ সংখ্যার OTP পাঠানো হয়েছে'),
          backgroundColor: AppColors.primary,
        ),
      );
    } else {
      final error = ref.read(subscriptionProvider).errorMessage;
      if (error == 'ALREADY_SUBSCRIBED') {
        setState(() {
          _authTab = AuthTab.login;
          _otpStep = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('এই নম্বরটি ইতিমধ্যে সাবস্ক্রাইব করা আছে! "লগইন করুন" ট্যাব থেকে লগইন করুন।'),
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'ওটিপি পাঠাতে সমস্যা হয়েছে। আবার চেষ্টা করুন।'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  // 2. Login Handler (Strict: Only Subscribed Numbers Allowed!)
  Future<void> _handleLogin() async {
    final raw = _mobileController.text.trim();
    final normalized = _normalizeMobile(raw);

    if (!_isValidBdMobile(normalized)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('সঠিক ১১ ডিজিটের রবি বা এয়ারটেল নম্বর দিন (যেমন: 018XXXXXXXX / 016XXXXXXXX)'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    _submittedMobile = normalized;
    final isAllowed = await ref
        .read(subscriptionProvider.notifier)
        .checkSubscriberLogin(normalized);

    if (!mounted) return;

    if (isAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('স্বাগতম! আপনার সাবস্ক্রিপশন সফলভাবে যাচাই হয়েছে।'),
          backgroundColor: AppColors.success,
        ),
      );
      _navigateToHome();
    } else {
      final error = ref.read(subscriptionProvider).errorMessage ??
          'এই নম্বরটি সাবস্ক্রাইব করা নেই! অ্যাপটি ব্যবহার করতে অনুগ্রহ করে প্রথমে "সাবস্ক্রাইব করুন" অপশন থেকে সাবস্ক্রিপশন সম্পন্ন করুন।';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.danger,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim().replaceAll(RegExp(r'\D'), '');
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('মোবাইলে আসা ওটিপি কোডটি লিখুন'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final success =
        await ref.read(subscriptionProvider.notifier).verifyOtp(otp);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('অভিনন্দন! সফলভাবে সাবস্ক্রিপশন ও লগইন সম্পন্ন হয়েছে।'),
          backgroundColor: AppColors.success,
        ),
      );
      _navigateToHome();
    } else {
      final error = ref.read(subscriptionProvider).errorMessage ??
          'ভুল OTP কোড। অনুগ্রহ করে সঠিক কোড দিন।';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.danger),
      );
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _resetToMobileStep() {
    setState(() {
      _otpStep = false;
      _otpController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final subState = ref.watch(subscriptionProvider);
    final isLoading = subState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Hero Branding
                  Container(
                    width: 92,
                    height: 92,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'বিজ্ঞপ্তি',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'AI-চালিত সরকারি ও ব্যাংক চাকরির নোটিশ ডাইজেস্ট',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Feature Badges
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _PillBadge(
                        icon: Icons.auto_awesome,
                        text: '৩০ সেকেন্ড AI ডাইজেস্ট',
                      ),
                      _PillBadge(
                        icon: Icons.sms_outlined,
                        text: 'অফলাইন SMS অ্যালার্ট',
                      ),
                      _PillBadge(
                        icon: Icons.access_time_rounded,
                        text: 'ডেডলাইন ট্র্যাকার',
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Main Interactive Portal Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Two Options Switcher (Only visible on Step 1)
                        if (!_otpStep) ...[
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.chipBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: isLoading
                                        ? null
                                        : () {
                                            setState(() {
                                              _authTab = AuthTab.subscribe;
                                              _otpStep = false;
                                            });
                                          },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _authTab == AuthTab.subscribe
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.card_membership_rounded,
                                            size: 16,
                                            color: _authTab == AuthTab.subscribe
                                                ? Colors.white
                                                : AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'সাবস্ক্রাইব করুন',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: _authTab == AuthTab.subscribe
                                                  ? Colors.white
                                                  : AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: isLoading
                                        ? null
                                        : () {
                                            setState(() {
                                              _authTab = AuthTab.login;
                                              _otpStep = false;
                                            });
                                          },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _authTab == AuthTab.login
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.login_rounded,
                                            size: 16,
                                            color: _authTab == AuthTab.login
                                                ? Colors.white
                                                : AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'লগইন করুন',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: _authTab == AuthTab.login
                                                  ? Colors.white
                                                  : AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],

                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _otpStep
                                    ? Icons.sms_outlined
                                    : (_authTab == AuthTab.subscribe
                                        ? Icons.card_membership_rounded
                                        : Icons.lock_outline_rounded),
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _otpStep
                                  ? 'ওটিপি কোড নিশ্চিত করুন'
                                  : (_authTab == AuthTab.subscribe
                                      ? 'নতুন সাবস্ক্রিপশন (রবি বা এয়ারটেল)'
                                      : 'বিদ্যমান সাবস্ক্রাইবার লগইন'),
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        if (!_otpStep) ...[
                          // Step 1: Mobile Input
                          TextFormField(
                            controller: _mobileController,
                            enabled: !isLoading,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'মোবাইল নম্বর',
                              hintText: 'যেমন: 018XXXXXXXX বা 016XXXXXXXX',
                              prefixIcon: const Icon(
                                Icons.phone_android_rounded,
                                color: AppColors.primary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.8,
                                ),
                              ),
                              filled: true,
                              fillColor: AppColors.chipBackground,
                            ),
                          ),
                          const SizedBox(height: 14),

                          if (_authTab == AuthTab.subscribe) ...[
                            // BDapps Pricing Compliance Box for Subscribe
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                ),
                              ),
                              child: const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'চার্জ সংক্রান্ত তথ্য: ২.৭৮ টাকা/দিন (ভ্যাট+এসডি+এসসি সহ, শুধু রবি ও এয়ারটেল গ্রাহকদের জন্য)',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Subscribe Button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _handleSubscribe,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'ওটিপি পাঠান ও সাবস্ক্রাইব করুন',
                                            style: TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(Icons.arrow_forward_rounded,
                                              size: 18),
                                        ],
                                      ),
                              ),
                            ),
                          ] else ...[
                            // Security / Rule Box for Login
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.chipBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.border,
                                ),
                              ),
                              child: const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.verified_user_outlined,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'সাবস্ক্রাইবার লগইন: পূর্বে সাবস্ক্রাইব করা রবি বা এয়ারটেল নম্বর দিন। কোনো অসাবস্ক্রাইবড নম্বর লগইন করতে পারবে না।',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryDark,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'যাচাই করে লগইন করুন',
                                            style: TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(Icons.login_rounded,
                                              size: 18),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ] else ...[
                          // Step 2: OTP Verification
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.chipBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.mark_email_read_outlined,
                                    size: 20, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '$_submittedMobile নম্বরে কোড পাঠানো হয়েছে',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _otpController,
                            enabled: !isLoading,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 6,
                            ),
                            decoration: InputDecoration(
                              labelText: '৬ সংখ্যার OTP লিখুন',
                              hintText: '••••••',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.8,
                                ),
                              ),
                              filled: true,
                              fillColor: AppColors.chipBackground,
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
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'OTP যাচাই করে প্রবেশ করুন',
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          Center(
                            child: TextButton(
                              onPressed: isLoading ? null : _resetToMobileStep,
                              child: const Text(
                                'অন্য নম্বর ব্যবহার করুন',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Telco Brand Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.red.withValues(alpha: 0.3)),
                        ),
                        child: const Text(
                          'Powered by BDapps',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '•  রবি ও এয়ারটেল অনুমোদিত',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PillBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PillBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
