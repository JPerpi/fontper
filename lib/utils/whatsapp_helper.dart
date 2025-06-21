import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

Future<void> compartirPorWhatsApp(BuildContext context, String mensaje) async {
  try {
    print('📤 Compartiendo mensaje...');
    await Share.share(mensaje);
  } catch (e) {
    print('❌ Error al compartir: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No se pudo compartir el mensaje')),
    );
  }
}
