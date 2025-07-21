import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Para desfocar/form esconder teclado al navegar
class KeyboardHidingObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    FocusManager.instance.primaryFocus?.unfocus();
  }
}

/// Si quieres seguir usando RouteObserver para RouteAware…
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
