import 'package:omnichord/features/auth/presentation/view/searchpage_view.dart';
import 'package:omnichord/features/auth/presentation/view/splashscreen_view.dart';

class AppRoutes {
  AppRoutes._();
  static const String splashscreenRoute = '/SlashscreenView';
  static const String homeRoute = '/home';
  static getApplicaton(){
    return {
      splashscreenRoute: (context) => const SplashscreenView(),
      homeRoute: (context) => const SearchpageView(),
    };
  }
}