import 'package:flutter/material.dart';
import 'package:fontper/widgets/glass_card.dart';
import 'package:provider/provider.dart';

import '../models/material_fontaneria.dart';
import '../models/pieza.dart';
import '../models/pieza_tarea.dart';
import '../models/tipo_pieza.dart';
import '../providers/material_provider.dart';
import '../providers/pieza_provider.dart';
import '../providers/tipo_pieza_provider.dart';
import '../screens/formulario_pieza_personalizada.dart';
import 'botón_personalizado.dart';

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
  List<TipoPieza> tipos = [];
  List<Pieza> piezasDelMaterial = [];

  Map<int, int> cantidades = {};
  int? materialSeleccionadoId;
  int? tipoSeleccionadoId;
  String filtroNombre = '';

  @override
  void initState() {
    super.initState();
    _cargarMaterialesYTipos();

    for (var pt in widget.piezasIniciales) {
      cantidades[pt.piezaId] = pt.cantidad;
    }
  }

  Future<void> _cargarMaterialesYTipos() async {
    final matProvider = Provider.of<MaterialProvider>(context, listen: false);
    final tipoProvider = Provider.of<TipoPiezaProvider>(context, listen: false);

    final resultadoMat = await matProvider.getMaterialesOrdenadosPorUso();
    await tipoProvider.getAllTipos();
    final resultadoTipos = tipoProvider.tipos;

    setState(() {
      materiales = resultadoMat;
      tipos = resultadoTipos;
    });
  }

  Future<void> _seleccionarMaterial(int id) async {
    if (materialSeleccionadoId == id) {
      final piezaProvider = Provider.of<PiezaProvider>(context, listen: false);
      final todas = await piezaProvider.getTodasLasPiezas();
      setState(() {
        materialSeleccionadoId = null;
        piezasDelMaterial = todas;
      });
    } else {
      final piezaProvider = Provider.of<PiezaProvider>(context, listen: false);
      final piezas = await piezaProvider.getPiezasPorMaterial(id);

      setState(() {
        materialSeleccionadoId = id;
        piezasDelMaterial = piezas;
      });
    }
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

  List<Pieza> get _piezasFiltradas {
    return piezasDelMaterial.where((pieza) {
      final coincideNombre = pieza.nombre.toLowerCase().contains(filtroNombre.toLowerCase());
      final coincideTipo = tipoSeleccionadoId == null || pieza.tipoId == tipoSeleccionadoId;
      return coincideNombre && coincideTipo;
    }).toList()
      ..sort((a, b) {
        final cmpUso = b.usoTotal.compareTo(a.usoTotal);
        return cmpUso != 0 ? cmpUso : a.nombre.compareTo(b.nombre);
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => setState(() => filtroNombre = value),
                    decoration: const InputDecoration(
                      labelText: 'Buscar por nombre',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: tipoSeleccionadoId,
                    decoration: const InputDecoration(labelText: 'Tipo'),
                    items: tipos.map((tipo) {
                      return DropdownMenuItem<int>(
                        value: tipo.id,
                        child: Text(tipo.nombre.replaceAll('_', ' ')),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => tipoSeleccionadoId = value),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'Pieza personalizada',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  tooltip: 'Añadir pieza personalizada',
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const FormularioPiezaPersonalizada(),
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
                    if (materialSeleccionadoId != null) {
                      await _seleccionarMaterial(materialSeleccionadoId!);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _piezasFiltradas.isEmpty
                ? const Center(child: Text('No hay piezas que coincidan.'))
                : ListView.builder(
              itemCount: _piezasFiltradas.length,
              itemBuilder: (context, index) {
                final pieza = _piezasFiltradas[index];
                final cantidad = cantidades[pieza.id] ?? 0;

                return GlassCard(
                  child: ListTile(
                    title: Text(pieza.nombre),
                    subtitle: pieza.materialId != null
                        ? Text('Tipo: ${pieza.tipoId}, Material: ${pieza.materialId}')
                        : null,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: BotonAccionFontPer(
              texto: 'Confirmar selección',
              onPressed: () {
                final resultado = cantidades.entries
                    .map((e) => PiezasTarea(piezaId: e.key, tareaId: -1, cantidad: e.value))
                    .toList();
                widget.onConfirmar(resultado);
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}