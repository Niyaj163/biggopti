import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/circular_model.dart';
import '../../models/scraper_log_model.dart';
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
        // ignore: deprecated_member_use
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

  /// Fetch scraper logs for Admin Dashboard
  Future<List<ScraperLogModel>> fetchScraperLogs({int limit = 50}) async {
    await initialize();
    try {
      final response = await client
          .from('scraper_logs')
          .select()
          .order('ran_at', ascending: false)
          .limit(limit);
      final List<dynamic> data = response;
      return data.map((json) => ScraperLogModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('[SupabaseService] Fetch scraper logs error: $e');
      return [];
    }
  }

  /// Fetch overall circular metrics
  Future<Map<String, dynamic>> fetchCircularStats() async {
    await initialize();
    try {
      final circularsRes = await client.from('circulars').select('id, category');
      final logsRes = await client.from('scraper_logs').select('id, status');

      final List<dynamic> circulars = circularsRes;
      final List<dynamic> logs = logsRes;

      final int totalCirculars = circulars.length;
      final int govtCount = circulars.where((c) => c['category'] == 'govt').length;
      final int bankCount = circulars.where((c) => c['category'] == 'bank').length;
      final int varsityCount = circulars.where((c) => c['category'] == 'varsity').length;
      
      final int totalRuns = logs.length;
      final int successRuns = logs.where((l) => l['status'] == 'SUCCESS').length;
      final int errorRuns = logs.where((l) => l['status'] == 'ERROR').length;

      return {
        'totalCirculars': totalCirculars,
        'govtCount': govtCount,
        'bankCount': bankCount,
        'varsityCount': varsityCount,
        'totalRuns': totalRuns,
        'successRuns': successRuns,
        'errorRuns': errorRuns,
      };
    } catch (e) {
      debugPrint('[SupabaseService] Fetch stats error: $e');
      return {
        'totalCirculars': 0,
        'govtCount': 0,
        'bankCount': 0,
        'varsityCount': 0,
        'totalRuns': 0,
        'successRuns': 0,
        'errorRuns': 0,
      };
    }
  }

  /// Record a new scraper log entry
  Future<bool> recordScraperLog(ScraperLogModel log) async {
    await initialize();
    try {
      await client.from('scraper_logs').insert(log.toJson());
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] Insert log error: $e');
      return false;
    }
  }

  /// Upsert subscriber record into Supabase subscribers table
  Future<bool> upsertSubscriber(String phoneNumber, {String status = 'ACTIVE'}) async {
    await initialize();
    try {
      await client.from('subscribers').upsert({
        'phone_number': phoneNumber,
        'subscription_status': status,
        'subscribed_at': DateTime.now().toIso8601String(),
      });
      debugPrint('[SupabaseService] Successfully upserted subscriber: $phoneNumber ($status)');
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] Upsert subscriber error: $e');
      return false;
    }
  }

  /// Update subscriber status (e.g. UNREGISTERED)
  Future<bool> updateSubscriberStatus(String phoneNumber, String status) async {
    await initialize();
    try {
      await client.from('subscribers').update({
        'subscription_status': status,
      }).eq('phone_number', phoneNumber);
      debugPrint('[SupabaseService] Updated subscriber status: $phoneNumber -> $status');
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] Update subscriber error: $e');
      return false;
    }
  }

  /// Query if a phone number is registered in Supabase
  Future<bool> isSubscriberActive(String phoneNumber) async {
    await initialize();
    try {
      final res = await client
          .from('subscribers')
          .select('subscription_status')
          .eq('phone_number', phoneNumber)
          .maybeSingle();
      if (res != null) {
        return res['subscription_status'] == 'ACTIVE' || res['subscription_status'] == 'REGISTERED';
      }
    } catch (e) {
      debugPrint('[SupabaseService] Check subscriber error: $e');
    }
    return false;
  }
}


