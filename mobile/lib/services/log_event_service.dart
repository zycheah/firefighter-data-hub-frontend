import 'dart:convert';

import 'package:intl/intl.dart';

import '../config/app_config.dart';
import 'auth_service.dart';

class LogEventService {
  static final LogEventService _instance = LogEventService._internal();
  factory LogEventService() => _instance;
  LogEventService._internal();

  final AuthService _auth = AuthService();

  /// POST log event.
  /// Returns created event_id when backend responds with 2xx.
  /// Returns null on failure.
  Future<String?> submitLogEvent({
    required DateTime eventDate,
    required String eventAddress,
    required bool isSamePpe,
  }) async {
    final uri = Uri.parse(AppConfig.logEventSubmitUrl);
    final dateStr = DateFormat('yyyy-MM-dd').format(eventDate);

    final body = jsonEncode({
      'event_date': dateStr,
      'event_address': eventAddress,
      'is_same_ppe': isSamePpe,
    });

    final response = await _auth.authorizedPost(uri, body: body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final eventId = decoded['event_id'] as String?;

      if (eventId == null || eventId.trim().isEmpty) {
        return null;
      }

      return eventId;
    } catch (_) {
      return null;
    }
  }
}