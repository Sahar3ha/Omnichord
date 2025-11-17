import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';

// Replace with your actual API key here
const String youtubeApiKey = 'AIzaSyAX-0vfvQ3FQmaM3w35OMeu5Gy-23x81-c';

class VideoItem {
  final String videoId;
  final String title;
  final String channelTitle;
  final String thumbnailUrl;

  VideoItem({
    required this.videoId,
    required this.title,
    required this.channelTitle,
    required this.thumbnailUrl,
  });
}

// Provider that fetches videos based on a search query
final youtubeSearchProvider = FutureProvider.family<List<VideoItem>, String>((
  ref,
  query,
) async {
  if (query.isEmpty) return [];

  final dio = Dio();
  final response = await dio.get(
    'https://www.googleapis.com/youtube/v3/search',
    queryParameters: {
      'part': 'snippet',
      'q': query,
      'type': 'video',
      'key': youtubeApiKey,
      'maxResults': 25,
    },
  );

  final items = response.data['items'] as List<dynamic>;
  return items.map((item) {
    final id = item['id']['videoId'] as String;
    final snippet = item['snippet'];
    return VideoItem(
      videoId: id,
      title: snippet['title'] as String,
      channelTitle: snippet['channelTitle'] as String,
      thumbnailUrl: snippet['thumbnails']['default']['url'] as String,
    );
  }).toList();
});

final currentVideoIdProvider = StateProvider<String?>((ref) => null);
