import 'package:flutter/material.dart';
import 'package:fontper/widgets/app_bar_general.dart';
import '../models/pieza_tarea.dart';
import '../widgets/selector_piezas.dart';

class SelectorPiezasScreen extends StatelessWidget {
  final List<PiezasTarea> piezasSeleccionadas;

  const SelectorPiezasScreen({super.key, required this.piezasSeleccionadas});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBarGeneral(titulo: 'Seleccionar piezas'),
      body: SelectorPiezas(
        piezasIniciales: piezasSeleccionadas,
        onConfirmar: (resultado) {
          Navigator.pop(context, resultado);
        },
      ),
    );
  }
}
