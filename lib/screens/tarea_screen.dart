// lib/screens/tarea_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:fontper/widgets/app_bar_general.dart';
import 'package:fontper/widgets/botón_personalizado.dart';
import 'package:fontper/widgets/glass_card.dart';

import '../models/tarea.dart';
import '../models/pieza_tarea.dart';
import '../providers/tarea_provider.dart';
import '../providers/pieza_provider.dart';

import '../utils/navigation_service.dart';
import 'selector_piezas_screen.dart';

class TareaScreen extends StatefulWidget {
  const TareaScreen({Key? key}) : super(key: key);

  @override
  State<TareaScreen> createState() => _TareaScreenState();
}

class _TareaScreenState extends State<TareaScreen> with RouteAware {
  final _formKey = GlobalKey<FormState>();
  String? nombre, direccion, telefono, notas;
  final Map<int, PiezasTarea> piezasSeleccionadas = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() {
    FocusScope.of(context).unfocus();
  }

  @override
  void didPopNext() {
    FocusScope.of(context).unfocus();
  }

  void _addPiezasDesdeSelector() async {
    final resultado = await Navigator.of(context).push<List<PiezasTarea>>(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => SelectorPiezasScreen(
          piezasSeleccionadas: piezasSeleccionadas.values.toList(),
        ),
        transitionDuration: const Duration(milliseconds: 150),
        transitionsBuilder: (_, animation, __, child) {
          final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOut);
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(opacity: curved, child: child),
          );
        },
      ),
    );
    if (resultado != null) {
      for (var pt in resultado) {
        piezasSeleccionadas.update(
          pt.piezaId,
              (existing) => PiezasTarea(
            piezaId: pt.piezaId,
            tareaId: -1,
            cantidad: existing.cantidad + pt.cantidad,
          ),
          ifAbsent: () => pt,
        );
      }
      setState(() {});
    }
  }

  void _modificarCantidad(int piezaId, int delta) {
    final actual = piezasSeleccionadas[piezaId];
    if (actual == null) return;
    final nueva = actual.cantidad + delta;
    if (nueva < 1)
      piezasSeleccionadas.remove(piezaId);
    else
      piezasSeleccionadas[piezaId] = PiezasTarea(
        piezaId: piezaId,
        tareaId: -1,
        cantidad: nueva,
      );
    setState(() {});
  }

  Future<void> _guardarTarea() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final tareaProvider =
    Provider.of<TareaProvider>(context, listen: false);
    final nuevaTarea = Tarea(
      nombreCliente: nombre,
      direccion: direccion,
      telefono: telefono,
      notas: notas,
    );
    await tareaProvider.crearTareaConPiezas(
      nuevaTarea,
      piezasSeleccionadas.values.toList(),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final piezaProvider =
    Provider.of<PiezaProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBarGeneral(titulo: 'Nueva tarea'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Form(
                  key: _formKey,
                  child: Column(children: [
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Nombre del cliente'),
                      onSaved: (v) => nombre = v,
                      validator: (v) =>
                      v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                    TextFormField(
                      decoration:
                      const InputDecoration(labelText: 'Dirección'),
                      onSaved: (v) => direccion = v,
                    ),
                    TextFormField(
                      decoration:
                      const InputDecoration(labelText: 'Teléfono'),
                      onSaved: (v) => telefono = v,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                    TextFormField(
                      decoration:
                      const InputDecoration(labelText: 'Notas'),
                      maxLines: null,
                      onSaved: (v) => notas = v,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text('Piezas seleccionadas',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.add_circle),
                          onPressed: _addPiezasDesdeSelector,
                        ),
                      ],
                    ),
                  ]),
                ),
                piezasSeleccionadas.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(child: Text('No hay piezas añadidas')),
                )
                    : ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: piezasSeleccionadas.values.map((pt) {
                    final p =
                    piezaProvider.getPiezaPorId(pt.piezaId);
                    return GlassCard(
                      child: ListTile(
                        title: Text(p?.nombre ?? 'Pieza'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () =>
                                    _modificarCantidad(
                                        pt.piezaId, -1)),
                            Text('${pt.cantidad}',
                                style:
                                const TextStyle(fontSize: 16)),
                            IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () =>
                                    _modificarCantidad(
                                        pt.piezaId, 1)),
                            IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    piezasSeleccionadas
                                        .remove(pt.piezaId);
                                  });
                                }),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                BotonAccionFontPer(
                  onPressed: _guardarTarea,
                  texto: 'Guardar tarea',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
