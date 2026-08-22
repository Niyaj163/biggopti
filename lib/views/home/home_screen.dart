import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/circular_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../detail/circular_detail_screen.dart';
import '../bookmarks/bookmarks_screen.dart';
import '../eligibility/eligibility_screen.dart';
import '../paywall/paywall_screen.dart';
import '../settings/settings_screen.dart';
import 'widgets/category_chip.dart';
import 'widgets/circular_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final circularsAsync = ref.watch(circularsProvider);
    final bookmarkedCount = ref.watch(bookmarksProvider).length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.notifications_active_rounded,
                  size: 20, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Text(
              'বিজ্ঞপ্তি (Biggopti)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.verified_user_rounded),
            tooltip: 'যোগ্যতা চেক',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EligibilityScreen(),
                ),
              );
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.bookmark_rounded),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BookmarksScreen(),
                    ),
                  );
                },
              ),
              if (bookmarkedCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$bookmarkedCount',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'সেটিংস',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // BDapps SMS Digest Banner
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaywallScreen(),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.sms_rounded, color: AppColors.secondary, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ডাটা অফ থাকলেও এসএমএস ডাইজেস্ট!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'মাত্র ৩ টাকা/দিনে বিডিঅ্যাপস সাবস্ক্রিপশন চালু করুন',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'চালু করুন',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Category Chips Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CategoryChip(
                    label: 'সব বিজ্ঞপ্তি',
                    categoryKey: 'all',
                    isSelected: selectedCategory == 'all',
                    onTap: () => ref
                        .read(selectedCategoryProvider.notifier)
                        .state = 'all',
                  ),
                  const SizedBox(width: 8),
                  CategoryChip(
                    label: '🏛️ সরকারি',
                    categoryKey: 'govt',
                    isSelected: selectedCategory == 'govt',
                    onTap: () => ref
                        .read(selectedCategoryProvider.notifier)
                        .state = 'govt',
                  ),
                  const SizedBox(width: 8),
                  CategoryChip(
                    label: '💳 ব্যাংক',
                    categoryKey: 'bank',
                    isSelected: selectedCategory == 'bank',
                    onTap: () => ref
                        .read(selectedCategoryProvider.notifier)
                        .state = 'bank',
                  ),
                  const SizedBox(width: 8),
                  CategoryChip(
                    label: '🎓 বিশ্ববিদ্যালয়',
                    categoryKey: 'varsity',
                    isSelected: selectedCategory == 'varsity',
                    onTap: () => ref
                        .read(selectedCategoryProvider.notifier)
                        .state = 'varsity',
                  ),
                ],
              ),
            ),
          ),

          // Circular Feed Content Area
          Expanded(
            child: circularsAsync.when(
              data: (circulars) {
                if (circulars.isEmpty) {
                  return const Center(
                    child: Text(
                      'কোনো বিজ্ঞপ্তি পাওয়া যায়নি।',
                      style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(circularsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: circulars.length,
                    itemBuilder: (context, index) {
                      final item = circulars[index];
                      return CircularCard(
                        circular: item,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CircularDetailScreen(circular: item),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 48, color: AppColors.danger),
                    const SizedBox(height: 12),
                    Text(
                      'বিজ্ঞপ্তি লোড করতে সমস্যা হয়েছে',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(circularsProvider),
                      child: const Text('পুনরায় চেষ্টা করুন'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
