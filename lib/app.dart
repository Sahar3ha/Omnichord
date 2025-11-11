import 'package:flutter/material.dart';
import 'package:omnichord/config/routes/app_routes.dart';

class OmnichordApp extends StatelessWidget {
  const OmnichordApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Omnichord',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F1115),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green,
        ).copyWith(
          secondary: Colors.greenAccent,
        ),
        appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        ),
      ),
      initialRoute: AppRoutes.splashscreenRoute,
      routes: AppRoutes.getApplicaton(),
    );
  }
}