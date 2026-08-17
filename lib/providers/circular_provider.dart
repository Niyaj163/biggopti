import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/circular_model.dart';
import '../core/services/supabase_service.dart';

final selectedCategoryProvider = StateProvider<String>((ref) => 'all');

final circularsProvider = FutureProvider<List<CircularModel>>((ref) async {
  final category = ref.watch(selectedCategoryProvider);
  final supabaseService = SupabaseService();
  return await supabaseService.fetchCirculars(category: category);
});
