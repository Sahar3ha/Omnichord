import 'package:flutter/material.dart';
import 'package:omnichord/config/routes/app_routes.dart';
import 'package:omnichord/config/themes/apptheme.dart';

class OmnichordApp extends StatelessWidget {
  const OmnichordApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Omnichord',
      theme: omnichordAppTheme(),
      initialRoute: AppRoutes.splashscreenRoute,
      routes: AppRoutes.getApplicaton(),
    );
  }
}