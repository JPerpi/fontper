import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tarea.dart';
import '../models/pieza.dart';
import '../models/pieza_tarea.dart';
import '../providers/tarea_provider.dart';
import '../providers/pieza_provider.dart';
import '../providers/pieza_tarea_provider.dart';
import '../utils/whatsapp_helper.dart';
import '../widgets/app_bar_general.dart';
import '../utils/mensaje_resumen.dart';
import 'tarea_detalle_screen.dart';
import 'tarea_screen.dart';

class TareaGeneralScreen extends StatefulWidget {
  final bool modoEnviar;
  const TareaGeneralScreen({super.key, this.modoEnviar = false});

  @override
  State<TareaGeneralScreen> createState() => _TareaGeneralScreenState();
}

class _TareaGeneralScreenState extends State<TareaGeneralScreen> {
  bool _modoEnviar = false;
  List<Tarea> tareas = [];
  Map<int, List<PiezasTarea>> piezasPorTarea = {};
  Map<int, Pieza> piezasMap = {};
  Map<int, Set<int>> piezasSeleccionadasPorTarea = {};
  Set<int> tareasSeleccionadas = {};

  @override
  void initState() {
    super.initState();
    _modoEnviar = widget.modoEnviar;
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final tareaProvider = Provider.of<TareaProvider>(context, listen: false);
    final piezaProvider = Provider.of<PiezaProvider>(context, listen: false);
    final piezaTareaProvider = Provider.of<PiezasTareaProvider>(context, listen: false);

    final listaTareas = await tareaProvider.getTodasLasTareas();
    final todasLasPiezas = await piezaProvider.getTodasLasPiezas();
    final piezasMapeadas = {for (var p in todasLasPiezas) p.id!: p};

    final mapa = <int, List<PiezasTarea>>{};
    for (final tarea in listaTareas) {
      final piezas = await piezaTareaProvider.getPiezasPorTarea(tarea.id!);
      mapa[tarea.id!] = piezas;
    }

    setState(() {
      tareas = listaTareas;
      piezasMap = piezasMapeadas;
      piezasPorTarea = mapa;
    });
  }

  void _seleccionarPieza(int tareaId, int piezaId, bool seleccionado) {
    setState(() {
      piezasSeleccionadasPorTarea.putIfAbsent(tareaId, () => {});
      if (seleccionado) {
        piezasSeleccionadasPorTarea[tareaId]!.add(piezaId);
      } else {
        piezasSeleccionadasPorTarea[tareaId]!.remove(piezaId);
      }
    });
  }

  void _seleccionarTareaEntera(int tareaId, bool seleccionado) {
    final piezas = piezasPorTarea[tareaId] ?? [];
    setState(() {
      piezasSeleccionadasPorTarea.putIfAbsent(tareaId, () => {});
      if (seleccionado) {
        tareasSeleccionadas.add(tareaId);
        for (final pt in piezas) {
          piezasSeleccionadasPorTarea[tareaId]!.add(pt.piezaId);
        }
      } else {
        tareasSeleccionadas.remove(tareaId);
        piezasSeleccionadasPorTarea[tareaId]?.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mensajeFinal = generarResumenDePiezasSeleccionadas(
      piezasPorTarea: piezasPorTarea,
      piezasSeleccionadasPorTarea: piezasSeleccionadasPorTarea,
      piezasMap: piezasMap,
    );

    return Scaffold(
      appBar: AppBarGeneral(titulo: 'Tareas', context: context),
      floatingActionButton: !_modoEnviar
          ? FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const TareaScreen()));
          _cargarDatos();
        },
        child: const Icon(Icons.add),
      )
          : null,
      bottomNavigationBar: _modoEnviar
          ? BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.cancel),
                label: const Text('Cancelar'),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TareaGeneralScreen(modoEnviar: false),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('Compartir'),
                onPressed: () => compartirPorWhatsApp(context, mensajeFinal),
              ),
            ),
          ],
        ),
      )
          : null,
      body: Column(
        children: [
          if (_modoEnviar)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(mensajeFinal, style: const TextStyle(fontSize: 14)),
              ),
            ),
          Expanded(
            child: tareas.isEmpty
                ? const Center(child: Text('No hay tareas'))
                : ListView.builder(
              itemCount: tareas.length,
              itemBuilder: (context, index) {
                final tarea = tareas[index];
                final piezas = piezasPorTarea[tarea.id] ?? [];
                final total = piezas.fold<int>(0, (s, p) => s + p.cantidad);

                final badge = Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Piezas totales: $total', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                );

                final cardContent = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tarea.nombreCliente ?? 'Sin nombre'),
                    Text(tarea.direccion ?? '', style: const TextStyle(fontSize: 12)),
                    Text(tarea.telefono ?? '', style: const TextStyle(fontSize: 12)),
                  ],
                );

                if (!_modoEnviar) {
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => TareaDetalleScreen(tarea: tarea)),
                          ).then((_) => _cargarDatos());
                        },
                        child: Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(title: cardContent),
                        ),
                      ),
                      badge,
                    ],
                  );
                }

                // Modo enviar
                final seleccionadas = piezasSeleccionadasPorTarea[tarea.id] ?? {};
                final tareaCompletaSeleccionada = tareasSeleccionadas.contains(tarea.id);

                return Stack(
                  children: [
                    Card(
                      margin: const EdgeInsets.all(8),
                      child: ExpansionTile(
                        title: Row(
                          children: [
                            Expanded(child: cardContent),
                            Checkbox(
                              value: tareaCompletaSeleccionada,
                              onChanged: (val) => _seleccionarTareaEntera(tarea.id!, val ?? false),
                            ),
                          ],
                        ),
                        children: piezas.map((pt) {
                          final pieza = piezasMap[pt.piezaId];
                          final nombre = pieza?.nombre ?? 'Pieza';
                          final seleccionada = seleccionadas.contains(pt.piezaId);
                          return CheckboxListTile(
                            title: Text('$nombre (${pt.cantidad} ud.)'),
                            value: seleccionada,
                            onChanged: (v) => _seleccionarPieza(tarea.id!, pt.piezaId, v ?? false),
                          );
                        }).toList(),
                      ),
                    ),
                    badge,
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
