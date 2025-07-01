import 'package:flutter/material.dart';
import 'package:fontper/widgets/app_bar_general.dart';
import 'package:fontper/widgets/glass_card.dart';
import 'package:provider/provider.dart';
import '../models/tarea.dart';
import '../models/pieza.dart';
import '../models/pieza_tarea.dart';
import '../providers/pieza_tarea_provider.dart';
import '../providers/tarea_provider.dart';
import 'selector_piezas_screen.dart';

class TareaDetalleScreen extends StatefulWidget {
  final Tarea tarea;
  const TareaDetalleScreen({super.key, required this.tarea});

  @override
  State<TareaDetalleScreen> createState() => _TareaDetalleScreenState();
}

class _TareaDetalleScreenState extends State<TareaDetalleScreen> {
  List<PiezasTarea> piezas = [];
  Map<int, Pieza> piezasMap = {};
  bool _modoEditar = false;
  late TextEditingController _ctrlDireccion;
  late TextEditingController _ctrlTelefono;
  late TextEditingController _ctrlNombre;

  @override
  void initState() {
    super.initState();
    _ctrlDireccion = TextEditingController(text: widget.tarea.direccion);
    _ctrlTelefono = TextEditingController(text: widget.tarea.telefono);
    _ctrlNombre = TextEditingController(text: widget.tarea.nombreCliente);
    _ctrlNombre.addListener(() {
      if (!_modoEditar) return;
      setState(() {});
    });
    _cargarPiezas();
  }

  @override
  void dispose() {
    _ctrlDireccion.dispose();
    _ctrlTelefono.dispose();
    _ctrlNombre.dispose();
    super.dispose();
  }

  Future<void> _cargarPiezas() async {
    final provider = Provider.of<PiezasTareaProvider>(context, listen: false);
    final lista = await provider.getPiezasPorTarea(widget.tarea.id!);
    final mapeo = await provider.getPiezasMapPorTarea(widget.tarea.id!);

    setState(() {
      piezas = lista;
      piezasMap = mapeo;
    });
  }

  Future<void> _actualizarCantidad(int piezaId, int delta) async {
    final provider = Provider.of<PiezasTareaProvider>(context, listen: false);
    final pt = piezas.firstWhere((p) => p.piezaId == piezaId);
    final nuevaCantidad = pt.cantidad + delta;

    if (nuevaCantidad < 1) {
      await provider.eliminarPiezaDeTarea(widget.tarea.id!, piezaId);
      setState(() {
        piezas.removeWhere((p) => p.piezaId == piezaId);
      });
    } else {
      await provider.actualizarCantidadPieza(
          widget.tarea.id!, piezaId, nuevaCantidad);
      setState(() {
        final index = piezas.indexWhere((p) => p.piezaId == piezaId);
        piezas[index] = PiezasTarea(
          id: pt.id,
          tareaId: pt.tareaId,
          piezaId: pt.piezaId,
          cantidad: nuevaCantidad,
        );
      });
    }
  }

  Future<void> _eliminarPieza(int piezaId) async {
    final provider = Provider.of<PiezasTareaProvider>(context, listen: false);
    await provider.eliminarPiezaDeTarea(widget.tarea.id!, piezaId);
    setState(() {
      piezas.removeWhere((p) => p.piezaId == piezaId);
    });
  }

  Future<void> _addPiezas() async {
    final resultado = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            SelectorPiezasScreen(piezasSeleccionadas: piezas),
        transitionDuration: const Duration(milliseconds: 150),
        transitionsBuilder: (_, animation, __, child) {
          final curved =
              CurvedAnimation(parent: animation, curve: Curves.easeOut);
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
    if (resultado != null && resultado is List<PiezasTarea>) {
      final provider = Provider.of<PiezasTareaProvider>(context, listen: false);

      final iniciales = {for (var p in piezas) p.piezaId: p.cantidad};

      for (final nueva in resultado) {
        final prev = iniciales[nueva.piezaId] ?? 0;
        final diff = nueva.cantidad - prev;
        if (diff > 0) {
          if (prev == 0) {
            // Nueva pieza: insertamos sólo la diferencia
            await provider.insertarNuevaPiezaTarea(
                widget.tarea.id!, nueva.piezaId, diff);
          } else {
            // Pieza existente: actualizamos sólo en +diff
            await provider.actualizarCantidadPieza(
                widget.tarea.id!, nueva.piezaId, diff);
          }
        }
      }

      await _cargarPiezas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBarGeneral(
        titulo: 'Detalle de ${_ctrlNombre.text}',
        actions: [
          IconButton(
            icon: Icon(_modoEditar ? Icons.check : Icons.edit),
            color: Theme.of(context).iconTheme.color,
            onPressed: () async {
              if (_modoEditar) {
                final tareaProv =
                    Provider.of<TareaProvider>(context, listen: false);
                await tareaProv.actualizarTarea(
                  id: widget.tarea.id!,
                  nombre: _ctrlNombre.text,
                  direccion: _ctrlDireccion.text,
                  telefono: _ctrlTelefono.text,
                );
              }
              setState(() {
                _modoEditar = !_modoEditar;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_modoEditar)
                TextFormField(
                  controller: _ctrlNombre,
                  decoration: InputDecoration(
                    labelText: 'Cliente',
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              const SizedBox(height: 8),
              _modoEditar
                  ? TextFormField(
                      controller: _ctrlDireccion,
                      decoration: InputDecoration(
                        labelText: 'Dirección',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    )
                  : Text('Dirección: ${_ctrlDireccion.text ?? ''}',
                      style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              _modoEditar
                  ? TextFormField(
                      controller: _ctrlTelefono,
                      decoration: InputDecoration(
                        labelText: 'Teléfono',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    )
                  : Text('Teléfono: ${_ctrlTelefono.text ?? ''}',
                      style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Piezas asociadas:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (_modoEditar)
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: _addPiezas,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: piezas.isEmpty
                    ? const Center(child: Text('No hay piezas en esta tarea.'))
                    : ListView.builder(
                        itemCount: piezas.length,
                        itemBuilder: (context, index) {
                          final pt = piezas[index];
                          final pieza = piezasMap[pt.piezaId];

                          // En modo edición, envolvemos en Dismissible
                          final card = GlassCard(
                            child: ListTile(
                              title: Text(pieza?.nombre ?? 'Pieza'),
                              trailing: _modoEditar
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () => _actualizarCantidad(
                                              pt.piezaId, -1),
                                        ),
                                        Text('${pt.cantidad}',
                                            style:
                                                const TextStyle(fontSize: 16)),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () => _actualizarCantidad(
                                              pt.piezaId, 1),
                                        ),
                                        // Eliminar directo con icono (opcional)
                                      ],
                                    )
                                  : Text('x ${pt.cantidad}',
                                      style: const TextStyle(fontSize: 16)),
                            ),
                          );

                          if (!_modoEditar) {
                            return card;
                          }

                          return Dismissible(
                            key: ValueKey(pt.piezaId),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.redAccent,
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            confirmDismiss: (_) => showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Confirmar'),
                                content: const Text('¿Eliminar esta pieza?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('No'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Sí'),
                                  ),
                                ],
                              ),
                            ),
                            onDismissed: (_) {
                              _eliminarPieza(pt.piezaId);
                            },
                            child: card,
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
