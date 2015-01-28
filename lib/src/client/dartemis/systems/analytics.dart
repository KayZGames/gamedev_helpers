part of gamedev_helpers;

class AnalyticsSystem extends VoidEntitySystem {
  static const GITHUB = 1;
  static const ITCHIO = 2;
  final bool trackLocal;
  final int accountId;
  final String category;
  js.JsFunction _ga;
  AnalyticsSystem(this.accountId, this.category, {this.trackLocal: false});

  @override
  void initialize() {
    if (!trackLocal && '127.0.0.1' == window.location.hostname) {
      _ga = new _NopJsFunction();
    } else {
      _ga = js.context['ga'];
      _ga.apply(['create', 'UA-56073673-$accountId']);
      _ga.apply(['send', 'pageview']);
    }
    eventBus.on(AnalyticsTrackEvent).listen((AnalyticsTrackEvent event) {
      _ga.apply(['send', 'event', category, event.action, event.label]);
    });
  }

  @override
  void processSystem() {
    // do nothing
  }

  @override
  bool checkProcessing() => false;
}

class _NopJsFunction implements js.JsFunction {

  @override
  operator [](property) {}

  @override
  operator []=(property, value) {}

  @override
  apply(List args, {thisArg}) {}

  @override
  callMethod(String method, [List args]) {}

  @override
  void deleteProperty(String property) {}

  @override
  bool hasProperty(String property) => false;

  @override
  bool instanceof(js.JsFunction type) => false;
}