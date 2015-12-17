library gamedev_helpers_shared;

import 'dart:math';
export 'dart:math';
import 'dart:async';

import 'package:dartemis/dartemis.dart';
export 'package:dartemis/dartemis.dart';

import 'package:event_bus/event_bus.dart' as event_bus;
import 'package:tweenengine/tweenengine.dart';
export 'package:tweenengine/tweenengine.dart';
import 'package:vector_math/vector_math.dart';
export 'package:vector_math/vector_math.dart';

part 'src/shared/dartemis/systems/tweening.dart';
part 'src/shared/dartemis/components.dart';
part 'src/shared/event_bus.dart';

final eventBus = new EventBus();

final Random random = new Random();

final tweenManager = new TweenManager();

class AnalyticsTrackEvent {
  String action;
  String label;
  AnalyticsTrackEvent(this.action, this.label);
}

/**
 * Converts [h][s][l] to rgb. All values between 0.0 and 1.0.
 */
List<double> hslToRgb(double h, double s, double l) {
  double r, g, b;
  if (s == 0.0) {
    r = g = b = l;
  } else {
    num q = l < 0.5 ? l * (1 + s) : l + s - l * s;
    num p = 2 * l - q;
    r = _hue2rgb(p, q, h + 1 / 3);
    g = _hue2rgb(p, q, h);
    b = _hue2rgb(p, q, h - 1 / 3);
  }
  return [r, g, b];
}

num _hue2rgb(num p, num q, num t) {
  if (t < 0) t += 1;
  if (t > 1) t -= 1;
  if (t < 1 / 6) return p + (q - p) * 6 * t;
  if (t < 1 / 2) return q;
  if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
  return p;
}

/**
 * Converts [r][g][b] to hsl. All values between 0.0 and 1.0.
 */
List<double> rgbToHsl(double red, double green, double blue) {
  int maxv = max(max(red, green), blue),
      minv = min(min(red, green), blue);
  double h, s, l = (maxv + minv) / 2.0;

  if(maxv == minv) {
    h = s = 0.0; // achromatic
  } else {
    num d = maxv - minv;
    s = l > 0.5 ? d / (2.0 - maxv - minv) : d / (maxv + minv);
    if (maxv == red) {
      h = (green - blue) / d + (green < blue ? 6 : 0);
    } else if (maxv == green) {
      h = (blue - red) / d + 2;
    } else if (maxv == blue) {
      h = (red - green) / d + 4;
    }
    h /= 6.0;
  }
  return [h, s, l];
}