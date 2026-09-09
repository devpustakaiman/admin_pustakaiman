import 'url_helper_stub.dart'
    if (dart.library.html) 'url_helper_web.dart' as helper;

void updateBrowserUrl(String url) {
  helper.pushUrlState(url);
  helper.saveStoredRoute(url);
}

String? getSavedRoute() {
  return helper.getStoredRoute();
}

void initUrlPopStateListener(void Function(String path) onUrlChanged) {
  helper.listenToUrlChanges(onUrlChanged);
}
