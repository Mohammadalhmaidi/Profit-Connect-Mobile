import '../../../../core/utils/time_formatter.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/presentation/widgets/stagger_entrance.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../api_service.dart';
import '../../domain/entities/notification_entity.dart';
import '../manager/notifications_cubit.dart';
import '../manager/notifications_state.dart';
import '../widgets/notification_tile.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String _formatTime(BuildContext context, DateTime dateTime) =>
      formatTimeAgo(context, dateTime);

  IconData _iconFor(String type) {
    switch (type) {
      case 'post_liked':
      case 'comment_liked':
        return Icons.thumb_up_outlined;
      case 'comment_added':
        return Icons.chat_bubble_outline;
      case 'post_shared':
        return Icons.share_outlined;
      case 'connection_request':
        return Icons.person_add_alt_outlined;
      case 'connection_accepted':
        return Icons.handshake_outlined;
      case 'job_application_status':
        return Icons.work_outline;
      case 'ai_detected':
        return Icons.auto_awesome_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  void _openNotification(BuildContext context, NotificationEntity n) {
    if (n.postId != null && n.postId!.isNotEmpty) {
      Navigator.pushNamed(context, AppRouter.postDetails, arguments: n.postId);
    }
  }

  @override
  void dispose() {
    // تعليم جميع الإشعارات كمقروءة عند مغادرة الصفحة
    unawaited(sl<ApiService>().markAllNotificationsRead());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.backgroundAlt,
    appBar: AppBar(
      backgroundColor: context.colors.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: context.colors.textPrimary,
          size: 20.sp,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        context.tr('nav.notifications'),
        style: TextStyle(
          color: context.colors.textPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    ),
    body: BlocProvider(
      create: (_) => sl<NotificationsCubit>()..fetch(),
      child: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NotificationsError) {
            return Center(
              child: Text(
                context.tr('error'),
                style: TextStyle(color: context.colors.textSecondary),
              ),
            );
          }
          if (state is NotificationsLoaded && state.notifications.isNotEmpty) {
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.notifications.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: context.colors.divider),
              itemBuilder: (context, index) {
                final item = state.notifications[index];
                return StaggerEntrance(
                  index: index,
                  child: InkWell(
                    onTap: () => _openNotification(context, item),
                    child: NotificationTile(
                      leading: CircleAvatar(
                        radius: 24.w,
                        backgroundColor: context.colors.chipUnselected,
                        child: Icon(
                          _iconFor(item.type),
                          size: 22.sp,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: TextSpan(
                        text: item.message,
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontSize: 14.sp,
                          height: 1.4,
                        ),
                      ),
                      time: _formatTime(context, item.createdAt),
                      isUnread: !item.read,
                    ),
                  ),
                );
              },
            );
          }
          return StaggerEntrance(
            index: 0,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64.sp,
                    color: context.colors.textHint,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    context.tr('notifications.empty_title'),
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    context.tr('notifications.empty_subtitle'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 14.sp,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}
