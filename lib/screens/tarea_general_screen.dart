import 'package:flutter/material.dart';
import 'package:fontper/widgets/elevatedButton_personalizado.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import '../models/tarea.dart';
import '../models/pieza.dart';
import '../models/pieza_tarea.dart';
import '../providers/tarea_provider.dart';
import '../providers/pieza_provider.dart';
import '../providers/pieza_tarea_provider.dart';
import '../utils/whatsapp_helper.dart';
import '../widgets/app_bar_general.dart';
import '../utils/mensaje_resumen.dart';
import '../widgets/glass_card.dart';
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
  String filtroNombreTarea = '';

  @override
  void initState() {
    super.initState();
    Provider.of<TareaProvider>(context, listen: false).eliminarTareasAntiguas();
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

    final tareasFiltradas = tareas
        .where((t) => (!_modoEnviar || t.finalizada != 1) &&
        (t.nombreCliente?.toLowerCase().contains(filtroNombreTarea.toLowerCase()) ?? false))
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBarGeneral(titulo: 'Tareas'),
      floatingActionButton: !_modoEnviar
          ? BotonAnimadoFlotante(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TareaScreen()),
          );
          _cargarDatos();
        },
      )
          : null,
      bottomNavigationBar: _modoEnviar
          ? BottomAppBar(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
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
                label: const Text('Compartir'),
                onPressed: () => compartirPorWhatsApp(context, mensajeFinal),
              ),
            ),
          ],
        ),
      )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                onChanged: (value) => setState(() => filtroNombreTarea = value),
                decoration: const InputDecoration(
                  labelText: 'Buscar por nombre',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white24,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
            ),
            if (_modoEnviar)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(mensajeFinal, style: const TextStyle(fontSize: 14)),
                ),
              ),
            Expanded(
              child: tareasFiltradas.isEmpty
                  ? const Center(child: Text('No hay tareas'))
                  : ListView.builder(
                itemCount: tareasFiltradas.length,
                itemBuilder: (context, index) {
                  final tarea = tareasFiltradas[index];
                  final piezas = piezasPorTarea[tarea.id] ?? [];
                  final total = piezas.fold<int>(0, (s, p) => s + p.cantidad);

                  // Badge de sello finalizada
                  final sello = tarea.finalizada == 1
                      ? Positioned(
                    top: -12,
                    right: -12,
                    child: Transform.rotate(
                      angle: -0.35,
                      child: Image.asset(
                        'assets/selloCompletada.png',
                        width: 88,
                        height: 88,
                      ),
                    ),
                  )
                      : const SizedBox.shrink();

                  // Badge de cantidad de piezas
                  final badgePiezas = tarea.finalizada != 1
                      ? Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Piezas: $total',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  )
                      : const SizedBox.shrink();
                  if (!_modoEnviar) {
                    return Dismissible(
                      key: Key('tarea_${tarea.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.redAccent,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('¿Eliminar tarea?'),
                            content: const Text('Esto eliminará la tarea y sus piezas.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
                              TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Eliminar')),
                            ],
                          ),
                        );
                      },
                      onDismissed: (_) async {
                        final tareaProvider = Provider.of<TareaProvider>(context, listen: false);
                        await tareaProvider.eliminarTareaConPiezas(tarea.id!);
                        await _cargarDatos();
                      },
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => TareaDetalleScreen(tarea: tarea)),
                              ).then((_) => _cargarDatos());
                            },
                            onLongPress: () async {
                              final tareaProvider = Provider.of<TareaProvider>(context, listen: false);
                              await tareaProvider.marcarComoFinalizada(tarea.id!, tarea.finalizada == 0);
                              await _cargarDatos();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              child: GlassCard(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(tarea.nombreCliente ?? 'Sin nombre'),
                                      Text(tarea.direccion ?? '', style: const TextStyle(fontSize: 12)),
                                      Text(tarea.telefono ?? '', style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        sello,
                        badgePiezas,
                        ],
                      ),
                    );
                  }

                  final seleccionadas = piezasSeleccionadasPorTarea[tarea.id] ?? {};
                  final tareaCompletaSeleccionada = tareasSeleccionadas.contains(tarea.id);

                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: GlassCard(
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(tarea.nombreCliente ?? 'Sin nombre'),
                                      Text(tarea.direccion ?? '', style: const TextStyle(fontSize: 12)),
                                      Text(tarea.telefono ?? '', style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
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
                      ),
                      sello,
                      badgePiezas,
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
