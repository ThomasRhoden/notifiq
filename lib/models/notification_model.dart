import 'dart:convert';
import 'package:flutter/material.dart';

// Representa uma notificação personalizada criada pelo usuário.
// Esse modelo centraliza os dados que serão exibidos, persistidos e agendados.
class NotifiqModel {
  final String id;
  String title;
  String body;
  Color accentColor;
  String icon;
  String sound;
  List<bool> days; // Mantido para compatibilidade com o fluxo anterior.
  TimeOfDay time;
  bool active;
  bool darkTheme;
  DateTime createdAt;
  DateTime? scheduledDate; // Data principal para o lembrete.
  List<TimeOfDay> reminderTimes; // Vários horários por data.

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
    this.scheduledDate,
    List<TimeOfDay>? reminderTimes,
  }) : createdAt = createdAt ?? DateTime.now(),
       reminderTimes = reminderTimes ?? [time];

  // Cria uma cópia do modelo com valores substituídos quando necessário.
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
    DateTime? scheduledDate,
    List<TimeOfDay>? reminderTimes,
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
      scheduledDate: scheduledDate ?? this.scheduledDate,
      reminderTimes: reminderTimes ?? List.from(this.reminderTimes),
    );
  }

  // Converte o modelo para um mapa serializável em JSON.
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
        'scheduledDate': scheduledDate?.toIso8601String(),
        'reminderTimes': reminderTimes
            .map((timeOfDay) => '${timeOfDay.hour}:${timeOfDay.minute}')
            .toList(),
      };

  // Reconstrói um objeto a partir de um mapa JSON persistido.
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
        scheduledDate: json['scheduledDate'] != null
            ? DateTime.parse(json['scheduledDate'])
            : null,
        reminderTimes: (json['reminderTimes'] as List<dynamic>?)
                ?.map((entry) {
                  final parts = entry.toString().split(':');
                  return TimeOfDay(
                    hour: int.parse(parts[0]),
                    minute: int.parse(parts[1]),
                  );
                })
                .toList() ??
            [TimeOfDay(hour: json['timeHour'], minute: json['timeMinute'])],
      );

  // Serializa o modelo para string para armazenamento local.
  String toJsonString() => jsonEncode(toJson());

  // Faz a leitura reversa da string persistida.
  factory NotifiqModel.fromJsonString(String s) =>
      NotifiqModel.fromJson(jsonDecode(s));

  // Gera um texto legível para apresentar a programação da notificação.
  String get scheduleLabel {
    if (scheduledDate != null) {
      final date = scheduledDate!;
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
    return 'Sem data';
  }

  // Formata a hora no padrão HH:MM para exibição visual.
  String get timeLabel {
    if (reminderTimes.isEmpty) {
      return '00:00';
    }

    final first = reminderTimes.first;
    final h = first.hour.toString().padLeft(2, '0');
    final m = first.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get reminderSummary {
    if (reminderTimes.isEmpty) return 'Nenhum horário';
    if (reminderTimes.length == 1) {
      return timeLabel;
    }
    return '${reminderTimes.length} horários';
  }
}
