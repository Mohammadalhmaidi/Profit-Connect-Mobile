import 'package:equatable/equatable.dart';

class JobEntity extends Equatable {
  final String id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final String logoUrl;
  final String type;
  final bool isRemote;

  const JobEntity({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.logoUrl,
    required this.type,
    required this.isRemote,
  });

  @override
  List<Object?> get props => [id, title, company, location, salary, logoUrl, type, isRemote];
}
