// lib/main.dart

import 'package:flutter/material.dart';
import 'package:fontper/providers/catalogo_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:fontper/utils/notification_helper.dart';
import 'package:fontper/utils/route_observer.dart';
import 'package:fontper/theme/fontper_theme.dart';

import 'package:fontper/providers/tipo_pieza_provider.dart';
import 'package:fontper/providers/pieza_provider.dart';
import 'package:fontper/providers/tarea_provider.dart';
import 'package:fontper/providers/pieza_tarea_provider.dart';
import 'package:fontper/providers/material_provider.dart';
import 'package:fontper/providers/tema_provider.dart';
import 'package:fontper/providers/imagenes_tarea_provider.dart';

import 'package:fontper/screens/tarea_general_screen.dart';
import 'package:fontper/screens/tarea_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationHelper.init();
  runApp(const FontPerApp());
}

class FontPerApp extends StatelessWidget {
  const FontPerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TipoPiezaProvider()..getAllTipos(),
        ),
        ChangeNotifierProvider(
          create: (_) => PiezaProvider()..getTodasLasPiezas(),
        ),
        ChangeNotifierProvider(create: (_) => TareaProvider()),
        ChangeNotifierProvider(create: (_) => PiezasTareaProvider()),
        ChangeNotifierProvider(create: (_) => MaterialProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ImagenTareaProvider()),
        ChangeNotifierProvider(create: (_) => CatalogoProvider()..loadAll()),

      ],
      child: Consumer<ThemeProvider>(
        builder: (context, tp, _) {
          // Splash mientras carga el tema
          if (!tp.cargado) {
            return const MaterialApp(
              home: Scaffold(
                backgroundColor: Colors.black,
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          // App principal
          return MaterialApp(
            navigatorObservers: [
              routeObserver,
              KeyboardHidingObserver(), // desenfoca al push/pop
            ],
            debugShowCheckedModeBanner: false,
            title: 'FontPer',
            theme: appTheme,
            darkTheme: appDarkTheme,
            themeMode: tp.mode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('es', 'ES'),
              Locale('en', 'US'),
            ],
            home: const TareaGeneralScreen(),
            routes: {
              '/nuevaTarea': (_) => const TareaScreen(),
            },
            builder: (ctx, child) {
              // Fondo según tema, sin GestureDetector que desenfoque
              final fondo = tp.mode == ThemeMode.dark
                  ? 'assets/fondo_oscuro.png'
                  : 'assets/fondo_claro.png';
              return Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      fondo,
                      key: ValueKey(fondo),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(child: child!),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
