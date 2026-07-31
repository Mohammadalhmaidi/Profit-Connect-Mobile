import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/company_entity.dart';

abstract class CompanyRepository {
  Future<Either<Failure, CompanyEntity>> createCompany({
    required String name,
    String? description,
    String? industry,
    String? website,
    String? location,
    String? logo,
  });

  Future<Either<Failure, CompanyEntity>> getCompany(String companyId);

  Future<Either<Failure, CompanyEntity>> updateCompany({
    required String companyId,
    String? name,
    String? description,
    String? industry,
    String? website,
    String? location,
    String? logo,
  });
}
