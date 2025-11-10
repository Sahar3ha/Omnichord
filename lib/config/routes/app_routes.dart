import 'package:omnichord/features/auth/presentation/view/splashscreen_view.dart';

class AppRoutes {
  AppRoutes._();
  static const String splashscreenRoute = '/SlashscreenView';
  
  static getApplicaton(){
    return {
      splashscreenRoute: (context) => const SplashscreenView(),
    };
  }
}