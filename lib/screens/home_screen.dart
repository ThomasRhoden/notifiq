import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/notifiq_preview.dart';
import 'editor_screen.dart';
import 'donate_screen.dart';

/// Tela inicial da aplicação que exibe a lista de notificações.
/// Responsável por carregar, listar, ativar/desativar e deletar notificações.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Centraliza o acesso ao serviço que salva e agenda notificações.
  final _service = NotificationService();
  // Armazena a lista atual de notificações carregadas do armazenamento local.
  List<NotifiqModel> _notifications = [];
  // Indica se os dados ainda estão sendo carregados na abertura da tela.
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // Carrega as notificações assim que a tela entra em cena.
    _load();
  }

  // Busca os itens salvos e atualiza o estado da interface.
  Future<void> _load() async {
    final list = await _service.loadAll();
    setState(() {
      _notifications = list;
      _loading = false;
    });
  }

  // Alterna o estado ativo/inativo de uma notificação e reaplica o agendamento.
  Future<void> _toggleActive(NotifiqModel notif) async {
    final updated = notif.copyWith(active: !notif.active);
    await _service.upsert(updated, _notifications);
    setState(() {});
  }

  // Remove uma notificação da lista e cancela seu agendamento existente.
  Future<void> _delete(NotifiqModel notif) async {
    await _service.delete(notif.id, _notifications);
    setState(() {});
  }

  // Abre a tela de edição e recarrega os dados quando a operação retornar sucesso.
  void _openEditor([NotifiqModel? existing]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditorScreen(
          existing: existing,
          allNotifications: _notifications,
        ),
      ),
    );
    if (result == true) _load();
  }

  // Monta uma mensagem resumida para o cabeçalho da tela inicial.
  String get _summaryText {
    if (_notifications.isEmpty) {
      return 'Nenhuma notificação criada ainda';
    }

    final activeCount = _notifications.where((item) => item.active).length;
    final totalCount = _notifications.length;

    if (activeCount == totalCount) {
      return '$totalCount notificações ativas e organizadas';
    }

    return '$activeCount de $totalCount notificações ativas';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            backgroundColor: AppTheme.bg,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notifiq',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'notificações inteligentes para lembrar no momento certo',
                    style: TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border,
                    color: AppTheme.textSecondary, size: 22),
                tooltip: 'Doe',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DonateScreen()),
                ),
              ),
            ],
          ),

          if (_loading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF5DCAA5),
                  strokeWidth: 2,
                ),
              ),
            )
          else if (_notifications.isEmpty)
            SliverFillRemaining(
              child: _EmptyState(onAdd: () => _openEditor()),
            )
          else
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: Color(0xFF5DCAA5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_active_outlined,
                              color: Colors.black, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Painel de lembretes',
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _summaryText,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  child: Column(
                    children: List.generate(_notifications.length, (i) {
                      final notif = _notifications[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _NotifCard(
                          notif: notif,
                          onTap: () => _openEditor(notif),
                          onToggle: () => _toggleActive(notif),
                          onDelete: () => _delete(notif),
                        ),
                      );
                    }),
                  ),
                ),
              ]),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        backgroundColor: const Color(0xFF5DCAA5),
        foregroundColor: Colors.black,
        elevation: 0,
        icon: const Icon(Icons.add),
        label: const Text(
          'Criar lembrete',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final NotifiqModel notif;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _NotifCard({
    required this.notif,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFE24B4A).withOpacity(0.2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline,
            color: Color(0xFFE24B4A), size: 22),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: notif.active ? 1.0 : 0.5,
          child: Stack(
            children: [
              NotifiqPreview(notif: notif),
              Positioned(
                top: 8,
                right: 12,
                child: GestureDetector(
                  onTap: onToggle,
                  child: _Toggle(active: notif.active, color: notif.accentColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final bool active;
  final Color color;

  const _Toggle({required this.active, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 40,
      height: 22,
      decoration: BoxDecoration(
        color: active ? color : AppTheme.border,
        borderRadius: BorderRadius.circular(11),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        alignment: active ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.all(3),
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🔔',
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhuma notificação ainda',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Crie sua primeira notificação personalizada',
            style: TextStyle(color: AppTheme.textTertiary, fontSize: 13),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Criar agora'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF5DCAA5),
              side: const BorderSide(color: Color(0xFF5DCAA5), width: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
