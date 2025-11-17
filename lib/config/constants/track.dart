// lib/models/track.dart
class Track {
  final String id;
  final String title;
  final String artist;
  final String artwork;
  String? audioUrl; // will be fetched lazily when play is requested
  final Duration? duration;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.artwork,
    this.audioUrl,
    this.duration,
  });

  // convenience for creating from dynamic JSON (robust/fallback parsing)
  factory Track.fromSaavn(dynamic t) {
    // Try a few common field names used by various unofficial Saavn wrappers
    final id = (t['id'] ?? t['songId'] ?? t['perma_url'] ?? t['hlink'] ?? '').toString();
    final title = (t['title'] ?? t['song'] ?? t['name'] ?? '').toString();
    final artist = (t['primaryArtists'] ??
            t['singers'] ??
            t['subtitle'] ??
            (t['more_info']?['primary_artists']) ??
            '')
        .toString();
    String artwork = '';
    try {
      artwork = (t['image'] ??
              t['images']?['coverArt'] ??
              t['album']?['cover'] ??
              t['more_info']?['album_image']) ??
          '';
    } catch (_) {
      artwork = '';
    }
    // fallback placeholder
    if (artwork == '') artwork = 'https://via.placeholder.com/150';

    return Track(
      id: id,
      title: title.isEmpty ? 'Unknown Title' : title,
      artist: artist.isEmpty ? 'Unknown Artist' : artist,
      artwork: artwork,
      duration: null,
    );
  }
}
