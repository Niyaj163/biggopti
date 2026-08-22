import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/scraper_log_model.dart';

class ScraperLogTable extends StatelessWidget {
  final List<ScraperLogModel> logs;

  const ScraperLogTable({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: const Text(
          'এখনো কোনো স্ক্র্যাপার লগ নেই।',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      );
    }

    final dateFormat = DateFormat('dd MMM, hh:mm a');

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: logs.length,
      separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
      itemBuilder: (context, index) {
        final log = logs[index];
        final isSuccess = log.status.toUpperCase() == 'SUCCESS';
        final isError = log.status.toUpperCase() == 'ERROR';

        final Color statusColor = isSuccess
            ? AppColors.success
            : isError
                ? AppColors.danger
                : AppColors.warning;

        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: statusColor.withValues(alpha: 0.5)),
            ),
            child: Text(
              log.status.toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            log.sourceUrl,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Row(
            children: [
              Text(
                dateFormat.format(log.ranAt.toLocal()),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              if (log.pdfHash != null) ...[
                const SizedBox(width: 8),
                Text(
                  'Hash: ${log.pdfHash!.substring(0, log.pdfHash!.length > 8 ? 8 : log.pdfHash!.length)}...',
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          trailing: log.errorMessage != null && log.errorMessage!.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.info_outline, size: 18, color: AppColors.danger),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('লগ ত্রুটি বিবরণ'),
                        content: SingleChildScrollView(
                          child: Text(
                            log.errorMessage!,
                            style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('বন্ধ করুন'),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : const Icon(Icons.check_circle_outline, size: 18, color: AppColors.success),
        );
      },
    );
  }
}
