import 'package:flutter/material.dart';
import 'package:fontper/widgets/elevatedButton_personalizado.dart';
import 'package:provider/provider.dart';

import '../models/tarea.dart';
import '../models/pieza.dart';
import '../models/pieza_tarea.dart';
import '../providers/tarea_provider.dart';
import '../providers/pieza_tarea_provider.dart';
import '../services/tarea_data_service.dart';
import '../widgets/app_bar_general.dart';
import '../utils/mensaje_resumen.dart';
import '../widgets/boton_enviar.dart';
import '../widgets/confirmar_envio.dart';
import '../widgets/search_bar_personalizada.dart';
import '../widgets/tarea_enviar.dart';
import '../widgets/tarea_normal.dart';
import 'tarea_detalle_screen.dart';
import 'tarea_screen.dart';

class TareaGeneralScreen extends StatefulWidget {
  final bool modoEnviar;
  const TareaGeneralScreen({super.key, this.modoEnviar = false});

  @override
  State<TareaGeneralScreen> createState() => _TareaGeneralScreenState();
}

class _TareaGeneralScreenState extends State<TareaGeneralScreen> with WidgetsBindingObserver {
  bool _modoEnviar = false;
  List<Tarea> tareas = [];
  Map<int, List<PiezasTarea>> piezasPorTarea = {};
  Map<int, Pieza> piezasMap = {};
  Map<int, Set<int>> piezasSeleccionadasPorTarea = {};
  Set<int> tareasSeleccionadas = {};
  String filtroNombreTarea = '';
  late PiezasTareaProvider prov;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    prov = context.read<PiezasTareaProvider>();
    Provider.of<TareaProvider>(context, listen: false).eliminarTareasAntiguas();
    _modoEnviar = widget.modoEnviar;
    _cargarDatos();
  }

  @override
  void dispose() {
    // 3) Nos desregistramos
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && prov.hasPending) {
      showConfirmarEnvioDialog(context).then((ok) async {
        if (ok == true) {
          await prov.confirmarMarcado();
          setState(() {
            _modoEnviar = false;
          });
        }
      });
    }
  }


  Future<void> _cargarDatos() async {
    final data = await TareaDataService.fetchTareaData();
    setState(() {
      tareas         = data.tareas;
      piezasPorTarea = data.piezasPorTarea;
      piezasMap      = data.piezasMap;
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
        final tareasFiltradas = tareas
        .where((t) => (!_modoEnviar || t.finalizada != 1) &&
        (t.nombreCliente?.toLowerCase().contains(filtroNombreTarea.toLowerCase()) ?? false))
        .toList();

        final piezasPorTareaFiltrado = piezasPorTarea.map(
              (tareaId, lista) => MapEntry(
            tareaId,
            lista.where((pt) => !_modoEnviar || pt.cantidad > pt.cantidadEnviada).toList(),          ),
        );

        final mensajeFinal = generarResumenDePiezasSeleccionadas(
          piezasPorTarea: piezasPorTareaFiltrado,
          piezasSeleccionadasPorTarea: piezasSeleccionadasPorTarea,
          piezasMap: piezasMap,
        );


    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBarGeneral(titulo: 'Tareas'),
      floatingActionButton: !_modoEnviar
          ? BotonAnimadoFlotante(
        onPressed: () async {
          await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const TareaScreen(),
              transitionDuration: const Duration(milliseconds: 150),
              transitionsBuilder: (_, animation, __, child) {
                final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
                final offset = Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(curved);

                return SlideTransition(
                  position: offset,
                  child: FadeTransition(
                    opacity: curved,
                    child: child,
                  ),
                );
              },
            ),
          );
          _cargarDatos();
        },
      )
          : null,
      bottomNavigationBar: _modoEnviar
          ? BotonEnviarBar(
        mensajeFinal: mensajeFinal,
        tareasFiltradas: tareasFiltradas,
        piezasPorTareaFiltrado: piezasPorTareaFiltrado,
        piezasSeleccionadasPorTarea: piezasSeleccionadasPorTarea,
      )
          : null,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              SearchBarPersonalizada(
                onChanged: (value) => setState(() => filtroNombreTarea = value),
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
                    final piezas = piezasPorTareaFiltrado[tarea.id] ?? [];
                    final total = piezas.fold<int>(0, (sum, pt) {
                      return sum + (_modoEnviar
                          ? (pt.cantidad - pt.cantidadEnviada)
                          : pt.cantidad
                      );
                    });
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
                        child: TareaItemNormal(
                          tarea: tarea,
                          piezas: piezas,
                          piezasMap: piezasMap,
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 300),
                                pageBuilder: (_, animation, __) =>
                                    TareaDetalleScreen(tarea: tarea),
                                transitionsBuilder: (_, animation, __, child) {
                                  final offsetAnim = Tween<Offset>(
                                    begin: const Offset(1, 0),
                                    end: Offset.zero,
                                  ).animate(animation);
                                  final fadeAnim = Tween<double>(
                                    begin: 0,
                                    end: 1,
                                  ).animate(animation);
                                  return SlideTransition(
                                    position: offsetAnim,
                                    child: FadeTransition(opacity: fadeAnim, child: child),
                                  );
                                },
                              ),
                            ).then((_) => _cargarDatos());
                          },
                          onLongPress: () async {
                            await Provider.of<TareaProvider>(context, listen: false)
                                .marcarComoFinalizada(tarea.id!, tarea.finalizada == 0);
                            await _cargarDatos();
                          },
                        ),
                      );
                    }
                    final seleccionadas = piezasSeleccionadasPorTarea[tarea.id!] ?? <int>{};
                    final tareaCompletaSeleccionada = tareasSeleccionadas.contains(tarea.id!);
        
                    return TareaItemEnviar(
                      tarea: tarea,
                      piezas: piezas,
                      piezasMap: piezasMap,
                      seleccionadas: seleccionadas,
                      tareaEnteraSeleccionada: tareaCompletaSeleccionada,
                      onSeleccionarTareaEntera: (val) =>
                          _seleccionarTareaEntera(tarea.id!, val),
                      onSeleccionarPieza: (piezaId, val) =>
                          _seleccionarPieza(tarea.id!, piezaId, val),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
