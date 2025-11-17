import 'package:flutter_riverpod/legacy.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:dio/dio.dart';
import 'package:omnichord/config/constants/audius_host_service.dart';

/// Holds track info
class Track {
  final String id;
  final String title;
  final String artist;
  final String artwork;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.artwork,
  });
}

/// AudioController manages playback, playlist, and current track state
class AudioController extends StateNotifier<Track?> {
  final AudioPlayer _player = AudioPlayer();
  final Dio _dio = Dio();

  // Playlist management
  List<Track> _playlist = [];
  int _currentIndex = -1;

  AudioController() : super(null);

  AudioPlayer get player => _player;

  /// Sets the current playlist (used by SearchPage or other list views)
  void setPlaylist(List<Track> tracks) {
    _playlist = tracks;
  }

  /// Play a specific track (optionally pass a new playlist)
  Future<void> playTrack(Track track, {List<Track>? playlist}) async {
    try {
      await _player.stop();
      

      if (playlist != null) {
        setPlaylist(playlist);
        _currentIndex = _playlist.indexWhere((t) => t.id == track.id);
      } else {
        _currentIndex = _playlist.indexWhere((t) => t.id == track.id);
      }

      // Get dynamic host
      final host = await AudiusHostService.getBaseHost();

      // Construct full stream URL
      final streamUrl = '$host/v1/tracks/${track.id}/stream?app_name=Omnichord';

      // Handle redirect manually
      final response = await _dio.head(
        streamUrl,
        options: Options(followRedirects: false, validateStatus: (_) => true),
      );
      final redirectUrl = response.headers.value('location') ?? streamUrl;

      // Set up audio source
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(redirectUrl),
          tag: MediaItem(
            id: track.id,
            title: track.title,
            artist: track.artist,
            artUri: Uri.parse(track.artwork),
          ),
        ),
      );

      // Start playback
      await _player.play();
      state = track;
    } catch (e) {
      print('❌ Error playing track: $e');
    }
  }

  /// Go to next track
  Future<void> next() async {
    if (_playlist.isEmpty) return;

    _currentIndex = (_currentIndex + 1) % _playlist.length;
    final nextTrack = _playlist[_currentIndex];
    await playTrack(nextTrack);
  }

  /// Go to previous track
  Future<void> previous() async {
    if (_playlist.isEmpty) return;

    _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
    final prevTrack = _playlist[_currentIndex];
    await playTrack(prevTrack);
  }

  Future<void> pause() async => await _player.pause();

  Future<void> resume() async => await _player.play();

  Future<void> stop() async {
    await _player.stop();
    state = null;
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

/// Provider for the audio controller
final audioControllerProvider = StateNotifierProvider<AudioController, Track?>(
  (ref) => AudioController(),
);
