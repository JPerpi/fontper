import 'package:flutter/material.dart';

/// Solo desenfoca el foco al cambiar de rutas,
/// pero NO llama a TextInput.hide().
class KeyboardHidingObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    FocusManager.instance.primaryFocus?.unfocus();
  }
}

/// Si lo usabas en pantallas RouteAware:
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
