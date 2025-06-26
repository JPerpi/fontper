import 'package:flutter/material.dart';

class FondoDinamico extends StatelessWidget {
  final Widget child;

  const FondoDinamico({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bool esOscuro = Theme.of(context).brightness == Brightness.dark;
    final String fondo = esOscuro
        ? 'assets/fondo_oscuro.png'
        : 'assets/fondo_claro.png';

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(fondo),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
