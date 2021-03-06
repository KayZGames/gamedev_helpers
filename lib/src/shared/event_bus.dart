part of gamedev_helpers_shared;

class EventBus {
  final event_bus.EventBus eventBus = event_bus.EventBus();
  final event_bus.EventBus eventBusSync = event_bus.EventBus(sync: true);

  void destroy() {
    eventBus.destroy();
    eventBusSync.destroy();
  }

  void fire(Object event, {bool sync = false}) {
    if (sync) {
      eventBusSync.fire(event);
    } else {
      eventBus.fire(event);
    }
  }

  Stream on<T>() {
    final sc = StreamController.broadcast(sync: true);
    var countDone = 0;
    void done() {
      countDone++;
      if (countDone == 2) {
        sc.close();
      }
    }

    eventBus.on<T>().listen(sc.add, onDone: done);
    eventBusSync.on<T>().listen(sc.add, onDone: done);
    return sc.stream;
  }
}
