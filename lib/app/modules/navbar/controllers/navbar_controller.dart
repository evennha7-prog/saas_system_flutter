import 'package:get/get.dart';
import 'package:vibration/vibration.dart';

class NavbarController extends GetxController {
  // Current tab index (0: Home, 1: Sales, 2: Scanner, 3: Lists, 4: Profile)
  final currentIndex = 0.obs;

  void changePage(int index) async {
    if (currentIndex.value != index) {
      currentIndex.value = index;
      _triggerHapticFeedback();
    }
  }

  void _triggerHapticFeedback() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        // Subtle 50ms vibration feedback on tab click
        Vibration.vibrate(duration: 50);
      }
    } catch (_) {}
  }
}

