part of 'jobs_bloc.dart';

abstract class JobsEvent extends Equatable {
  const JobsEvent();

  @override
  List<Object?> get props => [];
}

class GetJobsEvent extends JobsEvent {
  final String? type;
  final String? workPlace;

  const GetJobsEvent({this.type, this.workPlace});

  @override
  List<Object?> get props => [type, workPlace];
}
