// lib/providers/catalogs_provider.dart

import 'package:flutter/foundation.dart';
import 'package:fontper/models/material_fontaneria.dart';
import 'package:fontper/models/tipo_pieza.dart';
import 'package:fontper/providers/material_provider.dart';
import 'package:fontper/providers/tipo_pieza_provider.dart';

/// Un único ChangeNotifier que gestiona la carga de tipos y materiales.
class CatalogoProvider with ChangeNotifier {
  bool _loading = true;
  bool get loading => _loading;

  List<TipoPieza> tipos = [];
  List<MaterialFontaneria> materiales = [];

  /// Llama a los providers individuales y almacena resultados.
  Future<void> loadAll() async {
    _loading = true;
    notifyListeners();

    final matProv  = MaterialProvider();
    final tipoProv = TipoPiezaProvider();

    materiales = await matProv.getTodosLosMateriales();
    await tipoProv.getAllTipos();
    tipos       = tipoProv.tipos;

    _loading = false;
    notifyListeners();
  }
}
