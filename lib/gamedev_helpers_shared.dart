library gamedev_helpers_shared;

import 'dart:math';
export 'dart:math';

import 'package:dartemis/dartemis_mirrors.dart';
export 'package:dartemis/dartemis_mirrors.dart';

import 'package:vector_math/vector_math.dart';
export 'package:vector_math/vector_math.dart';

import 'package:event_bus/event_bus.dart';
export 'package:event_bus/event_bus.dart';

part 'src/shared/dartemis/components.dart';

final eventBus = new EventBus();
final random = new Random();

final analyticsTrackEvent = new EventType<AnalyticsTrackEvent>();

class AnalyticsTrackEvent {
  String action;
  String label;
  AnalyticsTrackEvent(this.action, this.label);
}