import 'dart:convert';
import 'package:flutter/material.dart';

class NotifiqModel {
  final String id;
  String title;
  String body;
  Color accentColor;
  String icon;
  String sound;
  List<bool> days; // [Dom, Seg, Ter, Qua, Qui, Sex, Sáb]
  TimeOfDay time;
  bool active;
  bool darkTheme;
  DateTime createdAt;

  NotifiqModel({
    required this.id,
    required this.title,
    required this.body,
    required this.accentColor,
    required this.icon,
    required this.sound,
    required this.days,
    required this.time,
    this.active = true,
    this.darkTheme = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  NotifiqModel copyWith({
    String? title,
    String? body,
    Color? accentColor,
    String? icon,
    String? sound,
    List<bool>? days,
    TimeOfDay? time,
    bool? active,
    bool? darkTheme,
  }) {
    return NotifiqModel(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      accentColor: accentColor ?? this.accentColor,
      icon: icon ?? this.icon,
      sound: sound ?? this.sound,
      days: days ?? List.from(this.days),
      time: time ?? this.time,
      active: active ?? this.active,
      darkTheme: darkTheme ?? this.darkTheme,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'accentColor': accentColor.value,
        'icon': icon,
        'sound': sound,
        'days': days,
        'timeHour': time.hour,
        'timeMinute': time.minute,
        'active': active,
        'darkTheme': darkTheme,
        'createdAt': createdAt.toIso8601String(),
      };

  factory NotifiqModel.fromJson(Map<String, dynamic> json) => NotifiqModel(
        id: json['id'],
        title: json['title'],
        body: json['body'],
        accentColor: Color(json['accentColor']),
        icon: json['icon'],
        sound: json['sound'],
        days: List<bool>.from(json['days']),
        time: TimeOfDay(hour: json['timeHour'], minute: json['timeMinute']),
        active: json['active'],
        darkTheme: json['darkTheme'] ?? true,
        createdAt: DateTime.parse(json['createdAt']),
      );

  String toJsonString() => jsonEncode(toJson());

  factory NotifiqModel.fromJsonString(String s) =>
      NotifiqModel.fromJson(jsonDecode(s));

  // Dias com notificação ativa como string legível
  String get scheduleLabel {
    final names = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    final active = <String>[];
    for (int i = 0; i < 7; i++) {
      if (days[i]) active.add(names[i]);
    }
    if (active.length == 7) return 'Todo dia';
    if (active.length == 5 &&
        !days[0] &&
        !days[6]) return 'Dias úteis';
    if (active.length == 2 && days[0] && days[6]) return 'Fins de semana';
    if (active.isEmpty) return 'Nenhum dia';
    return active.join(', ');
  }

  String get timeLabel {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
