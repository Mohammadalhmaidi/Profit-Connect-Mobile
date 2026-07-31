import '../../../../api_service.dart';
import '../models/company_model.dart';

abstract class CompanyRemoteDataSource {
  Future<CompanyModel> createCompany(Map<String, dynamic> data);
  Future<CompanyModel> getCompany(String companyId);
  Future<CompanyModel> updateCompany(String companyId, Map<String, dynamic> data);
}

class CompanyRemoteDataSourceImpl implements CompanyRemoteDataSource {
  final ApiService _apiService;

  CompanyRemoteDataSourceImpl(this._apiService);

  @override
  Future<CompanyModel> createCompany(Map<String, dynamic> data) async {
    final response = await _apiService.createCompany(data);
    // Backend wraps in { success, message, data: company }
    final body = response.data as Map<String, dynamic>;
    final companyJson = body['data'] as Map<String, dynamic>? ?? body;
    return CompanyModel.fromJson(companyJson);
  }

  @override
  Future<CompanyModel> getCompany(String companyId) async {
    final response = await _apiService.get('/api/companies/$companyId');
    final body = response.data as Map<String, dynamic>;
    final companyJson = body['data'] as Map<String, dynamic>? ?? body;
    return CompanyModel.fromJson(companyJson);
  }

  @override
  Future<CompanyModel> updateCompany(String companyId, Map<String, dynamic> data) async {
    final response = await _apiService.put('/api/companies/$companyId', data: data);
    final body = response.data as Map<String, dynamic>;
    final companyJson = body['data'] as Map<String, dynamic>? ?? body;
    return CompanyModel.fromJson(companyJson);
  }
}
