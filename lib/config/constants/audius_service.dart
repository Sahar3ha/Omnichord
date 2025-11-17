import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audiusServiceProvider = Provider<AudiusService>((ref) {
  return AudiusService();
});

class AudiusService {
  final Dio _dio = Dio();
  String? _baseUrl;
  List<String>? _hosts;

  /// Fetch and cache available discovery nodes
  Future<List<String>> _getHosts() async {
    if (_hosts != null && _hosts!.isNotEmpty) return _hosts!;
    try {
      final response = await _dio.get('https://api.audius.co');
      final List data = response.data['data'];
      _hosts = data.cast<String>();
      return _hosts!;
    } catch (e) {
      throw Exception('Failed to fetch Audius hosts: $e');
    }
  }

  /// Get a valid working host
  Future<String> _getHost() async {
    final hosts = await _getHosts();
    for (final host in hosts) {
      try {
        await _dio.get('$host/health_check');
        _baseUrl = host;
        return _baseUrl!;
      } catch (_) {
        continue; // try next host if one fails
      }
    }
    throw Exception('No working Audius hosts found');
  }

  /// Search tracks
  Future<List<Map<String, dynamic>>> searchTracks(String query) async {
    final host = await _getHost();
    final url = '$host/v1/tracks/search';
    try {
      final response = await _dio.get(
        url,
        queryParameters: {'query': query, 'app_name': 'Omnichord', 'limit': 20},
      );
      final List data = response.data['data'];
      return data
          .map(
            (track) => {
              'id': track['id'],
              'title': track['title'],
              'artist': track['user']['name'],
              'artwork':
                  track['artwork']['150x150'] ?? track['artwork']['480x480'],
              'stream_url':
                  '$host/v1/tracks/${track["id"]}/stream?app_name=Omnichord',
            },
          )
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.message?.contains('Connection reset by peer') == true) {
        // try another host
        _baseUrl = null;
        return await searchTracks(query);
      }
      rethrow;
    }
  }
}
