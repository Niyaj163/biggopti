import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/supabase_service.dart';
import '../models/scraper_log_model.dart';

final adminLogsProvider = FutureProvider.autoDispose<List<ScraperLogModel>>((ref) async {
  final supabase = SupabaseService();
  return supabase.fetchScraperLogs(limit: 50);
});

final circularStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final supabase = SupabaseService();
  return supabase.fetchCircularStats();
});

final isScrapingRunningProvider = StateProvider<bool>((ref) => false);
