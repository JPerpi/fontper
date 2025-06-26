import 'package:flutter/material.dart';
import 'package:fontper/widgets/app_bar_general.dart';
import 'package:provider/provider.dart';

import '../models/material_fontaneria.dart';
import '../models/pieza.dart';
import '../models/tipo_pieza.dart';
import '../providers/material_provider.dart';
import '../providers/pieza_provider.dart';
import '../providers/tipo_pieza_provider.dart';
import '../widgets/dropdown_personalizado.dart';

class FormularioPiezaPersonalizada extends StatefulWidget {
  const FormularioPiezaPersonalizada({super.key});

  @override
  State<FormularioPiezaPersonalizada> createState() => _FormularioPiezaPersonalizadaState();
}

class _FormularioPiezaPersonalizadaState extends State<FormularioPiezaPersonalizada> {
  final _formKey = GlobalKey<FormState>();

  String nombre = '';
  int? materialId;
  int? tipoId;

  // Campos opcionales
  String? conexion;
  String? medidaNominal;
  String? tipoControl;
  String? uso;
  String? instalacion;
  String? dimensiones;
  String? tipoTermo;
  String? capacidad;
  String? alimentacion;
  String? potencia;
  String? caudal;

  List<MaterialFontaneria> materiales = [];
  List<TipoPieza> tipos = [];

  @override
  void initState() {
    super.initState();
    _cargarListas();
  }

  Future<void> _cargarListas() async {
    final matProvider = Provider.of<MaterialProvider>(context, listen: false);
    final tipoProvider = Provider.of<TipoPiezaProvider>(context, listen: false);

    final listaMat = await matProvider.getTodosLosMateriales();
    await tipoProvider.getAllTipos();
    final listaTipos = tipoProvider.tipos;

    setState(() {
      materiales = listaMat;
      tipos = listaTipos;
    });
  }

  bool get esTermo => tipoId != null && (tipos.firstWhere((t) => t.id == tipoId).nombre.toLowerCase().contains('termo') || tipos.firstWhere((t) => t.id == tipoId).nombre.toLowerCase().contains('calentador'));

  bool get esSanitario {
    if (tipoId == null) return false;
    final nombreTipo = tipos.firstWhere((t) => t.id == tipoId).nombre.toLowerCase();
    return nombreTipo.contains('inodoro') || nombreTipo.contains('bañera') || nombreTipo.contains('plato');
  }

  bool get requiereMaterial {
    if (tipoId == null) return false;
    final nombreTipo = tipos.firstWhere((t) => t.id == tipoId).nombre.toLowerCase();
    return !nombreTipo.contains('inodoro') &&
        !nombreTipo.contains('plato') &&
        !nombreTipo.contains('bañera') &&
        !nombreTipo.contains('termo') &&
        !nombreTipo.contains('calentador');
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final pieza = Pieza(
      nombre: nombre,
      materialId: requiereMaterial ? materialId : null,
      tipoId: tipoId,
      conexion: conexion,
      medidaNominal: medidaNominal,
      tipoControl: tipoControl,
      uso: uso,
      instalacion: instalacion,
      dimensiones: dimensiones,
      tipoTermo: tipoTermo,
      capacidad: capacidad,
      alimentacion: alimentacion,
      potencia: potencia,
      caudal: caudal,
      usoTotal: 0,
      esPersonalizado: 1,
    );

    final piezaProvider = Provider.of<PiezaProvider>(context, listen: false);
    await piezaProvider.insertarPiezaPersonalizada(pieza);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBarGeneral(
        titulo: 'Nueva pieza'
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre *'),
                validator: (value) => value == null || value.isEmpty ? 'Obligatorio' : null,
                onSaved: (value) => nombre = value!,
              ),
              CustomDropdown<TipoPieza>(
                label: 'Tipo de pieza *',
                items: tipos,
                value: tipoId != null
                    ? tipos.firstWhere((t) => t.id == tipoId)
                    : null,
                labelBuilder: (tipo) => tipo.nombre.replaceAll('_', ' '),
                onChanged: (tipo) => setState(() => tipoId = tipo.id),
                validator: (val) => val == null ? 'Obligatorio' : null,
              ),

              if (requiereMaterial)
                CustomDropdown<MaterialFontaneria>(
                  label: 'Material *',
                  items: materiales,
                  value: materialId != null
                      ? materiales.firstWhere((m) => m.id == materialId)
                      : null,
                  labelBuilder: (mat) => mat.nombre,
                  onChanged: (mat) => setState(() => materialId = mat.id),
                  validator: (val) => requiereMaterial && val == null ? 'Obligatorio' : null,
                ),

              const SizedBox(height: 16),

              // Campos condicionales
              if (esTermo) ...[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Tipo de termo'),
                  onSaved: (value) => tipoTermo = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Capacidad (L)'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => capacidad = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Alimentación'),
                  onSaved: (value) => alimentacion = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Potencia (W)'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => potencia = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Caudal (L/min)'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => caudal = value,
                ),
              ] else if (esSanitario) ...[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Dimensiones'),
                  onSaved: (value) => dimensiones = value,
                ),
              ] else if (tipoId != null) ...[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Medida nominal'),
                  onSaved: (value) => medidaNominal = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Conexión'),
                  onSaved: (value) => conexion = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Tipo de control'),
                  onSaved: (value) => tipoControl = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Uso'),
                  onSaved: (value) => uso = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Instalación'),
                  onSaved: (value) => instalacion = value,
                ),
              ],

              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar pieza'),
                onPressed: _guardar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
