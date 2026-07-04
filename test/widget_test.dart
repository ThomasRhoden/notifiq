import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notifiq/models/notification_model.dart';

/// Testes unitários para validar a lógica do modelo de notificação.
/// 
/// Testa:
/// - Formatação de datas
/// - Formatação de horários
/// - Resumo de múltiplos horários
void main() {
  // ════════════════════════════════════════════════════════════════
  // TESTE 1: Formatação de data
  // ════════════════════════════════════════════════════════════════
  
  /// Verifica se a data agendada é exibida no formato DD/MM/YYYY.
  test('exibe a data selecionada no rótulo de agendamento', () {
    // Cria uma notificação com data específica
    final notif = NotifiqModel(
      id: 'notif-1',
      title: 'Reunião',
      body: 'Lembrete',
      accentColor: Colors.blue,
      icon: '📅',
      sound: 'default',
      days: [false, false, false, false, false, false, false],
      time: const TimeOfDay(hour: 8, minute: 30),
      scheduledDate: DateTime(2026, 7, 3),
    );

    // Valida que a data é formatada corretamente
    expect(notif.scheduleLabel, '03/07/2026');
  });

  // ════════════════════════════════════════════════════════════════
  // TESTE 2: Formatação de data nula
  // ════════════════════════════════════════════════════════════════
  
  /// Verifica se retorna "Sem data" quando nenhuma data foi definida.
  test('retorna um texto padrão quando não há data definida', () {
    // Cria uma notificação SEM data agendada
    final notif = NotifiqModel(
      id: 'notif-2',
      title: 'Estudo',
      body: 'Lembrete',
      accentColor: Colors.green,
      icon: '📚',
      sound: 'default',
      days: [false, true, false, false, false, false, false],
      time: const TimeOfDay(hour: 9, minute: 0),
    );

    // Valida que retorna o texto padrão
    expect(notif.scheduleLabel, 'Sem data');
  });

  // ════════════════════════════════════════════════════════════════
  // TESTE 3: Resumo de múltiplos horários
  // ════════════════════════════════════════════════════════════════
  
  /// Verifica se múltiplos horários são resumidos corretamente.
  test('agrupa múltiplos horários em um resumo claro', () {
    // Cria uma notificação com dois horários no mesmo dia
    final notif = NotifiqModel(
      id: 'notif-3',
      title: 'Treino',
      body: 'Lembrete',
      accentColor: Colors.orange,
      icon: '💪',
      sound: 'default',
      days: [false, false, false, false, false, false, false],
      time: const TimeOfDay(hour: 7, minute: 0),
      scheduledDate: DateTime(2026, 7, 3),
      reminderTimes: [
        const TimeOfDay(hour: 7, minute: 0),
        const TimeOfDay(hour: 19, minute: 30),
      ],
    );

    // Valida que o resumo mostra "2 horários"
    expect(notif.reminderSummary, '2 horários');
  });
}
