import 'package:flutter/material.dart';
import 'package:fontper/theme/fontper_theme.dart';
import 'package:provider/provider.dart';

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
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/fondo_app.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TipoPiezaProvider()..getAllTipos()),
          ChangeNotifierProvider(create: (_) => PiezaProvider()..getTodasLasPiezas()),
          ChangeNotifierProvider(create: (_) => TareaProvider()),
          ChangeNotifierProvider(create: (_) => PiezasTareaProvider()),
          ChangeNotifierProvider(create: (_) => MaterialProvider()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'FontPer',
          initialRoute: '/',
          routes: {
            '/nuevaTarea': (context) => const TareaScreen(),
          },
          theme: appTheme,
          home: const TareaGeneralScreen(),
        ),
      ),
    );
  }
}
