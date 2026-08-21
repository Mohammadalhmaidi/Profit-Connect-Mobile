import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../../core/utils/media_url_helper.dart';
import '../../../../core/utils/temp_password_generator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../api_service.dart';

class CompanyDashboardPage extends StatefulWidget {
  final String companyId;

  const CompanyDashboardPage({required this.companyId, super.key});

  @override
  State<CompanyDashboardPage> createState() => _CompanyDashboardPageState();
}

class _CompanyDashboardPageState extends State<CompanyDashboardPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _company;
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _permissions;
  List<Map<String, dynamic>> _employees = [];
  List<Map<String, dynamic>> _jobs = [];
  final Map<String, List<Map<String, dynamic>>> _applicants = {};
  final Set<String> _loadingApplicants = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final api = sl<ApiService>();
      final myCompanyRes = await api.getMyCompany(companyId: widget.companyId);
      final data = myCompanyRes.data['data'] as Map<String, dynamic>? ?? {};
      var employees = <Map<String, dynamic>>[];
      try {
        final empRes = await api.getCompanyEmployees(widget.companyId);
        employees = (empRes.data['data'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } catch (_) {}
      var jobs = <Map<String, dynamic>>[];
      try {
        final jobsRes = await api.getCompanyJobs(companyId: widget.companyId);
        jobs = (jobsRes.data['data'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _company = data['company'] as Map<String, dynamic>? ?? {};
        _stats = data['stats'] as Map<String, dynamic>?;
        _permissions = data['myPermissions'] as Map<String, dynamic>?;
        _employees = employees;
        _jobs = jobs;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  bool get _canPostJobs => _permissions?['canPostJobs'] != false;
  bool get _canManageApplicants =>
      _permissions?['canManageApplicants'] != false;

  Future<void> _addEmployee() async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final positionController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('company.add_employee')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: context.tr('company.employee_email'),
                  border: const OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: context.tr('company.employee_password'),
                  border: const OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: context.tr('company.employee_first'),
                  border: const OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: context.tr('company.employee_last'),
                  border: const OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: positionController,
                decoration: InputDecoration(
                  labelText: context.tr('company.employee_position'),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.tr('common.add')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final email = emailController.text.trim();
    if (email.isEmpty) {
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('company.email_required'),
      );
      return;
    }
    try {
      final enteredPassword = passwordController.text.trim();
      // عند عدم إدخال كلمة مرور: توليد كلمة مرور مؤقتة آمنة بدل ثابتة ضعيفة
      final employeePassword = enteredPassword.isNotEmpty
          ? enteredPassword
          : TempPasswordGenerator.generate();
      final res = await sl<ApiService>().addEmployee(widget.companyId, {
        'email': email,
        'password': employeePassword,
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'position': positionController.text.trim(),
      });
      final creds = res.data['data']?['loginCredentials'];
      if (!mounted) return;
      final message = creds != null
          ? context.tr('company.employee_added_creds', {
              'email': creds['email']?.toString() ?? '',
              'password': creds['password']?.toString() ?? '',
            })
          : context.tr('company.employee_added');
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.tr('company.employee_added')),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr('common.ok')),
            ),
          ],
        ),
      );
      _load();
    } catch (_) {
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('company.add_employee_failed'),
      );
    }
  }

  Future<void> _removeEmployee(String employeeId) async {
    try {
      await sl<ApiService>().removeEmployee(widget.companyId, employeeId);
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('company.employee_removed'),
        isError: false,
      );
      _load();
    } catch (_) {
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('company.remove_employee_failed'),
      );
    }
  }

  Future<void> _createJob() async {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();
    final minSalaryController = TextEditingController();
    final maxSalaryController = TextEditingController();
    var type = 'Full-time';
    var workLevel = 'Entry';
    var workPlace = 'On-site';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(context.tr('company.post_job')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: context.tr('company.job_title'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10.h),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: context.tr('company.job_location'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10.h),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  items:
                      [
                            'Full-time',
                            'Part-time',
                            'Contract',
                            'Internship',
                            'Freelance',
                          ]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (v) => setDialogState(() => type = v ?? type),
                  decoration: InputDecoration(
                    labelText: context.tr('company.job_type'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10.h),
                DropdownButtonFormField<String>(
                  initialValue: workLevel,
                  items: ['Entry', 'Mid', 'Senior', 'Director', 'VP']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => workLevel = v ?? workLevel),
                  decoration: InputDecoration(
                    labelText: context.tr('company.job_level'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10.h),
                DropdownButtonFormField<String>(
                  initialValue: workPlace,
                  items: ['On-site', 'Remote', 'Hybrid']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => workPlace = v ?? workPlace),
                  decoration: InputDecoration(
                    labelText: context.tr('company.workplace'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minSalaryController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: context.tr('company.min_salary'),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: TextField(
                        controller: maxSalaryController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: context.tr('company.max_salary'),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: context.tr('company.description'),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.tr('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.tr('company.post_job')),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;
    final title = titleController.text.trim();
    if (title.isEmpty) {
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('company.job_title_required'),
      );
      return;
    }
    try {
      await sl<ApiService>().createCompanyJob({
        'title': title,
        'location': locationController.text.trim(),
        'type': type,
        'workLevel': workLevel,
        'workPlace': workPlace,
        'description': descriptionController.text.trim(),
        'salary': {
          'min': double.tryParse(minSalaryController.text.trim()) ?? 0,
          'max': double.tryParse(maxSalaryController.text.trim()) ?? 0,
          'currency': 'USD',
        },
      }, companyId: widget.companyId);
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('company.job_posted'),
        isError: false,
      );
      _load();
    } catch (_) {
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('company.post_failed'),
      );
    }
  }

  Future<void> _loadApplicants(String jobId) async {
    if (_applicants.containsKey(jobId)) return;
    setState(() => _loadingApplicants.add(jobId));
    try {
      final res = await sl<ApiService>().getJobApplicants(jobId);
      if (!mounted) return;
      setState(() {
        _applicants[jobId] = (res.data['data'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _loadingApplicants.remove(jobId);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingApplicants.remove(jobId));
    }
  }

  Future<void> _updateApplicantStatus(
    Map<String, dynamic> application,
    String jobId,
    String status,
  ) async {
    final applicationId = application['_id']?.toString() ?? '';
    try {
      await sl<ApiService>().updateApplicationStatus(applicationId, status);
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('company.status_updated', {'status': status}),
        isError: false,
      );
      _applicants.remove(jobId);
      _loadApplicants(jobId);
    } catch (_) {
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('company.status_update_failed'),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.backgroundAlt,
    appBar: AppBar(
      backgroundColor: context.colors.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        context.tr('company.dashboard'),
        style: TextStyle(
          color: context.colors.textPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              children: [
                _buildOverview(),
                SizedBox(height: 16.h),
                _buildActions(),
                SizedBox(height: 24.h),
                _buildSectionTitle(
                  context.tr('company.employees_count', {
                    'count': '${_employees.length}',
                  }),
                ),
                if (_employees.isEmpty)
                  _buildEmptyRow(context.tr('company.no_employees'))
                else
                  ..._employees.map(_buildEmployeeRow),
                SizedBox(height: 24.h),
                _buildSectionTitle(
                  context.tr('company.jobs_count', {
                    'count': '${_jobs.length}',
                  }),
                ),
                if (_jobs.isEmpty)
                  _buildEmptyRow(context.tr('company.no_jobs'))
                else
                  ..._jobs.map(_buildJobSection),
              ],
            ),
          ),
  );

  Widget _buildOverview() {
    final logo = MediaUrlHelper.resolve(_company?['logo'] as String? ?? '');
    final stats = _stats ?? {};
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36.r,
            backgroundColor: context.colors.chipUnselected,
            backgroundImage: logo.isNotEmpty ? NetworkImage(logo) : null,
            child: logo.isEmpty
                ? Icon(
                    Icons.business,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32.sp,
                  )
                : null,
          ),
          SizedBox(height: 10.h),
          Text(
            _company?['name'] ?? context.tr('profile.my_company'),
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          if ((_company?['status'] as String?)?.isNotEmpty ?? false)
            Text(
              context.tr('company.status_value', {
                'status': _company!['status'],
              }),
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 13.sp,
              ),
            ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOverviewStat(
                '${stats['totalJobs'] ?? 0}',
                context.tr('company.total_jobs'),
              ),
              _buildOverviewStat(
                '${stats['openJobs'] ?? 0}',
                context.tr('company.open_jobs'),
              ),
              _buildOverviewStat(
                '${_employees.length}',
                context.tr('company.team'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStat(String value, String label) => Column(
    children: [
      Text(
        value,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 4.h),
      Text(
        label,
        style: TextStyle(color: context.colors.textSecondary, fontSize: 12.sp),
      ),
    ],
  );

  Widget _buildActions() => Row(
    children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: _canPostJobs ? _createJob : null,
          icon: const Icon(Icons.post_add),
          label: Text(context.tr('company.post_job')),
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
            side: BorderSide(color: Theme.of(context).colorScheme.primary),
            padding: EdgeInsets.symmetric(vertical: 12.h),
          ),
        ),
      ),
      SizedBox(width: 12.w),
      Expanded(
        child: OutlinedButton.icon(
          onPressed: _addEmployee,
          icon: const Icon(Icons.person_add_alt),
          label: Text(context.tr('company.add_employee')),
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
            side: BorderSide(color: Theme.of(context).colorScheme.primary),
            padding: EdgeInsets.symmetric(vertical: 12.h),
          ),
        ),
      ),
    ],
  );

  Widget _buildEmployeeRow(Map<String, dynamic> e) {
    final user = e['user'] is Map
        ? Map<String, dynamic>.from(e['user'] as Map)
        : <String, dynamic>{};
    final profile = user['profile'] as Map<String, dynamic>? ?? {};
    final name = '${profile['firstName'] ?? ''} ${profile['lastName'] ?? ''}'
        .trim();
    final position = e['position']?.toString() ?? '';
    final employeeId = user['_id']?.toString() ?? e['_id']?.toString() ?? '';
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: context.colors.chipUnselected,
            child: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.primary,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? context.tr('company.employee_name') : name,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  [
                    user['email']?.toString() ?? '',
                    position,
                  ].where((s) => s.isNotEmpty).join(' \u2022 '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeEmployee(employeeId),
            icon: Icon(
              Icons.person_remove_outlined,
              color: AppColors.logoutRed,
              size: 18.sp,
            ),
            tooltip: context.tr('company.remove_employee'),
          ),
        ],
      ),
    );
  }

  Widget _buildJobSection(Map<String, dynamic> job) {
    final jobId = job['_id']?.toString() ?? '';
    final applicants = _applicants[jobId];
    final isLoadingApplicants = _loadingApplicants.contains(jobId);
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              if (applicants == null && !isLoadingApplicants) {
                _loadApplicants(jobId);
              }
            },
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['title']?.toString() ?? '',
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        [
                          job['location']?.toString() ?? '',
                          job['type']?.toString() ?? '',
                          job['status']?.toString() ?? '',
                        ].where((s) => s.isNotEmpty).join(' \u2022 '),
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  applicants == null ? Icons.expand_more : Icons.expand_less,
                  color: context.colors.textSecondary,
                ),
              ],
            ),
          ),
          if (isLoadingApplicants)
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Center(
                child: SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (applicants != null)
            if (applicants.isEmpty)
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Text(
                  context.tr('company.no_applicants'),
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 13.sp,
                  ),
                ),
              )
            else
              ...applicants.map((a) => _buildApplicantRow(a, jobId)),
        ],
      ),
    );
  }

  Widget _buildApplicantRow(Map<String, dynamic> application, String jobId) {
    final applicant = application['applicant'] is Map
        ? Map<String, dynamic>.from(application['applicant'] as Map)
        : <String, dynamic>{};
    final profile = applicant['profile'] as Map<String, dynamic>? ?? {};
    final name = '${profile['firstName'] ?? ''} ${profile['lastName'] ?? ''}'
        .trim();
    final email = applicant['email']?.toString() ?? '';
    final status = application['status']?.toString() ?? 'Pending';
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: context.colors.chipUnselected,
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? context.tr('company.applicant') : name,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: _statusColor(status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: _statusColor(status),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (_canManageApplicants)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Wrap(
                spacing: 8.w,
                children: ['Shortlist', 'Accept', 'Reject']
                    .map(
                      (action) => OutlinedButton(
                        onPressed: () => _updateApplicantStatus(
                          application,
                          jobId,
                          action == 'Accept'
                              ? 'Accepted'
                              : action == 'Reject'
                              ? 'Rejected'
                              : 'Shortlisted',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: action == 'Reject'
                              ? AppColors.logoutRed
                              : Theme.of(context).colorScheme.primary,
                          side: BorderSide(
                            color: action == 'Reject'
                                ? AppColors.logoutRed
                                : Theme.of(context).colorScheme.primary,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.h,
                          ),
                          minimumSize: Size.zero,
                        ),
                        child: Text(
                          _applicantActionLabel(action),
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  String _applicantActionLabel(String action) {
    switch (action) {
      case 'Accept':
        return context.tr('company.accept');
      case 'Reject':
        return context.tr('company.reject');
      default:
        return context.tr('company.shortlist');
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return AppColors.successGreen;
      case 'rejected':
        return AppColors.logoutRed;
      case 'shortlisted':
        return Colors.orange;
      default:
        return context.colors.textSecondary;
    }
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: EdgeInsets.symmetric(vertical: 8.h),
    child: Text(
      title,
      style: TextStyle(
        color: context.colors.textPrimary,
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _buildEmptyRow(String text) => Padding(
    padding: EdgeInsets.all(12.w),
    child: Text(
      text,
      style: TextStyle(color: context.colors.textSecondary, fontSize: 14.sp),
    ),
  );
}
