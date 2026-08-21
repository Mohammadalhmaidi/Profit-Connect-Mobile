import '../../../../api_service.dart';
import '../models/job_model.dart';

abstract class JobsRemoteDataSource {
  Future<List<JobModel>> getJobs({
    String? search,
    String? type,
    String? workPlace,
    String? workLevel,
    int page = 1,
    int limit = 20,
  });
}

class JobsRemoteDataSourceImpl implements JobsRemoteDataSource {
  final ApiService _apiService;

  JobsRemoteDataSourceImpl(this._apiService);

  @override
  Future<List<JobModel>> getJobs({
    String? search,
    String? type,
    String? workPlace,
    String? workLevel,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiService.getJobs(
      search: search,
      type: type,
      workPlace: workPlace,
      workLevel: workLevel,
      page: page,
      limit: limit,
    );

    final data = response.data;
    List<dynamic> jobsList;

    if (data is List) {
      jobsList = data;
    } else if (data is Map) {
      jobsList = (data['jobs'] ?? data['data'] ?? []) as List<dynamic>;
    } else {
      jobsList = [];
    }

    return jobsList
        .map((json) => JobModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
