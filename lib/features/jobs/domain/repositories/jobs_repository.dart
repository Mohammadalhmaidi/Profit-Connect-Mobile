import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/job_entity.dart';

abstract class JobsRepository {
  Future<Either<Failure, List<JobEntity>>> getJobs({
    String? search,
    String? type,
    String? workPlace,
    String? workLevel,
  });
}
