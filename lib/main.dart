import 'package:flutter/material.dart';
import 'package:fontper/services/notifications_services.dart';
import 'package:intl/date_symbol_data_file.dart';
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
import 'package:flutter_localizations/flutter_localizations.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationsService.init();
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
          if (!tp.cargado) {
            return const MaterialApp(
              home: Scaffold(
                backgroundColor: Colors.black,
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          return AnimatedTheme(
            data: tp.mode == ThemeMode.dark ? appDarkTheme : appTheme,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: MaterialApp(
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('es', 'ES'),
                Locale('en', 'US'),
                // añade más si vas a soportar otros idiomas
              ],
              localeResolutionCallback: (locale, supportedLocales) {
                // Usa el locale del dispositivo si está soportado, si no, el primero de la lista
                if (locale != null && supportedLocales.contains(locale)) {
                  return locale;
                }
                return supportedLocales.first;
              },
              debugShowCheckedModeBanner: false,
              title: 'FontPer',
              theme: appTheme,
              darkTheme: appDarkTheme,
              themeMode: tp.mode,
              initialRoute: '/',
              routes: {
                '/nuevaTarea': (_) => const TareaScreen(),
              },
              builder: (context, child) {
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
              home: const TareaGeneralScreen(),
            ),
          );

        },
      ),

    );
  }
}
