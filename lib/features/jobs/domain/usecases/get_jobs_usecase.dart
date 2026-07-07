import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/job_entity.dart';
import '../repositories/jobs_repository.dart';

class GetJobsUseCase {
  final JobsRepository repository;

  GetJobsUseCase(this.repository);

  Future<Either<Failure, List<JobEntity>>> call({String? type, String? workPlace}) async {
    return await repository.getJobs(type: type, workPlace: workPlace);
  }
}
