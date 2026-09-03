import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_config.dart';
import '../../core/services/notification_service.dart';
import '../../providers/locale_provider.dart';
import '../../providers/subscription_provider.dart';
import '../admin/admin_login_screen.dart';
import '../auth/login_screen.dart';
import '../paywall/paywall_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _urgentNotifications = true;
  bool _allCircularsNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationState();
  }

  Future<void> _loadNotificationState() async {
    await _notificationService.initialize();
    if (mounted) {
      setState(() {
        _urgentNotifications =
            _notificationService.isTopicSubscribed('urgent_deadlines');
        _allCircularsNotifications =
            _notificationService.isTopicSubscribed('all_circulars');
      });
    }
  }

  Future<void> _showUnsubscribeDialog(BuildContext context, bool isBangla) async {
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final subState = ref.read(subscriptionProvider);
    final phoneController = TextEditingController(text: subState.phoneNumber ?? '');
    bool isProcessing = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.phonelink_erase_rounded, color: AppColors.danger, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isBangla ? 'সাবস্ক্রিপশন বাতিল' : 'Cancel Subscription',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isBangla
                    ? 'আপনার রবি বা এয়ারটেল নম্বরের দৈনিক এসএমএস ডাইজেস্ট সার্ভিসটি অবিলম্বে বন্ধ করতে চান?'
                    : 'Do you want to stop daily SMS alerts for your Robi/Airtel number?',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                enabled: !isProcessing,
                decoration: InputDecoration(
                  labelText: isBangla ? 'মোবাইল নম্বর (১১ ডিজিট)' : 'Mobile Number (11 digits)',
                  hintText: '018XXXXXXXX / 016XXXXXXXX',
                  prefixIcon: const Icon(Icons.phone_android_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isBangla
                    ? 'নোট: আনসাবস্ক্রাইব করার সাথে সাথে দৈনিক ২.৭৮ টাকা চার্জিং বন্ধ হবে।'
                    : 'Note: Daily 2.78 BDT charging will cease immediately.',
                style: const TextStyle(fontSize: 11, color: AppColors.textLight),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isProcessing ? null : () => Navigator.pop(ctx),
              child: Text(isBangla ? 'ফিরে যান' : 'Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: isProcessing
                  ? null
                  : () async {
                      final input = phoneController.text.trim();
                      if (input.length < 11) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(isBangla
                                ? 'অনুগ্রহ করে সঠিক ১১ ডিজিটের মোবাইল নম্বর দিন'
                                : 'Please enter a valid 11-digit mobile number'),
                            backgroundColor: AppColors.danger,
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isProcessing = true);
                      final success = await ref
                          .read(subscriptionProvider.notifier)
                          .unsubscribe(phoneOverride: input);

                      if (!success) {
                        setDialogState(() => isProcessing = false);
                        final error = ref.read(subscriptionProvider).errorMessage;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(error ??
                                (isBangla
                                    ? 'আনসাবস্ক্রিপশন নিশ্চিত হয়নি। আবার চেষ্টা করুন।'
                                    : 'Unsubscription was not confirmed. Please try again.')),
                            backgroundColor: AppColors.danger,
                            duration: const Duration(seconds: 5),
                          ),
                        );
                        return;
                      }

                      if (dialogCtx.mounted) {
                        Navigator.pop(dialogCtx);
                      }
                      if (mounted) {
                        nav.pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                        );
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(isBangla
                                ? 'আপনার সাবস্ক্রিপশন সফলভাবে বাতিল করা হয়েছে এবং আপনাকে লগআউট করা হয়েছে।'
                                : 'Subscription cancelled successfully and you have been logged out.'),
                            backgroundColor: AppColors.success,
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    },
              child: isProcessing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(isBangla ? 'আনসাবস্ক্রাইব করুন' : 'Unsubscribe'),
            ),
          ],
        ),
      ),
    );
    phoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isBangla = locale == 'bn';
    final subState = ref.watch(subscriptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isBangla ? 'সেটিংস ও প্রোফাইল' : 'Settings & Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // BDapps Subscription Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.sms_rounded, color: AppColors.secondary, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          isBangla ? 'বিডিঅ্যাপস এসএমএস ডাইজেস্ট' : 'BDapps SMS Digest',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: subState.isSubscribed
                            ? AppColors.success.withValues(alpha: 0.8)
                            : AppColors.accent.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        subState.isSubscribed
                            ? (isBangla ? 'সক্রিয়' : 'ACTIVE')
                            : (isBangla ? 'নিষ্ক্রিয়' : 'INACTIVE'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  subState.isSubscribed
                      ? (isBangla
                          ? 'আপনার নম্বরে এসএমএস এলার্ট চালু আছে: ${subState.phoneNumber ?? ''}'
                          : 'SMS alerts active for: ${subState.phoneNumber ?? ''}')
                      : (isBangla
                          ? 'ইন্টারনেট অফ থাকলেও প্রতিদিন সকালের নোটিশ সরাসরি এসএমএস-এ পান মাত্র ৩ টাকা/দিনে।'
                          : 'Receive daily notices via offline SMS at 3 BDT/day.'),
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PaywallScreen(),
                            ),
                          );
                        },
                        child: Text(
                          subState.isSubscribed
                              ? (isBangla ? 'প্ল্যান পরিচালনা করুন' : 'Manage Plan')
                              : (isBangla ? 'সাবস্ক্রাইব করুন' : 'Subscribe Now'),
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => _showUnsubscribeDialog(context, isBangla),
                      child: Text(
                        isBangla ? 'আনসাবস্ক্রাইব' : 'Unsub',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Dedicated Unsubscribe Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.phonelink_erase_rounded, color: AppColors.danger, size: 22),
              ),
              title: Text(
                isBangla ? 'এসএমএস সাবস্ক্রিপশন বাতিল (Unsubscribe)' : 'Cancel SMS Subscription',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
              subtitle: Text(
                isBangla
                    ? 'যেকোনো নম্বর থেকে দৈনিক চার্জিং ও নোটিফিকেশন বন্ধ করুন'
                    : 'Stop daily alerts & recurring charging for any number',
                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () => _showUnsubscribeDialog(context, isBangla),
            ),
          ),

          const SizedBox(height: 20),

          // Preferences Section
          _buildSectionHeader(isBangla ? 'অ্যাপ সেটিংস' : 'App Preferences'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                // Language Switch
                ListTile(
                  leading: const Icon(Icons.language_rounded, color: AppColors.primary),
                  title: Text(isBangla ? 'ভাষা (Language)' : 'Language (ভাষা)'),
                  subtitle: Text(isBangla ? 'বাংলা (Bangla)' : 'English'),
                  trailing: Switch(
                    value: isBangla,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) {
                      ref.read(localeProvider.notifier).toggleLocale();
                    },
                  ),
                ),
                const Divider(height: 1),
                // Push Notifications
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined,
                      color: AppColors.primary),
                  title: Text(
                    isBangla ? 'জরুরি ডেডলাইন অ্যালার্ট' : 'Urgent Deadline Alerts',
                  ),
                  subtitle: Text(
                    isBangla
                        ? 'আবেদনের সময় শেষ হওয়ার আগে পুশ নোটিফিকেশন'
                        : 'Receive push alerts before application deadlines',
                  ),
                  value: _urgentNotifications,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) async {
                    setState(() => _urgentNotifications = val);
                    if (val) {
                      await _notificationService.subscribeToTopic('urgent_deadlines');
                    } else {
                      await _notificationService.unsubscribeFromTopic('urgent_deadlines');
                    }
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.article_outlined, color: AppColors.primary),
                  title: Text(
                    isBangla ? 'সকল নতুন সার্কুলার বিজ্ঞপ্তি' : 'All New Circulars',
                  ),
                  subtitle: Text(
                    isBangla
                        ? 'নতুন নোটিশ প্রকাশের সাথে সাথে নোটিফিকেশন পান'
                        : 'Get notified when new circulars are published',
                  ),
                  value: _allCircularsNotifications,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) async {
                    setState(() => _allCircularsNotifications = val);
                    if (val) {
                      await _notificationService.subscribeToTopic('all_circulars');
                    } else {
                      await _notificationService.unsubscribeFromTopic('all_circulars');
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // About & Info
          _buildSectionHeader(isBangla ? 'তথ্য ও সহায়তা' : 'About & Support'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                  title: Text(isBangla ? 'বিজ্ঞপ্তি (Biggopti) সম্পর্কে' : 'About Biggopti'),
                  subtitle: Text(
                    isBangla
                        ? 'ভার্সন ${AppConfig.appVersion} | জেমিনি ২.৫ ফ্ল্যাশ এআই'
                        : 'Version ${AppConfig.appVersion} | Gemini 2.5 Flash AI',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.emoji_events_outlined, color: AppColors.primary),
                  title: Text(
                    isBangla
                        ? 'বিডিঅ্যাপস বুটক্যাম্প ২০২৬'
                        : 'BDapps Bootcamp 2026',
                  ),
                  subtitle: const Text('National Android Development Competition'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Account Section
          if (subState.isSubscribed) ...[
            _buildSectionHeader(isBangla ? 'অ্যাকাউন্ট' : 'Account'),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.danger),
                title: Text(
                  isBangla ? 'লগআউট / নম্বর পরিবর্তন' : 'Logout / Change Number',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.danger),
                ),
                subtitle: Text(
                  isBangla
                      ? 'বর্তমান নম্বর থেকে বের হয়ে নতুন নম্বরে লগইন করুন'
                      : 'Sign out and login with a different number',
                ),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(isBangla ? 'লগআউট নিশ্চিতকরণ' : 'Confirm Logout'),
                      content: Text(
                        isBangla
                            ? 'আপনি কি লগআউট করে লগইন স্ক্রিনে ফিরে যেতে চান?'
                            : 'Do you want to log out and return to the login screen?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(isBangla ? 'না' : 'Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                          child: Text(isBangla ? 'হ্যাঁ, লগআউট' : 'Logout'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref.read(subscriptionProvider.notifier).logout();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Admin Section
          _buildSectionHeader(isBangla ? 'প্রশাসনিক কন্ট্রোল' : 'Administration'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.primary),
              title: Text(
                isBangla ? 'অ্যাডমিন ড্যাশবোর্ড' : 'Admin Dashboard',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                isBangla
                  ? 'স্ক্র্যাপার লগ ও ডেটাবেজ পরিসংখ্যান (পিন সুরক্ষিত)'
                  : 'Scraper logs and database statistics (PIN protected)',
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminLoginScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
