import 'package:get/get.dart';
import '../screens/home_screen.dart';
import '../screens/video_call_screen.dart';
import '../bindings/video_call_binding.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    GetPage(
      name: AppRoutes.videoCall,
      page: () => const VideoCallScreen(),
      binding: VideoCallBinding(),
    ),
  ];
}
