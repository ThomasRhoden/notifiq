import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class DonateScreen extends StatelessWidget {
  const DonateScreen({super.key});

  static const String _pixKey = 'SEU_PIX_AQUI';
  static const String _bitcoinAddress = 'SEU_BITCOIN_AQUI';
  static const String _projectUrl = 'https://seusite.com.br/projeto';

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copiado!'),
        backgroundColor: AppTheme.surfaceHigh,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Doe')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 16),
          const Center(
            child: Text('❤️', style: TextStyle(fontSize: 48)),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Se tocou no seu coração, doe',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'O Notifiq é gratuito para sempre.\nSe ele te ajudou, considere contribuir.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 36),

          // PIX
          _DonateCard(
            emoji: '🏦',
            title: 'PIX',
            subtitle: 'Doe diretamente pelo PIX',
            detail: _pixKey,
            actionLabel: 'Copiar chave PIX',
            color: const Color(0xFF5DCAA5),
            onAction: () => _copyToClipboard(context, _pixKey, 'Chave PIX'),
          ),
          const SizedBox(height: 14),

          // Bitcoin
          _DonateCard(
            emoji: '₿',
            title: 'Bitcoin',
            subtitle: 'Doe em Bitcoin',
            detail: _bitcoinAddress,
            actionLabel: 'Copiar endereço',
            color: const Color(0xFFEF9F27),
            onAction: () =>
                _copyToClipboard(context, _bitcoinAddress, 'Endereço Bitcoin'),
          ),
          const SizedBox(height: 14),

          // Projeto social
          _DonateCard(
            emoji: '🌱',
            title: 'Projeto Social',
            subtitle: 'Apoie uma causa que acredito',
            detail: 'Conheça o projeto que estou apoiando agora',
            actionLabel: 'Ver projeto',
            color: const Color(0xFF7F77DD),
            onAction: () {
              // url_launcher abre o link
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Abrindo projeto...')),
              );
            },
          ),

          const SizedBox(height: 40),
          const Center(
            child: Text(
              'Feito com ❤️ em Campo Bom, RS',
              style: TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonateCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String detail;
  final String actionLabel;
  final Color color;
  final VoidCallback onAction;

  const _DonateCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.actionLabel,
    required this.color,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              detail,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color.withOpacity(0.5), width: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text(actionLabel,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }
}
