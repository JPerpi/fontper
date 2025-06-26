import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fontper/widgets/app_bar_general.dart';
import 'package:fontper/widgets/glass_card.dart';
import 'package:provider/provider.dart';

import '../models/tarea.dart';
import '../models/pieza_tarea.dart';
import '../models/pieza.dart';
import '../providers/tarea_provider.dart';
import '../providers/pieza_tarea_provider.dart';
import '../providers/pieza_provider.dart';
import 'selector_piezas_screen.dart';

class TareaScreen extends StatefulWidget {
  const TareaScreen({super.key});

  @override
  State<TareaScreen> createState() => _TareaScreenState();
}

class _TareaScreenState extends State<TareaScreen> {
  final _formKey = GlobalKey<FormState>();
  String? nombre;
  String? direccion;
  String? telefono;

  Map<int, PiezasTarea> piezasSeleccionadas = {};
  Map<int, Pieza> piezasMap = {};

  void _addPiezasDesdeSelector() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectorPiezasScreen(
          piezasSeleccionadas: piezasSeleccionadas.values.toList(),
        ),
      ),
    );

    if (resultado != null && resultado is List<PiezasTarea>) {
      for (var pt in resultado) {
        if (piezasSeleccionadas.containsKey(pt.piezaId)) {
          piezasSeleccionadas[pt.piezaId] = PiezasTarea(
            piezaId: pt.piezaId,
            tareaId: -1,
            cantidad: piezasSeleccionadas[pt.piezaId]!.cantidad + pt.cantidad,
          );
        } else {
          piezasSeleccionadas[pt.piezaId] = pt;
        }
      }
      setState(() {});
    }
  }

  void _modificarCantidad(int piezaId, int delta) {
    final actual = piezasSeleccionadas[piezaId];
    if (actual == null) return;

    final nuevaCantidad = actual.cantidad + delta;
    if (nuevaCantidad < 1) {
      piezasSeleccionadas.remove(piezaId);
    } else {
      piezasSeleccionadas[piezaId] = PiezasTarea(
        piezaId: actual.piezaId,
        tareaId: -1,
        cantidad: nuevaCantidad,
      );
    }
    setState(() {});
  }

  void _guardarTarea() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final tareaProvider = Provider.of<TareaProvider>(context, listen: false);

    final nuevaTarea = Tarea(
      nombreCliente: nombre,
      direccion: direccion,
      telefono: telefono,
    );

    await tareaProvider.crearTareaConPiezas(nuevaTarea, piezasSeleccionadas.values.toList());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final piezaProvider = Provider.of<PiezaProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBarGeneral(titulo: 'Nueva tarea'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Nombre del cliente'),
                        onSaved: (val) => nombre = val,
                        validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Dirección'),
                        onSaved: (val) => direccion = val,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Teléfono'),
                        onSaved: (val) => telefono = val,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Text('Piezas seleccionadas', style: TextStyle(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.add_circle),
                            onPressed: _addPiezasDesdeSelector,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                piezasSeleccionadas.isEmpty
                    ? const Center(child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text('No hay piezas añadidas'),
                ))
                    : ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: piezasSeleccionadas.values.map((pt) {
                    final pieza = piezaProvider.getPiezaPorId(pt.piezaId);
                    return GlassCard(
                      child: ListTile(
                        title: Text(pieza?.nombre ?? 'Pieza'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => _modificarCantidad(pt.piezaId, -1),
                            ),
                            Text('${pt.cantidad}', style: const TextStyle(fontSize: 16)),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => _modificarCantidad(pt.piezaId, 1),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                piezasSeleccionadas.remove(pt.piezaId);
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _guardarTarea,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar tarea'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
