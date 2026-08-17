import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/bookmark_provider.dart';
import '../detail/circular_detail_screen.dart';
import '../home/widgets/circular_card.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkedCirculars = ref.watch(bookmarksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('সংরক্ষিত বিজ্ঞপ্তি (Bookmarks)'),
      ),
      body: bookmarkedCirculars.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border_rounded,
                      size: 64, color: AppColors.textLight),
                  SizedBox(height: 16),
                  Text(
                    'আপনার কোনো সংরক্ষিত বিজ্ঞপ্তি নেই।',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'হোম ফিড থেকে হার্ট আইকনে ট্যাপ করে সেভ করুন।',
                    style: TextStyle(fontSize: 13, color: AppColors.textLight),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookmarkedCirculars.length,
              itemBuilder: (context, index) {
                final circular = bookmarkedCirculars[index];
                return CircularCard(
                  circular: circular,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CircularDetailScreen(circular: circular),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
