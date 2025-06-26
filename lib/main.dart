import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fontper/theme/fontper_theme.dart';
import 'package:fontper/providers/tema_provider.dart';
import 'package:fontper/providers/material_provider.dart';
import 'package:fontper/providers/pieza_provider.dart';
import 'package:fontper/providers/pieza_tarea_provider.dart';
import 'package:fontper/providers/tarea_provider.dart';
import 'package:fontper/providers/tipo_pieza_provider.dart';

import 'package:fontper/screens/tarea_general_screen.dart';
import 'package:fontper/screens/tarea_screen.dart';

void main() {
  runApp(const FontPerApp());
}

class FontPerApp extends StatelessWidget {
  const FontPerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TipoPiezaProvider()..getAllTipos()),
        ChangeNotifierProvider(create: (_) => PiezaProvider()..getTodasLasPiezas()),
        ChangeNotifierProvider(create: (_) => TareaProvider()),
        ChangeNotifierProvider(create: (_) => PiezasTareaProvider()),
        ChangeNotifierProvider(create: (_) => MaterialProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, tp, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'FontPer',
            initialRoute: '/',
            routes: {
              '/nuevaTarea': (_) => const TareaScreen(),
            },
            theme: appTheme,
            darkTheme: appDarkTheme,
            themeMode: tp.mode,

            // 👇 Esta es la clave
            builder: (context, child) {
              final fondo = tp.mode == ThemeMode.dark
                  ? 'assets/fondo_oscuro.png'
                  : 'assets/fondo_claro.png';

              return Stack(
                children: [
                  Positioned.fill(
                    child: Image(
                      image: AssetImage(fondo),
                      key: UniqueKey(), // 👈 fuerza recarga 100%
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(child: child!),
                ],
              );
            },
            home: const TareaGeneralScreen(),
          );
        },
      ),
    );
  }
}
