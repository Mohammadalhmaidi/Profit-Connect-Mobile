part of 'jobs_bloc.dart';

abstract class JobsState extends Equatable {
  const JobsState();

  @override
  List<Object?> get props => [];
}

class JobsInitial extends JobsState {}

class JobsLoading extends JobsState {}

class JobsLoaded extends JobsState {
  final List<JobEntity> jobs;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const JobsLoaded(
    this.jobs, {
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  JobsLoaded copyWith({
    List<JobEntity>? jobs,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) => JobsLoaded(
    jobs ?? this.jobs,
    hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );

  @override
  List<Object?> get props => [jobs, hasReachedMax, isLoadingMore];
}

class JobsError extends JobsState {
  final String message;

  const JobsError(this.message);

  @override
  List<Object?> get props => [message];
}
