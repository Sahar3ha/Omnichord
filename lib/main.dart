import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:just_audio_background/just_audio_background.dart';
import 'package:omnichord/app.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Hiveservice().init();
  
  runApp(
    const ProviderScope(
      child: OmnichordApp(),
    )
  );
  // await JustAudioBackground.init(
  //   androidNotificationChannelId: 'com.example.omnichord.channel.audio',
  //   androidNotificationChannelName: 'Audio playback',
  //   androidNotificationOngoing: true,
  // );
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:omnichord/features/auth/presentation/view/searchpage_view.dart';

// void main() {
//   runApp(const ProviderScope(child: OmnichordApp()));
// }

// class OmnichordApp extends StatelessWidget {
//   const OmnichordApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'YouTube Music Search',
//       theme: ThemeData.dark(),
//       home: const SearchPage(),
//     );
//   }
// }
