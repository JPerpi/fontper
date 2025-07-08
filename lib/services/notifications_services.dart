// lib/services/notifications_service.dart

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class NotificationsService {
  static final _notif = FlutterLocalNotificationsPlugin();

  /// Inicializa notificaciones y el sistema de zonas usando un mapeo de abreviaturas.
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1) Configuración del plugin
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _notif.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      ),
    );

    // 2) Carga de la base de datos de zonas
    tz_data.initializeTimeZones();

    // 3) Detecta la abreviatura local y mapea a la zona IANA correcta
    final abbr = DateTime.now().timeZoneName;
    final iana = _mapAbbreviationToIana(abbr);
    tz.setLocalLocation(tz.getLocation(iana));
  }

  /// Mapea abreviaturas comunes a zonas IANA.
  static String _mapAbbreviationToIana(String abbr) {
    switch (abbr) {
      case 'CET':
      case 'CEST':
        return 'Europe/Madrid';
      case 'PST':
      case 'PDT':
        return 'America/Los_Angeles';
      case 'EST':
      case 'EDT':
        return 'America/New_York';
    // añade más casos si lo necesitas
      default:
      // si no lo conocemos, devolvemos UTC como fallback
        return 'UTC';
    }
  }

  /// Programa 4 avisos para la cita: 2d, 1d, 5h y 1h antes.
  static Future<void> scheduleCita(
      int tareaId, String cliente, DateTime cita) async {
    final offsets = <Duration, String>{
      const Duration(days: 2): '2 días',
      const Duration(days: 1): '1 día',
      const Duration(hours: 5): '5 horas',
      const Duration(hours: 1): '1 hora',
    };

    for (var entry in offsets.entries) {
      // restamos 30m extra antes de la antelación que ya tenías
      final when = cita
          .subtract(const Duration(minutes: 30))
          .subtract(entry.key);
      if (!when.isAfter(DateTime.now())) continue;

      final notifId =
          tareaId * 10 + offsets.keys.toList().indexOf(entry.key);

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'canal_citas',
          'Citas',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      );

      await _notif.zonedSchedule(
        notifId,
        'Recordatorio (${entry.value})',
        'Cita con $cliente el ${DateFormat.yMd().add_jm().format(cita)}',
        tz.TZDateTime.from(when, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }



  /// Cancela los 4 recordatorios de la cita.
  static Future<void> cancelCita(int tareaId) async {
    for (var i = 0; i < 4; i++) {
      await _notif.cancel(tareaId * 10 + i);
    }
  }
}
