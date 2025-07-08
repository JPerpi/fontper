import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  const FormularioPiezaPersonalizada({Key? key}) : super(key: key);

  @override
  State<FormularioPiezaPersonalizada> createState() =>
      _FormularioPiezaPersonalizadaState();
}

class _FormularioPiezaPersonalizadaState
    extends State<FormularioPiezaPersonalizada> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Campos básicos
  String nombre = '';
  int? tipoId;
  int? materialId;

  // Dimensiones para sanitarios
  double? alto;
  double? ancho;
  double? profundo;

  // Campos genéricos
  String? medidaNominal;
  String? conexion;
  String? tipoControl;
  String? uso;
  String? instalacion;

  // Termo
  String? tipoTermo;
  String? capacidad;
  String? alimentacion;
  String? potencia;
  String? caudal;

  List<TipoPieza> tipos = [];
  List<MaterialFontaneria> materiales = [];

  late final AnimationController _animController;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _anim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _cargarListas();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _cargarListas() async {
    final matProv = Provider.of<MaterialProvider>(context, listen: false);
    final tipoProv = Provider.of<TipoPiezaProvider>(context, listen: false);

    final listaM = await matProv.getTodosLosMateriales();
    await tipoProv.getAllTipos();

    setState(() {
      materiales = listaM;
      tipos = tipoProv.tipos;
    });
  }

  TipoPieza? get tipoSeleccionado =>
      tipoId == null ? null : tipos.firstWhere((t) => t.id == tipoId);

  bool get esTermo {
    final n = tipoSeleccionado?.nombre.toLowerCase() ?? '';
    return n.contains('termo') || n.contains('calentador');
  }

  bool get esSanitario {
    final n = tipoSeleccionado?.nombre.toLowerCase() ?? '';
    return n.contains('inodoro') || n.contains('bañera') || n.contains('plato');
  }

  bool get requiereMaterial {
    if (tipoSeleccionado == null) return false;
    final n = tipoSeleccionado?.nombre.toLowerCase() ?? '';
    return !n.contains('inodoro') &&
        !n.contains('bañera') &&
        !n.contains('plato') &&
        !n.contains('termo') &&
        !n.contains('calentador');
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final dimensiones = esSanitario
        ? '${alto!.toInt()}x${ancho!.toInt()}x${profundo!.toInt()}'
        : null;

    final pieza = Pieza(
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

    await Provider.of<PiezaProvider>(context, listen: false)
        .insertarPiezaPersonalizada(pieza);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pieza guardada correctamente')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (tipos.isEmpty || materiales.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isValid = _formKey.currentState?.validate() ?? false;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AppBarGeneral(titulo: 'Nueva pieza'),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: () => setState(() {}),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: ListView(
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

                  // Tipo de pieza
                  CustomDropdown<TipoPieza>(
                    label: 'Tipo de pieza *',
                    items: tipos,
                    value: tipoSeleccionado,
                    labelBuilder: (t) => t.nombre.replaceAll('_', ' '),
                    onChanged: (t) {
                      setState(() {
                        tipoId = t.id;
                        _animController.forward(from: 0);
                      });
                    },
                    validator: (v) => v == null ? 'Obligatorio' : null,
                  ),

                  // Material si aplica
                  if (requiereMaterial) ...[
                    const SizedBox(height: 12),
                    CustomDropdown<MaterialFontaneria>(
                      label: 'Material *',
                      items: materiales,
                      value: materiales.firstWhere(
                        (m) => m.id == materialId,
                        orElse: () => materiales.first,
                      ),
                      labelBuilder: (m) => m.nombre,
                      onChanged: (m) => setState(() => materialId = m.id),
                      validator: (v) => v == null ? 'Obligatorio' : null,
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Campos condicionales
                  if (esTermo) ...[
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Tipo de termo',
                          helperText: 'Eléctrico, gas, horizontal…'),
                      onSaved: (v) => tipoTermo = v,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Capacidad (L)',
                        helperText: 'Volumen de agua caliente que almacena',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSaved: (v) => capacidad = v,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Alimentación',
                        helperText: 'Electricidad, gas, diesel...',
                      ),
                      onSaved: (v) => alimentacion = v,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Potencia (W)',
                        helperText: 'Potencia en vatios',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSaved: (v) => potencia = v,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Caudal (L/min)',
                        helperText: 'Caudal máximo en litros por minuto',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+(\.\d{1,2})?$'),
                        )
                      ],
                      onSaved: (v) => caudal = v,
                    ),
                  ] else if (esSanitario) ...[
                    // Sanitarios: alto/ancho/profundo
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Alto (cm) *',
                          helperText: 'Altura máxima de la pieza'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Obligatorio' : null,
                      onSaved: (v) => alto = double.tryParse(v!),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Ancho (cm) *',
                          helperText: 'Anchura máxima de la pieza'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Obligatorio' : null,
                      onSaved: (v) => ancho = double.tryParse(v!),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Profundo (cm) *',
                          helperText: 'Profundidad total de la pieza'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Obligatorio' : null,
                      onSaved: (v) => profundo = double.tryParse(v!),
                    ),
                  ] else if (tipoId != null) ...[
                    // Resto de piezas
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Medida nominal',
                        helperText: '1 1/", 1"...',
                      ),
                      onSaved: (v) => medidaNominal = v,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Conexión',
                        helperText: 'roscado, brida...',
                      ),
                      onSaved: (v) => conexion = v,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Tipo de control',
                        helperText: 'Bola, compuerta, diafragma...',
                      ),
                      onSaved: (v) => tipoControl = v,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Uso',
                        helperText: 'Agua caliente, fria...',
                      ),
                      onSaved: (v) => uso = v,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Instalación',
                        helperText: 'Pared, suelo...',
                      ),
                      onSaved: (v) => instalacion = v,
                    ),
                  ],

                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar pieza'),
                    onPressed: isValid ? _guardar : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
