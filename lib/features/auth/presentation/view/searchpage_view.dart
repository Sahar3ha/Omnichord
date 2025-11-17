import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnichord/features/auth/data/model/video_model.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';



class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _YouTubeSearchPageState();
}

class _YouTubeSearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  void _startSearch() {
    setState(() {}); // Rebuild to refresh provider with new query
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = _searchController.text;
    final searchResults = ref.watch(youtubeSearchProvider(searchQuery));

    return Scaffold(
      appBar: AppBar(title: const Text('Search YouTube Music')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search songs or artists',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _startSearch,
                ),
              ),
              onSubmitted: (_) => _startSearch(),
            ),
          ),
          Expanded(
            child: searchResults.when(
              data: (videos) {
                if (videos.isEmpty) {
                  return const Center(child: Text('No results found'));
                }
                return ListView.builder(
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return ListTile(
                      leading: Image.network(video.thumbnailUrl),
                      title: Text(video.title),
                      subtitle: Text(video.channelTitle),
                      onTap: () {
                        ref.read(currentVideoIdProvider.notifier).state =
                            video.videoId;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AudioOnlyPlayerScreen(videoId: video.videoId),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

class AudioOnlyPlayerScreen extends ConsumerStatefulWidget {
  final String videoId;

  const AudioOnlyPlayerScreen({required this.videoId, super.key});

  @override
  ConsumerState<AudioOnlyPlayerScreen> createState() =>
      _AudioOnlyPlayerScreenState();
}

class _AudioOnlyPlayerScreenState extends ConsumerState<AudioOnlyPlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        isLive: false,
        forceHD: false,
        useHybridComposition: true,
        controlsVisibleAtStart: true,
        hideControls: false,
        disableDragSeek: false,
        hideThumbnail: false,
        showLiveFullscreenButton: true,
        loop: false,
    
      
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Playing Audio')),
      body: Column(
        children: [
          SizedBox(
            height: 0,
            width: 0,
            child: YoutubePlayer(controller: _controller),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Playing video ID: ${widget.videoId}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
              setState(() {});
            },
            child: Text(_controller.value.isPlaying ? 'Pause' : 'Play'),
          ),
        ],
      ),
    );
  }
}
