import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';// States
abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}
class DashboardLoading extends DashboardState {}
class DashboardLoaded extends DashboardState {}

// Cubit
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(DashboardInitial());

  void init() async {
    emit(DashboardLoading());
    // Simulate loading local data or session
    await Future.delayed(const Duration(seconds: 2));
    emit(DashboardLoaded());
  }
}