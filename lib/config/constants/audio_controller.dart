// lib/controllers/audio_controller.dart
import 'package:flutter_riverpod/legacy.dart';
import 'package:just_audio/just_audio.dart';
import 'package:dio/dio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:omnichord/config/constants/track.dart';

final audioControllerProvider = StateNotifierProvider<AudioController, Track?>(
  (ref) => AudioController(),
);

class AudioController extends StateNotifier<Track?> {
  final AudioPlayer _player = AudioPlayer();
  final Dio _dio = Dio();

  // playlist & pointer
  List<Track> _playlist = [];
  int _currentIndex = -1;

  AudioController() : super(null);

  AudioPlayer get player => _player;

  bool get isPlaying => _player.playing;
  Stream<Duration> get positionStream => _player.positionStream;
  Duration? get duration => _player.duration;

  void setPlaylist(List<Track> tracks, {int startIndex = 0}) {
    _playlist = List<Track>.from(tracks);
    _currentIndex = startIndex.clamp(0, _playlist.length - 1);
  }
  String? _extractSaavnUrl(dynamic item) {
    if (item == null) return null;

    // Case 1: downloadUrl (array or string)
    if (item["downloadUrl"] != null) {
      final d = item["downloadUrl"];

      if (d is List && d.isNotEmpty) {
        final el = d.first;
        if (el is Map && el["link"] != null) return el["link"];
        if (el is String) return el;
      }

      if (d is String) return d;
    }

    // Case 2: downloadUrlMap (bitrate-specific)
    if (item["downloadUrlMap"] != null) {
      final map = item["downloadUrlMap"];
      if (map["320"]?["link"] != null) return map["320"]["link"];
      if (map["160"]?["link"] != null) return map["160"]["link"];
      if (map["96"]?["link"] != null) return map["96"]["link"];
    }

    // Case 3: preview URLs
    if (item["media_url"] != null) return item["media_url"];
    if (item["media_preview_url"] != null) return item["media_preview_url"];

    // Case 4: encrypted URLs
    if (item["more_info"]?["encrypted_media_url"] != null) {
      return item["more_info"]["encrypted_media_url"];
    }

    return null;
  }


  Future<String?> _resolveSaavnAudioUrl(String id) async {
    try {
      // ---------------------------------------------------------
      // 🔍 Attempt #1 — Search for the song (id or title)
      // ---------------------------------------------------------
      final safeQuery = Uri.encodeComponent(id);

      final searchRes = await _dio.get(
        'https://saavn.dev/api/search/songs?query=$safeQuery',
      );

      if (searchRes.statusCode == 200 && searchRes.data != null) {
        final data = searchRes.data;

        // Normalize list
        List<dynamic>? items;
        if (data is Map && data['data'] is List) {
          items = data['data'];
        } else if (data is Map && data['results'] is List) {
          items = data['results'];
        }

        if (items != null && items.isNotEmpty) {
          // Pick best match OR fallback to first
          final found = items.firstWhere(
            (it) =>
                it['id']?.toString() == id ||
                it['songid']?.toString() == id ||
                (it['perma_url']?.toString() ?? '').contains(id),
            orElse: () => items!.first,
          );

          // Try different URL formats
          final url = _extractSaavnUrl(found);
          if (url != null) return url;
        }
      }
    } catch (_) {
      // silent fail → try next method
    }

    try {
      // ---------------------------------------------------------
      // 🔍 Attempt #2 — Get direct song details
      // ---------------------------------------------------------
      final res = await _dio.get('https://saavn.dev/api/song/$id');

      if (res.statusCode == 200 && res.data != null) {
        final d = res.data;

        // Direct "downloadUrl" array
        final url = _extractSaavnUrl(d);
        if (url != null) return url;

        // Some wrappers return inside "data"
        if (d is Map && d["data"] != null) {
          final inner = d["data"];
          final innerUrl = _extractSaavnUrl(inner);
          if (innerUrl != null) return innerUrl;
        }
      }
    } catch (_) {
      // still silent
    }

    // ---------------------------------------------------------
    // ❌ If nothing works
    // ---------------------------------------------------------
    return null;
  }


  Future<void> playTrack(Track track, {List<Track>? playlist}) async {
    try {
      // if playlist passed, set it and choose index
      if (playlist != null) {
        _playlist = List.from(playlist);
        _currentIndex = _playlist.indexWhere((t) => t.id == track.id);
      } else {
        // ensure current index points to this track if present
        final idx = _playlist.indexWhere((t) => t.id == track.id);
        if (idx >= 0) _currentIndex = idx;
      }

      // update UI immediately so PlayerBar shows new title (fixes lag)
      state = track;

      // ensure audioUrl exists — fetch lazily if needed
      if (track.audioUrl == null || track.audioUrl!.isEmpty) {
        final url = await _resolveSaavnAudioUrl(track.id);
        if (url == null || url.isEmpty) {
          // failed to fetch url
          throw Exception('No streamable URL found for this track.');
        }
        // prioritize 160kbps when downloadUrlMap exists; some URLs include bitrate param - we'll pick 160 if available
        // Many providers already return a direct URL chosen by us here; if url contains "320" or "160" you can adjust.
        track.audioUrl = url;
      }

      // stop any previous playback and set source
      await _player.stop();
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(track.audioUrl!),
          tag: MediaItem(
            id: track.id,
            album: '',
            title: track.title,
            artist: track.artist,
            artUri: Uri.parse(track.artwork),
          ),
        ),
      );
      await _player.play();
    } catch (e) {
      // revert state if play failed (keep previous track visible)
      print('❌ Error playing track: $e');
      rethrow;
    }
  }

  Future<void> pause() => _player.pause();
  Future<void> resume() => _player.play();

  Future<void> next() async {
    if (_playlist.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % _playlist.length;
    final nextTrack = _playlist[_currentIndex];
    await playTrack(nextTrack);
  }

  Future<void> previous() async {
    if (_playlist.isEmpty) return;
    _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
    final prevTrack = _playlist[_currentIndex];
    await playTrack(prevTrack);
  }

  Future<void> seek(Duration position) => _player.seek(position);

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
