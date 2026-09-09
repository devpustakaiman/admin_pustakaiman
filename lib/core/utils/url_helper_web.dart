// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

void pushUrlState(String url) {
  try {
    final location = html.window.location;
    final currentPath = location.pathname ?? '';
    final currentHash = location.hash;

    if (currentPath != url && currentHash != '#$url' && currentHash != '#/$url') {
      html.window.history.pushState(null, '', url);
    }
  } catch (_) {}
}

String? getStoredRoute() {
  try {
    return html.window.localStorage['admin_active_route'];
  } catch (_) {
    return null;
  }
}

void saveStoredRoute(String route) {
  try {
    html.window.localStorage['admin_active_route'] = route;
  } catch (_) {}
}

void listenToUrlChanges(void Function(String path) onUrlChanged) {
  try {
    html.window.onPopState.listen((_) {
      try {
        final location = html.window.location;
        String path = location.pathname ?? '';
        if (path.isEmpty || path == '/') {
          final hash = location.hash;
          if (hash.startsWith('#')) {
            path = hash.substring(1);
          }
        }
        if (path.isNotEmpty) {
          onUrlChanged(path);
        }
      } catch (_) {}
    });
  } catch (_) {}
}
