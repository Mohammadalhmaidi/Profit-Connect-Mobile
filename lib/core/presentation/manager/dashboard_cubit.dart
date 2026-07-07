import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

abstract class DashboardState extends Equatable {
  final int tabIndex;
  const DashboardState(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial() : super(0);
}

class DashboardTabUpdated extends DashboardState {
  const DashboardTabUpdated(int index) : super(index);
}

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(const DashboardInitial());

  void changeTab(int index) {
    emit(DashboardTabUpdated(index));
  }
}
