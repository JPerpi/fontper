import 'package:flutter/material.dart';
import 'package:fontper/providers/pieza_provider.dart';
import 'package:fontper/providers/pieza_tarea_provider.dart';
import 'package:fontper/providers/tarea_provider.dart';
import 'package:fontper/providers/tipo_pieza_provider.dart';
import 'package:fontper/screens/tarea_detalle_screen.dart';
import 'package:fontper/screens/tarea_general_screen.dart';
import 'package:fontper/screens/tarea_screen.dart';
import 'package:fontper/widgets/selector_piezas.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const FontPerApp());
}

class FontPerApp extends StatelessWidget {
  const FontPerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TipoPiezaProvider()..loadData()),
        ChangeNotifierProvider(create: (_) => TareaProvider()..loadData()),
        ChangeNotifierProvider(create: (_) => PiezaProvider()..loadData()),
        ChangeNotifierProvider(create: (_) => PiezaTareaProvider()..loadData()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FontPer',
        initialRoute: '/',
        routes: {
          '/nuevaTarea': (context) =>TareaScreen() ,
          '/detalleTarea': (context) => TareaDetalleScreen(),
        },
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
          useMaterial3: true,
        ),
        home: TareaGeneralScreen(),
      ),
    );
  }
}
