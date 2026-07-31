import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/company_entity.dart';
import '../repositories/company_repository.dart';

class CreateCompanyUseCase {
  final CompanyRepository repository;
  CreateCompanyUseCase(this.repository);

  Future<Either<Failure, CompanyEntity>> call(CreateCompanyParams params) async {
    return await repository.createCompany(
      name: params.name,
      description: params.description,
      industry: params.industry,
      website: params.website,
      location: params.location,
      logo: params.logo,
    );
  }
}

class CreateCompanyParams extends Equatable {
  final String name;
  final String? description;
  final String? industry;
  final String? website;
  final String? location;
  final String? logo;

  const CreateCompanyParams({
    required this.name,
    this.description,
    this.industry,
    this.website,
    this.location,
    this.logo,
  });

  @override
  List<Object?> get props => [name, description, industry, website, location, logo];
}
