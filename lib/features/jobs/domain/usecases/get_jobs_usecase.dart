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
    int page = 1,
    int limit = 20,
  }) async => repository.getJobs(
    search: search,
    type: type,
    workPlace: workPlace,
    workLevel: workLevel,
    page: page,
    limit: limit,
  );
}
