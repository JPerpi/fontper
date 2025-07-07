import 'package:flutter/material.dart';
import 'package:fontper/widgets/elevatedButton_personalizado.dart';
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
import '../widgets/glass_card.dart';
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
    // 4) Al volver de WhatsApp (o de cualquier otra), si hay pendientes…
    if (state == AppLifecycleState.resumed && prov.hasPending) {
      _mostrarDialogoConfirmacion();
    }
  }

  void _mostrarDialogoConfirmacion() {
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Se envió correctamente?'),
        content: const Text('¿Marcar estas piezas como enviadas?'),
        actions: [
          TextButton(
            onPressed: () {
              prov.cancelarPendiente();
              Navigator.pop(context, false);
            },
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí'),
          ),
        ],
      ),
    ).then((ok) async {
      if (ok == true) {
        await prov.confirmarMarcado();
        setState(() {
          _modoEnviar = false;
        });
      }
    });
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
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const TareaGeneralScreen(modoEnviar: false),
                      transitionDuration: const Duration(milliseconds: 300),
                      transitionsBuilder: (_, animation, __, child) {
                        final offsetAnimation = Tween<Offset>(
                          begin: const Offset(0.0, 0.1), // deslizamiento vertical sutil
                          end: Offset.zero,
                        ).animate(animation);

                        return SlideTransition(
                          position: offsetAnimation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.share),
                label: const Text('Compartir'),
                onPressed: () {
                  // 1) Obtenemos el provider sin escucha para no redibujar aquí
                  final prov = Provider.of<PiezasTareaProvider>(
                    context,
                    listen: false,
                  );

                  // 2) Construimos la lista de PiezasTarea seleccionadas
                  final piezas = <PiezasTarea>[];
                  for (final tarea in tareasFiltradas) {
                    final lista = piezasPorTareaFiltrado[tarea.id] ?? [];
                    final seleccionadas = piezasSeleccionadasPorTarea[tarea.id] ?? {};
                    piezas.addAll(
                      lista.where((pt) => seleccionadas.contains(pt.piezaId)),
                    );
                  }

                  // 3) Registramos los IDs pendientes en el provider
                  prov.registrarPendientes(piezas);
                  compartirPorWhatsApp(context, mensajeFinal);
                },
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
                  final piezas = piezasPorTareaFiltrado[tarea.id] ?? [];
                  final total = piezas.fold<int>(0, (sum, pt) {
                    return sum + (_modoEnviar
                        ? (pt.cantidad - pt.cantidadEnviada)
                        : pt.cantidad
                    );
                  });
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
                                PageRouteBuilder(
                                  transitionDuration: const Duration(milliseconds: 300),
                                  pageBuilder: (_, animation, secondaryAnimation) => TareaDetalleScreen(tarea: tarea),
                                  transitionsBuilder: (_, animation, __, child) {
                                    final offsetAnimation = Tween<Offset>(
                                      begin: const Offset(1, 0),
                                      end: Offset.zero,
                                    ).animate(animation);

                                    final fadeAnimation = Tween<double>(
                                      begin: 0.0,
                                      end: 1.0,
                                    ).animate(animation);

                                    return SlideTransition(
                                      position: offsetAnimation,
                                      child: FadeTransition(
                                        opacity: fadeAnimation,
                                        child: child,
                                      ),
                                    );
                                  },
                                ),
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
                              final unidades = _modoEnviar
                                  ? (pt.cantidad - pt.cantidadEnviada)
                                  : pt.cantidad;
                              return CheckboxListTile(
                                title: Text('$nombre ($unidades ud.)'),
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
