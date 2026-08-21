part of 'jobs_bloc.dart';

abstract class JobsEvent extends Equatable {
  const JobsEvent();

  @override
  List<Object?> get props => [];
}

class GetJobsEvent extends JobsEvent {
  final String? search;
  final String? type;
  final String? workPlace;
  final String? workLevel;
  final bool loadMore;

  const GetJobsEvent({
    this.search,
    this.type,
    this.workPlace,
    this.workLevel,
    this.loadMore = false,
  });

  @override
  List<Object?> get props => [search, type, workPlace, workLevel, loadMore];
}
