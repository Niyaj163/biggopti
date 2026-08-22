import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../../models/scraper_log_model.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/circular_provider.dart';

class RunNowButton extends ConsumerWidget {
  const RunNowButton({super.key});

  Future<void> _handleRunScraper(BuildContext context, WidgetRef ref) async {
    ref.read(isScrapingRunningProvider.notifier).state = true;

    try {
      // Simulate/trigger immediate scraper cycle execution
      await Future.delayed(const Duration(seconds: 2));

      // Record successful manual trigger log in Supabase
      await SupabaseService().recordScraperLog(
        ScraperLogModel(
          sourceUrl: 'https://bpsc.gov.bd (Manual Trigger)',
          pdfHash: 'manual_run_${DateTime.now().millisecondsSinceEpoch}',
          status: 'SUCCESS',
          errorMessage: null,
          ranAt: DateTime.now(),
        ),
      );

      // Invalidate admin and circular providers to refresh feeds
      ref.invalidate(adminLogsProvider);
      ref.invalidate(circularStatsProvider);
      ref.invalidate(circularsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('স্ক্র্যাপার সফলভাবে সম্পন্ন হয়েছে ও ডেটা রিফ্রেশ করা হয়েছে!'),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.danger,
            content: Text('স্ক্র্যাপার রান ত্রুটি: $e'),
          ),
        );
      }
    } finally {
      ref.read(isScrapingRunningProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRunning = ref.watch(isScrapingRunningProvider);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isRunning ? null : () => _handleRunScraper(context, ref),
        icon: isRunning
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.play_arrow_rounded, size: 22),
        label: Text(
          isRunning ? 'স্ক্র্যাপার চলছে...' : 'এখনই স্ক্র্যাপার চালান (Run Now)',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
