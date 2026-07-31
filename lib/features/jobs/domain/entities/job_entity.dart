import 'package:equatable/equatable.dart';

class SalaryRange extends Equatable {
  final double min;
  final double max;
  final String currency;

  const SalaryRange({
    this.min = 0,
    this.max = 0,
    this.currency = 'USD',
  });

  @override
  List<Object?> get props => [min, max, currency];
}

class JobEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String companyId;
  final String companyName;
  final String companyLogo;
  final String location;
  final SalaryRange salary;
  final String type;
  final String workLevel;
  final String workPlace;
  final List<String> requirements;
  final List<String> responsibilities;
  final String status;
  final String postedById;

  const JobEntity({
    required this.id,
    required this.title,
    this.description = '',
    required this.companyId,
    this.companyName = '',
    this.companyLogo = '',
    this.location = '',
    this.salary = const SalaryRange(),
    this.type = 'Full-time',
    this.workLevel = 'Entry',
    this.workPlace = 'On-site',
    this.requirements = const [],
    this.responsibilities = const [],
    this.status = 'Open',
    this.postedById = '',
  });

  @override
  List<Object?> get props => [
        id, title, description, companyId, companyName, companyLogo,
        location, salary, type, workLevel, workPlace,
        requirements, responsibilities, status, postedById,
      ];
}
