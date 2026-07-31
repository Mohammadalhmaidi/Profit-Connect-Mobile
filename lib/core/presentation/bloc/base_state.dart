import 'package:equatable/equatable.dart';
import '../../error/failures.dart';

abstract class BaseState extends Equatable {
  final bool isLoading;
  final Failure? failure;

  const BaseState({this.isLoading = false, this.failure});

  @override
  List<Object?> get props => [isLoading, failure];
}

mixin LoadingState on BaseState {
  @override
  bool get isLoading => true;
}

mixin ErrorState on BaseState {
  @override
  Failure? get failure;
}
