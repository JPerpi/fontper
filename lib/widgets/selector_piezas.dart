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
  late final ScrollController _scrollCtrl;

  Map<int, int> cantidades = {};
  int? materialSeleccionadoId;
  int? tipoSeleccionadoId;
  String filtroNombre = '';

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController()
      ..addListener(() {
        final prov = context.read<PiezaProvider>();
        // Cuando queden menos de 200px para el final, carga más
        if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200) {
          if (!prov.isLoading && prov.hasMore) {
            prov.loadPiezas();
          }
        }
      });

    // 2) Carga la primera página
    context.read<PiezaProvider>().loadPiezas(reset: true);
    _cargarMaterialesYTipos();

    for (var pt in widget.piezasIniciales) {
      cantidades[pt.piezaId] = pt.cantidad;
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
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
                onSelected: (_) {
                  setState(() {
                    materialSeleccionadoId = seleccionado ? null : m.id;
                  });
                  context.read<PiezaProvider>().loadPiezas(
                    reset:        true,
                    materialId:   materialSeleccionadoId,
                    tipoId:       tipoSeleccionadoId,
                    nombreFilter: filtroNombre,
                  );
                },
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
                    onChanged: (value) {
                      setState(() => filtroNombre = value);
                      context.read<PiezaProvider>().loadPiezas(
                        reset:        true,
                        materialId:   materialSeleccionadoId,
                        tipoId:       tipoSeleccionadoId,
                        nombreFilter: filtroNombre,
                      );
                    },
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
                    onChanged: (value) {
                      setState(() => tipoSeleccionadoId = value);
                      context.read<PiezaProvider>().loadPiezas(
                        reset:        true,
                        materialId:   materialSeleccionadoId,
                        tipoId:       tipoSeleccionadoId,
                        nombreFilter: filtroNombre,
                      );
                    },
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
                          final offset = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(curved);
                          return SlideTransition(position: offset, child: FadeTransition(opacity: curved, child: child));
                        },
                      ),
                    );
                    await context.read<PiezaProvider>().loadPiezas(
                      reset:        true,
                      materialId:   materialSeleccionadoId,
                      tipoId:       tipoSeleccionadoId,
                      nombreFilter: filtroNombre,
                    );
                    _scrollCtrl.jumpTo(0);
                  },
                ),

              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer<PiezaProvider>(
              builder: (_, prov, __) {
                final lista = prov.piezasPaginadas;

                if (lista.isEmpty && prov.isLoading) {
                  // loader inicial
                  return const Center(child: CircularProgressIndicator());
                }
                if (lista.isEmpty) {
                  // no hay nada que mostrar
                  return const Center(child: Text('No hay piezas que coincidan.'));
                }

                return ListView.builder(
                  controller: _scrollCtrl,
                  itemCount: lista.length + (prov.hasMore ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i < lista.length) {
                      final pieza   = lista[i];
                      final cantidad = cantidades[pieza.id!] ?? 0;
                      return GlassCard(
                        child: ListTile(
                          title:    Text(pieza.nombre),
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
                    } else {
                      // loader al final
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                  },
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