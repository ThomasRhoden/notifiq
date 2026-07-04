import 'dart:convert';
import 'package:flutter/material.dart';

/// Modelo de dados que representa uma notificação personalizada.
/// 
/// Centraliza todos os dados de uma notificação: conteúdo, visual, som, agendamento.
/// Fornece métodos para serialização (JSON), cópia com modificações parciais,
/// e formatação de exibição para interface do usuário.
class NotifiqModel {
  // ────────────────────────────────────────────────────────
  // Identificação e conteúdo
  // ────────────────────────────────────────────────────────
  
  /// Identificador único da notificação (UUID v4).
  final String id;
  
  /// Título principal da notificação exibido ao usuário.
  String title;
  
  /// Descrição ou corpo detalhado da notificação.
  String body;

  // ────────────────────────────────────────────────────────
  // Personalização visual
  // ────────────────────────────────────────────────────────
  
  /// Cor de destaque que aparece na notificação e interface.
  Color accentColor;
  
  /// Emoji ou ícone representativo da notificação.
  String icon;
  
  /// Nome do arquivo de som personalizado para o alerta.
  String sound;

  // ────────────────────────────────────────────────────────
  // Agendamento e controle
  // ────────────────────────────────────────────────────────
  
  /// Array de dias da semana (mantido para compatibilidade legada).
  /// Cada índice representa: [seg, ter, qua, qui, sex, sab, dom].
  List<bool> days;
  
  /// Horário padrão da notificação (HH:MM).
  TimeOfDay time;
  
  /// Indica se a notificação está ativa para agendamento.
  bool active;
  
  /// Preferência de tema escuro para exibição da notificação.
  bool darkTheme;

  // ────────────────────────────────────────────────────────
  // Timestamps e datas
  // ────────────────────────────────────────────────────────
  
  /// Data e hora de criação da notificação.
  DateTime createdAt;
  
  /// Data específica quando a notificação deve ser disparada.
  /// Se null, a notificação não está agendada para uma data específica.
  DateTime? scheduledDate;
  
  /// Lista de múltiplos horários para disparar no mesmo dia.
  /// Permite criar lembretes em cascata em uma única data.
  List<TimeOfDay> reminderTimes;

  // ────────────────────────────────────────────────────────
  // Construtor
  // ────────────────────────────────────────────────────────
  
  /// Cria uma nova instância de NotifiqModel com os parâmetros fornecidos.
  /// 
  /// Parâmetros requeridos: id, title, body, accentColor, icon, sound,
  /// days, time.
  /// 
  /// Parâmetros opcionais com valores padrão: active (true), darkTheme (true),
  /// createdAt (agora), scheduledDate (null), reminderTimes (lista com 'time').
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

  // ────────────────────────────────────────────────────────
  // Métodos de cópia e transformação
  // ────────────────────────────────────────────────────────

  /// Cria uma cópia do modelo com campos opcionalmente substituídos.
  /// 
  /// Mantém o ID original e substitui apenas os campos fornecidos.
  /// Útil para atualizações parciais sem criar um novo objeto do zero.
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

  // ────────────────────────────────────────────────────────
  // Serialização para persistência
  // ────────────────────────────────────────────────────────

  /// Converte o modelo para um mapa que pode ser serializado em JSON.
  /// 
  /// Normaliza tipos complexos (Color, TimeOfDay) para tipos primitivos
  /// compatíveis com JSON (int, String, List).
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

  /// Reconstrói uma instância de NotifiqModel a partir de um mapa JSON.
  /// 
  /// Inverte a transformação de [toJson()], reconstruindo tipos complexos
  /// como Color e TimeOfDay a partir de suas representações primitivas.
  factory NotifiqModel.fromJson(Map<String, dynamic> json) => NotifiqModel(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        accentColor: Color(json['accentColor'] as int),
        icon: json['icon'] as String,
        sound: json['sound'] as String,
        days: List<bool>.from(json['days'] as List<dynamic>),
        time: TimeOfDay(
          hour: json['timeHour'] as int,
          minute: json['timeMinute'] as int,
        ),
        active: json['active'] as bool,
        darkTheme: json['darkTheme'] as bool? ?? true,
        createdAt: DateTime.parse(json['createdAt'] as String),
        scheduledDate: json['scheduledDate'] != null
            ? DateTime.parse(json['scheduledDate'] as String)
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
            [TimeOfDay(
              hour: json['timeHour'] as int,
              minute: json['timeMinute'] as int,
            )],
      );

  /// Converte o modelo para uma string JSON compactada.
  /// 
  /// Útil para armazenar em SharedPreferences ou base de dados local.
  String toJsonString() => jsonEncode(toJson());

  /// Reconstrói o modelo a partir de uma string JSON compactada.
  /// 
  /// Inverte a operação de [toJsonString()].
  factory NotifiqModel.fromJsonString(String s) =>
      NotifiqModel.fromJson(jsonDecode(s) as Map<String, dynamic>);

  // ────────────────────────────────────────────────────────
  // Getters para formatação e exibição
  // ────────────────────────────────────────────────────────

  /// Gera uma string legível representando a data agendada.
  /// 
  /// Formato: DD/MM/YYYY
  /// Retorna "Sem data" se nenhuma data foi definida.
  String get scheduleLabel {
    if (scheduledDate != null) {
      final date = scheduledDate!;
      return '${date.day.toString().padLeft(2, '0')}/'
             '${date.month.toString().padLeft(2, '0')}/'
             '${date.year}';
    }
    return 'Sem data';
  }

  /// Formata o primeiro horário em padrão HH:MM.
  /// 
  /// Usado para exibição rápida do horário da notificação.
  /// Retorna "00:00" se nenhum horário foi definido.
  String get timeLabel {
    if (reminderTimes.isEmpty) {
      return '00:00';
    }

    final first = reminderTimes.first;
    final h = first.hour.toString().padLeft(2, '0');
    final m = first.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Gera um resumo textual dos horários configurados.
  /// 
  /// - "00:00" se apenas um horário
  /// - "N horários" se múltiplos horários
  /// - "Nenhum horário" se lista vazia
  String get reminderSummary {
    if (reminderTimes.isEmpty) return 'Nenhum horário';
    if (reminderTimes.length == 1) {
      return timeLabel;
    }
    return '${reminderTimes.length} horários';
  }
}
