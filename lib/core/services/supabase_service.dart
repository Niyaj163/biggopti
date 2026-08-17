import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/circular_model.dart';
import '../constants/api_constants.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await Supabase.initialize(
        url: ApiConstants.supabaseUrl,
        anonKey: ApiConstants.supabaseAnonKey,
      );
      _isInitialized = true;
      debugPrint('[SupabaseService] Initialized successfully.');
    } catch (e) {
      debugPrint('[SupabaseService] Initialization warning: $e');
    }
  }

  SupabaseClient get client => Supabase.instance.client;

  /// Fetch circulars with optional category filter
  Future<List<CircularModel>> fetchCirculars({String category = 'all'}) async {
    await initialize();
    try {
      var query = client.from('circulars').select();
      if (category != 'all') {
        query = query.eq('category', category);
      }
      
      final response = await query.order('created_at', ascending: false);
      final List<dynamic> data = response;
      return data.map((json) => CircularModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('[SupabaseService] Fetch error: $e');
      return [];
    }
  }
}
