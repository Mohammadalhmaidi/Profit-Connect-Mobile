import 'package:equatable/equatable.dart';

class JobModel extends Equatable {
  final String id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final String logoUrl;
  final String type;
  final bool isRemote;

  const JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.logoUrl,
    required this.type,
    required this.isRemote,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      location: json['location'] ?? '',
      salary: json['salary'] ?? '',
      logoUrl: json['logoUrl'] ?? 'https://i.pravatar.cc/150?u=job',
      type: json['type'] ?? 'Full-time',
      isRemote: json['isRemote'] ?? false,
    );
  }

  @override
  List<Object?> get props => [id, title, company, location, salary, logoUrl, type, isRemote];
}
