import '../../../../core/utils/media_url_helper.dart';
import '../../domain/entities/company_entity.dart';

class CompanyModel extends CompanyEntity {
  const CompanyModel({
    required super.id,
    required super.name,
    super.logo,
    super.description,
    super.industry,
    super.website,
    super.location,
    super.companySize,
    super.ownerId,
    super.isVerified,
    super.followersCount,
    super.averageRating,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] ?? '',
      logo: MediaUrlHelper.resolve(json['logo'] as String?),
      description: json['description'] as String?,
      industry: json['industry'] as String?,
      website: json['website'] as String?,
      location: json['location'] as String?,
      companySize: json['companySize'] as String?,
      ownerId: json['owner']?.toString() ?? json['ownerId']?.toString(),
      isVerified: json['isVerified'] ?? json['status'] == 'Approved',
      followersCount: json['followersCount'] ?? 0,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'industry': industry,
      'website': website,
      'location': location,
      'companySize': companySize,
      'contactEmail': '', // optional
    };
  }
}
