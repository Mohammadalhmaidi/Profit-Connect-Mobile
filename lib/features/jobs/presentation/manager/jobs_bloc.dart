import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
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
      type: event.type,
      workPlace: event.workPlace,
    );

    result.fold(
      (failure) {
        debugPrint('❌ JobsBloc Error: ${failure.message}');
        emit(JobsError(failure.message));
      },
      (jobs) {
        // Debug binding: Print received entities count and first item if available
        debugPrint('✅ JobsBloc Success: Received ${jobs.length} jobs');
        if (jobs.isNotEmpty) {
          debugPrint('First Job Sample: ${jobs.first.title} at ${jobs.first.company}');
        }
        emit(JobsLoaded(jobs));
      },
    );
  }
}
