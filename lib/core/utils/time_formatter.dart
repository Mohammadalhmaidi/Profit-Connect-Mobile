import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';

String formatTimeAgo(BuildContext context, DateTime? dt) {
  if (dt == null) return '';
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return context.tr('common.just_now');
  if (diff.inMinutes < 60) {
    return context.tr('common.min_ago', {'m': '${diff.inMinutes}'});
  }
  if (diff.inHours < 24) {
    return context.tr('common.hour_ago', {'h': '${diff.inHours}'});
  }
  if (diff.inDays < 2) return context.tr('common.yesterday');
  if (diff.inDays < 7) {
    return context.tr('common.day_ago', {'d': '${diff.inDays}'});
  }
  return DateFormat.yMMMd().format(dt);
}
