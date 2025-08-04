import 'package:flutter/material.dart';
import 'package:fontper/widgets/pieza_fields_default.dart';
import '../models/pieza.dart';
import '../models/material_fontaneria.dart';
import '../models/tipo_pieza.dart';
import '../widgets/termo_fields.dart';
import '../widgets/sanitario_fields.dart';
import '../widgets/dropdown_personalizado.dart';

typedef OnSubmitPieza = Future<void> Function(Pieza pieza);

class PiezaPersonalizadaForm extends StatefulWidget {
  final List<TipoPieza> tipos;
  final List<MaterialFontaneria> materiales;
  final OnSubmitPieza onSubmit;

  const PiezaPersonalizadaForm({
    Key? key,
    required this.tipos,
    required this.materiales,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<PiezaPersonalizadaForm> createState() =>
      _PiezaPersonalizadaFormState();
}

class _PiezaPersonalizadaFormState extends State<PiezaPersonalizadaForm>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Campos básicos
  String nombre = '';
  int? tipoId;
  int? materialId;

  // Sanitarios
  double? alto, ancho, profundo;

  // Genéricos
  String? medidaNominal, conexion, tipoControl, uso, instalacion;

  // Termo
  String? tipoTermo, capacidad, alimentacion, potencia, caudal;

  bool get esTermo {
    final n = widget.tipos
        .firstWhere((t) => t.id == tipoId, orElse: () => TipoPieza(id: 0, nombre: ''))
        .nombre
        .toLowerCase();
    return n.contains('termo') || n.contains('calentador');
  }

  bool get esSanitario {
    final n = widget.tipos
        .firstWhere((t) => t.id == tipoId, orElse: () => TipoPieza(id: 0, nombre: ''))
        .nombre
        .toLowerCase();
    return n.contains('inodoro') || n.contains('bañera') || n.contains('plato');
  }

  bool get requiereMaterial {
    if (tipoId == null) return false;
    final n = widget.tipos
        .firstWhere((t) => t.id == tipoId)
        .nombre
        .toLowerCase();
    return !n.contains('inodoro') &&
        !n.contains('bañera') &&
        !n.contains('plato') &&
        !n.contains('termo') &&
        !n.contains('calentador');
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final dimensiones = esSanitario
        ? '${alto!.toInt()}x${ancho!.toInt()}x${profundo!.toInt()}'
        : null;

    final nuevaPieza = Pieza(
      nombre: nombre.trim(),
      tipoId: tipoId,
      materialId: requiereMaterial ? materialId : null,
      dimensiones: dimensiones,
      medidaNominal: !esSanitario ? medidaNominal : null,
      conexion: conexion,
      tipoControl: tipoControl,
      uso: uso,
      instalacion: instalacion,
      tipoTermo: tipoTermo,
      capacidad: capacidad,
      alimentacion: alimentacion,
      potencia: potencia,
      caudal: caudal,
      usoTotal: 0,
      esPersonalizado: 1,
    );

    await widget.onSubmit(nuevaPieza);
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _formKey.currentState?.validate() ?? false;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Nombre
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nombre *',
                helperText: 'Descripción breve de la pieza',
              ),
              validator: (v) =>
              v == null || v.isEmpty ? 'Obligatorio' : null,
              onSaved: (v) => nombre = v!,
            ),
            const SizedBox(height: 12),

            // Tipo
            CustomDropdown<TipoPieza>(
              label: 'Tipo de pieza *',
              items: widget.tipos,
              value: widget.tipos
                  .firstWhere((t) => t.id == tipoId, orElse: () => TipoPieza(id: 0, nombre: '')),
              labelBuilder: (t) => t.nombre.replaceAll('_', ' '),
              onChanged: (t) {
                setState(() {
                  tipoId = t.id;
                });
              },
              validator: (v) => v == null ? 'Obligatorio' : null,
            ),

            // Material
            if (requiereMaterial) ...[
              const SizedBox(height: 12),
              CustomDropdown<MaterialFontaneria>(
                label: 'Material *',
                items: widget.materiales,
                value: widget.materiales.firstWhere(
                      (m) => m.id == materialId,
                  orElse: () => widget.materiales.first,
                ),
                labelBuilder: (m) => m.nombre,
                onChanged: (m) => setState(() => materialId = m.id),
                validator: (v) => v == null ? 'Obligatorio' : null,
              ),
            ],

            const SizedBox(height: 16),

            // Campos condicionales:
            if (esTermo)
              TermoFields(
                onSavedTipoTermo:    (v) => tipoTermo    = v,
                onSavedCapacidad:    (v) => capacidad    = v,
                onSavedAlimentacion: (v) => alimentacion = v,
                onSavedPotencia:     (v) => potencia     = v,
                onSavedCaudal:       (v) => caudal       = v,
              )
            else if (esSanitario)
              SanitarioFields(
                onSavedAlto:     (v) => alto     = double.tryParse(v!),
                onSavedAncho:    (v) => ancho    = double.tryParse(v!),
                onSavedProfundo: (v) => profundo = double.tryParse(v!),
              )
            else if (tipoId != null)
                PiezaFieldsDefault(
                  onSavedMedidaNominal: (v) => medidaNominal = v,
                  onSavedConexion:      (v) => conexion      = v,
                  onSavedTipoControl:   (v) => tipoControl   = v,
                  onSavedUso:           (v) => uso           = v,
                  onSavedInstalacion:   (v) => instalacion   = v,
                ),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Guardar pieza'),
              onPressed: isValid ? _handleSubmit : null,
            ),
          ],
        ),
      ),
    );
  }
}
