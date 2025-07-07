import 'package:flutter/cupertino.dart';
import '../db/db_provider.dart';
import '../models/pieza.dart';

class PiezaProvider with ChangeNotifier {
  List<Pieza> _piezas = [];
  static const _pageSize = 20;
  List<Pieza> _piezasPaginadas = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  List<Pieza> get piezasPaginadas => _piezasPaginadas;
  bool get isLoading         => _isLoading;
  bool get hasMore           => _hasMore;

  Future<void> loadPiezas({
    bool reset = false,
    int? materialId,
    int? tipoId,
    String? nombreFilter,
  }) async {
    if (_isLoading) return;
    if (reset) {
      _offset = 0;
      _piezasPaginadas.clear();
      _hasMore = true;
    }
    if (!_hasMore) return;

    _isLoading = true;
    notifyListeners();

    final db = await DBProvider.database;
    final where = <String>[];
    final args  = <dynamic>[];

    if (materialId != null) {
      where.add('material_id = ?');
      args.add(materialId);
    }
    if (tipoId != null) {
      where.add('tipo_id = ?');
      args.add(tipoId);
    }
    if (nombreFilter != null && nombreFilter.isNotEmpty) {
      where.add('LOWER(nombre) LIKE ?');
      args.add('%${nombreFilter.toLowerCase()}%');
    }

    final maps = await db.query(
      'pieza',
      where:    where.isEmpty ? null : where.join(' AND '),
      whereArgs: where.isEmpty ? null : args,
      limit:    _pageSize,
      offset:   _offset,
      orderBy:  'nombre ASC',
    );
    final fetched = maps.map((m) => Pieza.fromMap(m)).toList();

    _piezasPaginadas.addAll(fetched);
    _offset += fetched.length;
    _hasMore = fetched.length == _pageSize;
    _isLoading = false;
    notifyListeners();
  }

  Future<List<Pieza>> getTodasLasPiezas() async {
    if (_piezas.isNotEmpty) return _piezas; // ya cargadas
    final db = await DBProvider.database;
    final res = await db.query('pieza');
    _piezas = res.map((e) => Pieza.fromMap(e)).toList();
    return _piezas;
  }

  Pieza? getPiezaPorId(int id) {
    try {
      return _piezas.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Pieza>> getPiezasPorMaterial(int materialId) async {
    final db = await DBProvider.database;
    final res = await db.query('pieza', where: 'material_id = ?', whereArgs: [materialId]);
    return res.map((e) => Pieza.fromMap(e)).toList();
  }

  Future<void> insertarPiezaPersonalizada(Pieza pieza) async {
    final db = await DBProvider.database;
    final nuevoId = await db.insert('pieza', pieza.toMap());
    pieza.id = nuevoId;
    _piezas.add(pieza);
    _piezasPaginadas.add(pieza);
    notifyListeners();
  }



}