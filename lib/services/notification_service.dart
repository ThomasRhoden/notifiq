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
    return raw.map((s) => NotifiqModel.fromJsonString(s)).toList()
      ..sort((a, b) =>
          a.time.hour * 60 + a.time.minute -
          (b.time.hour * 60 + b.time.minute));
  }

  Future<void> saveAll(List<NotifiqModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _prefsKey, list.map((n) => n.toJsonString()).toList());
  }

  Future<void> upsert(NotifiqModel notif, List<NotifiqModel> all) async {
    final idx = all.indexWhere((n) => n.id == notif.id);
    if (idx >= 0) {
      all[idx] = notif;
    } else {
      all.add(notif);
    }
    await saveAll(all);
    if (notif.active) {
      await schedule(notif);
    } else {
      await cancel(notif.id);
    }
  }

  Future<void> delete(String id, List<NotifiqModel> all) async {
    all.removeWhere((n) => n.id == id);
    await saveAll(all);
    await cancel(id);
  }

  // ──────────────── AGENDAMENTO ────────────────

  Future<void> schedule(NotifiqModel notif) async {
    await cancel(notif.id);

    final now = tz.TZDateTime.now(tz.local);
    final days = notif.days;

    // Agendamos uma notificação por dia da semana ativo
    for (int weekday = 0; weekday < 7; weekday++) {
      if (!days[weekday]) continue;

      // Flutter weekday: 1=Mon...7=Sun; nosso array: 0=Dom
      final flutterDay = weekday == 0 ? 7 : weekday;
      final notifId = _idFromString('${notif.id}_$weekday');

      tz.TZDateTime scheduledDate = _nextWeekday(
        flutterDay,
        notif.time.hour,
        notif.time.minute,
      );

      await _plugin.zonedSchedule(
        notifId,
        notif.title,
        notif.body,
        scheduledDate,
        _buildDetails(notif),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> cancel(String id) async {
    for (int weekday = 0; weekday < 7; weekday++) {
      await _plugin.cancel(_idFromString('${id}_$weekday'));
    }
  }

  NotificationDetails _buildDetails(NotifiqModel notif) {
    // Cor Android como int ARGB
    final colorValue = notif.accentColor.value;

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
