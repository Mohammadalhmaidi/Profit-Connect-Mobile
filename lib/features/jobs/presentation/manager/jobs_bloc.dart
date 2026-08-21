import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/usecases/get_jobs_usecase.dart';

part 'jobs_event.dart';
part 'jobs_state.dart';

class JobsBloc extends Bloc<JobsEvent, JobsState> {
  final GetJobsUseCase getJobsUseCase;
  static const int _limit = 20;
  int _currentPage = 1;
  bool _hasReachedMax = false;

  JobsBloc({required this.getJobsUseCase}) : super(JobsInitial()) {
    on<GetJobsEvent>(_onGetJobs);
  }

  Future<void> _onGetJobs(GetJobsEvent event, Emitter<JobsState> emit) async {
    if (event.loadMore) {
      if (_hasReachedMax) return;
      _currentPage++;
    } else {
      _currentPage = 1;
      _hasReachedMax = false;
    }

    final isLoadMore = event.loadMore && state is JobsLoaded;
    if (isLoadMore) {
      emit((state as JobsLoaded).copyWith(isLoadingMore: true));
    } else {
      emit(JobsLoading());
    }

    final result = await getJobsUseCase(
      search: event.search,
      type: event.type,
      workPlace: event.workPlace,
      workLevel: event.workLevel,
      page: _currentPage,
    );

    result.fold(
      (failure) {
        AppLogger.e('JobsBloc Error: ${failure.message}');
        if (isLoadMore) {
          _currentPage--;
          if (state is JobsLoaded) {
            emit((state as JobsLoaded).copyWith(isLoadingMore: false));
          }
        } else {
          emit(JobsError(failure.message));
        }
      },
      (jobs) {
        AppLogger.s('JobsBloc Success: Received ${jobs.length} jobs');
        if (jobs.length < _limit) _hasReachedMax = true;
        if (isLoadMore) {
          final current = state as JobsLoaded;
          emit(
            current.copyWith(
              jobs: [...current.jobs, ...jobs],
              hasReachedMax: _hasReachedMax,
              isLoadingMore: false,
            ),
          );
        } else {
          emit(
            JobsLoaded(
              jobs,
              hasReachedMax: _hasReachedMax,
            ),
          );
        }
      },
    );
  }
}
