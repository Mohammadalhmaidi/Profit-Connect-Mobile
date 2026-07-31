import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/job_entity.dart';
import '../repositories/jobs_repository.dart';

class GetJobsUseCase {
  final JobsRepository repository;

  GetJobsUseCase(this.repository);

  Future<Either<Failure, List<JobEntity>>> call({
    String? search,
    String? type,
    String? workPlace,
    String? workLevel,
  }) async {
    return await repository.getJobs(
      search: search,
      type: type,
      workPlace: workPlace,
      workLevel: workLevel,
    );
  }
}
