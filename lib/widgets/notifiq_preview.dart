import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../theme/app_theme.dart';

class NotifiqPreview extends StatelessWidget {
  final NotifiqModel notif;
  final bool compact;

  const NotifiqPreview({super.key, required this.notif, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final bg = notif.darkTheme
        ? const Color(0xFF1C1C1E)
        : const Color(0xFFF2F2F7);
    final titleColor = notif.darkTheme
        ? const Color(0xFFF1EFE8)
        : const Color(0xFF1C1C1E);
    final bodyColor = notif.darkTheme
        ? const Color(0xFF8E8E93)
        : const Color(0xFF6C6C70);
    final appNameColor = notif.accentColor;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(compact ? 14 : 18),
        border: Border(
          left: BorderSide(color: notif.accentColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: notif.accentColor.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 16,
        vertical: compact ? 10 : 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: compact ? 16 : 20,
                height: compact ? 16 : 20,
                decoration: BoxDecoration(
                  color: notif.accentColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Text(
                    notif.icon,
                    style: TextStyle(fontSize: compact ? 9 : 11),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Notifiq',
                style: TextStyle(
                  color: appNameColor,
                  fontSize: compact ? 11 : 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                notif.timeLabel,
                style: TextStyle(
                  color: bodyColor,
                  fontSize: compact ? 10 : 11,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 6 : 8),
          Text(
            notif.title,
            style: TextStyle(
              color: titleColor,
              fontSize: compact ? 13 : 15,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          if (notif.body.isNotEmpty) ...[
            SizedBox(height: compact ? 2 : 3),
            Text(
              notif.body,
              style: TextStyle(
                color: bodyColor,
                fontSize: compact ? 11 : 13,
                height: 1.4,
              ),
              maxLines: compact ? 1 : 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
