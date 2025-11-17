import 'package:dio/dio.dart';

/// A simple class to always get a valid Audius API host dynamically.
class AudiusHostService {
  static final Dio _dio = Dio();
  static String? _cachedHost;

  /// Fetches a valid Audius discovery node (with caching).
  static Future<String> getBaseHost() async {
    if (_cachedHost != null) return _cachedHost!;

    try {
      final response = await _dio.get('https://api.audius.co');
      final host = (response.data['data'] as List).first;
      _cachedHost = host;
      return host;
    } catch (e) {
      print('⚠️ Error fetching Audius host: $e');
      return 'https://discoveryprovider.audius.co'; // fallback
    }
  }
}
