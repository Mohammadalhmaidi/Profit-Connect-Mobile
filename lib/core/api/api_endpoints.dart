class ApiEndpoints {
  static const String baseUrl = 'http://127.0.0.1:5000';

  // Auth
  static const String signup = '/api/auth/signup';
  static const String login = '/api/auth/login';

  // Users
  static const String profile = '/api/user/profile';
  static const String userById = '/api/user/'; // + userId

  // Posts
  static const String posts = '/api/posts';
  static const String postLike = '/api/posts/'; // + :id/like
  static const String postComments = '/api/posts/'; // + :id/comments

  // Companies
  static const String companies = '/api/companies';
  static const String followCompany = '/api/companies/'; // + :id/follow
  static const String companyAdmins = '/api/companies/'; // + :id/admins

  // Jobs
  static const String jobs = '/api/jobs';
  static const String myApplications = '/api/jobs/my-applications';
  static const String jobApply = '/api/jobs/'; // + :id/apply
  static const String jobApplicants = '/api/jobs/'; // + :id/applicants
  static const String applicationStatus = '/api/jobs/applications/'; // + :aid/status

  // Network
  static const String connections = '/api/network/connections';
  static const String networkRequests = '/api/network/requests';
  static const String connectUser = '/api/network/connect/'; // + :userId
  static const String acceptRequest = '/api/network/accept/'; // + :reqId
  static const String rejectRequest = '/api/network/reject/'; // + :reqId
  static const String removeConnection = '/api/network/remove/'; // + :userId

  // Admin
  static const String adminPendingCompanies = '/api/admin/companies/pending';
  static const String adminCompanyStatus = '/api/admin/companies/'; // + :id/status
}
