import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
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
  Future<Either<Failure, List<JobEntity>>> getJobs({String? type, String? workPlace}) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteJobs = await remoteDataSource.getJobs(type: type, workPlace: workPlace);
        // Mapping JobModel to JobEntity
        final entities = remoteJobs.map((model) => JobEntity(
          id: model.id,
          title: model.title,
          company: model.company,
          location: model.location,
          salary: model.salary,
          logoUrl: model.logoUrl,
          type: model.type,
          isRemote: model.isRemote,
        )).toList();
        return Right(entities);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(ServerFailure('No Internet Connection'));
    }
  }
}
