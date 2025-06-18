import 'package:flutter/material.dart';
import 'package:fontper/providers/pieza_provider.dart';
import 'package:fontper/providers/pieza_tarea_provider.dart';
import 'package:fontper/providers/tarea_provider.dart';
import 'package:fontper/providers/tipo_pieza_provider.dart';
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
        ChangeNotifierProvider(create: (_) => PiezaTAreaProvider()..loadData()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FontPer',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
          useMaterial3: true,
        ),
        home: const TareaGeneralScreen(),
      ),
    );
  }
}
