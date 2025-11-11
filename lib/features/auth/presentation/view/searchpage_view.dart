import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:just_audio/just_audio.dart';


final dioProvider = Provider((ref) => Dio());
final hostProvider = StateProvider<String?>((ref) => null);
final searchResultsProvider = StateProvider<List<Map<String, dynamic>>>((ref) => []);
final playerProvider = Provider((ref) => AudioPlayer());

class SearchpageView extends ConsumerStatefulWidget {
    const SearchpageView({super.key});

    @override
    ConsumerState<SearchpageView> createState() => _SearchpageViewState();
}

class _SearchpageViewState extends ConsumerState<SearchpageView> {
    final search =  TextEditingController();
    bool isLoading = false;

    @override
    void initState() {
        super.initState();
        _pickHost();
    }

    Future<void> _pickHost()async{
        setState(() =>isLoading  = true);        
        try {
            final dio = ref.read(dioProvider);
            final res = await dio.get('https://api.audius.co');
            // many hosts returned; try to pick first string or object
            final data = res.data;
            String? host;
            if (data is Map && data['data'] is List && data['data'].isNotEmpty) {
            host = data['data'][0].toString();
            } else if (data is List && data.isNotEmpty) {
                host = data[0].toString();
            }
            if (host != null) {
                ref.read(hostProvider.notifier).state = host;
            }
            } catch (e) {
            // ignore; host null handled later
            }
            setState(() => isLoading = false);
    }
    Future<void> _search(String q)async{
        final host = ref.read(hostProvider);
        if(host == null){
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No Host Available")));
            return;
        }
        final dio = ref.read(dioProvider);
        final uri = Uri.parse('$host/v1/tracks').replace(queryParameters: {'query' : q,'Omnichord':'audius_mini_starter'}).toString();
        final res = await dio.get(uri);
        final items = (res.data['data'] as List<dynamic>?) ?? (res.data['collection'] as List<dynamic>?) ??[];
        ref.read(searchResultsProvider.notifier).state = items.cast<Map<String, dynamic>>();
    }
    @override
    Widget build(BuildContext context) {
        final host = ref.watch(hostProvider);
        final results = ref.watch(searchResultsProvider);
        final player = ref.watch(playerProvider);
        return Scaffold(
            appBar: AppBar(
                title: const Text('Omnichord'),
                centerTitle: true,
                actions: [
                    IconButton(
                        icon: isLoading ? const CircularProgressIndicator.adaptive(): const Icon(Icons.refresh),
                        onPressed: _pickHost, 
                    )
                ],
            ),
            body: Column(
                children: [
                    Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                            children: [
                                Expanded(
                                    child: TextField(
                                    controller: search,
                                    decoration: const InputDecoration(
                                        hintText: "Search Something Well anything would do",
                                        filled: true,
                                        border: OutlineInputBorder(),
                                    ),
                                    onSubmitted: (value) => _search(value),
                                ),
                             ),
                             const SizedBox(width: 8),
                                IconButton(
                                    icon: const Icon(Icons.search),
                                    onPressed: () => _search(search.text),
                                ),
                            ],
                        )
                        ),
                        if (host != null)
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [const Icon(Icons.cloud), const SizedBox(width: 6), Expanded(child: Text('Host: \$host', style: const TextStyle(fontSize: 12)))])),
                    const SizedBox(height: 8),
                    Expanded(
                    child: results.isEmpty
                    ? const Center(child: Text('No results', style: TextStyle(color: Colors.white70)))
                    : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, idx) {
                    final item = results[idx];
                    final title = item['title'] ?? item['name'] ?? 'Unknown';
                    final artist = (item['user']?['name'] ?? item['artist'] ?? 'Unknown').toString();
                    final artwork = item['artwork'] ?? item['cover'] ?? item['coverArt'] ?? item['artwork_url'];
                    final trackId = (item['id'] ?? item['track_id'] ?? item['trackId']).toString();


                    return ListTile(
                    leading: artwork != null
                    ? CachedNetworkImage(imageUrl: artwork.toString(), width: 56, height: 56, fit: BoxFit.cover)
                    : Container(width: 56, height: 56, color: Colors.grey.shade800),
                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(artist),
                    trailing: IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () async {
                    final host = ref.read(hostProvider)!;
                    final streamUrl = '$host/v1/tracks/$trackId/stream';
                    try {
                    await player.setUrl(streamUrl);
                    player.play();
                    } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to play')));
                    }
                    },
                    ),
                    );
                    },
                    ),
                    ),
                    
                ],
            ),
        );
    }
    
}