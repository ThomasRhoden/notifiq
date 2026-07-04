import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/notifiq_preview.dart';

class EditorScreen extends StatefulWidget {
  final NotifiqModel? existing;
  final List<NotifiqModel> allNotifications;

  const EditorScreen({
    super.key,
    this.existing,
    required this.allNotifications,
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final _service = NotificationService();
  late NotifiqModel _notif;
  bool _saving = false;

  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();

  // Controla quais blocos do formulário ficam abertos na interface.
  final Map<String, bool> _expanded = {
    'text': true,
    'color': false,
    'icon': false,
    'sound': false,
    'schedule': false,
  };

  @override
  void initState() {
    super.initState();
    // Quando a tela é usada para editar, reusa os dados já existentes.
    // Quando é nova, cria um modelo inicial com valores padrão para guiar o usuário.
    if (widget.existing != null) {
      _notif = widget.existing!.copyWith();
    } else {
      _notif = NotifiqModel(
        id: const Uuid().v4(),
        title: '',
        body: '',
        accentColor: AppTheme.accentColors[0],
        icon: AppTheme.iconOptions[0],
        sound: 'crystal',
        days: [false, true, true, true, true, true, false],
        time: const TimeOfDay(hour: 8, minute: 0),
        scheduledDate: DateTime.now(),
      );
    }
    _titleCtrl.text = _notif.title;
    _bodyCtrl.text = _notif.body;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  void _update(NotifiqModel updated) => setState(() => _notif = updated);

  // Salva a notificação após validar se o título foi preenchido.
  Future<void> _save() async {
    // Bloqueia o salvamento caso o usuário não tenha informado um título útil.
    if (_notif.title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione um título à notificação')),
      );
      return;
    }

    // Garante que a notificação tenha uma data para ser programada corretamente.
    if (_notif.scheduledDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma data para o agendamento')),
      );
      return;
    }

    // Evita salvar uma notificação em uma data já passada.
    final now = DateTime.now();
    final selectedDate = DateTime(
      _notif.scheduledDate!.year,
      _notif.scheduledDate!.month,
      _notif.scheduledDate!.day,
      _notif.time.hour,
      _notif.time.minute,
    );

    if (selectedDate.isBefore(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma data futura para o agendamento')),
      );
      return;
    }

    // Exibe um estado de carregamento curto enquanto a persistência é aplicada.
    setState(() => _saving = true);
    await _service.upsert(_notif, widget.allNotifications);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notificação salva com sucesso')),
      );
      Navigator.pop(context, true);
    }
  }

  // Abre o seletor de data para definir quando a notificação deve acontecer.
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _notif.scheduledDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked != null) {
      _update(_notif.copyWith(scheduledDate: picked));
    }
  }

  // Abre o seletor de hora para ajustar um horário específico da lista.
  Future<void> _pickTime([int? index]) async {
    final targetIndex = index ?? 0;
    final t = await showTimePicker(
      context: context,
      initialTime: _notif.reminderTimes.isNotEmpty
          ? _notif.reminderTimes[targetIndex.clamp(0, _notif.reminderTimes.length - 1)]
          : _notif.time,
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF5DCAA5),
            surface: Color(0xFF1A1A1A),
          ),
        ),
        child: child!,
      ),
    );

    if (t != null) {
      final updatedTimes = List<TimeOfDay>.from(_notif.reminderTimes);
      if (updatedTimes.isEmpty) {
        updatedTimes.add(t);
      } else {
        updatedTimes[targetIndex.clamp(0, updatedTimes.length - 1)] = t;
      }
      _update(_notif.copyWith(
        time: t,
        reminderTimes: updatedTimes,
      ));
    }
  }

  // Adiciona um novo horário ao mesmo dia selecionado.
  void _addReminderTime() {
    final newTime = _notif.reminderTimes.isEmpty
        ? _notif.time
        : _notif.reminderTimes.last;
    final updatedTimes = List<TimeOfDay>.from(_notif.reminderTimes)..add(newTime);
    _update(_notif.copyWith(reminderTimes: updatedTimes));
  }

  // Remove um horário adicional, preservando o primeiro para não deixar o fluxo vazio.
  void _removeReminderTime(int index) {
    if (_notif.reminderTimes.length <= 1) return;
    final updatedTimes = List<TimeOfDay>.from(_notif.reminderTimes)..removeAt(index);
    _update(_notif.copyWith(reminderTimes: updatedTimes));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Text(
          widget.existing == null ? 'Nova notificação' : 'Editar',
        ),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF5DCAA5),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text(
                'Salvar',
                style: TextStyle(
                  color: Color(0xFF5DCAA5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // ──── PRÉVIA ────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PRÉVIA',
                  style: TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                NotifiqPreview(notif: _notif),
              ],
            ),
          ),

          const Divider(height: 1, color: AppTheme.border),

          // ──── MÓDULOS ────
          _Module(
            icon: Icons.edit_outlined,
            title: 'Texto',
            expanded: _expanded['text']!,
            onToggle: () =>
                setState(() => _expanded['text'] = !_expanded['text']!),
            child: _TextModule(
              titleCtrl: _titleCtrl,
              bodyCtrl: _bodyCtrl,
              onChanged: () => _update(_notif.copyWith(
                title: _titleCtrl.text,
                body: _bodyCtrl.text,
              )),
            ),
          ),

          _Module(
            icon: Icons.palette_outlined,
            title: 'Cor & Tema',
            expanded: _expanded['color']!,
            onToggle: () =>
                setState(() => _expanded['color'] = !_expanded['color']!),
            child: _ColorModule(
              notif: _notif,
              onColorChanged: (c) => _update(_notif.copyWith(accentColor: c)),
              onThemeChanged: (dark) => _update(_notif.copyWith(darkTheme: dark)),
            ),
          ),

          _Module(
            icon: Icons.emoji_emotions_outlined,
            title: 'Ícone',
            expanded: _expanded['icon']!,
            onToggle: () =>
                setState(() => _expanded['icon'] = !_expanded['icon']!),
            child: _IconModule(
              selected: _notif.icon,
              onSelected: (ic) => _update(_notif.copyWith(icon: ic)),
            ),
          ),

          _Module(
            icon: Icons.music_note_outlined,
            title: 'Som',
            expanded: _expanded['sound']!,
            onToggle: () =>
                setState(() => _expanded['sound'] = !_expanded['sound']!),
            child: _SoundModule(
              selected: _notif.sound,
              onSelected: (s) => _update(_notif.copyWith(sound: s)),
            ),
          ),

          _Module(
            icon: Icons.calendar_today_outlined,
            title: 'Data e horário',
            expanded: _expanded['schedule']!,
            onToggle: () =>
                setState(() => _expanded['schedule'] = !_expanded['schedule']!),
            child: _ScheduleModule(
              notif: _notif,
              onDateChanged: _pickDate,
              onTimeChanged: _pickTime,
              onAddReminderTime: _addReminderTime,
              onRemoveReminderTime: _removeReminderTime,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// MÓDULO CONTAINER
// ──────────────────────────────────────────────────────────
class _Module extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  const _Module({
    required this.icon,
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.textSecondary, size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down,
                      color: AppTheme.textTertiary, size: 20),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: expanded
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: child,
                )
              : const SizedBox.shrink(),
        ),
        const Divider(height: 1, color: AppTheme.border),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────
// MÓDULO: TEXTO
// ──────────────────────────────────────────────────────────
class _TextModule extends StatelessWidget {
  final TextEditingController titleCtrl;
  final TextEditingController bodyCtrl;
  final VoidCallback onChanged;

  const _TextModule({
    required this.titleCtrl,
    required this.bodyCtrl,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final inputDecor = InputDecoration(
      filled: true,
      fillColor: AppTheme.surfaceHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.border, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.border, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF5DCAA5), width: 1),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      labelStyle:
          const TextStyle(color: AppTheme.textTertiary, fontSize: 13),
    );

    return Column(
      children: [
        TextField(
          controller: titleCtrl,
          onChanged: (_) => onChanged(),
          style:
              const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          decoration: inputDecor.copyWith(labelText: 'Título'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: bodyCtrl,
          onChanged: (_) => onChanged(),
          maxLines: 3,
          style:
              const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          decoration: inputDecor.copyWith(labelText: 'Mensagem (opcional)'),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────
// MÓDULO: COR & TEMA
// ──────────────────────────────────────────────────────────
class _ColorModule extends StatelessWidget {
  final NotifiqModel notif;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<bool> onThemeChanged;

  const _ColorModule({
    required this.notif,
    required this.onColorChanged,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cor de destaque',
            style: TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 11,
                letterSpacing: 0.4)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: AppTheme.accentColors.map((c) {
            final isSelected = notif.accentColor == c;
            return GestureDetector(
              onTap: () => onColorChanged(c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 2.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                              color: c.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 1)
                        ]
                      : [],
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        const Text('Fundo da notificação',
            style: TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 11,
                letterSpacing: 0.4)),
        const SizedBox(height: 10),
        Row(
          children: [
            _ThemeChip(
              label: '🌑 Escuro',
              selected: notif.darkTheme,
              onTap: () => onThemeChanged(true),
            ),
            const SizedBox(width: 10),
            _ThemeChip(
              label: '☀️ Claro',
              selected: !notif.darkTheme,
              onTap: () => onThemeChanged(false),
            ),
          ],
        ),
      ],
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.surfaceHigh : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.textSecondary : AppTheme.border,
            width: selected ? 1 : 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                selected ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontSize: 13,
            fontWeight:
                selected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// MÓDULO: ÍCONE
// ──────────────────────────────────────────────────────────
class _IconModule extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _IconModule({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: AppTheme.iconOptions.length,
      itemBuilder: (_, i) {
        final ic = AppTheme.iconOptions[i];
        final isSelected = ic == selected;
        return GestureDetector(
          onTap: () => onSelected(ic),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color:
                  isSelected ? AppTheme.surfaceHigh : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppTheme.textSecondary
                    : AppTheme.border,
                width: 0.5,
              ),
            ),
            child: Center(
              child: Text(ic, style: const TextStyle(fontSize: 22)),
            ),
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────
// MÓDULO: SOM
// ──────────────────────────────────────────────────────────
class _SoundModule extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _SoundModule({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: AppTheme.soundOptions.map((s) {
        final isSelected = s['file'] == selected;
        return InkWell(
          onTap: () => onSelected(s['file']!),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFF5DCAA5)
                        : AppTheme.border,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  s['name']!,
                  style: TextStyle(
                    color: isSelected
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.w500
                        : FontWeight.w400,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.play_circle_outline,
                  color: AppTheme.textTertiary,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ──────────────────────────────────────────────────────────
// MÓDULO: DATA E HORÁRIO
// ──────────────────────────────────────────────────────────
class _ScheduleModule extends StatelessWidget {
  final NotifiqModel notif;
  final VoidCallback onDateChanged;
  final Function(int)? onTimeChanged;
  final VoidCallback onAddReminderTime;
  final Function(int) onRemoveReminderTime;

  const _ScheduleModule({
    required this.notif,
    required this.onDateChanged,
    required this.onTimeChanged,
    required this.onAddReminderTime,
    required this.onRemoveReminderTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Data',
            style: TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 11,
                letterSpacing: 0.4)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onDateChanged,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border, width: 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  notif.scheduledDate != null
                      ? '${notif.scheduledDate!.day.toString().padLeft(2, '0')}/${notif.scheduledDate!.month.toString().padLeft(2, '0')}/${notif.scheduledDate!.year}'
                      : 'Selecionar data',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(Icons.calendar_today_outlined,
                    color: AppTheme.textTertiary, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text('Horários',
            style: TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 11,
                letterSpacing: 0.4)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border, width: 0.5),
          ),
          child: Column(
            children: [
              ...List.generate(notif.reminderTimes.length, (index) {
                final time = notif.reminderTimes[index];
                final timeText = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => onTimeChanged?.call(index),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.bg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.border, width: 0.5),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, color: AppTheme.textSecondary, size: 18),
                                const SizedBox(width: 10),
                                Text(
                                  timeText,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (notif.reminderTimes.length > 1)
                        IconButton(
                          onPressed: () => onRemoveReminderTime(index),
                          icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFE24B4A)),
                        ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onAddReminderTime,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Adicionar horário'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5DCAA5),
                    side: const BorderSide(color: Color(0xFF5DCAA5), width: 0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
