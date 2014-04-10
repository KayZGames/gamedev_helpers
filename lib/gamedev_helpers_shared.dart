library gamedev_helpers_shared;

import 'package:dartemis/dartemis_mirrors.dart';
export 'package:dartemis/dartemis_mirrors.dart';

import 'package:vector_math/vector_math.dart';
export 'package:vector_math/vector_math.dart';

import 'package:event_bus/event_bus.dart';
export 'package:event_bus/event_bus.dart';

part 'src/shared/dartemis/components.dart';

final eventBus = new EventBus();

final analyticsTrackEvent = new EventType<AnalyticsTrackEvent>();

class AnalyticsTrackEvent {
  String category;
  String action;
  String label;
  AnalyticsTrackEvent(this.category, this.action, this.label);
}