import 'package:flutter/material.dart';

/// Centraliza todas as cores, constantes e definições de tema do aplicativo.
///
/// Define um único ponto de verdade para a paleta de cores, tipografia,
/// ícones e sons disponíveis no aplicativo. Facilita manutenção e
/// alterações globais de estilo visual.
class AppTheme {
  // ════════════════════════════════════════════════════════
  // PALETA DE CORES - Modo escuro
  // ════════════════════════════════════════════════════════

  /// Cor de fundo principal do aplicativo (muito escuro).
  static const Color bg = Color(0xFF0E0E0E);

  /// Cor de superfícies elevadas (cards, modais).
  static const Color surface = Color(0xFF1A1A1A);

  /// Cor de superfícies ainda mais elevadas para hierarquia visual.
  static const Color surfaceHigh = Color(0xFF242424);

  /// Cor de bordas e divisores.
  static const Color border = Color(0xFF2E2E2E);

  /// Texto principal - máxima legibilidade.
  static const Color textPrimary = Color(0xFFF1EFE8);

  /// Texto secundário - para informações menos importantes.
  static const Color textSecondary = Color(0xFF888780);

  /// Texto terciário - para labels e hints.
  static const Color textTertiary = Color(0xFF4A4A48);

  // ════════════════════════════════════════════════════════
  // CORES DE DESTAQUE - Paleta de acentos personalizáveis
  // ════════════════════════════════════════════════════════

  /// Lista de cores de destaque disponíveis para customização de notificações.
  /// Cada cor representa uma opção visual distinta que o usuário pode escolher.
  static const List<Color> accentColors = [
    Color(0xFF5DCAA5), // Teal vibrante - natural e calmo
    Color(0xFF7F77DD), // Roxo - criativo e sofisticado
    Color(0xFF378ADD), // Azul - confiável e profissional
    Color(0xFFD4537E), // Rosa - quente e amigável
    Color(0xFFEF9F27), // Âmbar - energético e atencioso
    Color(0xFFE24B4A), // Vermelho - urgente e importante
    Color(0xFFB4B2A9), // Cinza - neutro e elegante
    Color(0xFF63C9E0), // Ciano - refrescante e moderno
  ];

  /// Nomes legíveis para cada cor de destaque.
  /// Usados na interface para apresentar opções ao usuário.
  static const List<String> accentNames = [
    'Teal',
    'Roxo',
    'Azul',
    'Rosa',
    'Âmbar',
    'Vermelho',
    'Cinza',
    'Ciano',
  ];

  // ════════════════════════════════════════════════════════
  // ÍCONES DISPONÍVEIS
  // ════════════════════════════════════════════════════════

  /// Lista de emojis disponíveis como ícones para notificações.
  /// Oferece variedade visual com representações simples e universais.
  static const List<String> iconOptions = [
    '💊', // Medicamento
    '💧', // Água - hidratação
    '💪', // Força - exercício
    '❤️', // Coração - saúde
    '⭐', // Estrela - importante
    '🔔', // Sino - alerta
    '📅', // Calendário - agendamento
    '💡', // Lâmpada - lembrança
    '☀️', // Sol - dia
    '🌙', // Lua - noite
    '🧘', // Meditação - bem-estar
    '🏃', // Corrida - atividade
    '📖', // Livro - estudo
    '✅', // Checkmark - conclusão
    '🎯', // Alvo - meta
    '🙏', // Oração - gratidão
  ];

  // ════════════════════════════════════════════════════════
  // OPÇÕES DE SOM
  // ════════════════════════════════════════════════════════

  /// Lista de sons disponíveis com seus nomes e identificadores de arquivo.
  /// Cada som oferece uma experiência auditiva diferente.
  static const List<Map<String, String>> soundOptions = [
    {'name': 'Cristal', 'file': 'crystal'},
    {'name': 'Sino suave', 'file': 'soft_bell'},
    {'name': 'Pulso', 'file': 'pulse'},
    {'name': 'Eco', 'file': 'echo'},
    {'name': 'Zen', 'file': 'zen'},
    {'name': 'Padrão', 'file': 'default'},
    {'name': 'Nenhum', 'file': 'none'},
  ];

  // ════════════════════════════════════════════════════════
  // CONSTRUÇÃO DO TEMA
  // ════════════════════════════════════════════════════════

  /// Constrói o tema completo do Material Design com as cores definidas.
  ///
  /// Retorna um [ThemeData] com todas as customizações de cores,
  /// tipografia e estilos de componentes para manter consistência
  /// visual em toda a aplicação.
  static ThemeData get theme => ThemeData(
        // Modo escuro para toda a aplicação
        brightness: Brightness.dark,

        // Cor de fundo padrão dos scaffolds
        scaffoldBackgroundColor: bg,

        // Esquema de cores complementares
        colorScheme: const ColorScheme.dark(
          surface: surface,
          primary: Color(0xFF5DCAA5), // Cor primária = Teal
        ),

        // ────────────────────────────────────────────────────────
        // AppBar - Barra superior customizada
        // ────────────────────────────────────────────────────────
        appBarTheme: const AppBarTheme(
          backgroundColor: bg,
          // Remove o efeito de "tint" da Material 3
          surfaceTintColor: Colors.transparent,
          // Sem elevação para design flat
          elevation: 0,
          // Título customizado
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.3,
          ),
          // Ícones da AppBar em cor secundária
          iconTheme: IconThemeData(color: textSecondary),
        ),

        // Cor de divisores (linhas entre elementos)
        dividerColor: border,

        // ────────────────────────────────────────────────────────
        // TextTheme - Tipografia padrão para todo o app
        // ────────────────────────────────────────────────────────
        textTheme: const TextTheme(
          // Texto grande - para corpo principal
          bodyLarge: TextStyle(
            color: textPrimary,
            fontSize: 15,
          ),
          // Texto médio - para corpo secundário
          bodyMedium: TextStyle(
            color: textSecondary,
            fontSize: 13,
          ),
          // Texto pequeno - para labels e hints
          labelSmall: TextStyle(
            color: textTertiary,
            fontSize: 11,
          ),
        ),
      );
}
