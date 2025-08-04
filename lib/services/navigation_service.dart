import 'package:flutter/material.dart';

import '../models/pieza_tarea.dart';
import '../screens/selector_piezas_screen.dart';

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

Future<List<PiezasTarea>?> openSelectorPiezas(
    BuildContext context,
    List<PiezasTarea> iniciales,
    ) {
  return Navigator.of(context).push<List<PiezasTarea>>(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) =>
          SelectorPiezasScreen(piezasSeleccionadas: iniciales),
      transitionDuration: const Duration(milliseconds: 150),
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
    ),
  );
}