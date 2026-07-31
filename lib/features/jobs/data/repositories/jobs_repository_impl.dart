import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/api_call_helper.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/repositories/jobs_repository.dart';
import '../datasources/jobs_remote_data_source.dart';

class JobsRepositoryImpl implements JobsRepository {
  final JobsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  JobsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<JobEntity>>> getJobs({
    String? search,
    String? type,
    String? workPlace,
    String? workLevel,
  }) async {
    return safeApiCallWithNetworkCheck(
      networkInfo: networkInfo,
      call: () => remoteDataSource.getJobs(
        search: search,
        type: type,
        workPlace: workPlace,
        workLevel: workLevel,
      ),
    );
  }
}
