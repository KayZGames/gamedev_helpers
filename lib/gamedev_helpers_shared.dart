library gamedev_helpers_shared;

import 'dart:async';
import 'dart:math';

import 'package:dartemis/dartemis.dart';

import 'package:event_bus/event_bus.dart' as event_bus;
import 'package:tweenengine/tweenengine.dart';
import 'package:vector_math/vector_math.dart' hide Quad;

export 'dart:math';
export 'package:dartemis/dartemis.dart';
export 'package:tweenengine/tweenengine.dart';
export 'package:vector_math/vector_math.dart' hide Quad;

part 'src/shared/dartemis/systems/tweening.dart';
part 'src/shared/dartemis/systems/simple_acceleration_system.dart';
part 'src/shared/dartemis/systems/simple_gravity_system.dart';
part 'src/shared/dartemis/systems/simple_movement_system.dart';
part 'src/shared/dartemis/systems/animation_system.dart';
part 'src/shared/dartemis/managers/web_gl_view_projection_matrix_manager.dart';
part 'src/shared/dartemis/managers/camera_manager.dart';
part 'src/shared/dartemis/components.dart';
part 'src/shared/event_bus.dart';

part 'gamedev_helpers_shared.g.dart';

final EventBus eventBus = EventBus();

final Random random = Random();

final TweenManager tweenManager = TweenManager();
const String playerTag = 'player';
const String cameraTag = 'camera';

class AnalyticsTrackEvent {
  String action;
  String label;
  AnalyticsTrackEvent(this.action, this.label);
}

/// Converts [h][s][l] to rgb. All values between 0.0 and 1.0.
List<double> hslToRgb(double h, double s, double l) {
  double r, g, b;
  if (s == 0.0) {
    r = g = b = l;
  } else {
    final num q = l < 0.5 ? l * (1 + s) : l + s - l * s;
    final num p = 2 * l - q;
    r = _hue2rgb(p, q, h + 1 / 3);
    g = _hue2rgb(p, q, h);
    b = _hue2rgb(p, q, h - 1 / 3);
  }
  return [r, g, b];
}

num _hue2rgb(num p, num q, num t) {
  var tNorm = t;
  if (tNorm < 0) {
    tNorm += 1;
  } else if (tNorm > 1) {
    tNorm -= 1;
  }
  if (tNorm < 1 / 6) {
    return p + (q - p) * 6 * tNorm;
  }
  if (tNorm < 1 / 2) {
    return q;
  }
  if (tNorm < 2 / 3) {
    return p + (q - p) * (2 / 3 - tNorm) * 6;
  }
  return p;
}

/// Converts rgb to hsl. All values between 0.0 and 1.0.
List<double> rgbToHsl(double red, double green, double blue) {
  final double maxv = max(max(red, green), blue),
      minv = min(min(red, green), blue);
  final l = (maxv + minv) / 2.0;
  double h, s;

  if (maxv == minv) {
    h = s = 0.0; // achromatic
  } else {
    final num d = maxv - minv;
    s = l > 0.5 ? d / (2.0 - maxv - minv) : d / (maxv + minv);
    if (maxv == red) {
      h = (green - blue) / d + (green < blue ? 6.0 : 0.0);
    } else if (maxv == green) {
      h = (blue - red) / d + 2.0;
    } else if (maxv == blue) {
      h = (red - green) / d + 4.0;
    }
    h /= 6.0;
  }
  return [h, s, l];
}
