import 'package:flutter/material.dart';
import 'package:fontper/widgets/glass_card.dart';
import 'package:provider/provider.dart';

import '../models/material.dart';
import '../models/pieza.dart';
import '../models/pieza_tarea.dart';
import '../providers/material_provider.dart';
import '../providers/pieza_provider.dart';

class SelectorPiezas extends StatefulWidget {
  final List<PiezasTarea> piezasIniciales;
  final void Function(List<PiezasTarea>) onConfirmar;

  const SelectorPiezas({
    super.key,
    required this.piezasIniciales,
    required this.onConfirmar,
  });

  @override
  State<SelectorPiezas> createState() => _SelectorPiezasState();
}

class _SelectorPiezasState extends State<SelectorPiezas> {
  List<MaterialFontaneria> materiales = [];
  List<Pieza> piezasDelMaterial = [];
  Map<int, int> cantidades = {}; // piezaId -> cantidad
  int? materialSeleccionadoId;

  @override
  void initState() {
    super.initState();
    _cargarMateriales();

    for (var pt in widget.piezasIniciales) {
      cantidades[pt.piezaId] = pt.cantidad;
    }
  }

  Future<void> _cargarMateriales() async {
    final provider = Provider.of<MaterialProvider>(context, listen: false);
    final resultado = await provider.getMaterialesOrdenadosPorUso();
    setState(() {
      materiales = resultado;
    });
  }

  Future<void> _seleccionarMaterial(int id) async {
    final provider = Provider.of<PiezaProvider>(context, listen: false);
    final piezas = await provider.getPiezasPorMaterial(id);
    setState(() {
      materialSeleccionadoId = id;
      piezasDelMaterial = piezas;
    });
  }

  void _modificarCantidad(int piezaId, int delta) {
    setState(() {
      final actual = cantidades[piezaId] ?? 0;
      final nuevo = actual + delta;
      if (nuevo < 1) {
        cantidades.remove(piezaId);
      } else {
        cantidades[piezaId] = nuevo;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Text('Selecciona un material:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: materiales.map((m) {
              final seleccionado = m.id == materialSeleccionadoId;
              return ChoiceChip(
                label: Text(m.nombre),
                selected: seleccionado,
                onSelected: (_) => _seleccionarMaterial(m.id!),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: piezasDelMaterial.isEmpty
                ? const Center(child: Text('Selecciona un material para ver las piezas.'))
                : ListView.builder(
              itemCount: piezasDelMaterial.length,
              itemBuilder: (context, index) {
                final pieza = piezasDelMaterial[index];
                final cantidad = cantidades[pieza.id] ?? 0;

                return GlassCard(
                  child: ListTile(
                    title: Text(pieza.nombre),
                    subtitle: Text('Tipo: ${pieza.tipoId}, Material: ${pieza.materialId}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => _modificarCantidad(pieza.id!, -1),
                        ),
                        Text('$cantidad', style: const TextStyle(fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _modificarCantidad(pieza.id!, 1),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('Confirmar selección'),
            onPressed: () {
              final resultado = cantidades.entries
                  .map((e) => PiezasTarea(piezaId: e.key, tareaId: -1, cantidad: e.value))
                  .toList();
              widget.onConfirmar(resultado);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
