import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../db/db_provider.dart';

class NotificationHelper {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static late Database _db;

  /// 1) Inicializa plugin + huso + asigna tu BBDD
  static Future<void> init() async {
    // A) Abre la BD real (que ya tiene la tabla `tareas`)
    _db = await DBProvider.database;

    // B) Carga zonas y DST
    tz.initializeTimeZones();
    final now = DateTime.now();
    final iana = (now.timeZoneName=='CET' || now.timeZoneName=='CEST')
        ? 'Europe/Madrid'
        : 'Etc/GMT${now.timeZoneOffset.isNegative ? '-' : '+'}${now.timeZoneOffset.inHours.abs()}';
    tz.setLocalLocation(tz.getLocation(iana));

    // C) Inicializa el plugin
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit    = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    // D) Pide permisos Android 13+
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        'canal_1',                 // mismo ID que usas en NotificationDetails
        'Recordatorios',           // nombre visible
        description: 'Citas y recordatorios de fontanería',
        importance: Importance.max,
        playSound: true,
      ),
    );
    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestExactAlarmsPermission();

    final bool? granted = await androidImpl?.requestNotificationsPermission();
    debugPrint('🔔 Permission POST_NOTIFICATIONS granted? $granted');

    // SCHEDULE_EXACT_ALARM
    final bool? exactAlarmGranted =
    await androidImpl?.requestExactAlarmsPermission();
    debugPrint('⏰ Permission SCHEDULE_EXACT_ALARM granted? $exactAlarmGranted');
  }

  static Future<void> scheduleTestNotification() async {
    final when = DateTime.now().add(const Duration(seconds: 10));
    await _plugin.zonedSchedule(
      999, // id de prueba
      '🔔 Test de notificaciones',
      'Si ves esto, las notificaciones funcionan',
      tz.TZDateTime.from(when, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'canal_test',
          'Canal de pruebas',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    debugPrint('🕒 Test programado para 10s después: $when');
  }

  static Future<void> logPendingRequests() async {
    final pendientes = await _plugin.pendingNotificationRequests();
    if (pendientes.isEmpty) {
      debugPrint('⚠️ No hay notificaciones pendientes.');
    } else {
      for (var r in pendientes) {
        debugPrint('🔍 Pendiente #${r.id}: ${r.title} — ${r.body}');
      }
    }
  }

  /// 2) Lee la fecha de `tareas.scheduledAt` (almacenada como INTEGER msSinceEpoch)
  static Future<DateTime?> _fetchAppointmentDate(int id) async {
    final maps = await _db.query(
      'tareas',
      columns: ['scheduledAt'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    final millis = maps.first['scheduledAt'] as int?;
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  /// 3) Programa los 4 recordatorios
  static Future<void> scheduleFromDatabase({
    required int appointmentId,
    required String title,
    required String body,
  }) async {
    final appointment = await _fetchAppointmentDate(appointmentId);
    if (appointment == null) {
      throw Exception('Cita $appointmentId no encontrada en la BBDD');
    }
    await _scheduleAll(appointmentId, title, body, appointment);
  }

  static Future<void> _scheduleAll(
      int baseId,
      String title,
      String body,
      DateTime appt,
      ) async {
    final now = DateTime.now();
    final offsets = <Duration, String>{
      Duration(days: 2): 'Faltan 2 días',
      Duration(days: 1): 'Mañana',
      Duration(hours: 5): 'En 5 horas',
      Duration(hours: 1): 'En 1 hora',
    };
    int idx = 0;
    for (final entry in offsets.entries) {
      final when = appt.subtract(entry.key);
      if (when.isAfter(now)) {
        await _plugin.zonedSchedule(
          baseId * 100 + idx,
          title,
          '${entry.value}: $body',
          tz.TZDateTime.from(when, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'canal_1',
              'Recordatorios',
              importance: Importance.max,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
      idx++;
    }
  }


  /// 4) Cancela los 4 avisos de una cita
  static Future<void> cancelAll(int baseId) async {
    for (int i = 0; i < 4; i++) {
      await _plugin.cancel(baseId * 100 + i);
    }
  }
}
