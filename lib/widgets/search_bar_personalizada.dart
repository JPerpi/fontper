import 'dart:ui';
import 'package:flutter/material.dart';

import 'glass_card.dart';

/// Campo de búsqueda que aplica tu estilo original
/// (filled semitransparente + OutlineInputBorder)
/// y un fondo glassmorphism (blur + semitransparencia).
class SearchBarPersonalizada extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const SearchBarPersonalizada({
    Key? key,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassCard(
        // GlassCard ya aporta el fondo semitransparente, borde redondeado, etc.
        child: TextField(
          onChanged: onChanged,
          decoration: const InputDecoration(
            hintText: 'Buscar por nombre',
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }
}