import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/circular_model.dart';
import '../../../providers/bookmark_provider.dart';

class CircularCard extends ConsumerWidget {
  final CircularModel circular;
  final VoidCallback onTap;

  const CircularCard({
    super.key,
    required this.circular,
    required this.onTap,
  });

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'govt':
        return AppColors.primary;
      case 'bank':
        return const Color(0xFF1E88E5);
      case 'varsity':
        return const Color(0xFF8E24AA);
      default:
        return AppColors.textSecondary;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'govt':
        return 'সরকারি';
      case 'bank':
        return 'ব্যাংক';
      case 'varsity':
        return 'বিশ্ববিদ্যালয়';
      default:
        return 'অন্যান্য';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarked =
        ref.watch(bookmarksProvider.notifier).isBookmarked(circular.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Category Badge + Priority Indicator + Heart Bookmark
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(circular.category)
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getCategoryLabel(circular.category),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getCategoryColor(circular.category),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (circular.isHighPriority)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.local_fire_department,
                              size: 14, color: AppColors.accent),
                          SizedBox(width: 2),
                          Text(
                            'জরুরি',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      isBookmarked
                          ? Icons.favorite
                          : Icons.favorite_border_rounded,
                      color: isBookmarked ? AppColors.accent : Colors.grey,
                      size: 22,
                    ),
                    onPressed: () {
                      ref
                          .read(bookmarksProvider.notifier)
                          .toggleBookmark(circular);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Org Name
              Text(
                circular.orgName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),

              // Main Circular Title
              Text(
                circular.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),

              // AI 3-Bullet Bangla Summary Highlights
              if (circular.summaryBullets.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: circular.summaryBullets
                        .take(3)
                        .map(
                          (bullet) => Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("• ",
                                    style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold)),
                                Expanded(
                                  child: Text(
                                    bullet,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      color: AppColors.textPrimary,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              const SizedBox(height: 12),

              // Footer Row: Deadline Badge & Action CTA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time_filled_rounded,
                          size: 16, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        'শেষ তারিখ: ${circular.deadline}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      Text(
                        'বিস্তারিত',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 12, color: AppColors.primary),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
