import 'package:flutter/material.dart';
import '../models/pieza.dart';
import '../widgets/selector_piezas.dart';

class SelectorPiezasScreen extends StatefulWidget {
  final Map<Pieza, int> piezasIniciales;

  const SelectorPiezasScreen({Key? key, required this.piezasIniciales}) : super(key: key);

  @override
  State<SelectorPiezasScreen> createState() => _SelectorPiezasScreenState();
}

class _SelectorPiezasScreenState extends State<SelectorPiezasScreen> {
  late Map<Pieza, int> piezasSeleccionadas;

  @override
  void initState() {
    super.initState();
    piezasSeleccionadas = Map.from(widget.piezasIniciales);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Seleccionar piezas')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SelectorPiezas(
                piezasSeleccionadas: piezasSeleccionadas,
                onPiezasActualizadas: (nuevas) {
                  setState(() {
                    piezasSeleccionadas = nuevas;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context, piezasSeleccionadas);
                },
                icon: Icon(Icons.check),
                label: Text('Guardar selección'),
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
