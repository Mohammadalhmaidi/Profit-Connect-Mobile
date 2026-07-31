import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/usecases/get_jobs_usecase.dart';

part 'jobs_event.dart';
part 'jobs_state.dart';

class JobsBloc extends Bloc<JobsEvent, JobsState> {
  final GetJobsUseCase getJobsUseCase;

  JobsBloc({required this.getJobsUseCase}) : super(JobsInitial()) {
    on<GetJobsEvent>(_onGetJobs);
  }

  Future<void> _onGetJobs(GetJobsEvent event, Emitter<JobsState> emit) async {
    emit(JobsLoading());
    
    final result = await getJobsUseCase(
      search: event.search,
      type: event.type,
      workPlace: event.workPlace,
      workLevel: event.workLevel,
    );

    result.fold(
      (failure) {
        AppLogger.e('JobsBloc Error: ${failure.message}');
        emit(JobsError(failure.message));
      },
      (jobs) {
        AppLogger.s('JobsBloc Success: Received ${jobs.length} jobs');
        emit(JobsLoaded(jobs));
      },
    );
  }
}
