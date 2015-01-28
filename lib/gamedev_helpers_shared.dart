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

final random = new Random();

final tweenManager = new TweenManager();

class AnalyticsTrackEvent {
  String action;
  String label;
  AnalyticsTrackEvent(this.action, this.label);
}