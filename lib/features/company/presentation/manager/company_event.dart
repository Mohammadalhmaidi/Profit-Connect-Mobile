part of 'company_bloc.dart';

abstract class CompanyEvent extends Equatable {
  const CompanyEvent();
  @override
  List<Object?> get props => [];
}

class CreateCompanyEvent extends CompanyEvent {
  final String name;
  final String? description;
  final String? industry;
  final String? website;
  final Map<String, dynamic>? location;
  final String? logo;

  const CreateCompanyEvent({
    required this.name,
    this.description,
    this.industry,
    this.website,
    this.location,
    this.logo,
  });

  @override
  List<Object?> get props => [
    name,
    description,
    industry,
    website,
    location,
    logo,
  ];
}

class ResetCompanyEvent extends CompanyEvent {
  const ResetCompanyEvent();
}
