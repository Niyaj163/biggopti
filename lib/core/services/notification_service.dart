import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _subscribedTopicsKey = 'fcm_subscribed_topics';
  final Set<String> _activeTopics = {};

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_subscribedTopicsKey) ?? [];
      _activeTopics.addAll(saved);

      // Default subscribe to urgent deadlines and all circulars on first run
      if (_activeTopics.isEmpty) {
        _activeTopics.addAll(['all_circulars', 'urgent_deadlines']);
        await _saveTopics();
      }
      _isInitialized = true;
      debugPrint('[NotificationService] Initialized with topics: $_activeTopics');
    } catch (e) {
      debugPrint('[NotificationService] Init error: $e');
    }
  }

  Set<String> get activeTopics => Set.unmodifiable(_activeTopics);

  bool isTopicSubscribed(String topic) => _activeTopics.contains(topic);

  Future<bool> subscribeToTopic(String topic) async {
    await initialize();
    _activeTopics.add(topic);
    debugPrint('[NotificationService] Subscribed to topic: $topic');
    return _saveTopics();
  }

  Future<bool> unsubscribeFromTopic(String topic) async {
    await initialize();
    _activeTopics.remove(topic);
    debugPrint('[NotificationService] Unsubscribed from topic: $topic');
    return _saveTopics();
  }

  Future<bool> toggleTopic(String topic) async {
    if (isTopicSubscribed(topic)) {
      return unsubscribeFromTopic(topic);
    } else {
      return subscribeToTopic(topic);
    }
  }

  Future<bool> _saveTopics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setStringList(
        _subscribedTopicsKey,
        _activeTopics.toList(),
      );
    } catch (e) {
      debugPrint('[NotificationService] Save error: $e');
      return false;
    }
  }
}
