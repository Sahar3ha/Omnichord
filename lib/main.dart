import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:omnichord/app.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Hiveservice().init();
  
  runApp(
    const ProviderScope(
      child: OmnichordApp(),
    )
  );
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.omnichord.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
}