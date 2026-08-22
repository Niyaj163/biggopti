import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_config.dart';
import '../../core/services/notification_service.dart';
import '../../providers/locale_provider.dart';
import '../../providers/subscription_provider.dart';
import '../admin/admin_login_screen.dart';
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
                    if (subState.isSubscribed) ...[
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
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('আনসাবস্ক্রাইব নিশ্চিত করুন'),
                              content: const Text(
                                'আপনি কি নিশ্চিত যে আপনি দৈনিক এসএমএস নোটিফিকেশন বন্ধ করতে চান?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('না'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('হ্যাঁ, আনসাবস্ক্রাইব করুন',
                                      style: TextStyle(color: AppColors.danger)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await ref.read(subscriptionProvider.notifier).unsubscribe();
                          }
                        },
                        child: Text(
                          isBangla ? 'বাতিল' : 'Unsub',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
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
