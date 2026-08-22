import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/circular_model.dart';
import '../core/services/supabase_service.dart';
import '../core/utils/deadline_helper.dart';

final selectedCategoryProvider = StateProvider<String>((ref) => 'all');

final circularsProvider = FutureProvider<List<CircularModel>>((ref) async {
  final category = ref.watch(selectedCategoryProvider);
  final supabaseService = SupabaseService();
  final allCirculars = await supabaseService.fetchCirculars(category: category);

  // Strictly filter out circulars where the application deadline has expired
  return allCirculars
      .where((circular) => DeadlineHelper.isActive(circular.deadline))
      .toList();
});
