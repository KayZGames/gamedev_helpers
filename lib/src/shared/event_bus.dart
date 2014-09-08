part of gamedev_helpers_shared;

class EventBus {
  final eventBus = new event_bus.EventBus();
  final eventBusSync = new event_bus.EventBus(sync: true);

  void destroy() {
    eventBus.destroy();
    eventBusSync.destroy();
  }

  void fire(event, {bool sync: false}) {
    if (sync) {
      eventBusSync.fire(event);
    } else {
      eventBus.fire(event);
    }
  }

  Stream on([Type eventType]) {
    var sc = new StreamController.broadcast(sync: true);
    var countDone = 0;
    done() {
      countDone++;
      if (countDone == 2) {
        sc.close();
      }
    }
    eventBus.on(eventType).listen((data) => sc.add(data), onDone: done);
    eventBusSync.on(eventType).listen((data) => sc.add(data), onDone: done);
    return sc.stream;
  }
}
