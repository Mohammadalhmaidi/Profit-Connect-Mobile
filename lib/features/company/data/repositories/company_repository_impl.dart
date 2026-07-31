import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/api_call_helper.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/company_entity.dart';
import '../../domain/repositories/company_repository.dart';
import '../datasources/company_remote_data_source.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  CompanyRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, CompanyEntity>> createCompany({
    required String name,
    String? description,
    String? industry,
    String? website,
    String? location,
    String? logo,
  }) async {
    return safeApiCallWithNetworkCheck(
      networkInfo: networkInfo,
      call: () => remoteDataSource.createCompany({
        'name': name,
        'description': description,
        'industry': industry,
        'website': website,
        'location': location,
        'logo': logo,
      }),
    );
  }

  @override
  Future<Either<Failure, CompanyEntity>> getCompany(String companyId) async {
    return safeApiCallWithNetworkCheck(
      networkInfo: networkInfo,
      call: () => remoteDataSource.getCompany(companyId),
    );
  }

  @override
  Future<Either<Failure, CompanyEntity>> updateCompany({
    required String companyId,
    String? name,
    String? description,
    String? industry,
    String? website,
    String? location,
    String? logo,
  }) async {
    return safeApiCallWithNetworkCheck(
      networkInfo: networkInfo,
      call: () => remoteDataSource.updateCompany(companyId, {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (industry != null) 'industry': industry,
        if (website != null) 'website': website,
        if (location != null) 'location': location,
        if (logo != null) 'logo': logo,
      }),
    );
  }
}
