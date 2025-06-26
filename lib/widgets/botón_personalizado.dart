import 'package:flutter/material.dart';

class BotonAccionFontPer extends StatelessWidget {
  final String texto;
  final void Function()? onPressed;
  final IconData? icono;
  final bool esCancelar;

  const BotonAccionFontPer({
    super.key,
    required this.texto,
    required this.onPressed,
    this.icono,
    this.esCancelar = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: icono != null ? Icon(icono, size: 20) : const SizedBox.shrink(),
      label: Text(
        texto,
        style: const TextStyle(
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: esCancelar ? Colors.grey[700] : const Color(0xFFCF4648),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
    );
  }
}
