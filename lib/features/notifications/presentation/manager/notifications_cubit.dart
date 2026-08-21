import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../api_service.dart';
import '../../domain/entities/notification_entity.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final ApiService _api;

  NotificationsCubit(this._api) : super(NotificationsInitial());

  Future<void> fetch() async {
    emit(NotificationsLoading());
    try {
      final response = await _api.getNotifications();
      final body = response.data is Map
          ? Map<String, dynamic>.from(response.data)
          : const <String, dynamic>{};
      final list = (body['data'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((e) => NotificationEntity.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      emit(NotificationsLoaded(list));
    } catch (error) {
      emit(NotificationsError(error.toString()));
    }
  }
}
