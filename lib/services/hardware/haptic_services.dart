import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

import '../../provider/haptic_state_provider.dart';

enum CustomHapticsType {
  success,
  warning,
  error,
  light,
  medium,
  heavy,
  rigid,
  soft,
  selection,
}

class HapticServices {
  static Future<void> vibrate(WidgetRef ref, CustomHapticsType type) async {
    // Haptic feedback for success
    final allowVibrate = ref.watch(vibrationStateProvider);

    if (allowVibrate) {
      switch (type) {
        case CustomHapticsType.success:
          await Haptics.vibrate(HapticsType.success);
          break;
        case CustomHapticsType.warning:
          await Haptics.vibrate(HapticsType.warning);
          break;
        case CustomHapticsType.error:
          await Haptics.vibrate(HapticsType.error);
          break;
        case CustomHapticsType.light:
          await Haptics.vibrate(HapticsType.light);
          break;
        case CustomHapticsType.medium:
          await Haptics.vibrate(HapticsType.medium);
          break;
        case CustomHapticsType.heavy:
          await Haptics.vibrate(HapticsType.heavy);
          break;
        case CustomHapticsType.rigid:
          await Haptics.vibrate(HapticsType.rigid);
          break;
        case CustomHapticsType.soft:
          await Haptics.vibrate(HapticsType.soft);
          break;
        case CustomHapticsType.selection:
          await Haptics.vibrate(HapticsType.selection);
          break;
      }
    }
  }
}
