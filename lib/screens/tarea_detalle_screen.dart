import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tarea.dart';
import '../models/pieza.dart';
import '../models/pieza_tarea.dart';
import '../providers/pieza_tarea_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _cargarPiezas();
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
      await provider.actualizarCantidadPieza(widget.tarea.id!, piezaId, nuevaCantidad);
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
      MaterialPageRoute(
        builder: (_) => SelectorPiezasScreen(piezasSeleccionadas: piezas),
      ),
    );

    if (resultado != null && resultado is List<PiezasTarea>) {
      final provider = Provider.of<PiezasTareaProvider>(context, listen: false);

      for (final nueva in resultado) {
        final existente = piezas.firstWhere(
              (p) => p.piezaId == nueva.piezaId,
          orElse: () => PiezasTarea(piezaId: -1, tareaId: -1, cantidad: 0),
        );

        if (existente.piezaId == -1) {
          await provider.insertarNuevaPiezaTarea(widget.tarea.id!, nueva.piezaId, nueva.cantidad);
        } else {
          await provider.actualizarCantidadPieza(
            widget.tarea.id!,
            nueva.piezaId,
            existente.cantidad + nueva.cantidad,
          );
        }
      }

      await _cargarPiezas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalle de ${widget.tarea.nombreCliente}')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dirección: ${widget.tarea.direccion ?? ''}', style: const TextStyle(fontSize: 16)),
            Text('Teléfono: ${widget.tarea.telefono ?? ''}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Piezas asociadas:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

                  return Card(
                    child: ListTile(
                      title: Text(pieza?.nombre ?? 'Pieza'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => _actualizarCantidad(pt.piezaId, -1),
                          ),
                          Text('${pt.cantidad}', style: const TextStyle(fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _actualizarCantidad(pt.piezaId, 1),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _eliminarPieza(pt.piezaId),
                          ),
                        ],
                      ),
                    ),
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
