import 'package:flutter/material.dart';
import 'package:omnichord/config/routes/app_routes.dart';

class OmnichordApp extends StatelessWidget {
  const OmnichordApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Omnichord',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: AppRoutes.splashscreenRoute,
      routes: AppRoutes.getApplicaton(),
    );
  }
}