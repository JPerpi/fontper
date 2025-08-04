import 'package:flutter/material.dart';
import 'package:fontper/widgets/lista_piezas_seleccionadas.dart';
import 'package:provider/provider.dart';

import '../widgets/app_bar_general.dart';
import '../widgets/botón_personalizado.dart';

import '../widgets/tarea_form.dart';
import '../services/navigation_service.dart';

import '../models/tarea.dart';
import '../models/pieza_tarea.dart';
import '../providers/tarea_provider.dart';
import '../providers/pieza_provider.dart';

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
  void didPushNext()  => FocusScope.of(context).unfocus();
  @override
  void didPopNext()   => FocusScope.of(context).unfocus();

  Future<void> _addPiezasDesdeSelector() async {
    final resultado = await openSelectorPiezas(
      context,
      piezasSeleccionadas.values.toList(),
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
    if (nueva < 1) {
      piezasSeleccionadas.remove(piezaId);
    } else {
      piezasSeleccionadas[piezaId] = PiezasTarea(
        piezaId: piezaId,
        tareaId: -1,
        cantidad: nueva,
      );
    }
    setState(() {});
  }

  Future<void> _guardarTarea() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final tareaProv = context.read<TareaProvider>();
    final nuevaTarea = Tarea(
      nombreCliente: nombre,
      direccion: direccion,
      telefono: telefono,
      notas: notas,
    );
    await tareaProv.crearTareaConPiezas(
      nuevaTarea,
      piezasSeleccionadas.values.toList(),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final piezaProvider = context.read<PiezaProvider>();

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
                // 1) Formulario extraído
                TareaForm(
                  formKey: _formKey,
                  onSavedNombre:   (v) => nombre    = v,
                  onSavedDireccion:(v) => direccion = v,
                  onSavedTelefono: (v) => telefono  = v,
                  onSavedNotas:    (v) => notas     = v,
                  onAddPiezas:     _addPiezasDesdeSelector,
                ),

                const SizedBox(height: 8),

                // 2) Lista de piezas extraída con swipe-to-delete
                ListaPiezasSeleccionadas(
                  piezas:           piezasSeleccionadas,
                  piezaProvider:    piezaProvider,
                  onChangeCantidad: _modificarCantidad,
                  onRemove:         (id) => setState(() => piezasSeleccionadas.remove(id)),
                ),

                const SizedBox(height: 8),

                // 3) Botón de guardar
                BotonAccionFontPer(
                  onPressed: _guardarTarea,
                  texto:     'Guardar tarea',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
