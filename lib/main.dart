import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:omnichord/app.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Hiveservice().init();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.app.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(
    const ProviderScope(
      child: OmnichordApp(),
    )
  );
}