import '../../../../api_service.dart';
import '../models/job_model.dart';

abstract class JobsRemoteDataSource {
  Future<List<JobModel>> getJobs({String? type, String? workPlace});
}

class JobsRemoteDataSourceImpl implements JobsRemoteDataSource {
  final ApiService _apiService;

  JobsRemoteDataSourceImpl(this._apiService);

  @override
  Future<List<JobModel>> getJobs({String? type, String? workPlace}) async {
    final response = await _apiService.getJobs(type: type, workPlace: workPlace);
    
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => JobModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load jobs');
    }
  }
}
