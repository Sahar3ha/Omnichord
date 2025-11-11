import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlayerBar extends StatefulWidget {
  final AudioPlayer player;
  const PlayerBar({required this.player, super.key});

  @override
  State<PlayerBar> createState() => _PlayerBarState();
}

class _PlayerBarState extends State<PlayerBar> {
  bool isplaying = false;

  @override
  void initState() {
    super.initState();
    widget.player.playerStateStream.listen((state) {
      final playing = state.playing;
      if (mounted) setState(() => isplaying = playing);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.grey.shade900),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.black26,
            child: Icon(Icons.music_note),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Playing", style: TextStyle(fontWeight: FontWeight.w600)),
                Text('Artist Name', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(isplaying? Icons.pause_circle_filled:Icons.play_circle_fill,size: 36,),
            onPressed: (){
              if(isplaying){
                widget.player.pause();
              }else{
                widget.player.play();
              }
            }, )
        ],
      ),
    );
  }
}
