import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _prefsKey = 'notifiq_notifications';

  Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(settings);

    // Request permissions (Android 13+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // ──────────────── PERSISTÊNCIA ────────────────

  Future<List<NotifiqModel>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? [];

    final parsed = raw.map((s) => NotifiqModel.fromJsonString(s)).toList();

    // Ordena por data e hora para manter a lista previsível na interface.
    parsed.sort((a, b) {
      final dateCompare = (a.scheduledDate ?? DateTime(1970)).compareTo(
        b.scheduledDate ?? DateTime(1970),
      );
      if (dateCompare != 0) return dateCompare;
      return (a.time.hour * 60 + a.time.minute) -
          (b.time.hour * 60 + b.time.minute);
    });

    return parsed;
  }

  Future<void> saveAll(List<NotifiqModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      list.map((n) => n.toJsonString()).toList(),
    );
  }

  Future<void> upsert(NotifiqModel notif, List<NotifiqModel> all) async {
    final idx = all.indexWhere((n) => n.id == notif.id);
    if (idx >= 0) {
      all[idx] = notif;
    } else {
      all.add(notif);
    }

    // Garante que a lista em memória reflita a mudança antes de salvar.
    await saveAll(all);

    if (notif.active) {
      await schedule(notif);
    } else {
      await cancel(notif.id, notif.reminderTimes);
    }
  }

  Future<void> delete(String id, List<NotifiqModel> all) async {
    all.removeWhere((n) => n.id == id);
    await saveAll(all);
    await cancel(id);
  }

  // ──────────────── AGENDAMENTO ────────────────

  // Agenda uma notificação para cada horário definido em uma mesma data.
  Future<void> schedule(NotifiqModel notif) async {
    // Remove qualquer agendamento anterior para evitar duplicidade.
    await cancel(notif.id, notif.reminderTimes);

    // Se a notificação estiver desativada ou não houver uma data definida,
    // não faz sentido tentar agendar nada.
    if (!notif.active || notif.scheduledDate == null) return;

    for (int index = 0; index < notif.reminderTimes.length; index++) {
      final time = notif.reminderTimes[index];
      final targetDate = DateTime(
        notif.scheduledDate!.year,
        notif.scheduledDate!.month,
        notif.scheduledDate!.day,
        time.hour,
        time.minute,
      );

      final scheduledDate = tz.TZDateTime.from(targetDate, tz.local);

      // Evita agendar uma notificação no passado.
      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) continue;

      await _plugin.zonedSchedule(
        _idFromString('${notif.id}_$index'),
        notif.title,
        notif.body,
        scheduledDate,
        _buildDetails(notif),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  // Cancela todos os agendamentos associados a uma notificação.
  Future<void> cancel(String id, [List<TimeOfDay>? reminderTimes]) async {
    if (reminderTimes == null || reminderTimes.isEmpty) {
      await _plugin.cancel(_idFromString(id));
      return;
    }

    for (int index = 0; index < reminderTimes.length; index++) {
      await _plugin.cancel(_idFromString('${id}_$index'));
    }
  }

  NotificationDetails _buildDetails(NotifiqModel notif) {
    final android = AndroidNotificationDetails(
      'notifiq_channel',
      'Notifiq',
      channelDescription: 'Suas notificações personalizadas',
      importance: Importance.high,
      priority: Priority.high,
      color: notif.accentColor,
      ledColor: notif.accentColor,
      ledOnMs: 1000,
      ledOffMs: 500,
      enableLights: true,
      styleInformation: BigTextStyleInformation(notif.body),
      // Som personalizado (arquivo em res/raw/ no Android)
      sound: notif.sound != 'default' && notif.sound != 'none'
          ? RawResourceAndroidNotificationSound(notif.sound)
          : null,
      playSound: notif.sound != 'none',
    );

    final ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: notif.sound != 'none',
      sound: notif.sound != 'none' && notif.sound != 'default'
          ? '${notif.sound}.aiff'
          : null,
    );

    return NotificationDetails(android: android, iOS: ios);
  }

  tz.TZDateTime _nextWeekday(int weekday, int hour, int minute) {
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      hour,
      minute,
    );

    while (scheduled.weekday != weekday ||
        scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  int _idFromString(String s) {
    int hash = 0;
    for (final r in s.runes) {
      hash = (hash * 31 + r) & 0x7FFFFFFF;
    }
    return hash;
  }
}
