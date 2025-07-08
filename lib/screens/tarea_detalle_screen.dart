import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fontper/widgets/app_bar_general.dart';
import 'package:fontper/widgets/glass_card.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../models/imagenes_tarea.dart';
import '../models/tarea.dart';
import '../models/pieza.dart';
import '../models/pieza_tarea.dart';
import '../providers/imagenes_tarea_provider.dart';
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
  List<ImagenTarea> _imagenes = [];
  Map<int, Pieza> piezasMap = {};
  bool _modoEditar = false;
  bool _notaExpandida = false;
  late TextEditingController _ctrlDireccion;
  late TextEditingController _ctrlTelefono;
  late TextEditingController _ctrlNombre;
  late TextEditingController _ctrlNotas;

  @override
  void initState() {
    super.initState();
    _ctrlDireccion = TextEditingController(text: widget.tarea.direccion);
    _ctrlTelefono = TextEditingController(text: widget.tarea.telefono);
    _ctrlNombre = TextEditingController(text: widget.tarea.nombreCliente);
    _ctrlNotas = TextEditingController(text: widget.tarea.notas);
    _ctrlNombre.addListener(() {
      if (!_modoEditar) return;
      setState(() {});
    });
    _cargarPiezas();
    _cargarImagenes();
  }

  @override
  void dispose() {
    _ctrlDireccion.dispose();
    _ctrlTelefono.dispose();
    _ctrlNombre.dispose();
    _ctrlNotas.dispose();
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

  Future<void> _cargarImagenes() async {
    final prov = Provider.of<ImagenTareaProvider>(context, listen: false);
    final lista = await prov.getImagenesPorTarea(widget.tarea.id!);
    setState(() => _imagenes = lista);
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
            await provider.insertarNuevaPiezaTarea(
                widget.tarea.id!, nueva.piezaId, diff);
          } else {
            await provider.actualizarCantidadPieza(
                widget.tarea.id!, nueva.piezaId, diff);
          }
        }
      }

      await _cargarPiezas();
    }
  }

  Widget _buildCitaCard(BuildContext context) {
    final ts = widget.tarea.scheduledAt!;
    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    final loc = MaterialLocalizations.of(context);

    // Formatea la fecha y la hora según la configuración del dispositivo
    final fechaStr = loc.formatFullDate(dt); // p.e. "7 de julio de 2025"
    final horaStr = loc.formatTimeOfDay(
      TimeOfDay.fromDateTime(dt),
      alwaysUse24HourFormat: true,
    ); // p.e. "14:30"

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GlassCard(
        child: ListTile(
          leading: Icon(
            Icons.event,
            size: 28,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            'Cita programada',
          ),
          subtitle: Text(
            '$fechaStr  •  $horaStr',
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndScheduleCita() async {
    final tarea = widget.tarea;
    final ahora = DateTime.now();
    // Si ya hay una cita, partimos de ella; si no, de ahora
    final initialDate = tarea.scheduledAt != null
        ? DateTime.fromMillisecondsSinceEpoch(tarea.scheduledAt!)
        : ahora;

    // 1. Selección de fecha
    final fecha = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: ahora,
      lastDate: ahora.add(const Duration(days: 365)),
    );
    if (fecha == null) return;

    // 2. Selección de hora
    final inicialTime = tarea.scheduledAt != null
        ? TimeOfDay.fromDateTime(initialDate)
        : TimeOfDay.now();
    final hora = await showTimePicker(
      context: context,
      initialTime: inicialTime,
    );
    if (hora == null) return;

    // 3. Combina y programa
    final nuevaCita =
        DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
    await context.read<TareaProvider>().programarCita(tarea, nuevaCita);

    // 4. Actualiza UI local
    setState(() {
      widget.tarea.scheduledAt = nuevaCita.millisecondsSinceEpoch;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tarea = widget.tarea;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBarGeneral(
        titulo: 'Detalle de ${_ctrlNombre.text}',
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ListView(
            children: [
              if (_modoEditar) ...[
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
                TextFormField(
                  controller: _ctrlDireccion,
                  decoration: InputDecoration(
                    labelText: 'Dirección',
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _ctrlTelefono,
                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 20),
              ] else ...[
                Text('Cliente: ${_ctrlNombre.text}',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Dirección: ${_ctrlDireccion.text}',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Teléfono: ${_ctrlTelefono.text}',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
              ],
              if (_modoEditar) ...[
                // En edición: siempre mostrar el card para poder escribir
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: const Text('Notas'),
                        trailing: IconButton(
                          icon: Icon(_notaExpandida ? Icons.expand_less : Icons.expand_more),
                          onPressed: () => setState(() => _notaExpandida = !_notaExpandida),
                        ),
                      ),
                      if (_notaExpandida)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: TextFormField(
                            controller: _ctrlNotas,
                            maxLines: null,
                            decoration: const InputDecoration(
                              hintText: 'Escribe aquí tus notas…',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ] else if (_ctrlNotas.text.isNotEmpty) ...[
                // En lectura: sólo mostrar si hay texto
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: const Text('Notas'),
                        trailing: IconButton(
                          icon: Icon(_notaExpandida ? Icons.expand_less : Icons.expand_more),
                          onPressed: () => setState(() => _notaExpandida = !_notaExpandida),
                        ),
                      ),
                      if (_notaExpandida)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            _ctrlNotas.text,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (_imagenes.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imagenes.length,
                    itemBuilder: (_, i) {
                      final img = _imagenes[i];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Stack(
                          children: [
                            // Envuelvo la miniatura en GestureDetector
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => Dialog(
                                    child: InteractiveViewer(
                                      panEnabled: true,
                                      minScale: 0.5,
                                      maxScale: 4,
                                      child: Image.file(
                                        File(img.ruta),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(img.ruta),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            if (_modoEditar)
                              Positioned(
                                top: 0, right: 0,
                                child: GestureDetector(
                                  onTap: () async {
                                    await context.read<ImagenTareaProvider>()
                                        .eliminarImagen(img.id!);
                                    await _cargarImagenes();
                                  },
                                  child: const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.redAccent,
                                    child: Icon(Icons.close, size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),

                ),
              if (widget.tarea.scheduledAt != null) _buildCitaCard(context),
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
              piezas.isEmpty
                  ? const Center(child: Text('No hay piezas en esta tarea.'))
                  : ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: piezas.length,
                      itemBuilder: (context, index) {
                        final pt = piezas[index];
                        final pieza = piezasMap[pt.piezaId];
                        final card = GlassCard(
                          child: ListTile(
                            title: Text(pieza?.nombre ?? 'Pieza'),
                            trailing: _modoEditar
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () =>
                                            _actualizarCantidad(pt.piezaId, -1),
                                      ),
                                      Text('${pt.cantidad}',
                                          style: const TextStyle(fontSize: 16)),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () =>
                                            _actualizarCantidad(pt.piezaId, 1),
                                      ),
                                    ],
                                  )
                                : Text('x ${pt.cantidad}',
                                    style: const TextStyle(fontSize: 16)),
                          ),
                        );

                        if (_modoEditar) {
                          return Dismissible(
                            key: ValueKey(pt.piezaId),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.redAccent,
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
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
                            onDismissed: (_) => _eliminarPieza(pt.piezaId),
                            child: card,
                          );
                        }
                        return card;
                      },
                    ),
            ],
          ),
        ),
      ),
      // —————————————————————————————————————————
      // SpeedDial en el FAB:
      floatingActionButton: _modoEditar
          // ——— MODO EDICIÓN: SOLO UN FAB DE GUARDAR ———
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.check, color: Colors.white),
              onPressed: () async {
                // Guarda los cambios
                final tareaProv = context.read<TareaProvider>();
                await tareaProv.actualizarTarea(
                  id: widget.tarea.id!,
                  nombre: _ctrlNombre.text,
                  direccion: _ctrlDireccion.text,
                  telefono: _ctrlTelefono.text,
                  notas: _ctrlNotas.text,
                );
                setState(() => _modoEditar = false);
              },
            )
          // ——— MODO NORMAL: TU SPEEDDIAL CON “Editar” COMO CHILD ———
          : SpeedDial(
              icon: Icons.more_vert,
              activeIcon: Icons.close,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              overlayOpacity: 0.0,
              children: [
                // 1) EDITAR DETALLES
                SpeedDialChild(
                  child: const Icon(Icons.edit),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  label: 'Editar',
                  labelBackgroundColor: Theme.of(context).colorScheme.primary,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  onTap: () {
                    setState(() => _modoEditar = true);
                  },
                ),

                // 2) PROGRAMAR/EDITAR CITA
                SpeedDialChild(
                  child: const Icon(Icons.calendar_today),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  label:
                      widget.tarea.scheduledAt == null ? 'Cita' : 'Editar cita',
                  labelBackgroundColor: Theme.of(context).colorScheme.primary,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  onTap: _pickAndScheduleCita,
                ),
                // 3) CANCELAR CITA
                if (widget.tarea.scheduledAt != null)
                  SpeedDialChild(
                    child: const Icon(Icons.delete),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    label: 'Cancelar cita',
                    labelBackgroundColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Cancelar cita'),
                          content: const Text('¿Seguro?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('No')),
                            ElevatedButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Sí')),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await context
                            .read<TareaProvider>()
                            .borrarCita(widget.tarea);
                        setState(() => widget.tarea.scheduledAt = null);
                      }
                    },
                  ),
                SpeedDialChild(
                  child: const Icon(Icons.camera_alt),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  label: 'Añadir foto',
                  labelBackgroundColor: Theme.of(context).colorScheme.primary,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  onTap: () async {
                    // Lanza el flujo de agregar imagen
                    await context.read<ImagenTareaProvider>()
                        .agregarImagen(widget.tarea.id!);
                    await _cargarImagenes(); // refresca la lista local
                  },
                ),
              ],
            ),
    );
  }
}
