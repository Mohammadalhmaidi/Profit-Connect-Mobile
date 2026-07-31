import 'package:equatable/equatable.dart';

class CompanyEntity extends Equatable {
  final String id;
  final String name;
  final String? logo;
  final String? description;
  final String? industry;
  final String? website;
  final String? location;
  final String? companySize;
  final String? ownerId;
  final bool isVerified;
  final int followersCount;
  final double averageRating;

  const CompanyEntity({
    required this.id,
    required this.name,
    this.logo,
    this.description,
    this.industry,
    this.website,
    this.location,
    this.companySize,
    this.ownerId,
    this.isVerified = false,
    this.followersCount = 0,
    this.averageRating = 0.0,
  });

  CompanyEntity copyWith({
    String? id,
    String? name,
    String? logo,
    String? description,
    String? industry,
    String? website,
    String? location,
    String? companySize,
    String? ownerId,
    bool? isVerified,
    int? followersCount,
    double? averageRating,
  }) {
    return CompanyEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      description: description ?? this.description,
      industry: industry ?? this.industry,
      website: website ?? this.website,
      location: location ?? this.location,
      companySize: companySize ?? this.companySize,
      ownerId: ownerId ?? this.ownerId,
      isVerified: isVerified ?? this.isVerified,
      followersCount: followersCount ?? this.followersCount,
      averageRating: averageRating ?? this.averageRating,
    );
  }

  @override
  List<Object?> get props => [
        id, name, logo, description, industry, website, location,
        companySize, ownerId, isVerified, followersCount, averageRating,
      ];
}
