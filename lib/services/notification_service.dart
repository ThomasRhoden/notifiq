import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/notification_model.dart';

/// Serviço singleton que centraliza persistência e agendamento de notificações.
/// 
/// Responsabilidades:
/// - Inicializar o plugin de notificações locais (Android e iOS)
/// - Carregar e salvar notificações em armazenamento local (SharedPreferences)
/// - Agendar notificações para datas e horários específicos
/// - Cancelar agendamentos já existentes
/// - Construir detalhes visuais e sonoros das notificações
class NotificationService {
  // ────────────────────────────────────────────────────────
  // Singleton Pattern
  // ────────────────────────────────────────────────────────
  
  /// Instância única do serviço (padrão Singleton).
  static final NotificationService _instance = NotificationService._();
  
  /// Factory que retorna sempre a mesma instância.
  factory NotificationService() => _instance;
  
  /// Construtor privado para impedir múltiplas instâncias.
  NotificationService._();

  // ────────────────────────────────────────────────────────
  // Propriedades
  // ────────────────────────────────────────────────────────
  
  /// Plugin do Flutter que gerencia as notificações locais.
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Chave padrão usada para persistir notificações em SharedPreferences.
  static const String _prefsKey = 'notifiq_notifications';

  // ────────────────────────────────────────────────────────
  // Inicialização
  // ────────────────────────────────────────────────────────

  /// Inicializa o serviço de notificações para ambos Android e iOS.
  /// 
  /// Deve ser chamado uma única vez na função main() do aplicativo.
  /// Configura:
  /// - Timezone para agendamentos com horário local
  /// - Ícone e detalhes do canal Android
  /// - Permissões de alerta, badge e som no iOS
  /// - Permissões de notificação no Android 13+
  Future<void> init() async {
    // Inicializa o suporte a fusos horários para agendamentos precisos
    tz.initializeTimeZones();

    // Configuração específica do Android: ícone padrão e identificador único
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Configuração específica do iOS: solicita permissões necessárias
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    // Combina configurações de ambas as plataformas
    const settings = InitializationSettings(android: android, iOS: ios);

    // Aplica as configurações ao plugin
    await _plugin.initialize(settings);

    // Solicita explicitamente permissão de notificações no Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // ════════════════════════════════════════════════════════
  // PERSISTÊNCIA - Salvar e carregar notificações
  // ════════════════════════════════════════════════════════

  /// Carrega todas as notificações armazenadas localmente.
  /// 
  /// Retorna uma lista ordenada por data e hora de agendamento.
  /// Se nenhuma notificação for encontrada, retorna uma lista vazia.
  Future<List<NotifiqModel>> loadAll() async {
    // Acessa o armazenamento local do sistema
    final prefs = await SharedPreferences.getInstance();
    
    // Recupera a lista de strings JSON, ou lista vazia se não houver
    final raw = prefs.getStringList(_prefsKey) ?? [];

    // Converte cada string JSON em um objeto NotifiqModel
    final parsed = raw.map((s) => NotifiqModel.fromJsonString(s)).toList();

    // Ordena por data agendada, depois por hora, para manter consistência na interface
    parsed.sort((a, b) {
      // Compara datas (usa 1970 como padrão para notificações sem data)
      final dateCompare = (a.scheduledDate ?? DateTime(1970)).compareTo(
        b.scheduledDate ?? DateTime(1970),
      );
      
      // Se datas são diferentes, retorna a diferença de data
      if (dateCompare != 0) return dateCompare;
      
      // Se datas são iguais, compara horários
      return (a.time.hour * 60 + a.time.minute) -
          (b.time.hour * 60 + b.time.minute);
    });

    return parsed;
  }

  /// Persiste uma lista completa de notificações em armazenamento local.
  /// 
  /// Substitui completamente os dados anteriores com os da lista fornecida.
  /// Cada notificação é convertida para string JSON antes de ser salva.
  Future<void> saveAll(List<NotifiqModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Converte cada modelo em sua representação JSON e salva
    await prefs.setStringList(
      _prefsKey,
      list.map((n) => n.toJsonString()).toList(),
    );
  }

  /// Insere ou atualiza uma notificação (upsert).
  /// 
  /// Se a notificação existe (mesmo ID), atualiza. Caso contrário, adiciona.
  /// Depois de persistir, reagenda a notificação se estiver ativa,
  /// ou cancela seu agendamento se estiver inativa.
  Future<void> upsert(NotifiqModel notif, List<NotifiqModel> all) async {
    // Encontra o índice da notificação com o mesmo ID
    final idx = all.indexWhere((n) => n.id == notif.id);
    
    if (idx >= 0) {
      // Se existe, substitui na lista
      all[idx] = notif;
    } else {
      // Se não existe, adiciona como nova
      all.add(notif);
    }

    // Persiste a lista atualizada em armazenamento local
    await saveAll(all);

    // Reagenda com base no status ativo/inativo
    if (notif.active) {
      await schedule(notif);
    } else {
      await cancel(notif.id, notif.reminderTimes);
    }
  }

  /// Deleta uma notificação e cancela seus agendamentos.
  /// 
  /// Remove a notificação da lista, persiste e cancela todos os alarmes associados.
  Future<void> delete(String id, List<NotifiqModel> all) async {
    // Remove todas as entradas com esse ID da lista
    all.removeWhere((n) => n.id == id);
    
    // Persiste a lista atualizada
    await saveAll(all);
    
    // Cancela qualquer agendamento remanescente
    await cancel(id);
  }

  // ════════════════════════════════════════════════════════
  // AGENDAMENTO - Agendar e cancelar notificações
  // ════════════════════════════════════════════════════════

  /// Agenda uma notificação para cada horário definido na data selecionada.
  /// 
  /// Cria agendamentos individuais para cada horário em reminderTimes,
  /// todos na mesma data. Ignora horários que já passaram.
  /// Se a notificação estiver inativa ou sem data, não faz nada.
  Future<void> schedule(NotifiqModel notif) async {
    // Remove qualquer agendamento anterior para evitar duplicatas
    await cancel(notif.id, notif.reminderTimes);

    // Ignora agendamentos inválidos: notificação desativada ou sem data
    if (!notif.active || notif.scheduledDate == null) return;

    // Itera sobre cada horário configurado na lista de lembretes
    for (int index = 0; index < notif.reminderTimes.length; index++) {
      final time = notif.reminderTimes[index];
      
      // Constrói a data-hora final: data agendada + horário específico
      final targetDate = DateTime(
        notif.scheduledDate!.year,
        notif.scheduledDate!.month,
        notif.scheduledDate!.day,
        time.hour,
        time.minute,
      );

      // Converte para TZDateTime considerando o fuso horário local
      final scheduledDate = tz.TZDateTime.from(targetDate, tz.local);

      // Evita agendar algo que já passou
      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) continue;

      // Agenda a notificação com ID único e detalhes específicos
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

  /// Cancela todos os agendamentos associados a uma notificação.
  /// 
  /// Se reminderTimes for fornecido, cancela cada horário individualmente.
  /// Caso contrário, cancela um único agendamento com o ID padrão.
  Future<void> cancel(String id, [List<TimeOfDay>? reminderTimes]) async {
    if (reminderTimes == null || reminderTimes.isEmpty) {
      // Cancela usando o ID simples (compatibilidade com agendamentos únicos)
      await _plugin.cancel(_idFromString(id));
      return;
    }

    // Cancela cada horário da lista individualmente
    for (int index = 0; index < reminderTimes.length; index++) {
      await _plugin.cancel(_idFromString('${id}_$index'));
    }
  }

  // ════════════════════════════════════════════════════════
  // DETALHES E CONFIGURAÇÃO
  // ════════════════════════════════════════════════════════

  /// Constrói os detalhes visuais e sonoros da notificação para ambas plataformas.
  /// 
  /// Customiza cores, LED, texto expandido para Android e sons/alertas para iOS.
  NotificationDetails _buildDetails(NotifiqModel notif) {
    // Configuração específica para Android
    final android = AndroidNotificationDetails(
      'notifiq_channel',
      'Notifiq',
      channelDescription: 'Suas notificações personalizadas',
      importance: Importance.high,
      priority: Priority.high,
      
      // Cores e LEDs personalizados com a cor de destaque da notificação
      color: notif.accentColor,
      ledColor: notif.accentColor,
      ledOnMs: 1000,
      ledOffMs: 500,
      enableLights: true,
      
      // Exibe o corpo completo da mensagem em modo expandido
      styleInformation: BigTextStyleInformation(notif.body),
      
      // Som personalizado ou silencioso conforme configuração
      sound: notif.sound != 'default' && notif.sound != 'none'
          ? RawResourceAndroidNotificationSound(notif.sound)
          : null,
      playSound: notif.sound != 'none',
    );

    // Configuração específica para iOS
    final ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: notif.sound != 'none',
      sound: notif.sound != 'none' && notif.sound != 'default'
          ? '${notif.sound}.aiff'
          : null,
    );

    // Retorna uma combinação de ambas as configurações
    return NotificationDetails(android: android, iOS: ios);
  }

  // ────────────────────────────────────────────────────────
  // Utilitários privados (legado, mantido para compatibilidade)
  // ────────────────────────────────────────────────────────

  /// Calcula o próximo agendamento para um dia da semana específico.
  /// (Legado: mantido para compatibilidade futura)
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

  /// Converte uma string em um inteiro determinístico para uso como ID de notificação.
  /// 
  /// Usa hash simples para gerar IDs que permitem identificar notificações
  /// de forma consistente mesmo após reinicializações.
  int _idFromString(String s) {
    // Inicializa com 0
    int hash = 0;
    
    // Itera sobre cada caractere e aplica hash bitwise
    for (final r in s.runes) {
      hash = (hash * 31 + r) & 0x7FFFFFFF;
    }
    
    return hash;
  }
}
