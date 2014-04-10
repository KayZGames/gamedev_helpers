part of gamedev_helpers;

class AnalyticsSystem extends VoidEntitySystem {
  static const GITHUB = 1;
  static const ITCHIO = 2;
  final bool trackLocal;
  final int accountId;
  js.JsObject _gaq;
  AnalyticsSystem(this.accountId, {this.trackLocal: false});

  @override
  void initialize() {
    if (!trackLocal && '127.0.0.1' == window.location.hostname) {
      _gaq = new _NopJsObject();
    } else {
      _gaq = js.context['_gaq'];
      _gaq.callMethod('push', [new js.JsArray.from(['_setAccount', 'UA-40549999-$accountId'])]);
      _gaq.callMethod('push', [new js.JsArray.from(['_trackPageview'])]);
    }
    eventBus.on(analyticsTrackEvent).listen((AnalyticsTrackEvent event) {
      _gaq.callMethod('push', [new js.JsArray.from(['_trackEvent', event.category, event.action, event.label])]);
    });
  }

  @override
  void processSystem() {
    // do nothing
  }

  @override
  bool checkProcessing() => false;
}

class _NopJsObject implements js.JsObject {

  @override
  operator [](property) {}

  @override
  operator []=(property, value) {}

  @override
  callMethod(String method, [List args]) {}

  @override
  void deleteProperty(String property) {}

  @override
  bool hasProperty(String property) => false;

  @override
  bool instanceof(js.JsFunction type) => false;
}