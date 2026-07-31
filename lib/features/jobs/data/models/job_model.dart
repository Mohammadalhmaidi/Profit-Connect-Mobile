import '../../domain/entities/job_entity.dart';

class JobModel extends JobEntity {
  const JobModel({
    required super.id,
    required super.title,
    super.description,
    required super.companyId,
    super.companyName,
    super.companyLogo,
    super.location,
    super.salary,
    super.type,
    super.workLevel,
    super.workPlace,
    super.requirements,
    super.responsibilities,
    super.status,
    super.postedById,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    final company = json['company'] as Map<String, dynamic>?;
    final salaryJson = json['salary'] as Map<String, dynamic>?;

    return JobModel(
      id: (json['_id'] ?? json['id']).toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      companyId: company?['_id']?.toString() ?? json['companyId']?.toString() ?? '',
      companyName: company?['name'] ?? json['companyName'] ?? '',
      companyLogo: company?['logo'] ?? json['companyLogo'] ?? '',
      location: json['location'] ?? '',
      salary: SalaryRange(
        min: (salaryJson?['min'] ?? 0).toDouble(),
        max: (salaryJson?['max'] ?? 0).toDouble(),
        currency: salaryJson?['currency'] ?? 'USD',
      ),
      type: json['type'] ?? 'Full-time',
      workLevel: json['workLevel'] ?? 'Entry',
      workPlace: json['workPlace'] ?? 'On-site',
      requirements: (json['requirements'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
      responsibilities: (json['responsibilities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
      status: json['status'] ?? 'Open',
      postedById: json['postedBy']?.toString() ?? '',
    );
  }
}
